layout = [
    ('ETH', [
        ('DST', 6),
        ('SRC',  6),
        ('TYPE', 2),
        [
            ('ARP', [
                ('SOMETHING', 6),
                ('OPCODE', 2),
                ('SRC_ETH', 6),
                ('SRC_IP', 4),
                ('DST_ETH', 6),
                ('DST_IP', 4) ]),
            ('IP', [
                ('VHLTOS', 2),
                ('LENGTH', 2),
                ('IPID', 2),
                ('IPOFFSET', 2),
                ('TTLPROTO', 2),
                ('CHKSUM', 2),
                ('SRCIP', 4),
                ('DSTIP', 4),
                [
                    ('ICMP', [
                        ('TYPECODE', 2),
                        ('CHKSUM', 2),
                        ('IDENTIFIER', 2),
                        ('SEQUENCE', 2) ]),
                    ('TCP', [
                        ('SOURCEPORT', 2),
                        ('DESTPORT', 2),
                        ('SEQNUM', 4),
                        ('ACK', 4),
                        ('FLAGS', 2),
                        ('WINDOW', 2),
                        ('CHECKSUM', 2),
                        ('URGENT', 2) ]),
                    ('UDP', [
                        ('SOURCEPORT', 2),
                        ('DESTPORT', 2),
                        ('LENGTH', 2),
                        ('CHECKSUM', 2),
                        [
                            ('DHCP', [
                                ('OP', 1),
                                ('HTYPE', 1),
                                ('HLEN', 1),
                                ('HOPS', 1),
                                ('XID', 4),
                                ('SECS', 2),
                                ('FLAGS', 2),
                                ('CIADDR', 4),
                                ('YIADDR', 4),
                                ('SIADDR', 4),
                                ('GIADDR', 4),
                                ('CHADDR', 16),
                                ('SNAME', 64),
                                ('FILE', 128),
                                ('OPTIONS', 312)
                            ]),
                            ('DNS', [
                                ('IDENTIFICATION', 2),
                                ('FLAGS', 2),
                                ('NOQ', 2),
                                ('NOA', 2),
                                ('NORR', 2),
                                ('NOARR', 2),
                                ('QUERY', 1)
                            ]),
                            ('NTP', [
                                ('FLAGS', 4),
                                ('ROOTDELAY', 4),
                                ('ROOTDISPERSION', 4),
                                ('REFID', 4),
                                ('REFERENCE', 8),
                                ('ORIGINATE', 8),
                                ('RECEIVE', 8),
                                ('TRANSMIT', 8),
                            ]),
                            ('TFTP', [
                                ('OPCODE', 2),
                                [
                                    ('RWRQ', [
                                        ('FILENAME', 512)
                                    ]),
                                    ('DATA', [
                                        ('BLOCK', 2),
                                        ('DATA', 512)
                                    ]),
                                    ('ACK', [
                                        ('BLOCK', 2),
                                    ]),
                                    ('ERROR', [
                                        ('NUMBER', 2),
                                        ('MESSAGE', 512),
                                    ]),
                                ]
                            ]),
                            ('LOADER', [
                                ('SEQNO', 2),
                                ('OPCODE', 2),
                                [
                                    ('RAMREAD', [
                                        ('ADDR', 2)
                                    ]),
                                    ('RAMWRITE', [
                                        ('ADDR', 2),
                                        ('DATA', 128)
                                    ]),
                                    ('FLASHREAD', [
                                        ('ADDR', 4)
                                    ]),
                                    ('FLASHWRITE', [
                                        ('ADDR', 4),
                                        ('DATA', 128)
                                    ]),
                                ]
                            ]),
                            ('WGE', [
                                ('MAGIC', 4),
                                ('TYPE', 4),
                                ('HRT', 16),
                                ('REPLYTO', [
                                    ('MAC', 8),
                                    ('IP', 4),
                                    ('PORT', 2),
                                ]),
                                ('PAD', 2),
                                [
                                    ('DISCOVER', [
                                        ('IP', 4)
                                    ]),
                                    ('CONFIGURE', [
                                        ('PRODUCT', 4),
                                        ('SERIAL', 4),
                                        ('IP', 4)
                                    ]),
                                    ('FLASHREAD', [
                                        ('ADDRESS', 4)
                                    ]),
                                    ('FLASHWRITE', [
                                        ('ADDRESS', 4),
                                        ('DATA', 264),
                                    ]),
                                    ('TRIGCONTROL', [
                                        ('TRIGSTATE', 4),
                                    ]),
                                    ('SENSORREAD', [
                                        ('ADDRESS', 1),
                                    ]),
                                    ('SENSORWRITE', [
                                        ('ADDRESS', 1),
                                        ('DATA', 2),
                                    ]),
                                    ('SENSORSELECT', [
                                        ('INDEX', 1),
                                        ('ADDRESS', 4),
                                    ]),
                                    ('IMAGERMODE', [
                                        ('MODE', 4),
                                    ]),
                                    ('IMAGERSETRES', [
                                        ('HORIZONTAL', 2),
                                        ('VERTICAL', 2),
                                    ]),
                                    ('SYSCONFIG', [
                                        ('MAC', 6),
                                        ('SERIAL', 4),
                                    ]),
                                    ('VIDSTART', [
                                        ('MAC', 8),
                                        ('IP', 4),
                                        ('PORT', 2),
                                    ]),
                                ]
                            ]),
                        ]
                    ])
                ]
            ])
        ]])
]

offsets = {}
def descend(offset, prefix, node):
    start = offset
    if isinstance(node, list):
        for n in node:
            descend(offset, prefix, n)
    else:
        (name, members) = node
        offsets[".".join((prefix + [name]))] = offset
        if isinstance(members, int):
            offset += members
        else:
            for n in members:
                offset = descend(offset, prefix + [name], n)
            # offsets["%s%s_SIZE" % (prefix, name)] = offset - start
    return offset

descend(0, [], layout[0])

offsets['TCP_FIN'] = 1
offsets['TCP_SYN'] = 2
offsets['TCP_RST'] = 4
offsets['TCP_PSH'] = 8
offsets['TCP_ACK'] = 16
offsets['TCP_URG'] = 32

offsets['IP_PROTO_ICMP'] = 1
offsets['IP_PROTO_IGMP'] = 2
offsets['IP_PROTO_TCP'] = 6
offsets['IP_PROTO_UDP'] = 17

offsets['NUM_TCPS'] = 2
