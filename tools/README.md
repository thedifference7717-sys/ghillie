# Ghillie artwork tools

Regenerate Ghillie's images from the CAMO branding files (`camo/contrib/camo/branding`):

    python3 tools/make_images.py . ../camo/contrib/camo/branding        # cards, title-bar logo, mining icon
    python3 tools/make_seed_pdf.py . ../camo/contrib/camo/branding/ghillie/ghillie-icon-256.png wizard/template.pdf

Needs Python 3 with Pillow (and reportlab for the PDF). The Ghillie logo is always scaled smoothly, never pixelated.
