# Diagram Creation Guide for Final Year Project

## Required Diagrams

### 1. **IEEE-754 Format Diagram** (`ieee754_format.png`)
**How to create:**
- **Tool:** Draw.io, PowerPoint, or online diagram tool
- **Content:** 
  - Draw a 32-bit register divided into 3 sections
  - Bit 31: Sign (S) - 1 bit (label with "0 = positive, 1 = negative")
  - Bits 30-23: Exponent (E) - 8 bits (label with "Biased by 127")
  - Bits 22-0: Fraction (F) - 23 bits (label with "Mantissa fractional part")
- **Resources:**
  - Google Image Search: "IEEE 754 single precision diagram"
  - Reference: https://en.wikipedia.org/wiki/Single-precision_floating-point_format
  - Can recreate similar diagrams in PowerPoint or Draw.io

---

### 2. **Proposed Architecture Diagram** (`proposed_architecture.png`)
**How to create:**
- **Tool:** Draw.io (https://app.diagrams.net/) - FREE
- **Content:**
  - Create block diagram with these modules:
    - Input blocks: A[31:0], B[31:0]
    - Field Extractor (Sign, Exponent, Fraction extraction)
    - Special Case Detector
    - Sign XOR block
    - Exponent Adder (8-bit)
    - Vedic 24×24 Multiplier (largest block)
    - Normalizer & Selector
    - Output block: Y[31:0]
  - Connect with arrows showing data flow
- **Style:** Professional block diagram with labeled connections

---

### 3. **Pipeline Architecture Diagram** (`pipeline_architecture.png`)
**How to create:**
- **Tool:** Draw.io or Lucidchart
- **Content:**
  - Show two stages separated by register bank
  - **Stage 1 (left):**
    - Input registers (a_r, b_r)
    - Mantissa Multiplier
    - Exponent Adder
    - Special Case Logic
  - **Pipeline Registers (center):**
    - Show register symbols (D flip-flops)
    - Labels: mant_r, expu_r, sign_r_r, flags
  - **Stage 2 (right):**
    - Normalizer
    - Priority Selector (MUX)
    - Output registers
  - Add clock signal line
  - Show valid_in and valid_out signals

---

### 4. **Vedic Multiplier Hierarchy** (`vedic_hierarchy.png`)
**How to create:**
- **Tool:** Draw.io
- **Content:**
  - Tree/pyramid structure showing:
    - Base level: Four 3×3 multipliers
    - Level 2: Four 6×6 multipliers (each containing 4× 3×3)
    - Level 3: Four 12×12 multipliers (each containing 4× 6×6)
    - Top level: One 24×24 multiplier (containing 4× 12×12)
  - Use boxes and connecting lines
  - Label each block with its size (e.g., "vedic3x3", "vedic6x6")
- **Alternative:** Create a tree diagram showing the recursive composition

---

### 5. **RTL Schematic** (`rtl_schematic.png`)
**How to get:**
- **From Vivado:**
  1. Open your project in Vivado
  2. After synthesis, go to: **Synthesis → Open Synthesized Design**
  3. Click **Schematic** button in the toolbar (or Window → Schematic)
  4. Navigate through the hierarchy to show your top module
  5. Take a screenshot or use File → Export → Export Image
  6. Capture the schematic showing main blocks
  
- **What to show:**
  - Top-level schematic with major blocks visible
  - Pipeline registers clearly shown
  - Vedic multiplier hierarchy (can zoom into this)
  - Input/output ports

---

### 6-8. **Simulation Waveforms** (3 files)
**How to get from Vivado:**

#### `waveform_normal.png` - Normal Operation (3.5 × -2.0)
1. Run simulation: `tb_fp_mul_pipelined`
2. Open waveform window
3. Add these signals:
   - clk
   - a (show as hex: 40600000)
   - b (show as hex: C0000000)
   - valid_in
   - valid_out
   - y (show as hex: C0E00000)
4. Run simulation for ~50ns
5. Zoom to show the relevant transaction
6. **File → Export → Export Waveform Image**

#### `waveform_zero.png` - Zero Handling
- Similar process, show:
  - a = 00000000 (zero)
  - b = 40A00000 (5.0)
  - y = 00000000 (zero result)

#### `waveform_nan.png` - NaN Handling
- Similar process, show:
  - a = 7FC00001 (NaN)
  - b = 40000000 (2.0)
  - y = 7FC00000 (NaN result)

---

## Quick Creation Tools

### Free Tools:
1. **Draw.io** (https://app.diagrams.net/) - Best for all diagrams
2. **Lucidchart** (Free tier available)
3. **Google Drawings** (Free with Google account)
4. **PowerPoint/Google Slides** - Simple diagrams
5. **Excalidraw** (https://excalidraw.com/) - Hand-drawn style

### For IEEE-754 Diagram:
You can use this online tool to visualize and screenshot:
- https://www.h-schmidt.net/FloatConverter/IEEE754.html
- https://baseconvert.com/ieee-754-floating-point

### Professional Tips:
- Use consistent colors (blue for data paths, red for control)
- Keep font sizes readable (minimum 12pt)
- Export as PNG with at least 1200px width for print quality
- Use white or light background for printing
- Add clear labels and legends

---

## Diagram Dimensions Recommendations

- **Width:** 1200-1600 pixels
- **Format:** PNG (best quality) or SVG
- **DPI:** 300 for print quality
- **Aspect Ratio:** 16:9 or 4:3 for most diagrams

---

## After Creating Diagrams

1. Save all diagrams in the `assets/` folder
2. Name them exactly as specified in `diagrams.js`
3. The report.html will automatically load them using the diagram manager

---

## Alternative: Use Placeholder Images Temporarily

If you need to generate the PDF now, you can:
1. Create simple text-based placeholders in Paint/PowerPoint
2. Just write the diagram title and description
3. Replace with proper diagrams later

The report will work with or without the images - they're referenced but won't break if missing.
