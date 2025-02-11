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

verify_homebrew() {
    print_message "Verifying Homebrew installation..."
    
    # Check if brew command is available
    if ! command -v brew >/dev/null 2>&1; then
        print_error "brew command not found in PATH"
        return 1
    fi
    
    # Determine Homebrew path based on architecture
    if [[ $(uname -m) == "arm64" ]]; then
        BREW_PATH="/opt/homebrew"
    else
        BREW_PATH="/usr/local"
    fi
    
    # Check directory ownership
    if [ ! -d "$BREW_PATH" ]; then
        print_error "Homebrew directory ($BREW_PATH) not found"
        return 1
    fi
    
    OWNER=$(stat -f '%Su' "$BREW_PATH")
    if [ "$OWNER" != "$USER" ]; then
        print_error "Homebrew directory has incorrect ownership (owned by $OWNER, should be $USER)"
        print_error "To fix, run: sudo chown -R $USER:admin $BREW_PATH"
        return 1
    fi
    
    # Check if brew doctor has critical issues
    print_message "Running brew doctor..."
    DOCTOR_OUTPUT=$(brew doctor 2>&1)
    if echo "$DOCTOR_OUTPUT" | grep -q "Error:"; then
        print_error "brew doctor reported critical issues:"
        echo "$DOCTOR_OUTPUT" | grep "Error:" >&2
        return 1
    elif echo "$DOCTOR_OUTPUT" | grep -q "Warning:"; then
        print_message "brew doctor reported warnings (these are usually okay):"
        echo "$DOCTOR_OUTPUT" | grep "Warning:" >&2
    fi
    
    # Verify core commands work
    print_message "Testing basic Homebrew functionality..."
    if ! brew --version >/dev/null 2>&1; then
        print_error "Unable to get Homebrew version"
        return 1
    fi
    
    # Check PATH setup
    if ! grep -q "brew shellenv" ~/.zprofile 2>/dev/null; then
        print_error "Homebrew PATH setup not found in ~/.zprofile"
        return 1
    fi
    
    print_success "Homebrew is correctly installed and configured!"
    print_message "Version: $(brew --version | head -n 1)"
    print_message "Prefix: $(brew --prefix)"
    print_message "Owner: $USER"
    return 0
}

# Check if running with sudo
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script with sudo"
    print_error "Homebrew should not be installed as root"
    exit 1
fi

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
        # Ensure brew is available in current session
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel path
        if ! grep -q "brew shellenv" ~/.zprofile; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        # Ensure brew is available in current session
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    print_success "Homebrew has been added to your PATH"
    print_message "Note: You may need to restart your terminal for all changes to take effect"
}

setup_editor_cli_tools() {
    print_message "Setting up command line tools for editors..."
    
    # Ensure /usr/local/bin exists
    if [ ! -d "/usr/local/bin" ]; then
        print_message "Creating /usr/local/bin directory..."
        sudo mkdir -p /usr/local/bin
    fi
    
    # VS Code CLI
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        # Create symlink if it doesn't exist
        if [ ! -f "/usr/local/bin/code" ]; then
            print_message "Installing 'code' command line tool..."
            sudo ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "/usr/local/bin/code"
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
            sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "/usr/local/bin/subl"
            print_success "'subl' command line tool installed"
        else
            print_message "'subl' command line tool already installed"
        fi
    fi
}

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    print_message "Installing Homebrew..."
    
    # First ensure the user has Command Line Tools installed
    if ! xcode-select -p &>/dev/null; then
        print_message "Installing Command Line Tools..."
        xcode-select --install
        print_message "Please wait for Command Line Tools installation to complete, then press any key to continue..."
        read -n 1 -s
    fi
    
    # Install Homebrew as non-root user
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Setup Homebrew in the PATH
    setup_brew_path
    
    # Verify the installation
    if ! verify_homebrew; then
        print_error "Homebrew installation verification failed"
        print_error "Please fix the reported issues and try again"
        exit 1
    fi
else
    print_message "Homebrew is already installed"
    print_message "Verifying installation..."
    
    # Verify existing installation
    if ! verify_homebrew; then
        print_error "Existing Homebrew installation has issues"
        print_error "Please fix the reported issues and try again"
        exit 1
    fi
    
    print_message "Updating Homebrew..."
    # Ensure brew is in PATH before using it
    setup_brew_path
    brew update
    
    print_success "Homebrew updated successfully!"
fi

# Ensure Homebrew is in PATH before proceeding
if ! command -v brew >/dev/null 2>&1; then
    print_error "Homebrew is not available in PATH. Please restart your terminal and run the script again."
    exit 1
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

# Create Screenshots directory if it doesn't exist
mkdir -p "${HOME}/Screenshots"

# Global settings
print_message "Configuring global settings..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Finder settings
print_message "Configuring Finder settings..."
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Screenshot settings
print_message "Configuring screenshot settings..."
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture type -string "png"

# Battery settings
print_message "Configuring menu bar settings..."
defaults write com.apple.menuextra.battery ShowPercent -bool true

# Trackpad settings
print_message "Configuring trackpad settings..."
# These require sudo as they modify system settings
sudo defaults write /Library/Preferences/com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults write /Library/Preferences/com.apple.AppleMultitouchTrackpad Clicking -bool true

# Also write to current user settings
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Accessibility settings
print_message "Configuring accessibility settings..."
# Note: These settings may require user interaction in System Preferences
print_message "Note: You may need to manually enable accessibility features in System Preferences > Accessibility"

# We'll skip the accessibility settings that require special permissions
# Instead, provide instructions for manual configuration
cat << 'EOF'
==> Please configure these accessibility settings manually:
1. Open System Preferences > Accessibility > Zoom
2. Enable "Use scroll gesture with modifier keys to zoom"
3. Select "Control" as the modifier key

These settings require security permissions that can't be automated.
EOF

# Activity Monitor settings
print_message "Configuring Activity Monitor settings..."
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Restart affected applications
print_message "Restarting affected applications..."
for app in "Finder" "SystemUIServer" "Activity Monitor"; do
    killall "${app}" &> /dev/null || true
done

print_success "macOS settings configured successfully!"
print_message "Note: Some accessibility settings need to be configured manually in System Preferences"
print_success "Basic setup completed successfully! You may need to restart your Mac for all changes to take effect." 