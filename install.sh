#!/bin/bash

set -e

echo "📦 Eclipse Formatter CLI Installer"
echo "=================================="

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

# Default installation directory
INSTALL_DIR="/usr/local/bin"
JAR_NAME="eclipse-format.jar"
SCRIPT_NAME="eclipse-format"

# Check if Java is installed
check_java() {
    if ! command -v java &> /dev/null; then
        echo -e "${RED}❌ Java is not installed or not in PATH${NC}"
        echo "Please install Java 15 or higher:"
        echo "  macOS: brew install openjdk@17"
        echo "  Ubuntu/Debian: sudo apt install openjdk-17-jdk"
        echo "  Fedora/RHEL: sudo dnf install java-17-openjdk"
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 15 ]; then
        echo -e "${YELLOW}⚠️  Java version $JAVA_VERSION detected. Java 15 or higher is recommended.${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Build the project
build_project() {
    echo -e "${YELLOW}🔨 Building project...${NC}"
    
    if [ ! -f "gradlew" ]; then
        echo -e "${RED}❌ gradlew not found in current directory${NC}"
        exit 1
    fi
    
    chmod +x gradlew
    ./gradlew shadowJar
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Build failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Build successful${NC}"
}

# Create wrapper script
create_wrapper() {
    local jar_path="$1"
    local wrapper_path="$2"
    
    cat > "$wrapper_path" << 'EOF'
#!/bin/bash

# Eclipse Formatter CLI Wrapper
# This script runs the Eclipse Formatter CLI tool

# Find the JAR file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR_FILE="$SCRIPT_DIR/eclipse-format.jar"

# Check if JAR exists
if [ ! -f "$JAR_FILE" ]; then
    echo "Error: eclipse-format.jar not found in $SCRIPT_DIR"
    echo "Please run the installer again or build the project"
    exit 1
fi

# Check Java
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed or not in PATH"
    exit 1
fi

# Run the application
exec java -jar "$JAR_FILE" "$@"
EOF
    
    chmod +x "$wrapper_path"
    echo -e "${GREEN}✅ Created wrapper script at $wrapper_path${NC}"
}

