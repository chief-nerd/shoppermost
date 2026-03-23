import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth/auth_cubit.dart';
import '../cubit/shopping/shopping_cubit.dart';
import '../cubit/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> _channels = [];
  String? _selectedChannelId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    final cubit = context.read<ShoppingCubit>();
    final channels = await cubit.getChannels();
    setState(() {
      _channels = channels;
      _selectedChannelId = cubit.channelId;
      _loading = false;
    });
  }

  Future<void> _onChannelSelected(String? channelId) async {
    if (channelId == null) return;
    setState(() => _selectedChannelId = channelId);
    await context.read<ShoppingCubit>().setChannel(channelId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // ── Shopping channel section ──────────────────────────
                _SectionHeader(
                  icon: Icons.forum_outlined,
                  title: 'Shopping Channel',
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedChannelId,
                          decoration: const InputDecoration(
                            hintText: 'Select a channel',
                          ),
                          items: _channels.map((channel) {
                            final displayName =
                                channel['display_name'] as String;
                            final name = channel['name'] as String;
                            return DropdownMenuItem<String>(
                              value: channel['id'] as String,
                              child: Text(
                                displayName.isNotEmpty ? displayName : name,
                              ),
                            );
                          }).toList(),
                          onChanged: _onChannelSelected,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Messages from this channel will appear as your shopping list.',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Appearance section ────────────────────────────────
                _SectionHeader(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        return SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto_rounded),
                                label: Text('Auto'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode_rounded),
                                label: Text('Light'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode_rounded),
                                label: Text('Dark'),
                              ),
                            ],
                            selected: {themeMode},
                            onSelectionChanged: (selection) {
                              context
                                  .read<ThemeCubit>()
                                  .setThemeMode(selection.first);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Account section ───────────────────────────────────
                _SectionHeader(
                  icon: Icons.person_outline_rounded,
                  title: 'Account',
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.read<AuthCubit>().logout();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: cs.error, size: 22),
                          const SizedBox(width: 14),
                          Text(
                            'Sign Out',
                            style: tt.titleSmall?.copyWith(color: cs.error),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded,
                              color: cs.onSurface.withValues(alpha: 0.3)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cs.primary,
                letterSpacing: 0.3,
              ),
        ),
      ],
    );
  }
}
