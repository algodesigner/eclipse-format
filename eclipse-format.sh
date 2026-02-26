#!/bin/bash

# Eclipse Formatter CLI - Universal Wrapper Script
# This script automatically finds and runs the Eclipse Formatter CLI

set -e

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

VERSION="0.1"
SCRIPT_NAME="eclipse-format"

# Default JAR name
JAR_NAME="eclipse-format.jar"

# Common installation locations
COMMON_JAR_PATHS=(
    # Relative to script location
    "$(dirname "$0")/$JAR_NAME"
    "$(dirname "$0")/build/libs/$JAR_NAME"
    "$(dirname "$0")/../build/libs/$JAR_NAME"
    
    # User local installations
    "$HOME/.local/bin/$JAR_NAME"
    "$HOME/bin/$JAR_NAME"
    
    # System installations
    "/usr/local/bin/$JAR_NAME"
    "/usr/bin/$JAR_NAME"
    "/opt/eclipse-format/$JAR_NAME"
    
    # Current directory and common build locations
    "./$JAR_NAME"
    "./build/libs/$JAR_NAME"
    "../build/libs/$JAR_NAME"
)

# Common wrapper/script locations
COMMON_WRAPPER_PATHS=(
    "$(dirname "$0")/eclipse-format"
    "$HOME/.local/bin/eclipse-format"
    "$HOME/bin/eclipse-format"
    "/usr/local/bin/eclipse-format"
    "/usr/bin/eclipse-format"
)

print_help() {
    cat << EOF
${BLUE}Eclipse Formatter CLI Wrapper${NC}
${GREEN}Version: $VERSION${NC}

This wrapper script helps you run the Eclipse Formatter CLI tool.
It automatically searches for the JAR file in common locations.

${YELLOW}Usage:${NC}
  $SCRIPT_NAME [options] <file|directory>
  $SCRIPT_NAME --jar-path /path/to/jar [options] <file|directory>

${YELLOW}Options:${NC}
  --help, -h              Show this help message
  --version               Show version information
  --jar-path <path>       Specify the JAR file path explicitly
  --find-jar              Search for JAR files and show locations
  --install-info          Show installation information
  --self-update           Update this wrapper script (if installed via package manager)

${YELLOW}Examples:${NC}
  $SCRIPT_NAME MyClass.java
  $SCRIPT_NAME -r src/
  $SCRIPT_NAME --jar-path ./my-build/eclipse-format.jar -v src/
  $SCRIPT_NAME --find-jar

${YELLOW}Installation:${NC}
  Run ./install.sh in the project directory for easy installation.
  Or manually copy the JAR to ~/.local/bin/ and create a wrapper.

EOF
}

print_version() {
    echo "Eclipse Formatter CLI Wrapper v$VERSION"
    echo "Project: https://github.com/algodesigner/eclipse-format-cli"
}

find_jar_files() {
    echo -e "${YELLOW}🔍 Searching for Eclipse Formatter JAR files...${NC}"
    echo ""
    
    local found=0
    
    for path in "${COMMON_JAR_PATHS[@]}"; do
        if [ -f "$path" ]; then
            echo -e "${GREEN}✅ Found: $path${NC}"
            local jar_size=$(du -h "$path" | cut -f1)
            local jar_date=$(date -r "$path" "+%Y-%m-%d %H:%M:%S")
            echo "    Size: $jar_size, Modified: $jar_date"
            found=$((found + 1))
        fi
    done
    
    echo ""
    if [ $found -eq 0 ]; then
        echo -e "${RED}❌ No JAR files found${NC}"
        echo "You need to build the project first:"
        echo "  ./gradlew shadowJar"
        echo "Or download a pre-built JAR from the releases page."
    else
        echo -e "${GREEN}Found $found JAR file(s)${NC}"
    fi
}

check_java() {
    if ! command -v java &> /dev/null; then
        echo -e "${RED}❌ Error: Java is not installed or not in PATH${NC}"
        echo ""
        echo "Please install Java 15 or higher:"
        echo "  • macOS: brew install openjdk@17"
        echo "  • Ubuntu/Debian: sudo apt install openjdk-17-jdk"
        echo "  • Fedora/RHEL: sudo dnf install java-17-openjdk"
        echo "  • Windows: Download from https://adoptium.net/"
        exit 1
    fi
    
    # Check Java version
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 15 ]; then
        echo -e "${YELLOW}⚠️  Warning: Java version $JAVA_VERSION detected${NC}"
        echo "Java 15 or higher is recommended for full compatibility."
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

