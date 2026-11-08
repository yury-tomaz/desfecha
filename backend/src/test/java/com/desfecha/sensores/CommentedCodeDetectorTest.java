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
}
