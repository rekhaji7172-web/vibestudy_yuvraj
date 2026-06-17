import 'dart:convert';

// ─── User Model ───────────────────────────────────────────────
class UserModel {
  final String name;
  final int xp;
  final int streak;
  final DateTime? lastStudyDate;
  final int totalFocusMinutes;
  final List<String> badges;

  const UserModel({
    required this.name,
    this.xp = 0,
    this.streak = 0,
    this.lastStudyDate,
    this.totalFocusMinutes = 0,
    this.badges = const [],
  });

  UserModel copyWith({
    String? name,
    int? xp,
    int? streak,
    DateTime? lastStudyDate,
    int? totalFocusMinutes,
    List<String>? badges,
  }) {
    return UserModel(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      badges: badges ?? this.badges,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'xp': xp,
    'streak': streak,
    'lastStudyDate': lastStudyDate?.toIso8601String(),
    'totalFocusMinutes': totalFocusMinutes,
    'badges': badges,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'] ?? 'Student',
    xp: json['xp'] ?? 0,
    streak: json['streak'] ?? 0,
    lastStudyDate: json['lastStudyDate'] != null
        ? DateTime.parse(json['lastStudyDate'])
        : null,
    totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
    badges: List<String>.from(json['badges'] ?? []),
  );
}

// ─── Note Model ───────────────────────────────────────────────
class NoteModel {
  final String id;
  final String title;
  final String content;
  final String subjectColor;
  final String subject;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.subjectColor,
    required this.subject,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  NoteModel copyWith({
    String? title,
    String? content,
    String? subjectColor,
    String? subject,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      subjectColor: subjectColor ?? this.subjectColor,
      subject: subject ?? this.subject,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'subjectColor': subjectColor,
    'subject': subject,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isPinned': isPinned,
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    subjectColor: json['subjectColor'] ?? '#6366F1',
    subject: json['subject'] ?? 'General',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    isPinned: json['isPinned'] ?? false,
  );
}

// ─── Flashcard Model ──────────────────────────────────────────
class FlashcardDeck {
  final String id;
  final String title;
  final String subject;
  final String color;
  final List<Flashcard> cards;
  final DateTime createdAt;

  const FlashcardDeck({
    required this.id,
    required this.title,
    required this.subject,
    required this.color,
    required this.cards,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'color': color,
    'cards': cards.map((c) => c.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) => FlashcardDeck(
    id: json['id'],
    title: json['title'],
    subject: json['subject'],
    color: json['color'] ?? '#6366F1',
    cards: (json['cards'] as List)
        .map((c) => Flashcard.fromJson(c))
        .toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class Flashcard {
  final String id;
  final String front;
  final String back;
  int confidence; // 0=new, 1=hard, 2=medium, 3=easy

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.confidence = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'front': front,
    'back': back,
    'confidence': confidence,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    front: json['front'],
    back: json['back'],
    confidence: json['confidence'] ?? 0,
  );
}

// ─── Task Model ───────────────────────────────────────────────
class TaskModel {
  final String id;
  final String title;
  final String subject;
  final String color;
  final DateTime dueDate;
  bool isCompleted;
  final int priority; // 1=low, 2=medium, 3=high

  TaskModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.color,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 2,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'color': color,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
    'priority': priority,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    title: json['title'],
    subject: json['subject'],
    color: json['color'] ?? '#6366F1',
    dueDate: DateTime.parse(json['dueDate']),
    isCompleted: json['isCompleted'] ?? false,
    priority: json['priority'] ?? 2,
  );
}

// ─── Mind Map Model ───────────────────────────────────────────
class MindMapModel {
  final String id;
  final String title;
  final String color;
  final MindMapNode root;
  final DateTime createdAt;

  const MindMapModel({
    required this.id,
    required this.title,
    required this.color,
    required this.root,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'color': color,
    'root': root.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory MindMapModel.fromJson(Map<String, dynamic> json) => MindMapModel(
    id: json['id'],
    title: json['title'],
    color: json['color'] ?? '#6366F1',
    root: MindMapNode.fromJson(json['root']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class MindMapNode {
  final String id;
  final String text;
  final List<MindMapNode> children;

  const MindMapNode({
    required this.id,
    required this.text,
    this.children = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'children': children.map((c) => c.toJson()).toList(),
  };

  factory MindMapNode.fromJson(Map<String, dynamic> json) => MindMapNode(
    id: json['id'],
    text: json['text'],
    children: (json['children'] as List? ?? [])
        .map((c) => MindMapNode.fromJson(c))
        .toList(),
  );
}

// ─── Focus Session Model ──────────────────────────────────────
class FocusSession {
  final String id;
  final int durationMinutes;
  final DateTime date;
  final String subject;

  const FocusSession({
    required this.id,
    required this.durationMinutes,
    required this.date,
    required this.subject,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'durationMinutes': durationMinutes,
    'date': date.toIso8601String(),
    'subject': subject,
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    id: json['id'],
    durationMinutes: json['durationMinutes'],
    date: DateTime.parse(json['date']),
    subject: json['subject'],
  );
}
