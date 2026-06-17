import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

class MindMapScreen extends StatelessWidget {
  const MindMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.deepNavy,
                title: Text('Mind Maps',
                  style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
              ),
              if (provider.mindMaps.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.account_tree_outlined,
                    title: 'No mind maps yet',
                    subtitle: 'Create your first mind map\nto visualize your ideas!',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx2, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MindMapCard(map: provider.mindMaps[i], provider: provider),
                      ).animate(delay: (i * 60).ms).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
                      childCount: provider.mindMaps.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateMindMap(context, provider),
            backgroundColor: AppColors.amberAccent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('New Map', style: TextStyle( color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  void _showCreateMindMap(BuildContext context, AppProvider provider) {
    final uuid = const Uuid();
    final titleCtrl = TextEditingController();
    String color = '#F59E0B';
    final rootCtrl = TextEditingController();
    final List<TextEditingController> branchCtrls = [TextEditingController()];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModal) => Container(
          height: MediaQuery.of(ctx2).size.height * 0.88,
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.navySurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Row(
                  children: [
                    Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
                    const Spacer(),
                    TextButton(onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle( color: AppColors.textSecondary))),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    const Text('New Mind Map',
                      style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle( color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: 'Map title...', prefixIcon: Icon(Icons.map_rounded, color: AppColors.textMuted)),
                    ),
                    const SizedBox(height: 14),
                    const Text('Color', style: TextStyle( color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 10),
                    SubjectColorPicker(selected: color, onChanged: (c) => setModal(() => color = c)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: rootCtrl,
                      style: const TextStyle( color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Central topic...',
                        prefixIcon: const Icon(Icons.circle, color: AppColors.amberAccent, size: 14),
                        filled: true,
                        fillColor: AppColors.amberAccent.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.amberAccent.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.amberAccent.withOpacity(0.3))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.amberAccent, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Branches', style: TextStyle( color: AppColors.textSecondary, fontSize: 13)),
                        GestureDetector(
                          onTap: () => setModal(() => branchCtrls.add(TextEditingController())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.amberAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('+ Add', style: TextStyle( color: AppColors.amberAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...branchCtrls.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: e.value,
                              style: const TextStyle( color: AppColors.textPrimary),
                              decoration: InputDecoration(hintText: 'Branch ${e.key + 1}...'),
                            ),
                          ),
                          if (branchCtrls.length > 1) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setModal(() => branchCtrls.removeAt(e.key)),
                              child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                            ),
                          ],
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: 'Create Mind Map',
                        icon: Icons.account_tree_rounded,
                        gradient: AppColors.goldGradient,
                        onTap: () {
                          if (titleCtrl.text.isNotEmpty && rootCtrl.text.isNotEmpty) {
                            final rootNode = MindMapNode(
                              id: uuid.v4(),
                              text: rootCtrl.text.trim(),
                              children: branchCtrls
                                  .where((c) => c.text.isNotEmpty)
                                  .map((c) => MindMapNode(id: uuid.v4(), text: c.text.trim()))
                                  .toList(),
                            );
                            provider.addMindMap(MindMapModel(
                              id: uuid.v4(),
                              title: titleCtrl.text.trim(),
                              color: color,
                              root: rootNode,
                              createdAt: DateTime.now(),
                            ));
                            Navigator.pop(ctx);
                          }
                        },
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

class _MindMapCard extends StatelessWidget {
  final MindMapModel map;
  final AppProvider provider;

  const _MindMapCard({required this.map, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.hexToColor(map.color);
    return GlassCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _MindMapViewer(map: map))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.account_tree_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(map.title, style: const TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('${map.root.children.length} branches', style: const TextStyle( color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => provider.deleteMindMap(map.id),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini preview
          _MindMapPreview(node: map.root, color: color),
        ],
      ),
    );
  }
}

class _MindMapPreview extends StatelessWidget {
  final MindMapNode node;
  final Color color;

  const _MindMapPreview({required this.node, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Root node
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              node.text,
              style: TextStyle( color: color, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          // Branches
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: node.children.take(4).map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(width: 16, height: 1, color: color.withOpacity(0.4)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        child.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle( color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mind Map Viewer ────────────────────────────────────────────
class _MindMapViewer extends StatelessWidget {
  final MindMapModel map;

  const _MindMapViewer({required this.map});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.hexToColor(map.color);
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: Text(map.title),
        backgroundColor: AppColors.deepNavy,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(200),
        minScale: 0.3,
        maxScale: 3.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: _MindMapTree(node: map.root, color: color, isRoot: true),
          ),
        ),
      ),
    );
  }
}

class _MindMapTree extends StatelessWidget {
  final MindMapNode node;
  final Color color;
  final bool isRoot;

  const _MindMapTree({required this.node, required this.color, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Node box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isRoot ? color.withOpacity(0.25) : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRoot ? color : color.withOpacity(0.4),
                  width: isRoot ? 2 : 1,
                ),
                boxShadow: isRoot ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 12)] : null,
              ),
              child: Text(
                node.text,
                style: TextStyle(
                  
                  color: isRoot ? color : AppColors.textPrimary,
                  fontWeight: isRoot ? FontWeight.w700 : FontWeight.w500,
                  fontSize: isRoot ? 16 : 13,
                ),
              ),
            ),
            if (node.children.isNotEmpty) ...[
              // Line to children
              Container(
                margin: const EdgeInsets.only(top: 18),
                width: 24,
                height: 2,
                color: color.withOpacity(0.4),
              ),
              // Children
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: node.children.asMap().entries.map((entry) {
                  final i = entry.key;
                  final child = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: i == 0 ? 0 : 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MindMapTree(node: child, color: color),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
