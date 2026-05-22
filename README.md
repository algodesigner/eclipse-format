# Eclipse Formatter CLI

A command-line tool for formatting Java code using Eclipse's code formatter in headless mode. Provides a simple, user-friendly interface for consistent code formatting across projects.

## Features

- 🚀 **Simple CLI interface** - Easy to use with intuitive commands
- ⚡ **Fast formatting** - Leverages Eclipse's proven formatter engine
- 🔧 **Customisable** - Use your own Eclipse formatter configuration
- 📁 **Batch processing** - Format single files or entire directories
- 🔍 **Dry run mode** - Preview changes before applying
- 🔄 **Recursive formatting** - Process nested directories
- 🧪 **Tested** - Comprehensive unit and integration tests
- 🏗️ **IDE friendly** - Works with Eclipse and IntelliJ IDEA

## 🚀 Quick Installation

### Option 1: One-Command Setup (Easiest & Recommended)
```bash
# Clone and setup in one go
git clone https://github.com/algodesigner/eclipse-format.git
cd eclipse-format
./setup.sh

# Now use it!
./eclipse-format --help
```

### Option 2: Interactive Installer (Full Features)
```bash
git clone https://github.com/algodesigner/eclipse-format.git
cd eclipse-format
./install.sh

# Choose from:
# 1. System-wide installation (requires sudo)
# 2. Local user installation (~/.local/bin)
# 3. Standalone script
# 4. Just build
```

### Option 3: Universal Wrapper (Smart Auto-Detection)
```bash
git clone https://github.com/algodesigner/eclipse-format.git
cd eclipse-format
./gradlew shadowJar
./eclipse-format.sh --help  # Auto-finds the JAR!
```

### Option 4: Direct Usage (Simple)
```bash
git clone https://github.com/algodesigner/eclipse-format.git
cd eclipse-format
./gradlew shadowJar
java -jar build/libs/eclipse-format.jar --help
```

### Option 5: Windows Users
```batch
git clone https://github.com/algodesigner/eclipse-format.git
cd eclipse-format
gradlew.bat shadowJar
eclipse-format.bat --help
```

## Usage

### Basic Usage

```bash
# Format a single Java file
eclipse-format MyClass.java

# Format all Java files in a directory
eclipse-format src/

# Format recursively
eclipse-format -r src/

# Dry run (show what would change)
eclipse-format -d src/

# Verbose output
eclipse-format -v MyClass.java

# Use custom configuration file
eclipse-format -c my-formatter.xml MyClass.java
```

### Command Line Options

```
Usage: eclipse-format [-cdrv] [-c=<configFile>] <target>
      <target>            File or directory to format
  -c, --config=<configFile>
                          Path to Eclipse formatter configuration file
                          (defaults to eclipse-format.xml in the current
                          directory; does not search parent directories)
  -d, --dry-run           Show what would be formatted without making changes
  -r, --recursive         Format files recursively
  -v, --verbose           Verbose output
      --help              Show this help message and exit
      --version           Print version information and exit
```

### Configuration File

The tool uses Eclipse's XML formatter configuration files. You can:

1. **Export from Eclipse IDE**: Window → Preferences → Java → Code Style → Formatter → Export...
2. **Use the default** included in this project (`eclipse-format.xml`)
3. **Create your own** XML configuration

**Config file resolution:** The config file path is resolved relative to
the **current working directory** from which you run the tool. There is
no automatic discovery — the tool does not search parent directories,
project roots, or `~/.config/`. Use the `-c` option to specify a full or
relative path to a config file elsewhere.

Example configuration file structure:
```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<profiles version="20">
<profile kind="CodeFormatterProfile" name="My Profile" version="20">
  <setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="4"/>
  <setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="space"/>
  <!-- More settings... -->
</profile>
</profiles>
```

## Development

### Prerequisites

- Java 15 or higher
- Gradle 8.5 or higher

### Setup Development Environment

```bash
# Clone and setup
git clone https://github.com/algodesigner/eclipse-format.git
cd eclipse-format

# Setup for Eclipse
./gradlew setupEclipse

# Setup for IntelliJ IDEA
./gradlew setupIntelliJ

# Clean IDE files
./gradlew cleanIDE
```

### Build Commands

```bash
# Build the project
./gradlew build

# Run tests
./gradlew test

# Run integration tests
./gradlew integrationTest

# Create executable JAR
./gradlew shadowJar

# Run the application
./gradlew run --args="-v MyClass.java"
```

### Project Structure

```
eclipse-format/
├── src/
│   ├── main/java/com/algodesigner/eclipseformat/cli/
│   │   ├── EclipseFormatCli.java        # Main CLI entry point
│   │   └── FormatterService.java        # Core formatting logic
│   └── test/java/com/algodesigner/eclipseformat/cli/
│       ├── EclipseFormatCliTest.java    # Unit tests
│       └── IntegrationTest.java         # Integration tests
├── eclipse-format.xml                   # Default formatter config
├── build.gradle                         # Gradle build configuration
├── gradlew                              # Gradle wrapper
└── README.md                            # This file
```

## Examples

### Example 1: Format a Project

```bash
# Format all Java files in your project
eclipse-format -r src/main/java/

# With custom configuration
eclipse-format -c company-style.xml -r src/
```

### Example 2: Preview Changes

```bash
# See what files would be formatted
eclipse-format -d -r src/

# Output:
# [DRY RUN] Would format: src/main/java/com/example/Main.java
# [DRY RUN] Would format: src/main/java/com/example/Util.java
```

### Example 3: CI/CD Integration

```bash
# Check if code is properly formatted (exit code 0 if formatted, 1 if not)
eclipse-format -d -r src/ && echo "Code is properly formatted"
```

## Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests "EclipseFormatterCliTest"

# Run integration tests
./gradlew test --tests "IntegrationTest"

# Generate test coverage report
./gradlew jacocoTestReport
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Style

Please ensure your code follows the project's formatting rules:
```bash
# Format your code before submitting
./gradlew run --args="src/main/java/"
```

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Uninstalling

Easy removal with the uninstall script:

```bash
# Interactive uninstall (recommended)
./uninstall.sh

# Remove everything
./uninstall.sh --all

# Clean up PATH entries
./uninstall.sh --clean-path
```

See [USAGE.md](USAGE.md) for complete uninstall options.

## Support

- 📖 **Documentation**: [README.md](README.md) and [USAGE.md](USAGE.md)
- 🐛 **Issues**: Report installation or usage issues
- 🔧 **Uninstall**: Use `./uninstall.sh` for clean removal

## Acknowledgments

- Built with [Picocli](https://picocli.info/) for CLI parsing
- Uses Eclipse's Java Development Tools for formatting
- Inspired by the need for consistent code formatting in CI/CD pipelines

---

Made with ❤️ by [Vlad Shurupov](https://github.com/algodesigner) for clean code everywhere
