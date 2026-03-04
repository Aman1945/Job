import 'package:flutter/material.dart';

/// Shared animated detail panel widget used by all master data tables.
/// Shows each field as a bordered rounded-corner card in a responsive grid
/// (3 per row on normal phones, auto-columns on wider screens).
class RowDetailPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> fields;
  final VoidCallback onClose;
  /// Optional accent color for the header icon & card borders. Default: indigo.
  final Color? accentColor;

  const RowDetailPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.fields,
    required this.onClose,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? const Color(0xFF6366F1);

    // No ConstrainedBox here — parent (AnimatedDetailWrapper) controls max height
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 13, color: accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.close, size: 13, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Card grid — scrollable so it never overflows ──
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cols = (width / 110).floor().clamp(3, 6);
                  const spacing = 8.0;
                  final cardWidth = (width - spacing * (cols - 1)) / cols;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: fields.map((f) => _InfoCard(
                        label: f.$1,
                        value: f.$2,
                        width: cardWidth,
                        accentColor: accent,
                      )).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}

/// A single info card — label on top, bold value below, with border.
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final double width;
  final Color accentColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.width,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: accentColor,
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Wraps any table with the animated detail panel.
/// Uses AnimatedSize + ClipRect to morph height from 0 → panel height
/// without overflowing the parent Column.
class AnimatedDetailWrapper extends StatefulWidget {
  final Widget table;
  final Widget? detailPanel;
  final String? selectedKey;

  const AnimatedDetailWrapper({
    super.key,
    required this.table,
    required this.detailPanel,
    required this.selectedKey,
  });

  @override
  State<AnimatedDetailWrapper> createState() => _AnimatedDetailWrapperState();
}

class _AnimatedDetailWrapperState extends State<AnimatedDetailWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  Widget? _currentPanel;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _currentPanel = widget.detailPanel;
    if (_currentPanel != null) _fadeCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedDetailWrapper old) {
    super.didUpdateWidget(old);
    if (widget.selectedKey != old.selectedKey) {
      if (widget.detailPanel != null) {
        _currentPanel = widget.detailPanel;
        _fadeCtrl.forward(from: 0);
      } else {
        _fadeCtrl.reverse().then((_) {
          if (mounted) setState(() => _currentPanel = null);
        });
      }
    } else if (widget.detailPanel != null) {
      _currentPanel = widget.detailPanel;
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Panel gets at most 45% of the ACTUAL available height.
        // Remaining 55%+ is always reserved for the table.
        final maxPanelH = constraints.maxHeight * 0.45;

        return Column(
          children: [
            // Table takes all remaining space via Expanded
            Expanded(child: widget.table),
            // Panel slides in below — height bounded by available space
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _currentPanel == null
                    ? const SizedBox.shrink()
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxPanelH),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: _currentPanel!,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
