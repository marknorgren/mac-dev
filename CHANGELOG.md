# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial project setup
- README.md with project documentation
- setup.sh script with Homebrew installation
- Support for both Intel and Apple Silicon Macs
- Colorized output in setup script
- Essential text editors installation (VS Code, Sublime Text)
- Command-line tools setup for editors
  - VS Code 'code' command
  - Sublime Text 'subl' command
  - Proper permissions handling with sudo
  - Automatic /usr/local/bin creation
- Sensible macOS defaults configuration
  - Finder preferences (show extensions, hidden files, path bar)
  - System preferences (screenshots, trackpad, security)
  - UI/UX improvements
  - Proper sudo usage for system-level settings
- Added one-line installation option using curl

### Enhanced

- Improved Homebrew PATH setup
  - Added comprehensive shell environment configuration
  - Support for both new installations and existing ones
  - Better handling of .zprofile updates
  - Added checks to prevent duplicate PATH entries
  - Fixed PATH availability in current shell session
  - Added verification before proceeding with brew commands
- Improved macOS defaults configuration
  - Better organization by categories
  - Added proper error handling
  - Fixed permissions for system-level settings
  - Added Screenshots directory creation
