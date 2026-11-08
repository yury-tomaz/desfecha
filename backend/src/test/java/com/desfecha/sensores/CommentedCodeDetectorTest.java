package com.desfecha.sensores;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class CommentedCodeDetectorTest {

  @Test
  void flagsLineCommentContainingCode() {
    String source =
        """
        class A {
          // int total = soma(a, b);
          int x;
        }
        """;

    assertThat(CommentedCodeDetector.lines(source)).containsExactly(2);
  }

  @Test
  void ignoresProseExplainingWhy() {
    String source =
        """
        class A {
          // O provedor devolve 429 sem Retry-After; esperamos 1 s fixo.
          int x;
        }
        """;

    assertThat(CommentedCodeDetector.lines(source)).isEmpty();
  }

  @Test
  void ignoresSlashesInsideStringLiterals() {
    String source =
        """
        class A {
          String url = "http://exemplo.com/a;";
          String texto = \"""
              // nao e comentario;
              \""";
          char c = '"';
          String depois = "// tambem nao;";
        }
        """;

    assertThat(CommentedCodeDetector.lines(source)).isEmpty();
  }
}
