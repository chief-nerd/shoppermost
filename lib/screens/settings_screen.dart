import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth/auth_cubit.dart';
import '../cubit/shopping/shopping_cubit.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shopping Channel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedChannelId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select a channel',
                    ),
                    items: _channels.map((channel) {
                      final displayName = channel['display_name'] as String;
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
                  const SizedBox(height: 8),
                  Text(
                    'Messages from this channel will be shown as your shopping list.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
