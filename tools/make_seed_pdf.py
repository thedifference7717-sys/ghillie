# Ghillie printable recovery-phrase sheet (replaces Monero's wizard/template.pdf). A4, ink-friendly.
import sys
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.utils import ImageReader
G, ICON, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
pdfmetrics.registerFont(TTFont('Inter', G + '/fonts/Inter-Regular.ttf'))
pdfmetrics.registerFont(TTFont('InterSB', G + '/fonts/Inter-SemiBold.ttf'))
pdfmetrics.registerFont(TTFont('VT323', G + '/fonts/VT323-Regular.ttf'))
W, H = A4
c = canvas.Canvas(OUT, pagesize=A4)
c.setTitle('Ghillie recovery phrase sheet'); c.setAuthor('The CAMO Project')
L, R = 56, W - 56
y = H - 70
c.drawImage(ImageReader(ICON), L, y - 6, 34, 34, mask='auto')
c.setFont('VT323', 34); c.setFillColorRGB(0.04, 0.06, 0.05); c.drawString(L + 44, y, 'GHILLIE')
c.setFont('Inter', 10); c.setFillColorRGB(0.35, 0.4, 0.35); c.drawRightString(R, y + 6, 'CAMO wallet · recovery sheet')
c.setFillColorRGB(0, 0, 0)

def para(text, x, y, size=10, leading=14, width=R - L, font='Inter'):
    from reportlab.lib.utils import simpleSplit
    c.setFont(font, size)
    for line in simpleSplit(text, font, size, width):
        c.drawString(x, y, line); y -= leading
    return y

y -= 44
y = para('Print this page, fill it in by hand, and keep it somewhere safe. Never share your recovery phrase with anybody, '
         'especially strangers offering "technical support". Nobody from CAMO will ever ask for it.', L, y, 11, 15)

def heading(t, x, y):
    c.setFont('InterSB', 13); c.drawString(x, y, t)

y -= 26; heading('Wallet name', L, y)
y -= 30; c.setStrokeColorRGB(0.6, 0.6, 0.6); c.setLineWidth(0.6); c.line(L, y, R, y)
y -= 34; heading('Recovery phrase (25 words)', L, y)
y -= 12
colw = (R - L) / 5
for row in range(5):
    y -= 34
    for col in range(5):
        n = col * 5 + row + 1
        x = L + col * colw
        c.setFont('Inter', 8); c.setFillColorRGB(0.45, 0.45, 0.45); c.drawString(x, y + 3, str(n))
        c.setFillColorRGB(0, 0, 0); c.line(x + 14, y, x + colw - 10, y)
y -= 26
y = para('These 25 words are your recovery phrase (mnemonic seed). They are the only thing needed to access your funds '
         'and restore your CAMO wallet, so no one but you should ever see them. Do not store them digitally '
         '(no email, cloud, screenshot, photo or computer file).', L, y, 9.5, 13)
y -= 20
heading('Wallet creation date', L, y); heading('Wallet restore height', L + (R - L) / 2 + 10, y)
y -= 30; c.line(L, y, L + (R - L) / 2 - 20, y); c.line(L + (R - L) / 2 + 10, y, R, y)
y -= 26
y = para('To restore this wallet, open Ghillie, choose "Restore wallet from keys or mnemonic seed", enter these words and '
         'the restore height. If you are not sure of the height, use 0: Ghillie then scans the whole chain, which takes '
         'longer but finds everything.', L, y, 9.5, 13)
y -= 6
y = para('Download Ghillie and other CAMO wallets only from camocoin.org.', L, y, 9.5, 13, font='InterSB')
c.setFont('Inter', 7.5); c.setFillColorRGB(0.5, 0.5, 0.5)
c.drawString(L, 36, 'Ghillie · camocoin.org · based on the Monero GUI wallet (BSD-3)')
c.showPage(); c.save()
print('ok')
