package com.algodesigner.eclipseformat.cli;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Stream;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.eclipse.jdt.core.ToolFactory;
import org.eclipse.jdt.core.formatter.CodeFormatter;
import org.eclipse.text.edits.TextEdit;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * Service class that provides Java source code formatting using the Eclipse
 * formatter engine.
 *
 * <p>
 * This class encapsulates the logic for:
 * <ul>
 * <li>Loading Eclipse formatter configuration from XML files</li>
 * <li>Initializing the Eclipse {@link CodeFormatter} with the loaded
 * settings</li>
 * <li>Formatting individual Java files or entire directories</li>
 * <li>Applying formatting changes to source code</li>
 * </ul>
 * The formatter produces output identical to the Eclipse IDE when using the
 * same configuration file.
 *
 * @author Vlad Shurupov
 * @version 0.1
 * @since 0.1
 * @see CodeFormatter
 * @see EclipseFormatCli
 */
public class FormatterService {
  /**
   * Map of formatter settings loaded from the configuration file.
   * <p>
   * * The map contains key-value pairs where keys are Eclipse formatter setting
   * IDs and values are the corresponding setting values.
   *
   */
  private final Map<String, String> formatterSettings;

  /**
   * Verbose output flag.
   */
  private final boolean verbose;

  /**
   * Eclipse code formatter instance initialised with the loaded settings.
   */
  private CodeFormatter codeFormatter;

  /**
   * Constructs a new FormatterService with the specified configuration file.
   * <p>
   * * The constructor loads and parses the Eclipse formatter configuration XML
   * file, initialises the Eclipse code formatter with those settings, and
   * prepares the service for formatting operations.
   *
   *
   * @param configFile the Eclipse formatter configuration XML file
   * @param verbose if true, enables verbose output
   * @throws IOException if the configuration file cannot be read or parsed
   * @throws IllegalArgumentException if the configuration file is invalid
   */
  public FormatterService(File configFile, boolean verbose) throws IOException {
    this.verbose = verbose;
    this.formatterSettings = new HashMap<>();

    try {
      DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
      DocumentBuilder builder = factory.newDocumentBuilder();
      org.w3c.dom.Document document = builder.parse(configFile);

      NodeList settingNodes = document.getElementsByTagName("setting");
      for (int i = 0; i < settingNodes.getLength(); i++) {
        Element setting = (Element)settingNodes.item(i);
        String id = setting.getAttribute("id");
        String value = setting.getAttribute("value");
        formatterSettings.put(id, value);
      }

      // Initialize Eclipse code formatter with the loaded settings
      Map<String, String> options = new HashMap<>();
      for (Map.Entry<String, String> entry : formatterSettings.entrySet()) {
        options.put(entry.getKey(), entry.getValue());
      }

      // Set default options if not present
      options.putIfAbsent(
        org.eclipse.jdt.core.formatter.DefaultCodeFormatterConstants.FORMATTER_TAB_CHAR,
        org.eclipse.jdt.core.formatter.DefaultCodeFormatterConstants.MIXED);
      options.putIfAbsent(
        org.eclipse.jdt.core.formatter.DefaultCodeFormatterConstants.FORMATTER_TAB_SIZE,
        "4");
      options.putIfAbsent(
        org.eclipse.jdt.core.formatter.DefaultCodeFormatterConstants.FORMATTER_INDENTATION_SIZE,
        "4");

      this.codeFormatter =
        ToolFactory.createCodeFormatter(options, ToolFactory.M_FORMAT_EXISTING);

    } catch (Exception e) {
      throw new IOException(
        "Failed to parse Eclipse formatter configuration: " + e.getMessage(),
        e);
    }

    if (verbose) {
      System.out.println("Loaded Eclipse formatter configuration from "
        + configFile.getAbsolutePath());
      System.out
        .println("Loaded " + formatterSettings.size() + " formatter settings");
    }
  }

  /**
   * Formats a single Java file using the Eclipse formatter.
   * <p>
   * * Reads the file content, formats it using the Eclipse formatter, and
   * writes the formatted content back to the file if changes were made.
   *
   *
   * @param file the Java file to format
   * @return true if the file was modified, false if no changes were needed
   * @throws IOException if the file cannot be read or written
   * @throws IllegalArgumentException if the file is not a Java file
   */
  public boolean formatFile(File file) throws IOException {
    if (!isJavaFile(file)) {
      if (verbose) {
        System.out.println("Skipping non-Java file: " + file.getAbsolutePath());
      }
      return false;
    }

    String originalContent = Files.readString(file.toPath());
    String formattedContent = formatJavaCode(originalContent);

    if (!originalContent.equals(formattedContent)) {
      Files.writeString(file.toPath(), formattedContent);
      return true;
    } else if (verbose) {
      System.out
        .println("No formatting changes for: " + file.getAbsolutePath());
    }

    return false;
  }

