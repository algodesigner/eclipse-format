#!/bin/bash

set -e

echo "Building Eclipse Formatter CLI..."

# Download gradle wrapper if needed
if [ ! -f "gradle/wrapper/gradle-wrapper.jar" ]; then
    echo "Downloading Gradle wrapper..."
    mkdir -p gradle/wrapper
    curl -L -o gradle/wrapper/gradle-wrapper.jar https://repo.maven.apache.org/maven2/org/gradle/wrapper/gradle-wrapper/8.5/gradle-wrapper-8.5.jar
fi

# Make gradlew executable
chmod +x gradlew

# Build the project
./gradlew build

# Create executable JAR
./gradlew shadowJar

echo ""
echo "Build complete!"
echo "Executable JAR: build/libs/eclipse-format.jar"
echo ""
echo "Usage:"
echo "  java -jar build/libs/eclipse-format.jar --help"
echo "  chmod +x build/libs/eclipse-format.jar"
echo "  ./build/libs/eclipse-format.jar --help"