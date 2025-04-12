import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';

// Special effect wrapper for Legendary/Mythical Pokémon
class LegendaryMythicalEffectWidget extends StatelessWidget {
  final Widget child;
  final PokemonDetailsViewModel viewModel;
  final PokemonTypeTheme theme;

  const LegendaryMythicalEffectWidget({
    super.key,
    required this.child,
    required this.viewModel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Early return if species isn't loaded yet or Pokémon is not legendary/mythical
    if (viewModel.isLoading ||
        !(viewModel.isLegendary || viewModel.isMythical)) {
      return child;
    }

    // Different effects for legendary vs mythical
    if (viewModel.isLegendary) {
      return LegendaryEffectWidget(
        theme: theme,
        isLegendary: true,
        child: child,
      );
    } else {
      return LegendaryEffectWidget(
        theme: theme,
        isLegendary: false,
        child: child,
      );
    }
  }
}

class LegendaryEffectWidget extends StatefulWidget {
  final Widget child;
  final PokemonTypeTheme theme;
  final bool isLegendary; // false means mythical

  const LegendaryEffectWidget({
    super.key,
    required this.child,
    required this.theme,
    required this.isLegendary,
  });

  @override
  State<LegendaryEffectWidget> createState() => _LegendaryEffectWidgetState();
}

class _LegendaryEffectWidgetState extends State<LegendaryEffectWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];
  final int particleCount = 20;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Generate particles based on type (legendary or mythical)
    _generateParticles();

    // Rebuild particles periodically to keep the effect dynamic
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _particles.clear();
          _generateParticles();
        });
      }
    });
  }

  void _generateParticles() {
    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        Particle(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          size: random.nextDouble() * 8 + 2, // Size between 2-10
          speed: random.nextDouble() * 1.5 + 0.5, // Speed between 0.5-2.0
          color: _getParticleColor(),
          shape: random.nextBool() ? ParticleShape.circle : ParticleShape.star,
        ),
      );
    }
  }

  Color _getParticleColor() {
    // Legendary particles are gold/silver, mythical are rainbow/magical
    if (widget.isLegendary) {
      // Gold and silver colors for legendary
      return [
        const Color(0xFFFFD700), // Gold
        const Color(0xFFFCC201),
        const Color(0xFFFFDF00),
        const Color(0xFFC0C0C0), // Silver
        const Color(0xFFE0E0E0),
        widget.theme.primary.withValues(alpha: 200),
      ][random.nextInt(6)];
    } else {
      // Magical/mystical colors for mythical
      return [
        const Color(0xFFFF69B4), // Pink
        const Color(0xFF8A2BE2), // Purple
        const Color(0xFF00BFFF), // Sky blue
        const Color(0xFF7FFFD4), // Aquamarine
        const Color(0xFFFFFFFF), // White sparkles
        widget.theme.primary.withValues(alpha: 200),
      ][random.nextInt(6)];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Special background effect
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.8,
              colors:
                  widget.isLegendary
                      ? [
                        widget.theme.primary.withValues(alpha: 100),
                        Colors.amber.withValues(alpha: 0.1),
                        Colors.white,
                      ]
                      : [
                        widget.theme.primary.withValues(alpha: 100),
                        Colors.purple.withValues(alpha: 0.1),
                        Colors.white,
                      ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
        ),

        // Particles overlay
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animation: _controller.value,
                isLegendary: widget.isLegendary,
              ),
              child: Container(),
            );
          },
        ),

        // Original content
        widget.child,

        // Badge indicator
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              gradient: LinearGradient(
                colors:
                    widget.isLegendary
                        ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
                        : const [Color(0xFF8A2BE2), Color(0xFFFF69B4)],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isLegendary ? Icons.auto_awesome : Icons.auto_fix_high,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.isLegendary ? 'LEGENDARY' : 'MYTHICAL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Particle shape enum
enum ParticleShape { circle, star }

// Particle class to represent each floating element
class Particle {
  Offset position;
  final double size;
  final double speed;
  final Color color;
  final ParticleShape shape;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.color,
    required this.shape,
  });
}

// CustomPainter to draw the particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final bool isLegendary;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.isLegendary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position for animation
      particle.position = Offset(
        particle.position.dx,
        (particle.position.dy - particle.speed) % size.height,
      );

      // Draw the particle
      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill;

      if (particle.shape == ParticleShape.circle) {
        // Draw simple circle
        canvas.drawCircle(particle.position, particle.size, paint);

        // Add glow effect
        final glowPaint =
            Paint()
              ..color = particle.color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
      } else {
        // Draw star shape for legendary/mythical
        drawStar(
          canvas,
          particle.position,
          5,
          particle.size * 2,
          particle.size,
          paint,
        );

        // Add glow effect
        final glowPaint =
            Paint()
              ..color = particle.color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        drawStar(
          canvas,
          particle.position,
          5,
          particle.size * 2.5,
          particle.size * 1.5,
          glowPaint,
        );
      }
    }
  }

  // Helper method to draw a star
  void drawStar(
    Canvas canvas,
    Offset center,
    int points,
    double outerRadius,
    double innerRadius,
    Paint paint,
  ) {
    final path = Path();
    final double rotation = 2 * pi / points / 2;

    for (int i = 0; i < points * 2; i++) {
      double radius = i.isEven ? outerRadius : innerRadius;
      double angle = i * rotation;
      final x = center.dx + radius * cos(angle - pi / 2);
      final y = center.dy + radius * sin(angle - pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
