package com.desfecha.sensores;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;

class NoCommentedCodeTest {

  @Test
  void sourceHasNoCommentedCode() throws IOException {
    List<String> problems = new ArrayList<>();
    try (Stream<Path> files = Files.walk(Path.of("src"))) {
      for (Path file : files.filter(f -> f.toString().endsWith(".java")).toList()) {
        for (int line : CommentedCodeDetector.lines(Files.readString(file))) {
          problems.add(
              "Código comentado em backend/%s:%d. Apague: o histórico fica no git."
                  .formatted(file, line));
        }
      }
    }

    assertThat(problems).as(String.join("\n", problems)).isEmpty();
  }
}
