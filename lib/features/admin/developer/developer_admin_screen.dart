import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/developer_info_model.dart';
import '../../../providers/developer_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

class DeveloperAdminScreen extends ConsumerStatefulWidget {
  const DeveloperAdminScreen({super.key});

  @override
  ConsumerState<DeveloperAdminScreen> createState() => _DeveloperAdminScreenState();
}

class _DeveloperAdminScreenState extends ConsumerState<DeveloperAdminScreen> {
  final _nameCtrl   = TextEditingController();
  final _avatarCtrl = TextEditingController();
  List<DeveloperLink> _links = [];
  bool _isEnabled = false;
  bool _isMaintenance = false;
  bool _showAvatar = true;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  void _initFields(DeveloperInfoModel data) {
    if (_isInitialized) return;
    _nameCtrl.text = data.name;
    _avatarCtrl.text = data.avatarUrl ?? '';
    _links = List.from(data.links);
    _isEnabled = data.isEnabled;
    _isMaintenance = data.isMaintenance;
    _showAvatar = data.showAvatar;
    _isInitialized = true;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final data = DeveloperInfoModel(
      isEnabled: _isEnabled,
      isMaintenance: _isMaintenance,
      name: _nameCtrl.text.trim().isEmpty ? 'Deepan Pramanick' : _nameCtrl.text.trim(),
      avatarUrl: _avatarCtrl.text.trim().isEmpty ? null : _avatarCtrl.text.trim(),
      showAvatar: _showAvatar,
      links: _links,
    );
    try {
      await SupabaseService.instance.upsertDeveloperInfo(data.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Developer Info saved successfully!'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addLink() {
    setState(() {
      _links.add(DeveloperLink(platform: 'github', url: ''));
    });
  }

  void _removeLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
  }

  void _updateLink(int index, String platform, String url) {
    setState(() {
      _links[index] = DeveloperLink(platform: platform, url: url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final devAsync = ref.watch(developerInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: devAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading: $e')),
        data: (devInfo) {
          _initFields(devInfo);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('App Control', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Manage maintenance mode, developer profile, and links.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),

                // ── Maintenance Card ──────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: _isMaintenance ? AppColors.errorSurface : AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isMaintenance ? AppColors.error : AppColors.border,
                      width: _isMaintenance ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.construction_rounded,
                            color: _isMaintenance ? AppColors.error : AppColors.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        const Text('Maintenance Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Switch(
                          value: _isMaintenance,
                          activeColor: AppColors.error,
                          onChanged: (v) => setState(() => _isMaintenance = v),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text(
                        _isMaintenance
                            ? '⚠️  Maintenance mode is ON — all students see the maintenance screen. Press Save to apply.'
                            : 'When enabled, students see a full-screen "We\'ll be back shortly" page.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isMaintenance ? AppColors.error : AppColors.textSecondary,
                          fontWeight: _isMaintenance ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 20),
                SolidCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Developer Button', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Toggle whether the students can see the Developer button.'),
                        value: _isEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _isEnabled = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(height: 30),
                      const Text('Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Developer Name', isDense: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _avatarCtrl,
                        decoration: const InputDecoration(labelText: 'Avatar Image URL (Optional)', isDense: true),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Show Animated Avatar', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Toggle the interactive parallax avatar card.'),
                        value: _showAvatar,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _showAvatar = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SolidCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('External Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Link'),
                            onPressed: _addLink,
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_links.isEmpty)
                        const Text('No links added yet.', style: TextStyle(color: AppColors.textHint)),
                      ...List.generate(_links.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: _links[i].platform,
                                  decoration: const InputDecoration(isDense: true, labelText: 'Platform'),
                                  items: const [
                                    DropdownMenuItem(value: 'github', child: Text('GitHub')),
                                    DropdownMenuItem(value: 'linkedin', child: Text('LinkedIn')),
                                    DropdownMenuItem(value: 'discord', child: Text('Discord')),
                                    DropdownMenuItem(value: 'twitter', child: Text('Twitter / X')),
                                    DropdownMenuItem(value: 'mail', child: Text('Email')),
                                    DropdownMenuItem(value: 'website', child: Text('Website')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) _updateLink(i, v, _links[i].url);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  initialValue: _links[i].url,
                                  decoration: const InputDecoration(isDense: true, labelText: 'URL'),
                                  onChanged: (v) => _updateLink(i, _links[i].platform, v),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _removeLink(i),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Save Configuration',
                  onPressed: _isSaving ? () {} : _save,
                  isLoading: _isSaving,
                  width: double.infinity,
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
