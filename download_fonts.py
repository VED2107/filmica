import os
import shutil

fonts = [
    'Inter-Regular.ttf',
    'Inter-Medium.ttf',
    'Inter-SemiBold.ttf',
    'Inter-Bold.ttf',
    'PlayfairDisplay-Bold.ttf'
]

os.makedirs('assets/fonts', exist_ok=True)
source_font = 'C:\\Windows\\Fonts\\arial.ttf'

for name in fonts:
    path = os.path.join('assets/fonts', name)
    if os.path.exists(source_font):
        shutil.copy(source_font, path)
        print(f"Copied fallback font for {name}")
    else:
        # Create empty if Arial not found just in case
        with open(path, 'wb') as f:
            pass
        print(f"Created empty font for {name}")