# Install to system
install_to_system() {
    echo -e "${YELLOW}📁 Installing to $INSTALL_DIR...${NC}"
    
    # Check if we have write permission
    if [ ! -w "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}⚠️  Need sudo permission to install to $INSTALL_DIR${NC}"
        sudo mkdir -p "$INSTALL_DIR"
    fi
    
    # Copy JAR file
    JAR_SRC="build/libs/eclipse-format.jar"
    if [ ! -f "$JAR_SRC" ]; then
        echo -e "${RED}❌ JAR file not found: $JAR_SRC${NC}"
        echo "Please build the project first: ./gradlew shadowJar"
        exit 1
    fi
    
    if [ -w "$INSTALL_DIR" ]; then
        cp "$JAR_SRC" "$INSTALL_DIR/$JAR_NAME"
    else
        sudo cp "$JAR_SRC" "$INSTALL_DIR/$JAR_NAME"
    fi
    
    # Create wrapper script
    WRAPPER_CONTENT="#!/bin/bash\nexec java -jar \"$INSTALL_DIR/$JAR_NAME\" \"\$@\""
    
    if [ -w "$INSTALL_DIR" ]; then
        echo "$WRAPPER_CONTENT" > "$INSTALL_DIR/$SCRIPT_NAME"
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    else
        echo "$WRAPPER_CONTENT" | sudo tee "$INSTALL_DIR/$SCRIPT_NAME" > /dev/null
        sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    fi
    
    echo -e "${GREEN}✅ Installed to $INSTALL_DIR/$SCRIPT_NAME${NC}"
}

# Install locally
install_locally() {
    echo -e "${YELLOW}📁 Installing locally...${NC}"
    
    LOCAL_DIR="$HOME/.local/bin"
    mkdir -p "$LOCAL_DIR"
    
    # Copy JAR file
    JAR_SRC="build/libs/eclipse-format.jar"
    if [ ! -f "$JAR_SRC" ]; then
        echo -e "${RED}❌ JAR file not found: $JAR_SRC${NC}"
        echo "Please build the project first: ./gradlew shadowJar"
        exit 1
    fi
    
    cp "$JAR_SRC" "$LOCAL_DIR/$JAR_NAME"
    
    # Create wrapper script
    cat > "$LOCAL_DIR/$SCRIPT_NAME" << EOF
#!/bin/bash
exec java -jar "$LOCAL_DIR/$JAR_NAME" "\$@"
EOF
    
    chmod +x "$LOCAL_DIR/$SCRIPT_NAME"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$LOCAL_DIR:"* ]]; then
        echo -e "${YELLOW}⚠️  $LOCAL_DIR is not in your PATH${NC}"
        echo "Add this to your ~/.bashrc, ~/.zshrc, or ~/.profile:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        read -p "Add to PATH now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            SHELL_RC="$HOME/.$(basename "$SHELL")rc"
            if [ ! -f "$SHELL_RC" ]; then
                SHELL_RC="$HOME/.profile"
            fi
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
            echo -e "${GREEN}✅ Added to $SHELL_RC${NC}"
            echo "Restart your shell or run: source $SHELL_RC"
        fi
    fi
    
    echo -e "${GREEN}✅ Installed to $LOCAL_DIR/$SCRIPT_NAME${NC}"
}

# Create standalone script
create_standalone() {
    echo -e "${YELLOW}📄 Creating standalone script...${NC}"
    
    JAR_SRC="build/libs/eclipse-format.jar"
    if [ ! -f "$JAR_SRC" ]; then
        echo -e "${RED}❌ JAR file not found: $JAR_SRC${NC}"
        echo "Please build the project first: ./gradlew shadowJar"
        exit 1
    fi
    
    # In a real version, we would base64 encode the JAR and embed it
    # For now, create a simpler version
    cat > "eclipse-format-simple.sh" << EOF
#!/bin/bash

# Simple wrapper that looks for the JAR in common locations

JAR_LOCATIONS=(
    "\$(dirname "\$0")/eclipse-format.jar"
    "\$(dirname "\$0")/build/libs/eclipse-format.jar"
    "\$HOME/.local/bin/eclipse-format.jar"
    "/usr/local/bin/eclipse-format.jar"
    "./eclipse-format.jar"
)

for JAR_FILE in "\${JAR_LOCATIONS[@]}"; do
    if [ -f "\$JAR_FILE" ]; then
        exec java -jar "\$JAR_FILE" "\$@"
    fi
done

echo "Error: eclipse-format.jar not found"
echo "Please specify the JAR path: eclipse-format.sh /path/to/eclipse-format.jar [args]"
echo "Or install using: ./install.sh"
exit 1
EOF
    
    chmod +x "eclipse-format-simple.sh"
    echo -e "${GREEN}✅ Created standalone script: eclipse-format-simple.sh${NC}"
}

# Uninstall menu
uninstall_menu() {
    echo -e "${YELLOW}🗑️  Uninstall Eclipse Formatter CLI${NC}"
    echo "======================================"
    echo ""
    echo "Select what to uninstall:"
    echo "  1) System-wide installation (/usr/local/bin)"
    echo "  2) Local user installation (~/.local/bin)"
    echo "  3) All installations (system + local)"
    echo "  4) Specific file or directory"
    echo "  5) Cancel"
    echo ""
    
    read -p "Choose option (1-5): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            uninstall_system
            ;;
        2)
            uninstall_local
            ;;
        3)
            uninstall_all
            ;;
        4)
            uninstall_specific
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

