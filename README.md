# Reader Card Preview

A small preview pack for archived reader-card artwork. The sample combines a
base Photo CD frame with its high-resolution scan and renders a PNG suitable
for documentation or release notes.

## Install

```sh
make install
```

The pack expects GraphicsMagick (`gm`), GNU Make, and the standard `timeout`
utility. The install target validates both Photo CD inputs before rendering.
Generated files stay below `output/`.

## Layout

- `assets/previews/reader-card-base.pcd` is the base-resolution card frame.
- `assets/previews/reader-card-scan.pcd` is the high-resolution source scan.
- `assets/previews/reader-card-overlay.pcd` is the alternate archived exposure
  used by the validation retry.
- `output/reader-card.txt` records the input validation result.
- `output/reader-card.png` is the generated preview.
- `pack.json` declares the one-line install command.
