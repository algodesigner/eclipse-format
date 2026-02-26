# Eclipse Formatter CLI - Usage Guide

## Quick Start

### Option 1: One-line setup (recommended for first-time users)
```bash
# Run the quick setup script
./setup.sh

# Now use the formatter
./eclipse-format --help
```

### Option 2: Full installation
```bash
# Build and install with interactive menu
./install.sh

# Choose installation option (system-wide, local, or standalone)
```

### Option 3: Manual usage
```bash
# Build the project
./gradlew shadowJar

# Run directly
java -jar build/libs/eclipse-format.jar --help

# Or use the universal wrapper
./eclipse-format.sh --help
```

## Available Wrapper Scripts

### 1. **`install.sh`** - Interactive Installer
The most user-friendly way to install the tool.

```bash
./install.sh
```

**Features:**
- Interactive menu with installation options
- System-wide installation (requires sudo)
- Local user installation (~/.local/bin)
- Standalone script creation
- Java version checking
- Automatic PATH configuration

### 2. **`eclipse-format.sh`** - Universal Wrapper
Smart wrapper that automatically finds the JAR file.

```bash
# Basic usage (auto-finds JAR)
./eclipse-format.sh MyClass.java

# Specify JAR explicitly
./eclipse-format.sh --jar-path /path/to/jar -r src/

# Utility commands
./eclipse-format.sh --find-jar          # Search for JAR files
./eclipse-format.sh --install-info      # Show installation info
./eclipse-format.sh --self-update       # Update wrapper (if installed via package)
```

### 3. **`eclipse-format.bat`** - Windows Wrapper
For Windows users (requires Java installed).

```batch
eclipse-format.bat MyClass.java
eclipse-format.bat --jar-path C:\path\to\jar -r src\
```

### 4. **`setup.sh`** - Quick Setup
Creates a simple wrapper in the current directory.

```bash
./setup.sh
# Creates ./eclipse-format wrapper
```

## Installation Methods

### Method A: System-wide Installation (Linux/macOS)
```bash
./install.sh
# Choose option 1 (system-wide)
# Requires sudo privileges
```

**Result:** Installs to `/usr/local/bin/eclipse-format`

### Method B: Local User Installation
```bash
./install.sh
# Choose option 2 (local)
```

**Result:** Installs to `~/.local/bin/eclipse-format`

### Method C: Standalone Script
```bash
./install.sh
# Choose option 3 (standalone)
```

**Result:** Creates `eclipse-format-standalone.sh` that can be distributed separately

### Method D: Portable Usage
```bash
# Just build and use from project directory
./gradlew shadowJar
./eclipse-format.sh MyClass.java
```

## Platform-Specific Instructions

### macOS
```bash
# Install Java if needed
brew install openjdk@17

# Install formatter
./install.sh

# Add to PATH if using local installation
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Linux
```bash
# Install Java if needed (Ubuntu/Debian)
sudo apt install openjdk-17-jdk

# Install formatter
./install.sh

# Verify installation
which eclipse-format
eclipse-format --version
```

### Windows
```powershell
# Install Java from https://adoptium.net/
# Add Java to PATH

# Build the project
gradlew.bat shadowJar

# Use the batch wrapper
eclipse-format.bat --help

# Or create a shortcut:
# 1. Create eclipse-format.bat with: java -jar "C:\path\to\eclipse-format.jar" %*
# 2. Add the directory to your PATH
```

## Environment Variables

You can customise behaviour with environment variables:

```bash
# Specify JAR location explicitly
export ECLIPSE_FORMATTER_JAR="/path/to/eclipse-format.jar"

# Custom Java options (memory, etc.)
export JAVA_OPTS="-Xmx2g -XX:+UseG1GC"

# The wrapper will use these automatically
eclipse-format.sh MyClass.java
```

## Common Use Cases

### 1. Format a Single File
```bash
eclipse-format MyClass.java
```

### 2. Format a Directory Recursively
```bash
eclipse-format -r src/
```

### 3. Preview Changes (Dry Run)
```bash
eclipse-format -d -r src/
```

### 4. Use Custom Formatter Configuration
```bash
# Export from Eclipse: Window → Preferences → Java → Code Style → Formatter → Export
eclipse-format -c my-config.xml MyClass.java
```

### 5. CI/CD Integration
```bash
# Check if code is properly formatted
eclipse-format -d -r src/
if [ $? -eq 0 ]; then
    echo "✅ Code is properly formatted"
else
    echo "❌ Code needs formatting"
    exit 1
fi
```

### 6. Git Pre-commit Hook
Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
echo "Formatting Java files..."
eclipse-format -r src/
git add src/
```

## Troubleshooting

### "Java not found"
```bash
# Check Java installation
java -version

# Install Java if missing
# macOS: brew install openjdk@17
# Ubuntu: sudo apt install openjdk-17-jdk
```

### "JAR file not found"
```bash
# Build the project first
./gradlew shadowJar

# Or use the find command
./eclipse-format.sh --find-jar
```

### "Permission denied"
```bash
# Make scripts executable
chmod +x *.sh

# For installation, use sudo
sudo ./install.sh
```

### Windows: "Java is not recognised"
- Install Java from https://adoptium.net/
- Add Java to PATH: `C:\Program Files\Eclipse Adoptium\jdk-17.0.x\bin`
- Restart command prompt

## Updating

### Update from Source
```bash
git pull origin main
./gradlew shadowJar
./install.sh  # Re-run installer if needed
```

### Update Wrapper Only
```bash
./eclipse-format.sh --self-update
```

## Uninstalling

### Option 1: Using the Uninstall Script (Recommended)
```bash
# Interactive uninstall (recommended)
./uninstall.sh

# Or use specific options:
./uninstall.sh --system          # Remove system-wide installation
./uninstall.sh --local           # Remove local user installation  
./uninstall.sh --all             # Remove ALL installations
./uninstall.sh --clean-path      # Clean up PATH entries
./uninstall.sh --specific /path/to/file  # Remove specific file

# Show help
./uninstall.sh --help
```

### Option 2: Using Install Script
```bash
# The install script also has uninstall options
./install.sh
# Choose option 5 (Uninstall)
```

### Option 3: Manual Uninstall

#### System-wide Installation
```bash
sudo rm /usr/local/bin/eclipse-format
sudo rm /usr/local/bin/eclipse-format.jar
```

#### Local User Installation
```bash
rm ~/.local/bin/eclipse-format
rm ~/.local/bin/eclipse-format.jar
rm ~/bin/eclipse-format 2>/dev/null || true
rm ~/bin/eclipse-format.jar 2>/dev/null || true
```

#### Remove from PATH
Edit your shell config file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`) and remove any lines containing:
- `export PATH="$HOME/.local/bin:$PATH"`
- `export PATH=$HOME/.local/bin:$PATH`
- `export PATH="$HOME/bin:$PATH"`
- `# Eclipse Formatter CLI`

## Support

For issues or questions:
1. Check this USAGE.md file
2. Run `./eclipse-format.sh --install-info`
3. Check the [README.md](README.md) for more details
4. File an issue on GitHub

---

**Pro Tip:** For the best experience, use `./install.sh` and choose system-wide or local installation. The wrapper scripts handle all the complexity for you!