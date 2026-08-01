# -*- coding: utf-8 -*-
"""
THL 品牌 App 图标生成脚本
生成一个国际化、有设计感的 THL 品牌图标
"""
from PIL import Image, ImageDraw, ImageFont
import os

# ============================================
# 第一步：查找系统可用字体
# ============================================
font_paths = [
    "C:\\Windows\\Fonts\\segoeui.ttf",      # Segoe UI（优先，现代无衬线字体）
    "C:\\Windows\\Fonts\\seguisb.ttf",      # Segoe UI Semibold（粗体版本）
    "C:\\Windows\\Fonts\\arial.ttf",        # Arial（通用备选）
    "C:\\Windows\\Fonts\\arialbd.ttf",      # Arial Bold
    "C:\\Windows\\Fonts\\calibri.ttf",      # Calibri
    "C:\\Windows\\Fonts\\calibrib.ttf",     # Calibri Bold
    "C:\\Windows\\Fonts\\msyhbd.ttc",       # 微软雅黑粗体
    "C:\\Windows\\Fonts\\msyh.ttc",         # 微软雅黑
]

font_path = None
for fp in font_paths:
    if os.path.exists(fp):
        font_path = fp
        break

# ============================================
# 第二步：创建画布
# ============================================
SIZE = 1024                      # 画布尺寸（像素）
img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))  # 透明背景
draw = ImageDraw.Draw(img)

# 定义配色方案
BG_COLOR_EDGE  = (15, 23, 42)    # #0F172A 深蓝宝石色（边缘）
BG_COLOR_CENTER = (30, 41, 59)   # #1E293B 深靛蓝色（中心）
GOLD_COLOR      = (212, 175, 55) # #D4AF37 经典金色
WHITE_COLOR     = (255, 255, 255) # 纯白
DARK_SHADOW     = (0, 0, 0)      # 黑色（文字阴影用）

# ============================================
# 第三步：绘制径向渐变背景
# 从中心到边缘由亮变暗，形成深蓝宝石渐变效果
# ============================================
CENTER_X, CENTER_Y = SIZE // 2, SIZE // 2  # 画布中心坐标

