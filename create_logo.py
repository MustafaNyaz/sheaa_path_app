from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math

def create_logo():
    # Dimensions
    size = 1024
    bg_color = (15, 23, 42) # #0F172A
    gold_color = (251, 191, 36) # #FBBF24
    
    # Create Canvas
    img = Image.new('RGB', (size, size), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Draw Crescent
    # Outer circle
    center = size // 2
    radius = size * 0.35
    draw.ellipse((center - radius, center - radius, center + radius, center + radius), fill=gold_color)
    
    # Inner circle (to cut the crescent) - Offset slightly up and right
    offset_x = size * 0.1
    offset_y = -size * 0.05
    inner_radius = radius * 0.85
    draw.ellipse(
        (center - inner_radius + offset_x, center - inner_radius + offset_y, 
         center + inner_radius + offset_x, center + inner_radius + offset_y), 
        fill=bg_color
    )
    
    # Draw Star (Simple 5-pointed star logic or just a circle for simplicity in "icon" feel)
    # Let's draw a nice 4-pointed star (diamond shine)
    star_x = center + (size * 0.15)
    star_y = center - (size * 0.2)
    star_size = size * 0.15
    
    # 4-point star path
    points = [
        (star_x, star_y - star_size), # Top
        (star_x + star_size * 0.3, star_y - star_size * 0.3),
        (star_x + star_size, star_y), # Right
        (star_x + star_size * 0.3, star_y + star_size * 0.3),
        (star_x, star_y + star_size), # Bottom
        (star_x - star_size * 0.3, star_y + star_size * 0.3),
        (star_x - star_size, star_y), # Left
        (star_x - star_size * 0.3, star_y - star_size * 0.3),
    ]
    draw.polygon(points, fill=gold_color)
    
    # Optional: Text "QD"
    # Loading font might be tricky without a file, so we stick to geometric shapes which are safer and professional.
    
    # Save
    img.save('assets/icon.png')
    print("Logo created at assets/icon.png")

if __name__ == "__main__":
    create_logo()
