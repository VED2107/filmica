import os
from PIL import Image, ImageDraw, ImageFont

def create_image(path, size, color, text=""):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img = Image.new('RGBA', size, color)
    if text:
        draw = ImageDraw.Draw(img)
        # Just use default font
        # try to get a better font if possible, but default is fine for placeholders
        try:
            # Add basic text centering
            bbox = draw.textbbox((0, 0), text)
            w = bbox[2] - bbox[0]
            h = bbox[3] - bbox[1]
            draw.text(((size[0]-w)/2, (size[1]-h)/2), text, fill="white")
        except Exception:
            draw.text((10, 10), text, fill="white")
    if path.endswith('.jpg'):
        img = img.convert('RGB')
    img.save(path)

# Icons
create_image('assets/icons/app_icon.png', (1024, 1024), (232, 168, 56), 'Dazz Cam')
create_image('assets/icons/lock.png', (16, 16), (255, 215, 0), '')

# Overlays
create_image('assets/overlays/light_leak.png', (2000, 2000), (255, 165, 0, 50), 'Light Leak')

# Thumbnails
create_image('assets/thumbnails/sample_thumb.jpg', (104, 104), (50, 50, 50), 'Thumb')
for preset in ['classic_film', 'vintage_fade', 'light_leak', 'mono_classic', 'golden_hour', 'soft_fade']:
    create_image(f'assets/thumbnails/{preset}.png', (104, 104), (100, 100, 100), preset)

# Onboarding
create_image('assets/onboarding/split.png', (750, 600), (40, 40, 40), 'Before / After')
create_image('assets/onboarding/grid.png', (750, 600), (60, 60, 60), 'Presets Grid')
create_image('assets/onboarding/export.png', (750, 600), (80, 80, 80), 'Export Mockup')

# Watermark
create_image('assets/watermark/watermark.png', (200, 60), (0, 0, 0, 0), 'DAZZ CAM')

# Samples
create_image('assets/samples/sample_photo.jpg', (2000, 2000), (120, 120, 120), 'Sample Photo')
create_image('assets/samples/splash.png', (1080, 1920), (10, 10, 10), 'DAZZ CAM')
create_image('assets/samples/before.png', (1000, 1000), (100, 100, 100), 'Before')
create_image('assets/samples/after.png', (1000, 1000), (150, 100, 50), 'After')

print("Placeholder assets generated successfully.")
