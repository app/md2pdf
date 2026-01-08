# md2pdf (typst-cmarker)

Container-based Markdown → PDF converter using Typst and cmarker.

## Usage

### 1. Build the image

```bash
podman build -t typst-cmarker .
```

### 2. Convert

```bash
./md2pdf.sh file.md
```

PDF will be created in the same directory as the source file.

## Requirements

- Podman (or Docker)
- Bash
