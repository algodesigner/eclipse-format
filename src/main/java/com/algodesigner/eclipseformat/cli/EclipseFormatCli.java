package com.algodesigner.eclipseformat.cli;

import java.io.File;
import java.util.concurrent.Callable;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

/**
 * Command-line interface for the Eclipse Code Formatter tool.
 *
 * <p>
 * This class provides a CLI interface using Picocli that allows users to format
 * Java source code files using the Eclipse formatter engine with a specified
 * configuration file. The tool can format individual files or entire
 * directories recursively, with options for dry-run mode and verbose output.
 *
 * <p>
 * Example usage:
 * 
 * <pre>
 *   eclipse-format -c config.xml -r src/
 *   eclipse-format -d -v MyClass.java
 *   eclipse-format --help
 * </pre>
 *
 * @author Vlad Shurupov
 * @version 0.1
 * @since 0.1
 * @see FormatterService
 * @see <a href="https://github.com/algodesigner/eclipse-format-cli">Project
 *      Repository</a>
 */
@Command(name = "eclipse-format", description = "Eclipse Code Formatter CLI Tool", mixinStandardHelpOptions = true, version = "0.1", subcommands = {
  CommandLine.HelpCommand.class })
public class EclipseFormatCli implements Callable<Integer> {

  /**
   * Path to the Eclipse formatter configuration file.
   *
   * <p>
   * The configuration file should be in Eclipse XML format containing formatter
   * settings. If not specified, defaults to "eclipse-format.xml" in the current
   * directory.
   */
  @Option(names = { "-c",
    "--config" }, description = "Path to Eclipse formatter configuration file", defaultValue = "eclipse-format.xml")
  private File configFile;

  /**
   * Dry-run mode flag.
   *
   * <p>
   * When enabled, the tool will show what files would be formatted without
   * actually making any changes to the files.
   */
  @Option(names = { "-d",
    "--dry-run" }, description = "Show what would be formatted without making changes")
  private boolean dryRun;

  /**
   * Recursive mode flag.
   * <p>
   * * When enabled and the target is a directory, the tool will format all Java
   * files in the directory and its subdirectories.
   *
   */
  @Option(names = { "-r",
    "--recursive" }, description = "Format files recursively")
  private boolean recursive;

  /**
   * Verbose output flag.
   * <p>
   * * When enabled, the tool will display detailed information about the
   * formatting process, including loaded configuration and file operations.
   *
   */
  @Option(names = { "-v", "--verbose" }, description = "Verbose output")
  private boolean verbose;

  /**
   * Target file or directory to format.
   * <p>
   * * This is a required parameter specifying the file or directory to process.
   * If a directory is specified, only Java files in that directory will be
   * formatted unless the recursive option is also specified.
   *
   */
  @Parameters(index = "0", description = "File or directory to format", arity = "1")
  private File target;

  /**
   * Main execution method called by Picocli when the command is invoked.
   * <p>
   * * This method orchestrates the formatting process by:
   * <ol>
   * <li>Validating the configuration file exists</li>
   * <li>Creating a {@link FormatterService} instance with the
   * configuration</li>
   * <li>Processing the target file or directory</li>
   * <li>Returning an appropriate exit code</li>
   * </ol>
   *
   *
   * @return exit code (0 for success, non-zero for errors)
   * @throws Exception if an unexpected error occurs during processing
   */
  @Override
  public Integer call() throws Exception {
    try {
      if (verbose) {
        System.out.println("Eclipse Formatter CLI v0.1");
        System.out.println("Target: " + target.getAbsolutePath());
        System.out.println("Config: " + configFile.getAbsolutePath());
        System.out.println("Dry run: " + dryRun);
        System.out.println("Recursive: " + recursive);
      }

      if (!target.exists()) {
        System.err
          .println("Error: Target does not exist: " + target.getAbsolutePath());
        return 1;
      }

      if (!configFile.exists()) {
        System.err.println(
          "Error: Config file not found: " + configFile.getAbsolutePath());
        System.err.println(
          "Please create an Eclipse formatter configuration file or specify one with -c");
        return 1;
      }

      FormatterService formatter = new FormatterService(configFile, verbose);

      if (target.isFile()) {
        return formatFile(formatter, target);
      } else {
        return formatDirectory(formatter, target);
      }

    } catch (Exception e) {
      System.err.println("Error: " + e.getMessage());
      if (verbose) {
        e.printStackTrace();
      }
      return 1;
    }
  }

  /**
   * Formats a single Java file using the provided formatter service.
   *
   * @param formatter the formatter service to use for formatting
   * @param file the Java file to format
   * @return 0 if successful, 1 if an error occurred
   */
  private int formatFile(FormatterService formatter, File file) {
    try {
      if (verbose) {
        System.out.println("Formatting file: " + file.getAbsolutePath());
      }

      if (dryRun) {
        // Check if file would be formatted without actually making changes
        boolean wouldFormat = formatter.wouldFormat(file);
        if (wouldFormat) {
          System.out
            .println("[DRY RUN] Would format: " + file.getAbsolutePath());
        } else if (verbose) {
          System.out
            .println("[DRY RUN] No changes needed: " + file.getAbsolutePath());
        }
        return 0;
      }

      boolean changed = formatter.formatFile(file);
      if (changed) {
        System.out.println("Formatted: " + file.getAbsolutePath());
      } else if (verbose) {
        System.out.println("No changes needed: " + file.getAbsolutePath());
      }

      return 0;
    } catch (Exception e) {
      System.err.println(
        "Failed to format " + file.getAbsolutePath() + ": " + e.getMessage());
      return 1;
    }
  }

  /**
   * Formats all Java files in a directory using the provided formatter service.
   * <p>
   * * If recursive mode is enabled, processes subdirectories as well.
   *
   *
   * @param formatter the formatter service to use for formatting
   * @param directory the directory containing Java files to format
   * @return 0 if successful, 1 if an error occurred
   */
  private int formatDirectory(FormatterService formatter, File directory) {
    try {
      if (verbose) {
        System.out
          .println("Formatting directory: " + directory.getAbsolutePath());
      }

      int result = formatter.formatDirectory(directory, recursive, dryRun);

      if (dryRun && result == 0) {
        System.out.println("[DRY RUN] No files would be formatted");
      }

      return result;
    } catch (Exception e) {
      System.err.println("Failed to format directory "
        + directory.getAbsolutePath() + ": " + e.getMessage());
      return 1;
    }
  }

  /**
   * Main entry point for the Eclipse Format CLI application.
   * <p>
   * * This method parses command-line arguments using Picocli and executes the
   * appropriate command. The exit code is propagated to the system.
   *
   *
   * @param args command-line arguments
   */
  public static void main(String[] args) {
    int exitCode = new CommandLine(new EclipseFormatCli()).execute(args);
    System.exit(exitCode);
  }
}
