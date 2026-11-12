# Generates Ghillie's replacement images (pixel-camo cards, titlebar logo, mining icon, splash).
import random, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
G = sys.argv[1]            # ghillie repo
BR = sys.argv[2]           # camo/contrib/camo/branding
VT = G + "/fonts/VT323-Regular.ttf"
icon = Image.open(BR + "/ghillie/ghillie-icon-1024.png").convert("RGBA")
camo = Image.open(BR + "/camo-logo-1024.png").convert("RGBA")

def notch_mask(w, h, n):
    m = Image.new("L", (w, h), 255); d = ImageDraw.Draw(m)
    for x0, y0 in [(0, 0), (w - n, 0), (0, h - n), (w - n, h - n)]:
        d.rectangle([x0, y0, x0 + n - 1, y0 + n - 1], fill=0)
    return m

def camo_field(w, h, cell, palette, seed):
    rnd = random.Random(seed)
    gw, gh = w // cell + 2, h // cell + 2
    # smooth noise on a coarse grid -> organic blobs, then quantize per cell (pixel camo)
    small = Image.new("L", (max(2, gw // 6), max(2, gh // 6)))
    small.putdata([rnd.randint(0, 255) for _ in range(small.width * small.height)])
    big = small.resize((gw, gh), Image.BICUBIC)
    lo, hi = big.getextrema(); big = big.point(lambda v: int((v - lo) * 255 / max(1, hi - lo)))
    detail = Image.new("L", (gw, gh)); detail.putdata([rnd.randint(0, 255) for _ in range(gw * gh)])
    img = Image.new("RGB", (w, h)); d = ImageDraw.Draw(img)
    for gy in range(gh):
        for gx in range(gw):
            v = big.getpixel((gx, gy)) * 0.93 + detail.getpixel((gx, gy)) * 0.07
            idx = min(len(palette) - 1, int(v / 256 * len(palette)))
            d.rectangle([gx * cell, gy * cell, gx * cell + cell - 1, gy * cell + cell - 1], fill=palette[idx])
    return img

def tint(hexc, base):
    c = tuple(int(hexc[i:i + 2], 16) for i in (1, 3, 5))
    return tuple(int(b * 0.7 + cc * 0.3) for b, cc in zip(base, c))

BASE = [(0x0E, 0x14, 0x10), (0x17, 0x22, 0x1A), (0x22, 0x31, 0x26), (0x2E, 0x40, 0x34), (0x3D, 0x52, 0x40)]
ACCOUNTS = ["#4A5E4E", "#5E5A3A", "#3A5E5A", "#5E4A3A", "#3A4A5E", "#55603A", "#3F5244", "#4E4E4E"]

def card(i, scale):
    w, h = 260 * scale, 135 * scale
    pal = [tint(ACCOUNTS[i], b) if k else b for k, b in enumerate(BASE)]
    img = camo_field(w, h, 5 * scale, pal, 7000 + i).convert("RGBA")
    # darken the lower-left where the balance text sits, for contrast
    shade = Image.new("L", (w, h), 0); sd = ImageDraw.Draw(shade)
    for y in range(h):
        sd.line([(0, y), (w, y)], fill=int(170 * max(0, (y - h * 0.40) / (h * 0.60))))
    img = Image.composite(Image.new("RGBA", (w, h), (8, 11, 9, 255)), img, shade)
    d = ImageDraw.Draw(img)
    n = 4 * scale
    d.rectangle([0, 0, w - 1, h - 1], outline=(0x2E, 0x40, 0x34), width=2 * scale)
    ic = icon.resize((32 * scale, 32 * scale), Image.LANCZOS)   # logo stays smooth
    img.alpha_composite(ic, (20 * scale, 22 * scale))
    img.putalpha(Image.composite(img.getchannel("A"), Image.new("L", (w, h), 0), notch_mask(w, h, n)))
    return img

for i in range(8):
    card(i, 1).save(f"{G}/images/card-background-black{i}.png")
    card(i, 2).save(f"{G}/images/card-background-black{i}@2x.png")

def titlebar(scale, color, path):
    w, h = 125 * scale, 28 * scale
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    img.alpha_composite(icon.resize((22 * scale, 22 * scale), Image.LANCZOS), (2 * scale, 3 * scale))
    f = ImageFont.truetype(VT, 26 * scale)
    d = ImageDraw.Draw(img); d.fontmode = "1"     # pixel font, smoothing off
    d.text((30 * scale, 14 * scale), "GHILLIE", font=f, fill=color, anchor="lm")
    img.save(path)

titlebar(1, (0xE7, 0xE9, 0xE2, 255), f"{G}/images/titlebarLogo.png")
titlebar(2, (0xE7, 0xE9, 0xE2, 255), f"{G}/images/titlebarLogo@2x.png")
titlebar(1, (0x0B, 0x0F, 0x0C, 255), f"{G}/images/themes/white/titlebarLogo.png")
titlebar(2, (0x0B, 0x0F, 0x0C, 255), f"{G}/images/themes/white/titlebarLogo@2x.png")

# mining icon: pixel pickaxe over a CAMO coin (replaces Monero's)
for sfx, sc in [("", 1), ("@2x", 2)]:
    W = 32 * sc
    im = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    coin = camo.resize((18 * sc, 18 * sc), Image.LANCZOS)
    im.alpha_composite(coin, (W - coin.width, W - coin.height))
    d = ImageDraw.Draw(im)
    px = lambda x, y, c: d.rectangle([x * sc, y * sc, x * sc + sc - 1, y * sc + sc - 1], fill=c)
    for t in range(15):                       # handle, diagonal
        px(3 + t, 26 - t, (0xB0, 0x7A, 0x42, 255)); px(4 + t, 26 - t, (0x9C, 0x6B, 0x3A, 255)); px(4 + t, 27 - t, (0x6E, 0x4A, 0x28, 255))
    head = [(9,3),(10,3),(11,3),(12,3),(13,4),(14,4),(15,5),(16,6),(17,7),(18,7),(19,8),(20,9),(21,10),(21,11),(22,12),(22,13),(23,14),(23,15),(23,16)]
    for x, y in head:
        px(x, y - 1, (0xE7, 0xE9, 0xE2, 255)); px(x, y, (0xC9, 0xD6, 0xB8, 255)); px(x, y + 1, (0x9A, 0xA5, 0x93, 255)); px(x - 1, y + 1, (0x6F, 0x7A, 0x6A, 255))
    im.save(f"{G}/images/miningxmr{sfx}.png")

# merchant titlebar (white logo, 132x22)
w, h = 132, 22
img = Image.new("LA", (w, h), (0, 0)); d = ImageDraw.Draw(img); d.fontmode = "1"
d.text((0, 11), "GHILLIE", font=ImageFont.truetype(VT, 24), fill=(255, 255), anchor="lm")
img.save(f"{G}/images/moneroLogo_white.png")
print("ok")
