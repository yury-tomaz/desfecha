package com.desfecha.sensores;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

final class CommentedCodeDetector {

  private static final Pattern CODE = Pattern.compile("^(.*[;{}]|@\\w+(\\(.*\\))?)$");

  private CommentedCodeDetector() {}

  static List<Integer> lines(String source) {
    List<Integer> found = new ArrayList<>();
    for (Comment comment : comments(source)) {
      if (CODE.matcher(comment.text().strip()).matches()) {
        found.add(comment.line());
      }
    }
    return found;
  }

  private record Comment(int line, String text) {}

  private static List<Comment> comments(String source) {
    List<Comment> comments = new ArrayList<>();
    int i = 0;
    while (i < source.length()) {
      i = readToken(source, i, comments);
    }
    return comments;
  }

  private static int readToken(String source, int start, List<Comment> comments) {
    if (source.startsWith("//", start)) {
      int end = endOfLine(source, start);
      comments.add(new Comment(lineAt(source, start), source.substring(start + 2, end)));
      return end;
    }
    if (source.startsWith("/*", start)) {
      int end = endOf(source, start + 2, "*/");
      if (!isJavadoc(source, start)) {
        addBlockLines(comments, lineAt(source, start), source.substring(start + 2, end));
      }
      return end;
    }
    if (source.startsWith("\"\"\"", start)) {
      return endOfQuoted(source, start + 3, "\"\"\"");
    }
    char c = source.charAt(start);
    if (c == '"' || c == '\'') {
      return endOfQuoted(source, start + 1, String.valueOf(c));
    }
    return start + 1;
  }

  private static int lineAt(String source, int index) {
    return (int) source.substring(0, index).chars().filter(c -> c == '\n').count() + 1;
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
}