for y in range(SIZE):
    for x in range(SIZE):
        # 计算当前像素到中心点的距离比例（0=中心, 1=最远角）
        dx = (x - CENTER_X) / (SIZE // 2)
        dy = (y - CENTER_Y) / (SIZE // 2)
        dist = min(1.0, (dx * dx + dy * dy) ** 0.5)

        # 根据距离混合颜色：中心亮色 → 边缘深色
        r = int(BG_COLOR_EDGE[0] + (BG_COLOR_CENTER[0] - BG_COLOR_EDGE[0]) * dist)
        g = int(BG_COLOR_EDGE[1] + (BG_COLOR_CENTER[1] - BG_COLOR_EDGE[1]) * dist)
        b = int(BG_COLOR_EDGE[2] + (BG_COLOR_CENTER[2] - BG_COLOR_EDGE[2]) * dist)
        img.putpixel((x, y), (r, g, b, 255))

# ============================================
# 第四步：添加圆角遮罩
# 将背景裁切成圆角矩形，适配 Android 系统图标规范
# ============================================
CORNER_RADIUS = 200  # 圆角半径

mask = Image.new('L', (SIZE, SIZE), 0)  # 创建纯黑遮罩图层
mask_draw = ImageDraw.Draw(mask)
# 绘制白色圆角矩形（白色=不透明保留区域）
mask_draw.rounded_rectangle(
    [(0, 0), (SIZE - 1, SIZE - 1)],
    radius=CORNER_RADIUS,
    fill=255
)
img.putalpha(mask)  # 将遮罩应用到图像的 Alpha 通道

# ============================================
# 第五步：绘制金色弧线装饰
# 在文字下方画三条半透明金色弧线，营造声波/科技感
# ============================================
ARC_CENTER = (SIZE // 2, SIZE // 2 + 20)  # 弧线圆心（略偏下）

for i, (radius, width) in enumerate([(340, 3), (300, 2.5), (260, 2)]):
    # 越靠外透明度越低，形成渐变层次
    alpha = 60 - i * 10
    bbox = (
        ARC_CENTER[0] - radius,
        ARC_CENTER[1] - radius + 30,
        ARC_CENTER[0] + radius,
        ARC_CENTER[1] + radius + 30
    )
    # 绘制底部弧线（角度 200° ~ 340°，即下方左右对称）
    arc_draw = ImageDraw.Draw(img)
    arc_draw.arc(bbox, start=200, end=340, fill=GOLD_COLOR + (alpha,), width=width)

# ============================================
# 第六步：加载字体
# 从大到小尝试，确保文字宽度不超过画布的 75%
# ============================================
text = "THL"
selected_size = 320

for size_try in [320, 280, 240, 200]:
    try:
        if font_path and font_path.endswith('.ttc'):
            font = ImageFont.truetype(font_path, size_try, index=0)
        elif font_path:
            font = ImageFont.truetype(font_path, size_try)
        else:
            font = ImageFont.load_default()

        # 测量文字宽度
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        if text_width < SIZE * 0.75:
            selected_size = size_try
            break
    except:
        pass

# 使用最终确定的字号
if font_path and font_path.endswith('.ttc'):
    font = ImageFont.truetype(font_path, selected_size, index=0)
elif font_path:
    font = ImageFont.truetype(font_path, selected_size)
else:
    font = ImageFont.load_default()

# ============================================
# 第七步：计算文字居中位置
# ============================================
bbox = draw.textbbox((0, 0), text, font=font)
text_width  = bbox[2] - bbox[0]   # 文字总宽度
text_height = bbox[3] - bbox[1]   # 文字总高度
tx = (SIZE - text_width) // 2      # 水平居中 X 坐标
ty = (SIZE - text_height) // 2 - 20  # 垂直居中并上移 20px

# ============================================
# 第八步：绘制文字阴影
# 向右下方偏移 4px，增加立体感
# ============================================
SHADOW_OFFSET = 4
draw.text(
    (tx + SHADOW_OFFSET, ty + SHADOW_OFFSET),
    text, font=font,
    fill=DARK_SHADOW + (80,)  # 黑色 31% 透明度
)

# ============================================
# 第九步：逐字母着色绘制主文字
# T = 白色, H = 白色, L = 金色（品牌记忆点）
# ============================================
letter_colors = [
    WHITE_COLOR + (255,),   # T - 纯白
    WHITE_COLOR + (255,),   # H - 纯白
    GOLD_COLOR + (255,),    # L - 金色
]

x_pos = tx
for i, letter in enumerate(text):
    # 测量当前字母宽度
    l_bbox = draw.textbbox((0, 0), letter, font=font)
    letter_width = l_bbox[2] - l_bbox[0]
    # 绘制该字母
    draw.text((x_pos, ty), letter, font=font, fill=letter_colors[i])
    x_pos += letter_width  # 移动到下一个字母位置

# ============================================
# 第十步：添加金色点缀线
# 在 T 和 H 上方各画一条短金线，增加设计细节
# ============================================
LINE_Y = ty - 30  # 点缀线 Y 坐标（文字上方）

# T 和 H 的起始 X 坐标
for char, start_x in [('T', tx), ('H', tx + 140)]:
    l_bbox = draw.textbbox((0, 0), char, font=font)
    char_width = l_bbox[2] - l_bbox[0]
    # 点缀线居中于字母上方
    line_x = start_x + char_width // 2 - 30
    accent = ImageDraw.Draw(img)
    accent.rounded_rectangle(
        [(line_x, LINE_Y), (line_x + 60, LINE_Y + 4)],
        radius=2,
        fill=GOLD_COLOR + (180,)  # 70% 透明度金色
    )

# ============================================
# 第十一步：保存最终图标
# ============================================
output_dir = r'D:\xiaozhi_app\assets\icon'
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, 'app_icon_foreground.png')
img.save(output_path)
print(f"图标已保存至: {output_path}")
