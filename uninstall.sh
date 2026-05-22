#!/bin/bash

printf "\xF0\x9F\x97\x91\xEF\xB8\x8F  Eclipse Formatter CLI Uninstaller\n"
printf "======================================\n"

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Detect all installed files
detect_installations() {
    printf "${YELLOW}\xF0\x9F\x94\x8D Detecting installed files...${NC}\n"
    printf "\n"

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
        "$(dirname "$0")/eclipse-format"
        "$(dirname "$0")/eclipse-format.jar"
        "$(dirname "$0")/eclipse-format.sh"
        "$(dirname "$0")/eclipse-format.bat"
        "$(dirname "$0")/eclipse-format-simple.sh"

        # Other common locations
        "/opt/eclipse-format/"
        "$HOME/Applications/eclipse-format"
    )

    for location in "${locations[@]}"; do
        if [ -e "$location" ]; then
            found_count=$((found_count + 1))
            if [ -f "$location" ]; then
                local size
                size=$(du -h "$location" 2>/dev/null | cut -f1) || size="?"
                printf "${GREEN}\xE2\x9C\x85 Found file: $location${NC} (Size: $size)\n"
            elif [ -d "$location" ]; then
                local item_count
                item_count=$(find "$location" -type f 2>/dev/null | wc -l) || item_count="?"
                printf "${BLUE}\xF0\x9F\x93\x81 Found directory: $location${NC} (Files: $item_count)\n"
            fi
        fi
    done

    if [ $found_count -eq 0 ]; then
        printf "${YELLOW}\xE2\x9A\xA0\xEF\xB8\x8F  No Eclipse Formatter CLI installations detected${NC}\n"
    else
        printf "\n"
        printf "${GREEN}Found $found_count installation(s)${NC}\n"
    fi

    return $found_count
}

# Interactive uninstall
interactive_uninstall() {
    while true; do
        detect_installations
        printf "\n"
        printf "Uninstall Options:\n"
        printf "  1) Remove system-wide installation (/usr/local/bin)\n"
        printf "  2) Remove local user installation (~/.local/bin)\n"
        printf "  3) Remove project files\n"
        printf "  4) Remove ALL detected installations\n"
        printf "  5) Remove specific file or directory\n"
        printf "  6) Clean up PATH entries\n"
        printf "  7) Exit\n"
        printf "\n"
        printf "Choose (1-7): "
        read -r choice

        case $choice in
            1) remove_system ;;
            2) remove_local ;;
            3) remove_project ;;
            4) remove_all ;;
            5) remove_specific ;;
            6) cleanup_path ;;
            7) printf "Done\n"; exit 0 ;;
            *) printf "${RED}Invalid option${NC}\n" ;;
        esac
    done
}

# Remove system-wide installation
remove_system() {
    printf "${YELLOW}\xF0\x9F\x97\x91\xEF\xB8\x8F  Removing system-wide installation...${NC}\n"

    local removed=0
    local need_sudo=false

    # Check if we can write to /usr/local/bin
    if [ ! -w "/usr/local/bin" ] && [ "$(id -u)" -ne 0 ]; then
        need_sudo=true
    fi

    local system_files=(
        "/usr/local/bin/eclipse-format"
        "/usr/local/bin/eclipse-format.jar"
        "/usr/bin/eclipse-format"
        "/usr/bin/eclipse-format.jar"
    )

    for file in "${system_files[@]}"; do
        if [ -f "$file" ]; then
            printf "Removing: $file\n"
            if [ "$need_sudo" = true ]; then
                sudo rm -f "$file"
            else
                rm -f "$file"
            fi
            removed=$((removed + 1))
        fi
    done

    if [ $removed -eq 0 ]; then
        printf "${YELLOW}\xE2\x9A\xA0\xEF\xB8\x8F  No system-wide installation found${NC}\n"
    else
        printf "${GREEN}\xE2\x9C\x85 Removed $removed system file(s)${NC}\n"
    fi
}

