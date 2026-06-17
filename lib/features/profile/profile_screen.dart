import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final user = provider.user;
        final level = provider.level;
        final progress = provider.levelProgress;
        final title = AppUtils.getLevelTitle(level);

        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Profile ──────────────────────────
              SliverToBoxAdapter(
                child: _ProfileHero(user: user, level: level, progress: progress, title: title, provider: provider)
                    .animate().fadeIn(duration: 500.ms),
              ),
              // ── Achievement Badges ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: SectionHeader(title: 'Achievements 🏅'),
                ).animate(delay: 100.ms).fadeIn(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _BadgesGrid(userBadges: user.badges),
                ).animate(delay: 150.ms).fadeIn(),
              ),
              // ── Stats Grid ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: SectionHeader(title: 'Your Stats'),
                ).animate(delay: 200.ms).fadeIn(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _StatsGrid(provider: provider),
                ).animate(delay: 250.ms).fadeIn(),
              ),
              // ── Rewards ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: SectionHeader(title: 'Rewards & Goals 🎯'),
                ).animate(delay: 300.ms).fadeIn(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx2, i) {
                      final rewards = _getRewards(provider);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RewardCard(reward: rewards[i], userXP: user.xp),
                      ).animate(delay: (300 + i * 60).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
                    },
                    childCount: _getRewards(provider).length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getRewards(AppProvider provider) {
    return [
      {'title': 'First Focus', 'desc': 'Complete your first 25-min session', 'xp': 50, 'icon': '🎯', 'required': 50},
      {'title': 'Note Taker', 'desc': 'Write 5 notes', 'xp': 100, 'icon': '📝', 'required': 100},
      {'title': 'Card Master', 'desc': 'Create a flashcard deck', 'xp': 150, 'icon': '🃏', 'required': 150},
      {'title': 'Week Warrior', 'desc': 'Study for 7 days in a row', 'xp': 300, 'icon': '🔥', 'required': 300},
      {'title': 'Scholar', 'desc': 'Reach Level 5', 'xp': 500, 'icon': '🎓', 'required': 500},
      {'title': 'Focus Machine', 'desc': 'Complete 20 focus sessions', 'xp': 1000, 'icon': '⚡', 'required': 1000},
      {'title': 'Legend', 'desc': 'Reach Level 10', 'xp': 2500, 'icon': '👑', 'required': 2500},
    ];
  }
}

class _ProfileHero extends StatelessWidget {
  final dynamic user;
  final int level;
  final double progress;
  final String title;
  final AppProvider provider;

  const _ProfileHero({
    required this.user,
    required this.level,
    required this.progress,
    required this.title,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigoPrimary.withOpacity(0.2), AppColors.deepNavy],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.indigoPrimary.withOpacity(0.4), blurRadius: 24)],
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                    style: const TextStyle( color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: AppColors.amberAccent.withOpacity(0.4), blurRadius: 8)],
                ),
                child: Text(
                  'Lv.$level',
                  style: const TextStyle( color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Name (editable)
          GestureDetector(
            onTap: () => _editName(context, provider, user.name),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user.name,
                  style: const TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
                const SizedBox(width: 8),
                const Icon(Icons.edit_rounded, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.indigoPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.indigoPrimary.withOpacity(0.3)),
            ),
            child: Text(title,
              style: const TextStyle( color: AppColors.indigoPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: XPBar(xp: user.xp, level: level, progress: progress),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroStat(icon: Icons.local_fire_department_rounded, value: '${user.streak}', label: 'Streak', color: AppColors.orangeAccent),
              const SizedBox(width: 20),
              _HeroStat(icon: Icons.star_rounded, value: '${user.xp}', label: 'Total XP', color: AppColors.amberAccent),
              const SizedBox(width: 20),
              _HeroStat(icon: Icons.timer_rounded, value: AppUtils.formatMinutes(user.totalFocusMinutes), label: 'Focused', color: AppColors.electricBlue),
            ],
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, AppProvider provider, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navySurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name', style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle( color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Your name...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle( color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                provider.setUserName(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle( color: AppColors.indigoPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HeroStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle( color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        Text(label, style: const TextStyle( color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  final List<String> userBadges;

  const _BadgesGrid({required this.userBadges});

  @override
  Widget build(BuildContext context) {
    final allBadges = [
      {'id': 'first_session', 'emoji': '🎯', 'name': 'First Focus'},
      {'id': 'note_taker', 'emoji': '📝', 'name': 'Note Taker'},
      {'id': 'card_master', 'emoji': '🃏', 'name': 'Card Master'},
      {'id': 'week_warrior', 'emoji': '🔥', 'name': 'Warrior'},
      {'id': 'scholar', 'emoji': '🎓', 'name': 'Scholar'},
      {'id': 'legend', 'emoji': '👑', 'name': 'Legend'},
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: allBadges.map((badge) {
        final earned = userBadges.contains(badge['id']);
        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                badge['emoji']!,
                style: TextStyle(
                  fontSize: 28,
                  color: earned ? null : Colors.transparent,
                ),
              ),
              if (!earned)
                const Icon(Icons.lock_rounded, size: 28, color: AppColors.textMuted),
              const SizedBox(height: 6),
              Text(
                badge['name']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  
                  color: earned ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AppProvider provider;

  const _StatsGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Notes Created', 'value': '${provider.notes.length}', 'icon': Icons.note_alt_rounded, 'color': AppColors.purpleAccent},
      {'label': 'Card Decks', 'value': '${provider.decks.length}', 'icon': Icons.style_rounded, 'color': AppColors.mintGreen},
      {'label': 'Tasks Done', 'value': '${provider.tasks.where((t) => t.isCompleted).length}', 'icon': Icons.task_alt_rounded, 'color': AppColors.electricBlue},
      {'label': 'Mind Maps', 'value': '${provider.mindMaps.length}', 'icon': Icons.account_tree_rounded, 'color': AppColors.amberAccent},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: stats.map((s) {
        final color = s['color'] as Color;
        return GlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(s['icon'] as IconData, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s['value'] as String, style: TextStyle( color: color, fontWeight: FontWeight.w800, fontSize: 22)),
                  Text(s['label'] as String, style: const TextStyle( color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Map<String, dynamic> reward;
  final int userXP;

  const _RewardCard({required this.reward, required this.userXP});

  @override
  Widget build(BuildContext context) {
    final requiredXP = reward['required'] as int;
    final unlocked = userXP >= requiredXP;
    final progress = (userXP / requiredXP).clamp(0.0, 1.0);

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: unlocked ? AppColors.amberAccent.withOpacity(0.15) : AppColors.cardElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: unlocked
                  ? Text(reward['icon'] as String, style: const TextStyle(fontSize: 24))
                  : const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward['title'] as String,
                  style: TextStyle( color: unlocked ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(reward['desc'] as String,
                  style: const TextStyle( color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.cardElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(unlocked ? AppColors.amberAccent : AppColors.indigoPrimary),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (unlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('✓ Done', style: TextStyle( color: AppColors.mintGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                )
              else
                Text('${requiredXP} XP', style: const TextStyle( color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
