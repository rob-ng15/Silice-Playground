from twisted.internet.protocol import DatagramProtocol
from twisted.internet import reactor, task
from twisted.internet.task import deferLater

import os
import time
import struct
import sys
import hashlib
import operator
import functools
import random

class Transporter(DatagramProtocol):

    def __init__(self, jobs):
        self.udp_transport = reactor.listenUDP(9947, self)
        self.pending = {}
        self.seq = 0
        self.jobs = jobs
        self.firstjob()
        task.LoopingCall(self.earliest).start(0.1)
        reactor.run()

    def firstjob(self):
        self.jobs[0].startwork(self)

    def propose(self, cmd, rest):
        seq = self.seq
        self.seq += 1
        data = struct.pack(">HH", seq, cmd) + rest;
        self.pending[seq] = (time.time(), data)
        return seq

    def earliest(self):
        bytime = [(t, k) for (k, (t, _)) in self.pending.items()]
        for (t, seq) in sorted(bytime)[:32]:
            self.send(seq)
            self.pending[seq] = (time.time(), self.pending[seq][1])

    def datagramReceived(self, data, (host, port)):
        # print "received %r from %s:%d" % (data, host, port)
        (opcode, seq) = struct.unpack(">HH", data[:4])
        assert opcode == 0
        if seq in self.pending:
            del self.pending[seq]
            try:
                self.jobs[0].addresult(self, seq, data[4:])
            except AssertionError as e:
                print 'assertion failed', e
                reactor.stop()
                return
            print "ACK ", seq, "pending", len(self.pending)
            if len(self.pending) == 0:
                self.jobs[0].close()
                self.jobs = self.jobs[1:]
                if self.jobs != []:
                    self.firstjob()
                else:
                    reactor.stop()
            # self.transport.write(data, (host, port))

    def send(self, seq):
        (_, data) = self.pending[seq]
        # print "send %r" % data
        self.udp_transport.write(data, ("192.168.0.99", 947))

    def addresult(self, seq, payload):
        pass


class Action(object):
    def addresult(self, tr, seq, payload):
        pass

    def close(self):
        pass

class ReadRAM(Action):

    def startwork(self, tr):
        self.result = 16384 * [None]
        self.seqs = {}
        for i in range(0, 128):
            self.seqs[tr.propose(0, struct.pack(">H", i * 128))] = i * 128

    def addresult(self, tr, seq, payload):
        addr = self.seqs[seq]
        assert len(payload) == 128
        for i in range(128):
            self.result[addr + i] = ord(payload[i])

    def close(self):
        for a in range(0, 16384, 16):
            print ("%04x  " % a) + " ".join("%02x" % x for x in self.result[a:a+16])


class WriteRAM(Action):

    def startwork(self, tr):
        code = open('j1.bin').read()
        for i in range(0x1f80 / 128):
            print i
            o = 128 * i
            tr.propose(1, struct.pack(">H128s", 0x2000 + o, code[o:o+128]))

class VerifyRAM(ReadRAM):
    def close(self):
        actual = "".join([chr(c) for c in self.result[0x2000:]])
        expected = open('j1.bin').read()
        l = 0x1f80
        assert actual[:l] == expected[:l]

class Reboot(Action):
    def startwork(self, tr):
        tr.propose(2, "")

class ReadFlash(Action):

    def startwork(self, tr):
        self.result = 2 * 1024 * 1024 * [None]
        self.seqs = {}
        for addr in range(0, len(self.result), 128):
            self.seqs[tr.propose(3, struct.pack(">I", addr))] = addr

    def addresult(self, tr, seq, payload):
        addr = self.seqs[seq]
        assert len(payload) == 128
        for i in range(128):
            self.result[addr + i] = ord(payload[i])

    def close(self):
        open('flash.dump', 'w').write("".join([chr(x) for x in self.result]))
        for a in range(0, 256, 16):
            print ("%04x  " % a) + " ".join("%02x" % x for x in self.result[a:a+16])

class EraseFlash(Action):
    def startwork(self, tr):
        tr.propose(4, "")
    def close(self):
        time.sleep(5)

class WaitFlash(Action):
    def startwork(self, tr):
        self.seq = tr.propose(5, struct.pack(">I", 0))
    def addresult(self, tr, seq, payload):
        (res,) = struct.unpack(">H", payload)
        if res == 0:
            self.startwork(tr)

def bitload(bitfilename):
    bit = open(bitfilename, "r")

    def getH(fi):
        return struct.unpack(">H", bit.read(2))[0]
    def getI(fi):
        return struct.unpack(">I", bit.read(4))[0]

    bit.seek(getH(bit), os.SEEK_CUR)
    assert getH(bit) == 1

    # Search for the data section in the .bit file...
    while True:
        ty = ord(bit.read(1))
        if ty == 0x65:
            break
        length = getH(bit)
        bit.seek(length, os.SEEK_CUR)
    fieldLength = getI(bit)
    return bit.read(fieldLength)

# open("xxx", "w").write(bitload("j1_program.bit"))

