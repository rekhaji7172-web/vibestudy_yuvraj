import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final notes = provider.notes
            .where((n) =>
                _search.isEmpty ||
                n.title.toLowerCase().contains(_search.toLowerCase()) ||
                n.subject.toLowerCase().contains(_search.toLowerCase()))
            .toList()
          ..sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });

        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.deepNavy,
                title: const Text(
                  'Notes',
                  style: TextStyle(
                    
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      style: const TextStyle( color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        suffixIcon: _search.isNotEmpty
                            ? GestureDetector(
                                onTap: () => setState(() => _search = ''),
                                child: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                ),
              ),
              if (notes.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.note_alt_outlined,
                    title: _search.isNotEmpty ? 'No results found' : 'No notes yet',
                    subtitle: _search.isNotEmpty
                        ? 'Try a different search term.'
                        : 'Tap + to create your first note.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx2, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NoteCard(
                          note: notes[i],
                          provider: provider,
                        ),
                      ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
                      childCount: notes.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showNoteEditor(context, provider, null),
            backgroundColor: AppColors.indigoPrimary,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'New Note',
              style: TextStyle(
                
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNoteEditor(BuildContext context, AppProvider provider, NoteModel? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    String subject = existing?.subject ?? 'General';
    String color = existing?.subjectColor ?? '#6366F1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModal) => Container(
          height: MediaQuery.of(ctx2).size.height * 0.9,
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.navySurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle + Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel',
                          style: TextStyle( color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 4),
                    GradientButton(
                      label: existing != null ? 'Update' : 'Save',
                      isSmall: true,
                      onTap: () {
                        if (titleCtrl.text.isNotEmpty) {
                          if (existing != null) {
                            provider.updateNote(existing.id, titleCtrl.text.trim(), contentCtrl.text.trim());
                          } else {
                            provider.addNote(titleCtrl.text.trim(), contentCtrl.text.trim(), subject, color);
                          }
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(
                        
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Note title...',
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle( color: AppColors.textPrimary, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Subject...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.indigoPrimary),
                              ),
                              filled: true,
                              fillColor: AppColors.cardSurface,
                            ),
                            onChanged: (v) => subject = v.isEmpty ? 'General' : v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SubjectColorPicker(
                      selected: color,
                      onChanged: (c) => setModal(() => color = c),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: AppColors.textMuted.withOpacity(0.15),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentCtrl,
                      style: const TextStyle(
                        
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Start writing your note...',
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final AppProvider provider;

  const _NoteCard({required this.note, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.hexToColor(note.subjectColor);
    return GlassCard(
      onTap: () => _showNoteDetail(context, note, provider),
      border: Border(left: BorderSide(color: color, width: 3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  note.subject,
                  style: TextStyle(
                    
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (note.isPinned)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.push_pin_rounded, size: 15, color: AppColors.amberAccent),
                ),
              GestureDetector(
                onTap: () => _showOptions(context, note, provider),
                child: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note.title,
            style: const TextStyle(
              
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppUtils.timeAgo(note.updatedAt),
            style: const TextStyle(
              
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteDetail(BuildContext context, NoteModel note, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.navySurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppUtils.hexToColor(note.subjectColor).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorDot(hex: note.subjectColor),
                        const SizedBox(width: 6),
                        Text(
                          note.subject,
                          style: TextStyle(
                            
                            color: AppUtils.hexToColor(note.subjectColor),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note.title,
                    style: const TextStyle(
                      
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated ${AppUtils.formatDate(note.updatedAt)}',
                    style: const TextStyle(
                      
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: AppColors.textMuted.withOpacity(0.15)),
                  const SizedBox(height: 20),
                  Text(
                    note.content,
                    style: const TextStyle(
                      
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, NoteModel note, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                color: AppColors.amberAccent,
              ),
              title: Text(
                note.isPinned ? 'Unpin' : 'Pin Note',
                style: const TextStyle( color: AppColors.textPrimary),
              ),
              onTap: () {
                provider.togglePinNote(note.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.roseAccent),
              title: const Text(
                'Delete',
                style: TextStyle( color: AppColors.roseAccent),
              ),
              onTap: () {
                provider.deleteNote(note.id);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
