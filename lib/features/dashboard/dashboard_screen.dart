import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.user;
        final level = provider.level;
        final progress = provider.levelProgress;
        final todayTasks = provider.todayTasks;
        final focusToday = provider.totalFocusToday;

        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Header ──────────────────────────────
              SliverToBoxAdapter(
                child: _HeroHeader(user: user, level: level, progress: progress)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.1, end: 0),
              ),
              // ── Quick Stats ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _QuickStats(
                    streak: user.streak,
                    focusMinutes: focusToday,
                    totalNotes: provider.notes.length,
                    xp: user.xp,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              ),
              // ── Daily Quote ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _QuoteCard(),
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
              ),
              // ── Today's Tasks ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SectionHeader(
                    title: "Today's Plan",
                    action: 'See all',
                    onAction: () => provider.setNavIndex(1),
                  ),
                ).animate(delay: 200.ms).fadeIn(),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final task = todayTasks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TaskTile(task: task, provider: provider),
                      ).animate(delay: (200 + i * 60).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
                    },
                    childCount: todayTasks.length > 4 ? 4 : todayTasks.length,
                  ),
                ),
              ),
              if (todayTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.mintGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.check_circle_outline, color: AppColors.mintGreen, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'No tasks for today.\nAdd some in the Planner!',
                              style: TextStyle(
                                
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // ── Quick Actions ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: SectionHeader(title: 'Quick Actions'),
                ).animate(delay: 300.ms).fadeIn(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _QuickActions(provider: provider),
                ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
              ),
              // ── Recent Notes ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SectionHeader(
                    title: 'Recent Notes',
                    action: 'See all',
                    onAction: () => provider.setNavIndex(3),
                  ),
                ).animate(delay: 400.ms).fadeIn(),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 150,
                  child: provider.notes.isEmpty
                      ? const Center(
                          child: Text(
                            'No notes yet',
                            style: TextStyle(
                              
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.notes.length > 5
                              ? 5
                              : provider.notes.length,
                          itemBuilder: (ctx, i) {
                            final note = provider.notes[i];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: _NotePreviewCard(note: note),
                            ).animate(delay: (400 + i * 60).ms).fadeIn();
                          },
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

// ── Hero Header ────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final dynamic user;
  final int level;
  final double progress;

  const _HeroHeader({
    required this.user,
    required this.level,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF0A0E1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppUtils.getGreeting() + ' 👋',
                    style: const TextStyle(
                      
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.name,
                    style: const TextStyle(
                      
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.indigoPrimary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppUtils.getLevelTitle(level),
                        style: const TextStyle(
                          
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${user.xp} total XP',
                      style: const TextStyle(
                        
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                XPBar(xp: user.xp, level: level, progress: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats ────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  final int streak;
  final int focusMinutes;
  final int totalNotes;
  final int xp;

  const _QuickStats({
    required this.streak,
    required this.focusMinutes,
    required this.totalNotes,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatChip(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: 'Day streak',
            color: AppColors.orangeAccent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatChip(
            icon: Icons.timer_rounded,
            value: AppUtils.formatMinutes(focusMinutes),
            label: 'Focus today',
            color: AppColors.electricBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatChip(
            icon: Icons.note_alt_rounded,
            value: '$totalNotes',
            label: 'Notes',
            color: AppColors.purpleAccent,
          ),
        ),
      ],
    );
  }
}

// ── Daily Quote Card ───────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final String _quote = AppUtils.getRandomQuote();

  _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.indigoPrimary.withOpacity(0.2),
            AppColors.purpleAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.indigoPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _quote,
              style: const TextStyle(
                
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task Tile ─────────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final dynamic task;
  final AppProvider provider;

  const _TaskTile({required this.task, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.hexToColor(task.color);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => provider.toggleTask(task.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? color : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    
                    color: task.isCompleted
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.subject,
                  style: TextStyle(
                    
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PriorityBadge(priority: task.priority),
        ],
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final AppProvider provider;

  const _QuickActions({required this.provider});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.timer_rounded, 'label': 'Focus', 'color': AppColors.electricBlue, 'index': 2},
      {'icon': Icons.note_add_rounded, 'label': 'Note', 'color': AppColors.purpleAccent, 'index': 3},
      {'icon': Icons.style_rounded, 'label': 'Cards', 'color': AppColors.mintGreen, 'index': 4},
      {'icon': Icons.map_rounded, 'label': 'Mind Map', 'color': AppColors.amberAccent, 'index': 7},
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () => provider.setNavIndex(a['index'] as int),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (a['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a['label'] as String,
                      style: const TextStyle(
                        
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Note Preview Card ─────────────────────────────────────────
class _NotePreviewCard extends StatelessWidget {
  final dynamic note;

  const _NotePreviewCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.hexToColor(note.subjectColor);
    return SizedBox(
      width: 180,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ColorDot(hex: note.subjectColor),
                const SizedBox(width: 8),
                Text(
                  note.subject,
                  style: TextStyle(
                    
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (note.isPinned) ...[
                  const Spacer(),
                  const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.amberAccent),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
