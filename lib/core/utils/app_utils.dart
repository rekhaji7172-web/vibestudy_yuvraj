import 'package:flutter/material.dart';
import 'dart:math';

class AppUtils {
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String getRandomQuote() {
    final quotes = [
      'Small steps every day add up to massive results.',
      'The secret of getting ahead is getting started.',
      'Focus on progress, not perfection.',
      'Your future self will thank you.',
      'Every expert was once a beginner.',
    ];
    return quotes[Random().nextInt(quotes.length)];
  }

  static int getLevelFromXP(int xp) {
    return (xp / 500).floor() + 1;
  }

  static double getLevelProgress(int xp) {
    return (xp % 500) / 500.0;
  }

  static String getLevelTitle(int level) {
    if (level < 3) return 'Novice';
    if (level < 6) return 'Learner';
    if (level < 10) return 'Scholar';
    if (level < 15) return 'Expert';
    if (level < 20) return 'Master';
    return 'Legend';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
