#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_message() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is only for macOS"
    exit 1
fi

setup_brew_path() {
    print_message "Setting up Homebrew in your shell environment..."
    
    # Create a new line in .zprofile if it exists, create if it doesn't
    touch ~/.zprofile
    echo >> ~/.zprofile
    
    # Add Homebrew to PATH
    if [[ $(uname -m) == "arm64" ]]; then
        # Apple Silicon path
        if ! grep -q "brew shellenv" ~/.zprofile; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        # Intel path
        if ! grep -q "brew shellenv" ~/.zprofile; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    print_success "Homebrew has been added to your PATH"
    print_message "Note: You may need to restart your terminal for all changes to take effect"
}

setup_editor_cli_tools() {
    print_message "Setting up command line tools for editors..."
    
    # VS Code CLI
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        # Create symlink if it doesn't exist
        if [ ! -f "/usr/local/bin/code" ]; then
            print_message "Installing 'code' command line tool..."
            ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "/usr/local/bin/code"
            print_success "'code' command line tool installed"
        else
            print_message "'code' command line tool already installed"
        fi
    fi
    
    # Sublime Text CLI
    if [ -d "/Applications/Sublime Text.app" ]; then
        # Create symlink if it doesn't exist
        if [ ! -f "/usr/local/bin/subl" ]; then
            print_message "Installing 'subl' command line tool..."
            ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "/usr/local/bin/subl"
            print_success "'subl' command line tool installed"
        else
            print_message "'subl' command line tool already installed"
        fi
    fi
}

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    print_message "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Setup Homebrew in the PATH
    setup_brew_path
    
    print_success "Homebrew installed successfully!"
else
    print_message "Homebrew is already installed"
    print_message "Updating Homebrew..."
    brew update
    
    # Ensure Homebrew is in PATH even if it's already installed
    setup_brew_path
    
    print_success "Homebrew updated successfully!"
fi

# Install essential applications
print_message "Installing essential applications..."

# Install editors
print_message "Installing text editors..."
brew install --cask sublime-text visual-studio-code

print_success "Essential applications installed successfully!"

# Setup CLI tools for editors
setup_editor_cli_tools

# Configure macOS defaults
print_message "Configuring macOS settings..."

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Save screenshots to Screenshots folder
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Show battery percentage in menu bar
defaults write com.apple.menuextra.battery ShowPercent -bool true

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Restart affected applications
print_message "Restarting affected applications..."
for app in "Finder" "SystemUIServer" "Activity Monitor"; do
    killall "${app}" &> /dev/null || true
done

print_success "macOS settings configured successfully!"
print_success "Basic setup completed successfully! You may need to restart your Mac for all changes to take effect." 