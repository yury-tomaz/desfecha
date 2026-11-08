package com.desfecha.sensores;

import java.util.ArrayList;
import java.util.List;

final class CommentedCodeDetector {

  private CommentedCodeDetector() {}

  static List<Integer> lines(String source) {
    List<Integer> found = new ArrayList<>();
    for (Comment comment : comments(source)) {
      if (comment.text().strip().endsWith(";")) {
        found.add(comment.line());
      }
    }
    return found;
  }

  private record Comment(int line, String text) {}

  private static List<Comment> comments(String source) {
    List<Comment> comments = new ArrayList<>();
    int line = 1;
    int i = 0;
    while (i < source.length()) {
      char c = source.charAt(i);
      if (source.startsWith("//", i)) {
        int end = endOfLine(source, i);
        comments.add(new Comment(line, source.substring(i + 2, end)));
        i = end;
      } else if (source.startsWith("/*", i)) {
        int end = endOf(source, i + 2, "*/");
        line += count(source, i, end, '\n');
        i = end;
      } else if (source.startsWith("\"\"\"", i)) {
        int end = endOfQuoted(source, i + 3, "\"\"\"");
        line += count(source, i, end, '\n');
        i = end;
      } else if (c == '"' || c == '\'') {
        i = endOfQuoted(source, i + 1, String.valueOf(c));
      } else {
        if (c == '\n') {
          line++;
        }
        i++;
      }
    }
    return comments;
  }

  private static int endOfLine(String source, int from) {
    int end = source.indexOf('\n', from);
    return end < 0 ? source.length() : end;
  }

  private static int endOf(String source, int from, String terminator) {
    int end = source.indexOf(terminator, from);
    return end < 0 ? source.length() : end + terminator.length();
  }

  private static int endOfQuoted(String source, int from, String quote) {
    int i = from;
    while (i < source.length() && !source.startsWith(quote, i)) {
      i += source.charAt(i) == '\\' ? 2 : 1;
    }
    return Math.min(i + quote.length(), source.length());
  }

  private static int count(String source, int from, int to, char wanted) {
    int n = 0;
    for (int i = from; i < to; i++) {
      if (source.charAt(i) == wanted) {
        n++;
      }
    }
    return n;
  }
}
