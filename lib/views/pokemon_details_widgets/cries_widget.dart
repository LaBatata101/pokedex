import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/views/pokemon_details.dart';

class CriesWidget extends StatefulWidget {
  final PokemonCries cries;
  final PokemonTypeTheme theme;

  const CriesWidget(this.cries, this.theme, {super.key});

  @override
  State<StatefulWidget> createState() => _CriesWidgetState();
}

class _CriesWidgetState extends State<CriesWidget> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentlyPlaying;
  bool isPlaying = false;
  final double volume = 1.0;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          currentlyPlaying = null;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playCry(String? url, String cryType) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$cryType cry is not available for this Pokémon'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (isPlaying) {
        await audioPlayer.stop();
      }

      setState(() {
        isPlaying = true;
        currentlyPlaying = cryType;
      });

      HapticFeedback.mediumImpact();

      await audioPlayer.setVolume(volume);
      await audioPlayer.play(UrlSource(url));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing $cryType cry...'),
            duration: const Duration(seconds: 1),
            backgroundColor: widget.theme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          currentlyPlaying = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing sound: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final hasCries = widget.cries.latest != null || widget.cries.legacy != null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Pokémon Cries',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (hasCries) ...[
              if (widget.cries.latest != null)
                _CryButton(
                  label: 'Modern Cry',
                  description: 'Current generation sound',
                  icon: Icons.surround_sound,
                  isPlaying: isPlaying && currentlyPlaying == 'Modern',
                  theme: widget.theme,
                  onTap: () => playCry(widget.cries.latest, 'Modern'),
                ),
              if (widget.cries.latest != null && widget.cries.legacy != null)
                const SizedBox(height: 12),
              if (widget.cries.legacy != null)
                _CryButton(
                  label: 'Legacy Cry',
                  description: 'Classic 8-bit sound',
                  icon: Icons.music_video,
                  isPlaying: isPlaying && currentlyPlaying == 'Legacy',
                  theme: widget.theme,
                  onTap: () => playCry(widget.cries.legacy, 'Legacy'),
                ),
              if (!hasCries)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.volume_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No cry sound available for this Pokémon',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CryButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isPlaying;
  final PokemonTypeTheme theme;
  final VoidCallback onTap;

  const _CryButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.isPlaying,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying ? theme.primary : Colors.grey[300]!,
            width: isPlaying ? 2 : 1,
          ),
          color:
              isPlaying
                  ? theme.primary.withValues(alpha: 0.1)
                  : Colors.grey[100],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying ? theme.primary : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  key: ValueKey<bool>(isPlaying),
                  color: isPlaying ? theme.text : theme.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Cry details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isPlaying ? theme.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Cry type icon
            Icon(
              icon,
              color: isPlaying ? theme.primary : Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
