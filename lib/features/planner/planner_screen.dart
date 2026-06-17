import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final _uuid = const Uuid();
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final tasks = provider.tasks
            .where((t) => _showCompleted || !t.isCompleted)
            .toList();
        final completed = provider.tasks.where((t) => t.isCompleted).length;
        final total = provider.tasks.length;

        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, provider, completed, total),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: _buildProgressCard(completed, total),
                ).animate().fadeIn(duration: 400.ms),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      const Text(
                        'Show completed',
                        style: TextStyle(
                          
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showCompleted,
                        onChanged: (v) => setState(() => _showCompleted = v),
                        activeColor: AppColors.indigoPrimary,
                        inactiveTrackColor: AppColors.cardSurface,
                      ),
                    ],
                  ),
                ),
              ),
              if (tasks.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.task_alt_rounded,
                    title: 'All clear!',
                    subtitle: _showCompleted
                        ? 'No tasks yet. Tap + to add one.'
                        : 'No pending tasks.\nYou\'re crushing it! 🎉',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx2, i) {
                        final task = tasks[i];
                        return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.roseAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.roseAccent, size: 26),
                          ),
                          onDismissed: (_) => provider.deleteTask(task.id),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TaskCard(task: task, provider: provider),
                          ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
                        );
                      },
                      childCount: tasks.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTaskSheet(context, provider),
            backgroundColor: AppColors.indigoPrimary,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Task',
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

  SliverAppBar _buildAppBar(
      BuildContext context, AppProvider provider, int completed, int total) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.deepNavy,
      title: const Text(
        'Study Planner',
        style: TextStyle(
          
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            '$completed/$total done',
            style: const TextStyle(
              
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(int completed, int total) {
    final ratio = total == 0 ? 0.0 : completed / total;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                '${(ratio * 100).round()}%',
                style: const TextStyle(
                  
                  color: AppColors.mintGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.textMuted.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completed of $total tasks completed',
            style: const TextStyle(
              
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, AppProvider provider) {
    final titleCtrl = TextEditingController();
    String selectedSubject = 'General';
    String selectedColor = '#6366F1';
    int selectedPriority = 2;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx2).viewInsets.bottom + 30),
            decoration: const BoxDecoration(
              color: AppColors.navySurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'New Task',
                  style: TextStyle(
                    
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle( color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Task title...',
                    prefixIcon: Icon(Icons.task_alt_rounded, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle( color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Subject (e.g. Physics)',
                    prefixIcon: Icon(Icons.school_rounded, color: AppColors.textMuted),
                  ),
                  onChanged: (v) => selectedSubject = v.isEmpty ? 'General' : v,
                ),
                const SizedBox(height: 16),
                const Text('Color', style: TextStyle( color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                SubjectColorPicker(
                  selected: selectedColor,
                  onChanged: (c) => setModalState(() => selectedColor = c),
                ),
                const SizedBox(height: 16),
                const Text('Priority', style: TextStyle( color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [1, 2, 3].map((p) {
                    final labels = {1: 'Low', 2: 'Medium', 3: 'High'};
                    final colors = {
                      1: AppColors.mintGreen,
                      2: AppColors.amberAccent,
                      3: AppColors.roseAccent,
                    };
                    final isSelected = selectedPriority == p;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedPriority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors[p]!.withOpacity(0.2)
                              : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? colors[p]! : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          labels[p]!,
                          style: TextStyle(
                            
                            color: isSelected ? colors[p]! : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Add Task',
                    icon: Icons.add_rounded,
                    onTap: () {
                      if (titleCtrl.text.isNotEmpty) {
                        provider.addTask(TaskModel(
                          id: _uuid.v4(),
                          title: titleCtrl.text.trim(),
                          subject: selectedSubject,
                          color: selectedColor,
                          dueDate: selectedDate,
                          priority: selectedPriority,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final AppProvider provider;

  const _TaskCard({required this.task, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.hexToColor(task.color);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => provider.toggleTask(task.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.isCompleted ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? color : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
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
                    
                    color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ColorDot(hex: task.color, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      task.subject,
                      style: const TextStyle(
                        
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      AppUtils.formatDate(task.dueDate),
                      style: const TextStyle(
                        
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
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