import intelhex
import array

class Hexfile(object):
    def __init__(self, filename):
        self.hf = intelhex.IntelHex(filename)
        self.hf.readfile()
        while (self.hf.maxaddr() % 128) != 127:
            self.hf[self.hf.maxaddr() + 1] = 0xff
        print "%x %x" % (self.hf.minaddr(), self.hf.maxaddr())

    def minmax(self):
        return (self.hf.minaddr(), self.hf.maxaddr())

    # The XESS CPLD bootloader runs the flash in byte mode,
    # and the flash is littleendian, so must do the endian
    # swap here
    def blk(self, o):
        b128 = array.array('B', [self.hf[o + i] for i in range(128)]).tostring()
        hh = array.array('H', b128)
        hh.byteswap()
        return hh.tostring()

class WriteFlash(Action, Hexfile):

    def startwork(self, tr):
        for o in range(self.hf.minaddr(), self.hf.maxaddr(), 128):
            tr.propose(6, struct.pack(">I", o) + self.blk(o))

class VerifyFlash(Action, Hexfile):

    def startwork(self, tr):
        self.seqs = {}
        for o in range(self.hf.minaddr(), self.hf.maxaddr(), 128):
            self.seqs[tr.propose(3, struct.pack(">I", o))] = o

    def addresult(self, tr, seq, payload):
        addr = self.seqs[seq]
        assert len(payload) == 128, 'short packet'
        assert self.blk(addr) == payload, "mismatch at %#x" % addr

    def close(self):
        print "Flash verified OK"

class EraseSector(Action):
    def __init__(self, a):
        self.a = a
    def startwork(self, tr):
        tr.propose(7, struct.pack(">I", self.a))
    def close(self):
        time.sleep(.1)

class WaitSector(Action):
    def __init__(self, a):
        self.a = a
    def startwork(self, tr):
        self.seq = tr.propose(5, struct.pack(">I", self.a))
    def addresult(self, tr, seq, payload):
        (res,) = struct.unpack(">H", payload)
        if res == 0:
            self.startwork(tr)

class LoadSector(Action):
    def __init__(self, a, data):
        self.a = a
        self.data = data
    def startwork(self, tr):
        for o in range(0, len(self.data), 128):
            blk = self.data[o:o+128]
            if blk != (128 * chr(0xff)):
                tr.propose(6, struct.pack(">I", self.a + o) + blk)

class DumpSector(Action):

    def __init__(self, a):
        self.a = a
    def startwork(self, tr):
        self.seqs = {}
        for o in [0]:
            self.seqs[tr.propose(3, struct.pack(">I", self.a + o))] = o

    def addresult(self, tr, seq, payload):
        addr = self.a + self.seqs[seq]
        assert len(payload) == 128
        print "result", repr(payload)

# t = Transporter([WriteRAM(), VerifyRAM(), Reboot()])
# t = Transporter([EraseFlash(), WaitFlash()])
# sys.exit(0)

erasing = [EraseFlash(), WaitFlash()]
bases = [ 0 ]
bases = [0, 0x80000, 0x100000, 0x180000]
bases = [0x80000]
# Transporter(erasing + [WriteFlash("j1_program_%x.mcs" % base) for base in bases])
# Transporter([VerifyFlash("j1_program_%x.mcs" % base) for base in bases])
# Transporter([EraseSector(seca), WaitSector(seca), ld, DumpSector(seca)])

def loadcode(dsta, filenames):
    data = "".join([open(fn).read() for fn in filenames])
    return [EraseSector(dsta),
            WaitSector(dsta),
            LoadSector(dsta, data)]

def pngstr(filename):
    import Image
    sa = array.array('B', Image.open(filename).convert("L").tostring())
    return struct.pack('>1024H', *sa.tolist())

def erasesecs(lo, hi):
    r = []
    for s in range(lo, hi, 65536):
        r += [EraseSector(s), WaitSector(s)]
    return r

def loadhex(filename):
    w = WriteFlash(filename)
    (lo, hi) = w.minmax()
    return erasesecs(lo, hi) + [w]

def loadsprites(dsta, filenames):
    data = "".join([pngstr(f) for f in filenames])
    print "Loading %d bytes" % len(data)
    return erasesecs(dsta, dsta + len(data)) + [LoadSector(dsta, data)]

# Transporter(loadcode(0x180000, ["j1.png.pic", "font8x8", "j1.png.chr"]) + [Reboot()])
spr = ["%d.png" % (i/2) for i in range(16)]
spr += ["blob.png"] * 16
spr += ["fsm-32.png", "pop.png"] * 6 + ["bomb.png", "pop.png", "shot.png", "pop.png"]
              
# Transporter(loadsprites(0x200000, spr))
# Transporter(loadcode(0x190000, ["j1.bin"]) + [Reboot()])
# t = Transporter([ReadFlash()])

Transporter(
# loadhex("j1_program_80000.mcs")
loadcode(0x190000, ["j1.bin"]) + [Reboot()]
)
