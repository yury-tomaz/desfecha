package com.desfecha.sensores;

import java.util.ArrayList;
import java.util.List;

final class CommentedCodeDetector {

  private CommentedCodeDetector() {}

  static List<Integer> lines(String source) {
    List<Integer> found = new ArrayList<>();
    String[] sourceLines = source.split("\n", -1);
    for (int i = 0; i < sourceLines.length; i++) {
      int start = sourceLines[i].indexOf("//");
      if (start >= 0 && sourceLines[i].substring(start + 2).strip().endsWith(";")) {
        found.add(i + 1);
      }
    }
    return found;
  }
}
