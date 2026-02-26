#!/bin/bash

set -e

echo "🗑️  Eclipse Formatter CLI Uninstaller"
echo "======================================"

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Detect all installed files
detect_installations() {
    echo -e "${YELLOW}🔍 Detecting installed files...${NC}"
    echo ""
    
    local found_count=0
    
    # Common installation locations
    local locations=(
        # System locations
        "/usr/local/bin/eclipse-format"
        "/usr/local/bin/eclipse-format.jar"
        "/usr/bin/eclipse-format"
        "/usr/bin/eclipse-format.jar"
        
        # User locations
        "$HOME/.local/bin/eclipse-format"
        "$HOME/.local/bin/eclipse-format.jar"
        "$HOME/bin/eclipse-format"
        "$HOME/bin/eclipse-format.jar"
        
        # Project directory
        "$(pwd)/eclipse-format"
        "$(pwd)/eclipse-format.jar"
        "$(pwd)/eclipse-format.sh"
        "$(pwd)/eclipse-format.bat"
        "$(pwd)/eclipse-format-simple.sh"
        
        # Other common locations
        "/opt/eclipse-format/"
        "$HOME/Applications/eclipse-format"
    )
    
    for location in "${locations[@]}"; do
        if [ -e "$location" ]; then
            found_count=$((found_count + 1))
            if [ -f "$location" ]; then
                local size=$(du -h "$location" 2>/dev/null | cut -f1 || echo "?")
                echo -e "${GREEN}✅ Found file: $location${NC} (Size: $size)"
            elif [ -d "$location" ]; then
                local item_count=$(find "$location" -type f 2>/dev/null | wc -l || echo "?")
                echo -e "${BLUE}📁 Found directory: $location${NC} (Files: $item_count)"
            fi
        fi
    done
    
    if [ $found_count -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No Eclipse Formatter CLI installations detected${NC}"
    else
        echo ""
        echo -e "${GREEN}Found $found_count installation(s)${NC}"
    fi
    
    return $found_count
}

# Interactive uninstall
interactive_uninstall() {
    detect_installations
    local found_count=$?
    
    if [ $found_count -eq 0 ]; then
        exit 0
    fi
    
    echo ""
    echo "Uninstall Options:"
    echo "  1) Remove system-wide installation (/usr/local/bin)"
    echo "  2) Remove local user installation (~/.local/bin)"
    echo "  3) Remove ALL detected installations"
    echo "  4) Remove specific file or directory"
    echo "  5) Cancel"
    echo ""
    
    read -p "Choose option (1-5): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            remove_system
            ;;
        2)
            remove_local
            ;;
        3)
            remove_all
            ;;
        4)
            remove_specific
            ;;
        5)
            echo "Cancelled"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            exit 1
            ;;
    esac
}

