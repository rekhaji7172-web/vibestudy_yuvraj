import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';

class AppProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  late SharedPreferences _prefs;
  bool _initialized = false;

  // ─── State ────────────────────────────────────────────────
  UserModel _user = const UserModel(name: 'Student');
  List<NoteModel> _notes = [];
  List<FlashcardDeck> _decks = [];
  List<TaskModel> _tasks = [];
  List<MindMapModel> _mindMaps = [];
  List<FocusSession> _sessions = [];
  int _selectedNavIndex = 0;

  // ─── Getters ──────────────────────────────────────────────
  UserModel get user => _user;
  List<NoteModel> get notes => _notes;
  List<FlashcardDeck> get decks => _decks;
  List<TaskModel> get tasks => _tasks;
  List<MindMapModel> get mindMaps => _mindMaps;
  List<FocusSession> get sessions => _sessions;
  int get selectedNavIndex => _selectedNavIndex;
  bool get initialized => _initialized;

  int get level => AppUtils.getLevelFromXP(_user.xp);
  double get levelProgress => AppUtils.getLevelProgress(_user.xp);
  String get levelTitle => AppUtils.getLevelTitle(level);

  List<TaskModel> get todayTasks => _tasks.where((t) {
    return AppUtils.isSameDay(t.dueDate, DateTime.now());
  }).toList();

  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  int get totalFocusToday {
    final today = DateTime.now();
    return _sessions
        .where((s) => AppUtils.isSameDay(s.date, today))
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  // ─── Init ─────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAll();
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadAll() async {
    // User
    final userJson = _prefs.getString(AppConstants.keyUserName);
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
        _updateStreak();
      } catch (_) {}
    }
    // Notes
    final notesJson = _prefs.getStringList(AppConstants.keyNotes) ?? [];
    _notes = notesJson.map((n) {
      try {
        return NoteModel.fromJson(jsonDecode(n));
      } catch (_) {
        return null;
      }
    }).whereType<NoteModel>().toList();
    // Decks
    final decksJson = _prefs.getStringList(AppConstants.keyFlashcards) ?? [];
    _decks = decksJson.map((d) {
      try {
        return FlashcardDeck.fromJson(jsonDecode(d));
      } catch (_) {
        return null;
      }
    }).whereType<FlashcardDeck>().toList();
    // Tasks
    final tasksJson = _prefs.getStringList(AppConstants.keyTasks) ?? [];
    _tasks = tasksJson.map((t) {
      try {
        return TaskModel.fromJson(jsonDecode(t));
      } catch (_) {
        return null;
      }
    }).whereType<TaskModel>().toList();
    // Mind Maps
    final mapsJson = _prefs.getStringList(AppConstants.keyMindMaps) ?? [];
    _mindMaps = mapsJson.map((m) {
      try {
        return MindMapModel.fromJson(jsonDecode(m));
      } catch (_) {
        return null;
      }
    }).whereType<MindMapModel>().toList();
    // Sessions (stored in prefs as simple list)
    final sessionsJson = _prefs.getStringList('focus_sessions') ?? [];
    _sessions = sessionsJson.map((s) {
      try {
        return FocusSession.fromJson(jsonDecode(s));
      } catch (_) {
        return null;
      }
    }).whereType<FocusSession>().toList();

    // Seed demo data if first run
    if (_notes.isEmpty && _decks.isEmpty && _tasks.isEmpty) {
      await _seedDemoData();
    }
  }

  void _updateStreak() {
    if (_user.lastStudyDate == null) return;
    final diff = DateTime.now().difference(_user.lastStudyDate!).inDays;
    if (diff > 1) {
      _user = _user.copyWith(streak: 0);
      _saveUser();
    }
  }

  Future<void> _seedDemoData() async {
    final now = DateTime.now();
    // Demo notes
    _notes = [
      NoteModel(
        id: _uuid.v4(),
        title: 'Quantum Mechanics Intro',
        content: 'Wave-particle duality is the concept that every particle exhibits the properties of not only particles, but also waves. The double-slit experiment demonstrates this beautifully.',
        subjectColor: '#6366F1',
        subject: 'Physics',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isPinned: true,
      ),
      NoteModel(
        id: _uuid.v4(),
        title: 'Calculus: Limits & Derivatives',
        content: 'A limit is the value that a function approaches as the input approaches some value. The derivative measures the rate of change of a function.',
        subjectColor: '#22D3EE',
        subject: 'Mathematics',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      NoteModel(
        id: _uuid.v4(),
        title: 'Organic Chemistry Reactions',
        content: 'Nucleophilic substitution reactions (SN1 and SN2) are fundamental to organic chemistry. SN2 is a concerted mechanism with inversion of stereochemistry.',
        subjectColor: '#10B981',
        subject: 'Chemistry',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
    ];
    // Demo decks
    _decks = [
      FlashcardDeck(
        id: _uuid.v4(),
        title: 'Physics Formulas',
        subject: 'Physics',
        color: '#6366F1',
        createdAt: now.subtract(const Duration(days: 3)),
        cards: [
          Flashcard(id: _uuid.v4(), front: "Newton's 2nd Law", back: "F = ma (Force = mass × acceleration)"),
          Flashcard(id: _uuid.v4(), front: "Kinetic Energy", back: "KE = ½mv² (half × mass × velocity²)"),
          Flashcard(id: _uuid.v4(), front: "Ohm's Law", back: "V = IR (Voltage = Current × Resistance)"),
        ],
      ),
      FlashcardDeck(
        id: _uuid.v4(),
        title: 'Calculus Concepts',
        subject: 'Mathematics',
        color: '#22D3EE',
        createdAt: now.subtract(const Duration(days: 1)),
        cards: [
          Flashcard(id: _uuid.v4(), front: "Power Rule", back: "d/dx(xⁿ) = nxⁿ⁻¹"),
          Flashcard(id: _uuid.v4(), front: "Chain Rule", back: "d/dx[f(g(x))] = f'(g(x)) × g'(x)"),
        ],
      ),
    ];
    // Demo tasks
    _tasks = [
      TaskModel(
        id: _uuid.v4(),
        title: 'Complete Physics Problem Set',
        subject: 'Physics',
        color: '#6366F1',
        dueDate: now,
        priority: 3,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Review Calculus Chapter 4',
        subject: 'Mathematics',
        color: '#22D3EE',
        dueDate: now,
        priority: 2,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Chemistry Lab Report',
        subject: 'Chemistry',
        color: '#10B981',
        dueDate: now.add(const Duration(days: 2)),
        priority: 3,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'History Essay Draft',
        subject: 'History',
        color: '#F59E0B',
        dueDate: now.add(const Duration(days: 4)),
        priority: 1,
      ),
    ];
    // Demo mind map
    _mindMaps = [
      MindMapModel(
        id: _uuid.v4(),
        title: 'Newton\'s Laws of Motion',
        color: '#6366F1',
        createdAt: now.subtract(const Duration(days: 1)),
        root: MindMapNode(
          id: _uuid.v4(),
          text: 'Newton\'s Laws',
          children: [
            MindMapNode(id: _uuid.v4(), text: '1st Law\nInertia', children: [
              MindMapNode(id: _uuid.v4(), text: 'Objects at rest stay at rest'),
            ]),
            MindMapNode(id: _uuid.v4(), text: '2nd Law\nF = ma', children: [
              MindMapNode(id: _uuid.v4(), text: 'Force & Acceleration'),
            ]),
            MindMapNode(id: _uuid.v4(), text: '3rd Law\nAction-Reaction', children: [
              MindMapNode(id: _uuid.v4(), text: 'Equal opposite forces'),
            ]),
          ],
        ),
      ),
    ];
    // Demo user
    _user = const UserModel(name: 'Alex', xp: 320, streak: 3, totalFocusMinutes: 150, badges: ['first_session', 'note_taker']);
    await _saveAll();
  }

  Future<void> _saveAll() async {
    await _saveUser();
    await _saveNotes();
    await _saveDecks();
    await _saveTasks();
    await _saveMindMaps();
    await _saveSessions();
  }

  Future<void> _saveUser() async {
    await _prefs.setString(AppConstants.keyUserName, jsonEncode(_user.toJson()));
  }

  Future<void> _saveNotes() async {
    await _prefs.setStringList(AppConstants.keyNotes,
        _notes.map((n) => jsonEncode(n.toJson())).toList());
  }

  Future<void> _saveDecks() async {
    await _prefs.setStringList(AppConstants.keyFlashcards,
        _decks.map((d) => jsonEncode(d.toJson())).toList());
  }

  Future<void> _saveTasks() async {
    await _prefs.setStringList(AppConstants.keyTasks,
        _tasks.map((t) => jsonEncode(t.toJson())).toList());
  }

  Future<void> _saveMindMaps() async {
    await _prefs.setStringList(AppConstants.keyMindMaps,
        _mindMaps.map((m) => jsonEncode(m.toJson())).toList());
  }

  Future<void> _saveSessions() async {
    await _prefs.setStringList('focus_sessions',
        _sessions.map((s) => jsonEncode(s.toJson())).toList());
  }

  // ─── Navigation ───────────────────────────────────────────
  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  // ─── User ─────────────────────────────────────────────────
  Future<void> setUserName(String name) async {
    _user = _user.copyWith(name: name);
    await _saveUser();
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    final newXP = _user.xp + amount;
    _user = _user.copyWith(xp: newXP);
    await _saveUser();
    notifyListeners();
  }

  Future<void> recordStudySession(int durationMinutes, String subject) async {
    final session = FocusSession(
      id: _uuid.v4(),
      durationMinutes: durationMinutes,
      date: DateTime.now(),
      subject: subject,
    );
    _sessions.insert(0, session);
    if (_sessions.length > 100) _sessions = _sessions.sublist(0, 100);

    final lastDate = _user.lastStudyDate;
    int newStreak = _user.streak;
    if (lastDate == null || !AppUtils.isSameDay(lastDate, DateTime.now())) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      if (lastDate != null && AppUtils.isSameDay(lastDate, yesterday)) {
        newStreak++;
      } else if (lastDate == null) {
        newStreak = 1;
      } else {
        newStreak = 1;
      }
    }

    _user = _user.copyWith(
      xp: _user.xp + AppConstants.xpPerFocusSession,
      streak: newStreak,
      lastStudyDate: DateTime.now(),
      totalFocusMinutes: _user.totalFocusMinutes + durationMinutes,
    );
    await _saveUser();
    await _saveSessions();
    notifyListeners();
  }

  // ─── Notes ────────────────────────────────────────────────
  Future<void> addNote(String title, String content, String subject, String color) async {
    final note = NoteModel(
      id: _uuid.v4(),
      title: title,
      content: content,
      subject: subject,
      subjectColor: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, note);
    await addXP(AppConstants.xpPerNote);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(String id, String title, String content) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notes[idx] = _notes[idx].copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> togglePinNote(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notes[idx] = _notes[idx].copyWith(isPinned: !_notes[idx].isPinned);
      await _saveNotes();
      notifyListeners();
    }
  }

  // ─── Flashcards ───────────────────────────────────────────
  Future<void> addDeck(FlashcardDeck deck) async {
    _decks.insert(0, deck);
    await addXP(AppConstants.xpPerFlashcard * deck.cards.length);
    await _saveDecks();
    notifyListeners();
  }

  Future<void> deleteDeck(String id) async {
    _decks.removeWhere((d) => d.id == id);
    await _saveDecks();
    notifyListeners();
  }

  Future<void> updateCardConfidence(String deckId, String cardId, int confidence) async {
    final deckIdx = _decks.indexWhere((d) => d.id == deckId);
    if (deckIdx >= 0) {
      final cardIdx = _decks[deckIdx].cards.indexWhere((c) => c.id == cardId);
      if (cardIdx >= 0) {
        _decks[deckIdx].cards[cardIdx].confidence = confidence;
        await _saveDecks();
        notifyListeners();
      }
    }
  }

  // ─── Tasks ────────────────────────────────────────────────
  Future<void> addTask(TaskModel task) async {
    _tasks.insert(0, task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
      if (_tasks[idx].isCompleted) {
        await addXP(AppConstants.xpPerTask);
      }
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();
    notifyListeners();
  }

  // ─── Mind Maps ────────────────────────────────────────────
  Future<void> addMindMap(MindMapModel map) async {
    _mindMaps.insert(0, map);
    await _saveMindMaps();
    notifyListeners();
  }

  Future<void> deleteMindMap(String id) async {
    _mindMaps.removeWhere((m) => m.id == id);
    await _saveMindMaps();
    notifyListeners();
  }
}
