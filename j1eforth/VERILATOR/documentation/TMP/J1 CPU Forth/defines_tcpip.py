layout = [
    ('ETH', [
        ('DST', 6),
        ('SRC',  6),
        ('TYPE', 2),
        [
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
                            ('JUICE', [
                                ('HASH', 20),
                                ('MAGIC', 4),
                                ('SEQ', 2),
                                ('COMMAND', 2),
                                ('PAYLOAD', 2)
                            ])
                        ]
                    ])
                ]
            ])
        ]])
]

offsets = {}
def descend(offset, prefix, node):
    (name, members) = node
    offsets[prefix + name] = offset
    start = offset
    for m in members:
        if isinstance(m, tuple):
            (field, size) = m
            # print prefix, name, field, offset
            offsets["%s%s_%s" % (prefix, name, field)] = offset
            offset += size
        else:
            for n in m:
                descend(offset, prefix, n)
    # print prefix, name, "SIZE", offset - start
    offsets["%s%s_SIZE" % (prefix, name)] = offset - start

descend(0, 'OFFSET_', layout[0])
