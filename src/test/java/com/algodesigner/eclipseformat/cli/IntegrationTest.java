package com.algodesigner.eclipseformat.cli;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

/**
 * Integration tests for the Eclipse Format CLI tool.
 * <p>
 * Tests cover end-to-end functionality including file formatting,
 * directory processing, and CLI integration with the formatter service.
 *
 *
 * @author Vlad Shurupov
 * @version 0.1
 * @since 0.1
 */
class IntegrationTest {

  @TempDir
  Path tempDir;

  private Path configFile;
  private Path sampleJavaFile;

  @BeforeEach
  void setUp() throws IOException {
    configFile = tempDir.resolve("eclipse-format.xml");
    Files.copy(Paths.get("eclipse-format.xml"), configFile);

    sampleJavaFile = tempDir.resolve("Sample.java");
    Files.writeString(sampleJavaFile,
      "public class Sample {\n" + "  public static void main(String[] args) {\n"
        + "    System.out.println(\"Hello World\");\n" + "  }\n" + "}\n");
  }

  @Test
  void testFormatSingleFile() throws IOException {
    FormatterService service = new FormatterService(configFile.toFile(), false);

    boolean changed = service.formatFile(sampleJavaFile.toFile());
    assertFalse(changed, "Well-formatted code should not change");

    String contentAfter = Files.readString(sampleJavaFile);
    assertThat(contentAfter).contains("public class Sample");
  }

  @Test
  void testFormatDirectoryDryRun() throws IOException {
    Path subDir = tempDir.resolve("src");
    Files.createDirectory(subDir);

    Path javaFile1 = subDir.resolve("File1.java");
    Files.writeString(javaFile1, "public class File1{}");

    Path javaFile2 = subDir.resolve("File2.java");
    Files.writeString(javaFile2, "public class File2{}");

    FormatterService service = new FormatterService(configFile.toFile(), true);

    int result = service.formatDirectory(subDir.toFile(), true, true);
    assertEquals(0, result, "Dry run should succeed");
  }

  @Test
  void testFormatDirectoryRecursive() throws IOException {
    Path subDir = tempDir.resolve("src/main/java");
    Files.createDirectories(subDir);

    Path javaFile = subDir.resolve("Main.java");
    Files.writeString(javaFile,
      "public class Main{public static void main(String[] args){System.out.println(\"test\");}}");

    FormatterService service = new FormatterService(configFile.toFile(), false);

    int result = service.formatDirectory(tempDir.toFile(), true, false);
    assertEquals(0, result, "Formatting should succeed");

    String formattedContent = Files.readString(javaFile);
    assertThat(formattedContent).contains("public class Main");
  }

  @Test
  void testCliWithValidFile() throws IOException {
    String[] args =
      { "-c", configFile.toString(), "-v", sampleJavaFile.toString() };

    int exitCode =
      new picocli.CommandLine(new EclipseFormatCli()).execute(args);
    assertEquals(0, exitCode, "CLI should succeed with valid file");
  }

  @Test
  void testCliWithDirectory() throws IOException {
    Path srcDir = tempDir.resolve("src");
    Files.createDirectory(srcDir);

    Path javaFile = srcDir.resolve("Test.java");
    Files.writeString(javaFile, "public class Test{}");

    String[] args = { "-c", configFile.toString(), "-r", srcDir.toString() };

    int exitCode =
      new picocli.CommandLine(new EclipseFormatCli()).execute(args);
    assertEquals(0, exitCode, "CLI should succeed with directory");
  }

  @Test
  void testCliDryRun() throws IOException {
    String[] args =
      { "-c", configFile.toString(), "-d", "-v", sampleJavaFile.toString() };

    int exitCode =
      new picocli.CommandLine(new EclipseFormatCli()).execute(args);
    assertEquals(0, exitCode, "CLI dry run should succeed");
  }
}
