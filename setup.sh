#!/bin/bash

# Eclipse Formatter CLI - Quick Setup Script
# One-line setup for users who just want to get started quickly

set -e

echo "🚀 Eclipse Formatter CLI - Quick Setup"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "build.gradle" ]; then
    echo "❌ Error: build.gradle not found in current directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Make scripts executable
chmod +x gradlew install.sh eclipse-format.sh build.sh 2>/dev/null || true

# Check Java
if ! command -v java &> /dev/null; then
    echo "❌ Java not found. Please install Java 15 or higher."
    exit 1
fi

# Build the project
echo "🔨 Building project..."
./gradlew shadowJar

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check the error messages above."
    exit 1
fi

# Create a simple wrapper in current directory
cat > eclipse-format << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec java -jar "$SCRIPT_DIR/build/libs/eclipse-format.jar" "$@"
EOF

chmod +x eclipse-format

echo ""
echo "✅ Setup complete!"
echo ""
echo "You can now use the formatter in several ways:"
echo ""
echo "1. ${GREEN}From current directory:${NC}"
echo "   ./eclipse-format --help"
echo ""
echo "2. ${GREEN}Using the universal wrapper:${NC}"
echo "   ./eclipse-format.sh --help"
echo ""
echo "3. ${GREEN}Install system-wide:${NC}"
echo "   ./install.sh"
echo ""
echo "4. ${GREEN}Direct JAR usage:${NC}"
echo "   java -jar build/libs/eclipse-format.jar --help"
echo ""
echo "Example: ./eclipse-format -r src/"
echo ""
echo "For more installation options, run: ./install.sh"