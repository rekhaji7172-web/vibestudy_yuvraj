import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final decks = provider.decks;
        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.deepNavy,
                title: Text(
                  'Flashcards',
                  style: TextStyle(
                    
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              if (decks.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.style_outlined,
                    title: 'No decks yet',
                    subtitle: 'Create your first flashcard deck\nto start studying!',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx2, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _DeckCard(deck: decks[i], provider: provider),
                      ).animate(delay: (i * 60).ms).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
                      childCount: decks.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateDeck(context, provider),
            backgroundColor: AppColors.mintGreen,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'New Deck',
              style: TextStyle( color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  void _showCreateDeck(BuildContext context, AppProvider provider) {
    final uuid = const Uuid();
    final titleCtrl = TextEditingController();
    String subject = 'General';
    String color = '#10B981';
    final List<Map<String, String>> cards = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModal) {
          void addCard() {
            final frontCtrl = TextEditingController();
            final backCtrl = TextEditingController();
            showDialog(
              context: ctx2,
              builder: (dCtx) => AlertDialog(
                backgroundColor: AppColors.navySurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Add Card', style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: frontCtrl,
                      style: const TextStyle( color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: 'Front (question)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: backCtrl,
                      style: const TextStyle( color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: 'Back (answer)'),
                      maxLines: 2,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dCtx),
                    child: const Text('Cancel', style: TextStyle( color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      if (frontCtrl.text.isNotEmpty && backCtrl.text.isNotEmpty) {
                        setModal(() {
                          cards.add({'front': frontCtrl.text, 'back': backCtrl.text});
                        });
                        Navigator.pop(dCtx);
                      }
                    },
                    child: const Text('Add', style: TextStyle( color: AppColors.mintGreen, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }

          return Container(
            height: MediaQuery.of(ctx2).size.height * 0.9,
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
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle( color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text('Create Flashcard Deck',
                        style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleCtrl,
                        style: const TextStyle( color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Deck title...', prefixIcon: Icon(Icons.style_rounded, color: AppColors.textMuted)),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        style: const TextStyle( color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Subject...', prefixIcon: Icon(Icons.school_rounded, color: AppColors.textMuted)),
                        onChanged: (v) => subject = v.isEmpty ? 'General' : v,
                      ),
                      const SizedBox(height: 16),
                      const Text('Color', style: TextStyle( color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 10),
                      SubjectColorPicker(selected: color, onChanged: (c) => setModal(() => color = c)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cards (${cards.length})',
                            style: const TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                          GestureDetector(
                            onTap: addCard,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.mintGreen.withOpacity(0.4)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add_rounded, color: AppColors.mintGreen, size: 16),
                                  SizedBox(width: 4),
                                  Text('Add Card', style: TextStyle( color: AppColors.mintGreen, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...cards.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.value['front']!, style: const TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(e.value['back']!, style: const TextStyle( color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setModal(() => cards.removeAt(e.key)),
                                child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          label: 'Create Deck',
                          icon: Icons.check_rounded,
                          gradient: AppColors.greenGradient,
                          onTap: () {
                            if (titleCtrl.text.isNotEmpty && cards.isNotEmpty) {
                              final deck = FlashcardDeck(
                                id: uuid.v4(),
                                title: titleCtrl.text.trim(),
                                subject: subject,
                                color: color,
                                createdAt: DateTime.now(),
                                cards: cards.map((c) => Flashcard(
                                  id: uuid.v4(),
                                  front: c['front']!,
                                  back: c['back']!,
                                )).toList(),
                              );
                              provider.addDeck(deck);
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
          );
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final FlashcardDeck deck;
  final AppProvider provider;

  const _DeckCard({required this.deck, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.hexToColor(deck.color);
    final mastered = deck.cards.where((c) => c.confidence == 3).length;

    return GlassCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _FlashcardStudyScreen(deck: deck, provider: provider))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.style_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.title, style: const TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(deck.subject, style: TextStyle( color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => provider.deleteDeck(deck.id),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBit(label: '${deck.cards.length}', sub: 'cards', color: color),
              const SizedBox(width: 20),
              _StatBit(label: '$mastered', sub: 'mastered', color: AppColors.mintGreen),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Study', style: TextStyle( color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          if (deck.cards.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: mastered / deck.cards.length,
                backgroundColor: AppColors.textMuted.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBit extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;

  const _StatBit({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle( color: color, fontWeight: FontWeight.w700, fontSize: 18)),
        Text(sub, style: const TextStyle( color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

// ── Flashcard Study Screen ─────────────────────────────────────
class _FlashcardStudyScreen extends StatefulWidget {
  final FlashcardDeck deck;
  final AppProvider provider;

  const _FlashcardStudyScreen({required this.deck, required this.provider});

  @override
  State<_FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<_FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  bool _flipped = false;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipped) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  void _next(int confidence) {
    widget.provider.updateCardConfidence(widget.deck.id, widget.deck.cards[_index].id, confidence);
    if (_index < widget.deck.cards.length - 1) {
      setState(() {
        _index++;
        _flipped = false;
      });
      _flipCtrl.reset();
    } else {
      _showComplete();
    }
  }

  void _showComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.navySurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Deck Complete!', style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22)),
              const SizedBox(height: 8),
              Text('You studied all ${widget.deck.cards.length} cards.', textAlign: TextAlign.center, style: const TextStyle( color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() { _index = 0; _flipped = false; });
                        _flipCtrl.reset();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(12)),
                        child: const Text('Restart', textAlign: TextAlign.center, style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Done',
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.deck.cards[_index];
    final deckColor = AppUtils.hexToColor(widget.deck.color);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: Text(widget.deck.title),
        backgroundColor: AppColors.deepNavy,
        leading: const BackButton(color: AppColors.textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_index + 1} / ${widget.deck.cards.length}',
                style: const TextStyle( color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_index + 1) / widget.deck.cards.length,
                backgroundColor: AppColors.cardSurface,
                valueColor: AlwaysStoppedAnimation<Color>(deckColor),
                minHeight: 6,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _flip,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (_, __) {
                    final angle = _flipAnim.value * 3.14159;
                    final showBack = _flipAnim.value > 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: showBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _buildCardFace(card.back, deckColor, false),
                            )
                          : _buildCardFace(card.front, deckColor, true),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_flipped)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                children: [
                  const Text('How well did you know this?',
                    style: TextStyle( color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ConfidenceBtn(label: 'Hard', color: AppColors.roseAccent, onTap: () => _next(1)),
                      const SizedBox(width: 8),
                      _ConfidenceBtn(label: 'Okay', color: AppColors.amberAccent, onTap: () => _next(2)),
                      const SizedBox(width: 8),
                      _ConfidenceBtn(label: 'Easy', color: AppColors.mintGreen, onTap: () => _next(3)),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Text('Tap card to reveal answer',
                style: const TextStyle( color: AppColors.textMuted, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildCardFace(String text, Color color, bool isFront) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFront
              ? [AppColors.cardSurface, AppColors.cardElevated]
              : [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isFront ? Colors.white.withOpacity(0.06) : color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFront ? 'QUESTION' : 'ANSWER',
            style: TextStyle(
              
              color: isFront ? AppColors.textMuted : color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ConfidenceBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle( color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ),
    );
  }
}
