package com.algodesigner.eclipseformat.cli;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

/**
 * Unit tests for the {@link EclipseFormatCli} class.
 * <p>
 * Tests cover command-line argument parsing, file validation, and basic
 * CLI functionality.
 *
 *
 * @author Vlad Shurupov
 * @version 0.1
 * @since 0.1
 */
class EclipseFormatCliTest {

  @TempDir
  Path tempDir;

  @Test
  void testIsJavaFile() throws IOException {
    Path configFile = tempDir.resolve("formatter.xml");
    Files.writeString(configFile,
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><profiles></profiles>");

    FormatterService service = new FormatterService(configFile.toFile(), false);

    assertTrue(service.isJavaFile(new File("Test.java")));
    assertTrue(service.isJavaFile(new File("Test.JAVA")));
    assertTrue(service.isJavaFile(new File("Test.Java")));
    assertFalse(service.isJavaFile(new File("Test.txt")));
    assertFalse(service.isJavaFile(new File("Test.class")));
    assertFalse(service.isJavaFile(new File("Test")));
  }

  @Test
  void testFormatterServiceCreation() {
    assertDoesNotThrow(() -> {
      Path configFile = tempDir.resolve("formatter.xml");
      Files.writeString(configFile,
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?><profiles></profiles>");

      FormatterService service =
        new FormatterService(configFile.toFile(), false);
      assertNotNull(service);
    });
  }

  @Test
  void testFormatterServiceCreationMissingConfig() {
    File missingFile = new File("missing-config.xml");
    assertThrows(IOException.class,
      () -> new FormatterService(missingFile, false));
  }

  @ParameterizedTest
  @ValueSource(strings =
  { "Test.java", "Main.java", "Example.JAVA" })
  void testFormatFileNonJavaFile(String filename) throws IOException {
    Path configFile = tempDir.resolve("formatter.xml");
    Files.writeString(configFile,
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><profiles></profiles>");

    FormatterService service = new FormatterService(configFile.toFile(), false);

    Path textFile = tempDir.resolve("test.txt");
    Files.writeString(textFile, "Not a Java file");

    boolean result = service.formatFile(textFile.toFile());
    assertFalse(result);
  }

  @Test
  void testCliHelp() {
    String[] args = { "--help" };
    int exitCode =
      new picocli.CommandLine(new EclipseFormatCli()).execute(args);
    assertEquals(0, exitCode);
  }

  @Test
  void testCliVersion() {
    String[] args = { "--version" };
    int exitCode =
      new picocli.CommandLine(new EclipseFormatCli()).execute(args);
    assertEquals(0, exitCode);
  }

  @Test
  void testCliMissingTarget() {
    String[] args = {};
    int exitCode =
      new picocli.CommandLine(new EclipseFormatCli()).execute(args);
    assertEquals(2, exitCode);
  }

  @Test
  void testCliNonExistentTarget() {
    String[] args = { "nonexistent-file.java" };
    int exitCode =
      new picocli.CommandLine(new EclipseFormatCli()).execute(args);
    assertEquals(1, exitCode);
  }
}
