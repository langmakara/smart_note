import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  const SkeletonLoader({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.baseColor ?? theme.dividerColor;
    final highlight = widget.highlightColor ?? theme.cardColor;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Container(
          width: widget.width,
          height: widget.height,
          color: base,
        ),
      ),
    );
  }
}

class SkeletonNoteCard extends StatelessWidget {
  const SkeletonNoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.dividerColor;
    final cardColor = theme.cardColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                height: 20,
                width: 20,
                borderRadius: BorderRadius.circular(4),
                baseColor: base,
                highlightColor: cardColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  height: 18,
                  width: double.infinity,
                  baseColor: base,
                  highlightColor: cardColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            height: 14,
            width: double.infinity,
            baseColor: base,
            highlightColor: cardColor,
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            height: 14,
            width: 150,
            baseColor: base,
            highlightColor: cardColor,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                height: 12,
                width: 80,
                baseColor: base,
                highlightColor: cardColor,
              ),
              SkeletonLoader(
                height: 12,
                width: 40,
                baseColor: base,
                highlightColor: cardColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonListView({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: index < itemCount - 1 ? 12 : 0),
        child: SizedBox(height: itemHeight, child: const SkeletonNoteCard()),
      ),
    );
  }
}

class SkeletonButton extends StatelessWidget {
  final double height;
  final double width;

  const SkeletonButton({
    super.key,
    this.height = 48,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.dividerColor;
    final cardColor = theme.cardColor;

    return SkeletonLoader(
      height: height,
      width: width,
      baseColor: base,
      highlightColor: cardColor,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.dividerColor;
    final cardColor = theme.cardColor;

    return SkeletonLoader(
      height: size,
      width: size,
      baseColor: base,
      highlightColor: cardColor,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}
