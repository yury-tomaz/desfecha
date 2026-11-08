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
        if (!isJavadoc(source, i)) {
          addBlockLines(comments, line, source.substring(i + 2, end));
        }
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

  private static boolean isJavadoc(String source, int start) {
    return source.startsWith("/**", start) && !source.startsWith("/**/", start);
  }

  private static void addBlockLines(List<Comment> comments, int firstLine, String body) {
    String[] bodyLines = body.split("\n", -1);
    for (int offset = 0; offset < bodyLines.length; offset++) {
      String text = bodyLines[offset].replaceFirst("\\*/$", "").replaceFirst("^\\s*\\*", "");
      comments.add(new Comment(firstLine + offset, text));
    }
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
