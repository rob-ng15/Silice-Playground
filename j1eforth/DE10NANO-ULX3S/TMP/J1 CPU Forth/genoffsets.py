from defines_tcpip import offsets

d = open("defines_tcpip.fs", "w")
for nm,o in sorted(offsets.items()):
  print >>d, "%d constant %s" % (o, nm)

import defines_tcpip2

d = open("defines_tcpip2.fs", "w")
for nm,o in sorted(defines_tcpip2.offsets.items()):
  print >>d, "%d constant %s" % (o, nm)
