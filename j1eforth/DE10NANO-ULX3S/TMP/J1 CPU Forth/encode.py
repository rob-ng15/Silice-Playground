import sys
import Image
from array import array

def getch(im, x, y):
    return tuple(tuple((int(0 != im.getpixel((x + j, y + i)))) for j in range(8)) for i in range(8))
    
def main(filename):
    sm = Image.open(filename).convert("L")
    im = Image.new("L", (512, 256))
    im.paste(sm, (0,0))
    charset = {}
    picture = []
    for y in range(0, im.size[1], 8):
        for x in range(0, im.size[0], 8):
            glyph = getch(im, x, y)
            if not glyph in charset:
                charset[glyph] = 96 + len(charset)
            picture.append(charset[glyph])
    open(filename + ".pic", "w").write(array('B', picture).tostring())
    cd = array('B', [0] * 8 * len(charset))
    for d,i in charset.items():
        i -= 96
        for y in range(8):
            cd[8 * i + y] = sum([(d[y][x] << (7 - x)) for x in range(8)])
    open(filename + ".chr", "w").write(cd.tostring())

main(sys.argv[1])