  /**
   * Checks if a file would be formatted without actually making changes.
   * <p>
   * * This method performs the same formatting logic as {@link #formatFile(File)}
   * but only checks if the formatted content differs from the original without
   * writing any changes to disk.
   *
   * @param file the Java source file to check
   * @return true if the file would be formatted (content differs), false otherwise
   * @throws IOException if the file cannot be read
   * @throws IllegalArgumentException if the file is not a Java file
   */
  public boolean wouldFormat(File file) throws IOException {
    if (!isJavaFile(file)) {
      return false;
    }

    String originalContent = Files.readString(file.toPath());
    String formattedContent = formatJavaCode(originalContent);

    return !originalContent.equals(formattedContent);
  }

  /**
   * Formats all Java files in a directory.
   * <p>
   * * Recursively processes Java files in the specified directory and its
   * subdirectories if the recursive flag is set. In dry-run mode, only reports
   * what would be formatted without making changes.
   *
   *
   * @param directory the directory to process
   * @param recursive if true, processes subdirectories recursively
   * @param dryRun if true, only reports what would be formatted without making
   *        changes
   * @return 0 if successful, 1 if errors occurred during formatting
   * @throws IOException if directory access fails
   */
  public int formatDirectory(File directory, boolean recursive, boolean dryRun)
    throws IOException
  {
    int formattedCount = 0;
    int errorCount = 0;

    try (Stream<Path> paths =
      Files.walk(directory.toPath(), recursive ? Integer.MAX_VALUE : 1))
    {
      for (Path path : paths.toArray(Path[]::new)) {
        File file = path.toFile();
        if (file.isFile() && isJavaFile(file)) {
          try {
            if (dryRun) {
              boolean wouldFormat = wouldFormat(file);
              if (wouldFormat) {
                System.out
                  .println("[DRY RUN] Would format: " + file.getAbsolutePath());
                formattedCount++;
              } else if (verbose) {
                System.out.println(
                  "[DRY RUN] No changes needed: " + file.getAbsolutePath());
              }
            } else {
              boolean changed = formatFile(file);
              if (changed) {
                formattedCount++;
              }
            }
          } catch (Exception e) {
            System.err.println("Error formatting " + file.getAbsolutePath()
              + ": " + e.getMessage());
            errorCount++;
          }
        }
      }
    }

    if (verbose) {
      System.out.println("Formatted " + formattedCount + " files"
        + (dryRun ? " (dry run)" : ""));
      if (errorCount > 0) {
        System.out.println("Encountered " + errorCount + " errors");
      }
    }

    return errorCount > 0 ? 1 : 0;
  }

  /**
   * Formats Java source code using the Eclipse formatter.
   * <p>
   * * Applies Eclipse formatting rules to the provided Java source code string.
   * If formatting fails (e.g., due to syntax errors), the original code is
   * returned unchanged.
   *
   *
   * @param javaCode the Java source code to format
   * @return the formatted Java source code, or the original if formatting fails
   */
  private String formatJavaCode(String javaCode) {
    if (javaCode == null || javaCode.trim().isEmpty()) {
      return javaCode;
    }

    try {
      // Use the Eclipse code formatter
      TextEdit edit =
        codeFormatter.format(CodeFormatter.K_COMPILATION_UNIT, javaCode, 0,
          javaCode.length(), 0, System.getProperty("line.separator", "\n"));

      if (edit == null) {
        // Formatter returned null (e.g., syntax error)
        return javaCode;
      }

      // Apply the text edit to get formatted code
      org.eclipse.jface.text.Document document =
        new org.eclipse.jface.text.Document(javaCode);
      edit.apply(document);
      return document.get();

    } catch (Exception e) {
      // If formatting fails, return original code
      if (verbose) {
        System.err.println("Formatting error: " + e.getMessage());
      }
      return javaCode;
    }
  }

  /**
   * Returns a copy of the loaded formatter settings.
   * <p>
   * * The returned map contains all formatter settings loaded from the
   * configuration file, including any default values that were added.
   *
   *
   * @return a copy of the formatter settings map
   */
  public Map<String, String> getFormatterSettings() {
    return new HashMap<>(formatterSettings);
  }

  /**
   * Checks if a file is a Java source file based on its extension.
   * <p>
   * * The check is case-insensitive and recognises files ending with ".java".
   *
   *
   * @param file the file to check
   * @return true if the file has a ".java" extension, false otherwise
   */
  boolean isJavaFile(File file) {
    String name = file.getName().toLowerCase();
    return name.endsWith(".java");
  }
}