# Remove local user installation
remove_local() {
    printf "${YELLOW}\xF0\x9F\x97\x91\xEF\xB8\x8F  Removing local user installation...${NC}\n"

    local removed=0

    local local_files=(
        "$HOME/.local/bin/eclipse-format"
        "$HOME/.local/bin/eclipse-format.jar"
        "$HOME/bin/eclipse-format"
        "$HOME/bin/eclipse-format.jar"
    )

    for file in "${local_files[@]}"; do
        if [ -f "$file" ]; then
            printf "Removing: $file\n"
            rm -f "$file"
            removed=$((removed + 1))
        fi
    done

    if [ $removed -eq 0 ]; then
        printf "${YELLOW}\xE2\x9A\xA0\xEF\xB8\x8F  No local user installation found${NC}\n"
    else
        printf "${GREEN}\xE2\x9C\x85 Removed $removed local file(s)${NC}\n"
    fi
}

# Remove project files
remove_project() {
    printf "${YELLOW}\xF0\x9F\x97\x91\xEF\xB8\x8F  Removing project files...${NC}\n"

    local project_dir
    project_dir="$(dirname "$0")"
    local removed=0

    local project_files=(
        "$project_dir/eclipse-format"
        "$project_dir/eclipse-format.jar"
        "$project_dir/eclipse-format.sh"
        "$project_dir/eclipse-format.bat"
        "$project_dir/eclipse-format-simple.sh"
    )

    for file in "${project_files[@]}"; do
        if [ -f "$file" ]; then
            printf "Removing: $file\n"
            rm -f "$file"
            removed=$((removed + 1))
        fi
    done

    if [ $removed -eq 0 ]; then
        printf "${YELLOW}\xE2\x9A\xA0\xEF\xB8\x8F  No project files found${NC}\n"
    else
        printf "${GREEN}\xE2\x9C\x85 Removed $removed project file(s)${NC}\n"
    fi
}

# Remove all detected installations
remove_all() {
    printf "${YELLOW}\xF0\x9F\x97\x91\xEF\xB8\x8F  Removing ALL installations...${NC}\n"
    printf "\n"

    local project_dir
    project_dir="$(dirname "$0")"

    # First pass: remove files we can remove without asking
    local auto_locations=(
        "$HOME/.local/bin/eclipse-format"
        "$HOME/.local/bin/eclipse-format.jar"
        "$HOME/bin/eclipse-format"
        "$HOME/bin/eclipse-format.jar"
        "$project_dir/eclipse-format"
        "$project_dir/eclipse-format.jar"
        "$project_dir/eclipse-format.sh"
        "$project_dir/eclipse-format.bat"
        "$project_dir/eclipse-format-simple.sh"
    )

    for location in "${auto_locations[@]}"; do
        if [ -f "$location" ]; then
            printf "Removing: $location\n"
            rm -f "$location"
        fi
    done

    printf "\n"
    printf "${YELLOW}System files (may require sudo):${NC}\n"

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
        printf "${YELLOW}\xE2\x9A\xA0\xEF\xB8\x8F  Some system files require sudo permission${NC}\n"
        printf "Continue with sudo? (y/N): "
        read -r confirm
        if printf "%s" "$confirm" | grep -iq "^y"; then
            for location in "${system_locations[@]}"; do
                if [ -f "$location" ]; then
                    printf "Removing: $location\n"
                    sudo rm -f "$location"
                fi
            done
        else
            printf "Skipping system files\n"
        fi
    else
        for location in "${system_locations[@]}"; do
            if [ -f "$location" ]; then
                printf "Removing: $location\n"
                rm -f "$location"
            fi
        done
    fi

    # Check for directories
    printf "\n"
    printf "${YELLOW}Checking for directories...${NC}\n"

    local dir_locations=(
        "/opt/eclipse-format/"
        "$HOME/Applications/eclipse-format"
    )

    for location in "${dir_locations[@]}"; do
        if [ -d "$location" ]; then
            printf "${YELLOW}Found directory: $location${NC}\n"
            printf "Remove this directory? (y/N): "
            read -r confirm
            if printf "%s" "$confirm" | grep -iq "^y"; then
                if [ ! -w "$location" ] && [ "$(id -u)" -ne 0 ]; then
                    printf "Removing with sudo: $location\n"
                    sudo rm -rf "$location"
                else
                    printf "Removing: $location\n"
                    rm -rf "$location"
                fi
            fi
        fi
    done

    printf "${GREEN}\xE2\x9C\x85 Uninstall complete${NC}\n"
}

