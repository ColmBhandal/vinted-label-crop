# Vinted label crop

A small Bash script that crops Vinted shipping-label PDFs to the exact label area so you can print and stick only the label, without having to waste ink printing the instructions part.

## What it does

- Takes a full-page PDF (e.g. A4) that contains a Vinted shipping label.
- Crops it to a fixed rectangle (bounding box) in PDF coordinates, so the output is just the label region.
- Uses **pdfcrop** with an explicit `--bbox` (no auto-detection); coordinates are in PDF points: `llx lly urx ury`, with the origin at the **bottom-left** of the page.
- Supports multiple label **types** (e.g. FR, IE), each with its own bounding box, because layout differs by country/source.

Output is written to a new PDF (by default `*_cropped.pdf`).

## Prerequisites

You need **pdfcrop** on your system. On Windows, pdfcrop is provided by **MiKTeX**.

### Windows (Chocolatey)

Install MiKTeX (which supplies pdfcrop):

```powershell
choco install miktex
```

If pdfcrop is not on your PATH after installation, add MiKTeX’s `bin` folder to PATH, or run from the MiKTeX console. If the `pdfcrop` command is missing, install the MiKTeX package:

```powershell
mpm --install=pdfcrop
```

(Alternatively, use the MiKTeX Package Manager GUI to install the `pdfcrop` package.)

## Usage

```bash
./label-crop.sh [--type fr|ie] [input.pdf] [output.pdf]
```

| Argument     | Description |
|-------------|-------------|
| `--type`    | Label type: `fr` or `ie`. Default: `ie`. |
| `input.pdf` | Input PDF. If omitted, the first `*.pdf` in the current directory is used. |
| `output.pdf`| Output PDF. If omitted, the name is `{input_base}_cropped.pdf`. |

Examples:

```bash
./label-crop.sh --type ie label.pdf
# → label_cropped.pdf

./label-crop.sh --type fr
# Uses first .pdf in current dir, writes *_cropped.pdf

./label-crop.sh --type ie in.pdf out.pdf
# Explicit input and output
```

## Adding more label types

To support another country or layout:

1. **Define a bounding box**  
   At the top of `label-crop.sh`, add a new array (PDF points: `llx lly urx ury`, origin bottom-left), for example:

   ```bash
   # Crop rectangle for DE label (example)
   DE_BBOX=(0 100 595 500)
   ```

2. **Add a `--type` option**  
   In the `case "$TYPE" in` block, add a branch that sets `BBOX` from your new array:

   ```bash
   de)
     BBOX=("${DE_BBOX[@]}")
     ;;
   ```

3. **Update the invalid-type message**  
   In the `*)` branch, extend the “expected” list (e.g. “expected fr, ie or de”) so the help stays accurate.

4. **Optional**  
   Update `show_help()` so the usage line lists the new type (e.g. `--type fr|ie|de`).

To find the right numbers for your new type, it's recommended to just do trial and error until you get a snug fit.

## License

Use and modify as you like.
