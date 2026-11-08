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

  @Test
  void flagsEachCodeLineInsideBlockComment() {
    String source =
        """
        class A {
          /*
           * Explica o motivo.
           * int total = 0;
           */
          /* return total; */
        }
        """;

    assertThat(CommentedCodeDetector.lines(source)).containsExactly(4, 6);
  }

  @Test
  void ignoresJavadocExamples() {
    String source =
        """
        /**
         * Exemplo de uso:
         * <pre>{@code var a = A.of(1);}</pre>
         */
        class A {}
        """;

    assertThat(CommentedCodeDetector.lines(source)).isEmpty();
  }

  @Test
  void flagsBlockDelimitersAndAnnotations() {
    String source =
        """
        class A {
          // @Test
          // void antigo() {
          // }
          // Ver RFC 9110 (seção 15.5.20) {exemplo}.
        }
        """;

    assertThat(CommentedCodeDetector.lines(source)).containsExactly(2, 3, 4);
  }
}