# Remove specific file or directory
remove_specific() {
    printf "${YELLOW}\xF0\x9F\x97\x91\xEF\xB8\x8F  Remove specific file or directory${NC}\n"
    printf "Enter the full path to remove:\n"
    printf "(e.g., /usr/local/bin/eclipse-format or ~/.local/bin/eclipse-format.jar)\n"
    printf "\n"

    printf "Path: "
    read -r target_path

    # Expand ~ to home directory
    target_path="${target_path/#\~/$HOME}"

    if [ -z "$target_path" ]; then
        printf "${RED}\xE2\x9D\x8C No path specified${NC}\n"
        return 1
    fi

    if [ ! -e "$target_path" ]; then
        printf "${RED}\xE2\x9D\x8C Path does not exist: $target_path${NC}\n"
        return 1
    fi

    printf "\n"
    printf "${YELLOW}Target: $target_path${NC}\n"

    if [ -f "$target_path" ]; then
        printf "Type: File\n"
        ls -la "$target_path"
    elif [ -d "$target_path" ]; then
        printf "Type: Directory\n"
        ls -la "$target_path/" | head -10
        printf "...\n"
    else
        printf "${RED}\xE2\x9D\x8C Not a file or directory${NC}\n"
        return 1
    fi

    printf "\n"
    printf "Are you sure you want to remove this? (y/N): "
    read -r confirm

    if ! printf "%s" "$confirm" | grep -iq "^y"; then
        printf "Cancelled\n"
        return 0
    fi

    # Check permissions
    if [ ! -w "$(dirname "$target_path")" ] && [ "$(id -u)" -ne 0 ]; then
        printf "${YELLOW}\xE2\x9A\xA0\xEF\xB8\x8F  Need sudo permission${NC}\n"
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

    printf "${GREEN}\xE2\x9C\x85 Removed: $target_path${NC}\n"
}

# Clean up PATH entries
cleanup_path() {
    printf "${YELLOW}\xF0\x9F\x94\xA7 Optional: Clean up PATH entries${NC}\n"
    printf "The installer may have added entries to your PATH.\n"
    printf "Would you like to remove them from your shell configuration?\n"
    printf "\n"
    printf "Shell configuration files checked:\n"
    printf "  ~/.bashrc, ~/.bash_profile, ~/.zshrc, ~/.profile\n"
    printf "\n"

    printf "Clean up PATH entries? (y/N): "
    read -r confirm

    if ! printf "%s" "$confirm" | grep -iq "^y"; then
        return
    fi

    local shell_files=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.profile"
    )

    local path_patterns=(
        'export PATH="$HOME/.local/bin:$PATH"'
        'export PATH=$HOME/.local/bin:$PATH'
        'export PATH="$HOME/bin:$PATH"'
        'export PATH=$HOME/bin:$PATH'
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
                printf "Cleaned: $file\n"
                changed=true
            else
                rm -f "$temp_file"
            fi

            if [ "$changed" = true ]; then
                printf "${GREEN}\xE2\x9C\x85 Updated $file${NC}\n"
                printf "Backup created: ${file}.backup-*\n"
            fi
        fi
    done

    printf "\n"
    printf "${YELLOW}\xE2\x9A\xA0\xEF\xB8\x8F  Changes will take effect after restarting your shell${NC}\n"
    printf "Or run: source ~/.bashrc (or your shell config file)\n"
}

# Show help
show_help() {
    cat << EOF
${BLUE}Eclipse Formatter CLI Uninstaller${NC}
${GREEN}Version: 0.1${NC}
${YELLOW}GitHub: https://github.com/algodesigner/eclipse-format${NC}

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
                printf "${RED}\xE2\x9D\x8C --specific requires a path argument${NC}\n"
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
            ;;
        *)
            printf "${RED}\xE2\x9D\x8C Unknown option: $1${NC}\n"
            show_help
            exit 1
            ;;
    esac

    printf "\n"
    printf "${GREEN}\xF0\x9F\x8E\x89 Uninstall complete!${NC}\n"
}

# Run main function
main "$@"