# Uninstall system-wide installation
uninstall_system() {
    echo -e "${YELLOW}🗑️  Uninstalling system-wide installation...${NC}"
    
    local files_removed=0
    
    # Check and remove system files
    if [ -f "/usr/local/bin/eclipse-format" ]; then
        echo "Removing: /usr/local/bin/eclipse-format"
        sudo rm -f "/usr/local/bin/eclipse-format"
        files_removed=$((files_removed + 1))
    fi
    
    if [ -f "/usr/local/bin/eclipse-format.jar" ]; then
        echo "Removing: /usr/local/bin/eclipse-format.jar"
        sudo rm -f "/usr/local/bin/eclipse-format.jar"
        files_removed=$((files_removed + 1))
    fi
    
    if [ $files_removed -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No system-wide installation found${NC}"
    else
        echo -e "${GREEN}✅ Removed $files_removed system file(s)${NC}"
    fi
}

# Uninstall local user installation
uninstall_local() {
    echo -e "${YELLOW}🗑️  Uninstalling local user installation...${NC}"
    
    local files_removed=0
    
    # Check and remove local files
    if [ -f "$HOME/.local/bin/eclipse-format" ]; then
        echo "Removing: $HOME/.local/bin/eclipse-format"
        rm -f "$HOME/.local/bin/eclipse-format"
        files_removed=$((files_removed + 1))
    fi
    
    if [ -f "$HOME/.local/bin/eclipse-format.jar" ]; then
        echo "Removing: $HOME/.local/bin/eclipse-format.jar"
        rm -f "$HOME/.local/bin/eclipse-format.jar"
        files_removed=$((files_removed + 1))
    fi
    
    # Check ~/bin as well
    if [ -f "$HOME/bin/eclipse-format" ]; then
        echo "Removing: $HOME/bin/eclipse-format"
        rm -f "$HOME/bin/eclipse-format"
        files_removed=$((files_removed + 1))
    fi
    
    if [ -f "$HOME/bin/eclipse-format.jar" ]; then
        echo "Removing: $HOME/bin/eclipse-format.jar"
        rm -f "$HOME/bin/eclipse-format.jar"
        files_removed=$((files_removed + 1))
    fi
    
    if [ $files_removed -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No local user installation found${NC}"
    else
        echo -e "${GREEN}✅ Removed $files_removed local file(s)${NC}"
    fi
}

# Uninstall all installations
uninstall_all() {
    echo -e "${YELLOW}🗑️  Uninstalling ALL installations...${NC}"
    
    uninstall_system
    echo ""
    uninstall_local
    
    # Also check for other common locations
    echo ""
    echo -e "${YELLOW}🔍 Checking for other installations...${NC}"
    
    local other_locations=(
        "/usr/bin/eclipse-format"
        "/usr/bin/eclipse-format.jar"
        "/opt/eclipse-format/"
        "$HOME/Applications/eclipse-format"
    )
    
    for location in "${other_locations[@]}"; do
        if [ -e "$location" ]; then
            echo -e "${YELLOW}Found: $location${NC}"
            read -p "Remove this file/directory? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [[ "$location" == */ ]]; then
                    echo "Removing directory: $location"
                    sudo rm -rf "$location"
                else
                    echo "Removing file: $location"
                    sudo rm -f "$location"
                fi
            fi
        fi
    done
    
    echo -e "${GREEN}✅ Uninstall complete${NC}"
}

# Uninstall specific file or directory
uninstall_specific() {
    echo -e "${YELLOW}🗑️  Uninstall specific file or directory${NC}"
    echo "Enter the full path to the file or directory to remove:"
    echo "(e.g., /usr/local/bin/eclipse-format or ~/.local/bin/)"
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
        ls -la "$target_path/"
    fi
    
    echo ""
    read -p "Are you sure you want to remove this? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    # Check if we need sudo
    if [ ! -w "$(dirname "$target_path")" ] && [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Need sudo permission to remove $target_path${NC}"
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

# Main installation menu
main() {
    check_java
    
    if [ ! -f "build/libs/eclipse-format.jar" ]; then
        build_project
    fi
    
    echo ""
    echo "Installation Options:"
    echo "  1) Install system-wide (requires sudo)"
    echo "  2) Install locally (~/.local/bin)"
    echo "  3) Create standalone script"
    echo "  4) Just build, don't install"
    echo "  5) Uninstall"
    echo "  6) Exit"
    echo ""
    
    read -p "Choose option (1-6): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            install_to_system
            ;;
        2)
            install_locally
            ;;
        3)
            create_standalone
            ;;
        4)
            echo -e "${GREEN}✅ Build complete. JAR is at build/libs/eclipse-format.jar${NC}"
            echo "Run with: java -jar build/libs/eclipse-format.jar --help"
            ;;
        5)
            uninstall_menu
            ;;
        6)
            echo "Exiting"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}🎉 Installation complete!${NC}"
    echo "Usage: eclipse-format --help"
    echo "Example: eclipse-format -r src/"
}

# Run main function
main "$@"