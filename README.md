# Mac Development Environment Setup

This repository contains scripts and instructions for setting up a minimal development environment on macOS. The setup includes essential tools required for further development environment configuration.

## Prerequisites

- macOS (tested on macOS Sonoma 14.0+)
- Terminal access
- Administrator privileges (for installation)

## Quick Install

One-line installation:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/marknorgren/mac-dev/main/setup.sh)"
```

## Manual Installation

If you prefer to review the script first (recommended):

```bash
# Clone this repository
git clone https://github.com/yourusername/mac-dev.git
cd mac-dev

# Make the script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

## What Gets Installed

The script installs and configures:

### Package Manager

- [Homebrew](https://brew.sh) - The Missing Package Manager for macOS

### Text Editors

- [Visual Studio Code](https://code.visualstudio.com) - Modern code editor with great extensions
- [Sublime Text](https://www.sublimetext.com) - Fast, lightweight text editor

### macOS Configurations

The script also applies several sensible macOS defaults.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