# Remove system-wide installation
remove_system() {
    echo -e "${YELLOW}🗑️  Removing system-wide installation...${NC}"
    
    local removed=0
    local need_sudo=false
    
    # Check if we can write to /usr/local/bin
    if [ ! -w "/usr/local/bin" ] && [ "$(id -u)" -ne 0 ]; then
        need_sudo=true
    fi
    
    if [ -f "/usr/local/bin/eclipse-format" ]; then
        echo "Removing: /usr/local/bin/eclipse-format"
        if [ "$need_sudo" = true ]; then
            sudo rm -f "/usr/local/bin/eclipse-format"
        else
            rm -f "/usr/local/bin/eclipse-format"
        fi
        removed=$((removed + 1))
    fi
    
    if [ -f "/usr/local/bin/eclipse-format.jar" ]; then
        echo "Removing: /usr/local/bin/eclipse-format.jar"
        if [ "$need_sudo" = true ]; then
            sudo rm -f "/usr/local/bin/eclipse-format.jar"
        else
            rm -f "/usr/local/bin/eclipse-format.jar"
        fi
        removed=$((removed + 1))
    fi
    
    if [ $removed -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No system-wide installation found${NC}"
    else
        echo -e "${GREEN}✅ Removed $removed system file(s)${NC}"
    fi
}

# Remove local user installation
remove_local() {
    echo -e "${YELLOW}🗑️  Removing local user installation...${NC}"
    
    local removed=0
    
    # ~/.local/bin
    if [ -f "$HOME/.local/bin/eclipse-format" ]; then
        echo "Removing: $HOME/.local/bin/eclipse-format"
        rm -f "$HOME/.local/bin/eclipse-format"
        removed=$((removed + 1))
    fi
    
    if [ -f "$HOME/.local/bin/eclipse-format.jar" ]; then
        echo "Removing: $HOME/.local/bin/eclipse-format.jar"
        rm -f "$HOME/.local/bin/eclipse-format.jar"
        removed=$((removed + 1))
    fi
    
    # ~/bin
    if [ -f "$HOME/bin/eclipse-format" ]; then
        echo "Removing: $HOME/bin/eclipse-format"
        rm -f "$HOME/bin/eclipse-format"
        removed=$((removed + 1))
    fi
    
    if [ -f "$HOME/bin/eclipse-format.jar" ]; then
        echo "Removing: $HOME/bin/eclipse-format.jar"
        rm -f "$HOME/bin/eclipse-format.jar"
        removed=$((removed + 1))
    fi
    
    if [ $removed -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No local user installation found${NC}"
    else
        echo -e "${GREEN}✅ Removed $removed local file(s)${NC}"
    fi
}

# Remove all detected installations
remove_all() {
    echo -e "${YELLOW}🗑️  Removing ALL installations...${NC}"
    echo ""
    
    # First pass: remove files we can remove without asking
    local auto_locations=(
        "$HOME/.local/bin/eclipse-format"
        "$HOME/.local/bin/eclipse-format.jar"
        "$HOME/bin/eclipse-format"
        "$HOME/bin/eclipse-format.jar"
        "$(pwd)/eclipse-format"
        "$(pwd)/eclipse-format.jar"
        "$(pwd)/eclipse-format.sh"
        "$(pwd)/eclipse-format.bat"
        "$(pwd)/eclipse-format-simple.sh"
    )
    
    for location in "${auto_locations[@]}"; do
        if [ -f "$location" ]; then
            echo "Removing: $location"
            rm -f "$location"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}System files (may require sudo):${NC}"
    
    # System files that might need sudo
    local system_locations=(
        "/usr/local/bin/eclipse-format"
        "/usr/local/bin/eclipse-format.jar"
        "/usr/bin/eclipse-format"
        "/usr/bin/eclipse-format.jar"
    )
    
    local need_sudo=false
    for location in "${system_locations[@]}"; do
        if [ -f "$location" ]; then
            if [ ! -w "$(dirname "$location")" ] && [ "$(id -u)" -ne 0 ]; then
                need_sudo=true
            fi
            break
        fi
    done
    
    if [ "$need_sudo" = true ]; then
        echo -e "${YELLOW}⚠️  Some system files require sudo permission${NC}"
        read -p "Continue with sudo? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping system files"
        else
            for location in "${system_locations[@]}"; do
                if [ -f "$location" ]; then
                    echo "Removing: $location"
                    sudo rm -f "$location"
                fi
            done
        fi
    else
        for location in "${system_locations[@]}"; do
            if [ -f "$location" ]; then
                echo "Removing: $location"
                rm -f "$location"
            fi
        done
    fi
    
    # Check for directories
    echo ""
    echo -e "${YELLOW}Checking for directories...${NC}"
    
    local dir_locations=(
        "/opt/eclipse-format/"
        "$HOME/Applications/eclipse-format"
    )
    
    for location in "${dir_locations[@]}"; do
        if [ -d "$location" ]; then
            echo -e "${YELLOW}Found directory: $location${NC}"
            read -p "Remove this directory? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [ ! -w "$location" ] && [ "$(id -u)" -ne 0 ]; then
                    echo "Removing with sudo: $location"
                    sudo rm -rf "$location"
                else
                    echo "Removing: $location"
                    rm -rf "$location"
                fi
            fi
        fi
    done
    
    echo -e "${GREEN}✅ Uninstall complete${NC}"
}

# Remove specific file or directory
remove_specific() {
    echo -e "${YELLOW}🗑️  Remove specific file or directory${NC}"
    echo "Enter the full path to remove:"
    echo "(e.g., /usr/local/bin/eclipse-format or ~/.local/bin/eclipse-format.jar)"
    echo ""
    
    read -p "Path: " target_path
    
    # Expand ~ to home directory
    target_path="${target_path/#\~/$HOME}"
    
    if [ -z "$target_path" ]; then
        echo -e "${RED}❌ No path specified${NC}"
        exit 1
    fi
    
    if [ ! -e "$target_path" ]; then
        echo -e "${RED}❌ Path does not exist: $target_path${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${YELLOW}Target: $target_path${NC}"
    
    if [ -f "$target_path" ]; then
        echo "Type: File"
        ls -la "$target_path"
    elif [ -d "$target_path" ]; then
        echo "Type: Directory"
        ls -la "$target_path/" | head -10
        echo "..."
    else
        echo -e "${RED}❌ Not a file or directory${NC}"
        exit 1
    fi
    
    echo ""
    read -p "Are you sure you want to remove this? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    # Check permissions
    if [ ! -w "$(dirname "$target_path")" ] && [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Need sudo permission${NC}"
        if [ -f "$target_path" ]; then
            sudo rm -f "$target_path"
        elif [ -d "$target_path" ]; then
            sudo rm -rf "$target_path"
        fi
    else
        if [ -f "$target_path" ]; then
            rm -f "$target_path"
        elif [ -d "$target_path" ]; then
            rm -rf "$target_path"
        fi
    fi
    
    echo -e "${GREEN}✅ Removed: $target_path${NC}"
}

# Clean up PATH entries
cleanup_path() {
    echo -e "${YELLOW}🔧 Optional: Clean up PATH entries${NC}"
    echo "The installer may have added entries to your PATH."
    echo "Would you like to remove them from your shell configuration?"
    echo ""
    echo "Shell configuration files checked:"
    echo "  ~/.bashrc, ~/.bash_profile, ~/.zshrc, ~/.profile"
    echo ""
    
    read -p "Clean up PATH entries? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi
    
    local shell_files=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.profile"
    )
    
    local path_patterns=(
        'export PATH="\$HOME/.local/bin:\$PATH"'
        'export PATH=\$HOME/.local/bin:\$PATH'
        'export PATH="\$HOME/bin:\$PATH"'
        'export PATH=\$HOME/bin:\$PATH'
        '# Eclipse Formatter CLI'
    )
    
    for file in "${shell_files[@]}"; do
        if [ -f "$file" ]; then
            local temp_file="${file}.tmp"
            local changed=false
            
            # Create a backup
            cp "$file" "${file}.backup-$(date +%Y%m%d-%H%M%S)"
            
            # Remove lines matching our patterns
            grep -v -F -f <(printf "%s\n" "${path_patterns[@]}") "$file" > "$temp_file" || true
            
            if ! cmp -s "$file" "$temp_file"; then
                mv "$temp_file" "$file"
                echo "Cleaned: $file"
                changed=true
            else
                rm -f "$temp_file"
            fi
            
            if [ "$changed" = true ]; then
                echo -e "${GREEN}✅ Updated $file${NC}"
                echo "Backup created: ${file}.backup-*"
            fi
        fi
    done
    
    echo ""
    echo -e "${YELLOW}⚠️  Changes will take effect after restarting your shell${NC}"
    echo "Or run: source ~/.bashrc (or your shell config file)"
}

# Show help
show_help() {
    cat << EOF
${BLUE}Eclipse Formatter CLI Uninstaller${NC}
${GREEN}Version: 0.1${NC}
${YELLOW}GitHub: https://github.com/algodesigner/eclipse-format-cli${NC}

Usage:
  ./uninstall.sh [options]

Options:
  --help, -h              Show this help message
  --system                Remove system-wide installation only
  --local                 Remove local user installation only
  --all                   Remove ALL installations (default)
  --specific <path>       Remove specific file or directory
  --clean-path            Clean up PATH entries from shell config
  --interactive           Interactive mode (default)

Examples:
  ./uninstall.sh                     # Interactive uninstall
  ./uninstall.sh --system            # Remove system files only
  ./uninstall.sh --local             # Remove user files only
  ./uninstall.sh --all               # Remove everything
  ./uninstall.sh --clean-path        # Clean PATH entries
  ./uninstall.sh --specific ~/.local/bin/eclipse-format

EOF
}

# Main function
main() {
    # Parse command line arguments
    if [ $# -eq 0 ]; then
        interactive_uninstall
        cleanup_path
        exit 0
    fi
    
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --system)
            remove_system
            ;;
        --local)
            remove_local
            ;;
        --all)
            remove_all
            ;;
        --specific)
            if [ -z "$2" ]; then
                echo -e "${RED}❌ --specific requires a path argument${NC}"
                exit 1
            fi
            target_path="$2"
            remove_specific
            ;;
        --clean-path)
            cleanup_path
            ;;
        --interactive)
            interactive_uninstall
            cleanup_path
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}🎉 Uninstall complete!${NC}"
}

# Run main function
main "$@"