find_best_jar() {
    # First check if JAR path was explicitly provided via environment variable
    if [ -n "$ECLIPSE_FORMATTER_JAR" ] && [ -f "$ECLIPSE_FORMATTER_JAR" ]; then
        echo "$ECLIPSE_FORMATTER_JAR"
        return 0
    fi
    
    # Check command line argument
    for arg in "$@"; do
        if [ "$arg" = "--jar-path" ]; then
            shift
            if [ -n "$1" ] && [ -f "$1" ]; then
                echo "$1"
                return 0
            else
                echo -e "${RED}❌ Error: JAR file not found: $1${NC}"
                exit 1
            fi
        fi
    done
    
    # Search common locations
    for path in "${COMMON_JAR_PATHS[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

show_install_info() {
    echo -e "${BLUE}📦 Eclipse Formatter CLI Installation Information${NC}"
    echo ""
    
    # Check if Java is installed
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        echo -e "${GREEN}✅ Java: $JAVA_VERSION${NC}"
    else
        echo -e "${RED}❌ Java: Not installed${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Installation Methods:${NC}"
    echo "1. ${GREEN}Using install.sh${NC} (recommended)"
    echo "   ./install.sh"
    echo ""
    echo "2. ${GREEN}Manual installation${NC}"
    echo "   ./gradlew shadowJar"
    echo "   cp build/libs/eclipse-format.jar ~/.local/bin/"
    echo "   echo '#!/bin/bash' > ~/.local/bin/eclipse-format"
    echo "   echo 'exec java -jar ~/.local/bin/eclipse-format.jar \"\$@\"' >> ~/.local/bin/eclipse-format"
    echo "   chmod +x ~/.local/bin/eclipse-format"
    echo ""
    echo "3. ${GREEN}System-wide installation${NC}"
    echo "   sudo cp build/libs/eclipse-format.jar /usr/local/bin/"
    echo "   sudo cp eclipse-format.sh /usr/local/bin/eclipse-format"
    echo "   sudo chmod +x /usr/local/bin/eclipse-format"
    
    echo ""
    echo -e "${YELLOW}Current JAR Search Paths:${NC}"
    for path in "${COMMON_JAR_PATHS[@]}"; do
        if [ -f "$path" ]; then
            echo -e "  ${GREEN}✓ $path${NC}"
        else
            echo -e "  ${RED}✗ $path${NC}"
        fi
    done
}

self_update() {
    echo -e "${YELLOW}🔄 Checking for updates...${NC}"
    
    # This would check for updates from a remote source
    # For now, just show a message
    echo "Self-update feature requires installation via package manager."
    echo "If you installed manually, update by re-running install.sh"
    echo "or replacing this wrapper script with the latest version."
}

main() {
    # Handle wrapper-specific options first
    for arg in "$@"; do
        case $arg in
            --help|-h)
                print_help
                exit 0
                ;;
            --version)
                print_version
                exit 0
                ;;
            --find-jar)
                find_jar_files
                exit 0
                ;;
            --install-info)
                show_install_info
                exit 0
                ;;
            --self-update)
                self_update
                exit 0
                ;;
        esac
    done
    
    # Check Java
    check_java
    
    # Find JAR file
    JAR_FILE=$(find_best_jar "$@")
    
    if [ -z "$JAR_FILE" ]; then
        echo -e "${RED}❌ Error: eclipse-format.jar not found${NC}"
        echo ""
        echo "Please specify the JAR file using one of these methods:"
        echo "1. Set environment variable:"
        echo "   export ECLIPSE_FORMATTER_JAR=/path/to/eclipse-format.jar"
        echo ""
        echo "2. Use --jar-path option:"
        echo "   $SCRIPT_NAME --jar-path /path/to/jar [options]"
        echo ""
        echo "3. Build the project:"
        echo "   ./gradlew shadowJar"
        echo ""
        echo "4. Search for existing JAR files:"
        echo "   $SCRIPT_NAME --find-jar"
        echo ""
        echo "5. Show installation info:"
        echo "   $SCRIPT_NAME --install-info"
        exit 1
    fi
    
    if [ ! -f "$JAR_FILE" ]; then
        echo -e "${RED}❌ Error: JAR file not found: $JAR_FILE${NC}"
        exit 1
    fi
    
    # Remove --jar-path argument if present
    ARGS=()
    SKIP_NEXT=false
    
    for arg in "$@"; do
        if [ "$SKIP_NEXT" = true ]; then
            SKIP_NEXT=false
            continue
        fi
        
        if [ "$arg" = "--jar-path" ]; then
            SKIP_NEXT=true
            continue
        fi
        
        ARGS+=("$arg")
    done
    
    # Run the Java application
    if [ "${#ARGS[@]}" -eq 0 ]; then
        # No arguments, show help
        exec java -jar "$JAR_FILE" --help
    else
        exec java -jar "$JAR_FILE" "${ARGS[@]}"
    fi
}

# Run main function
main "$@"