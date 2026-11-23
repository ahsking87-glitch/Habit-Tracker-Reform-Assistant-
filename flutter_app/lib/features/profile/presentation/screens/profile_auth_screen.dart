import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class ProfileAuthScreen extends ConsumerStatefulWidget {
  const ProfileAuthScreen({super.key});

  @override
  ConsumerState<ProfileAuthScreen> createState() => _ProfileAuthScreenState();
}

class _ProfileAuthScreenState extends ConsumerState<ProfileAuthScreen> {
  String _authTab = 'login'; // 'login' | 'register'
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  String? _authError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  void _showUpgradeGuestDialog() {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: MizanColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: MizanColors.amber400),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upgrade Guest to Sovereign Account',
                style: MizanTypography.title(fontSize: 17, color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              TextField(
                controller: emailC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              TextField(
                controller: passC,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration:
                    const InputDecoration(labelText: 'Vault Passphrase (6+ chars)'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MizanColors.amber500,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      if (passC.text.length < 6) return;
                      await ref.read(userProfileProvider.notifier).upgradeGuest(
                            nameC.text,
                            emailC.text,
                            passC.text,
                          );
                      if (mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Seal Vault Account'),
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
    final user = ref.watch(userProfileProvider);

    if (user == null) {
      return _buildAuthGate();
    }
    return _buildProfileDashboard(user);
  }

  Widget _buildAuthGate() {
    final screenW = MediaQuery.of(context).size.width;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenW > 540 ? 480 : screenW),
        child: MizanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sovereign Offline Vault Authentication',
                style: MizanTypography.title(fontSize: 19, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '100% local SHA-256 iterative credential derivation. Zero third-party tracking servers.',
                style: MizanTypography.body(
                    fontSize: 12, color: MizanColors.slate300),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ChoiceChip(
                    selected: _authTab == 'login',
                    selectedColor: MizanColors.amber500,
                    label: Text(
                      'Sign In',
                      style: TextStyle(
                        color:
                            _authTab == 'login' ? Colors.black : Colors.white,
                      ),
                    ),
                    onSelected: (_) => setState(() => _authTab = 'login'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    selected: _authTab == 'register',
                    selectedColor: MizanColors.amber500,
                    label: Text(
                      'Create Local Vault',
                      style: TextStyle(
                        color: _authTab == 'register'
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    onSelected: (_) => setState(() => _authTab = 'register'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_authTab == 'register') ...[
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Vault Passphrase (min 6 chars)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_authError != null) ...[
                const SizedBox(height: 8),
                Text(_authError!,
                    style: const TextStyle(color: MizanColors.rose400)),
              ],
              const SizedBox(height: 14),
              MizanIconButton(
                label: _authTab == 'login'
                    ? 'Unlock Local Vault'
                    : 'Initialize Encrypted Account',
                icon: LucideIcons.key,
                fullWidth: true,
                onPressed: () async {
                  try {
                    setState(() => _authError = null);
                    if (_authTab == 'login') {
                      await ref
                          .read(userProfileProvider.notifier)
                          .login(_emailCtrl.text, _passCtrl.text);
                    } else {
                      await ref.read(userProfileProvider.notifier).register(
                            _nameCtrl.text,
                            _emailCtrl.text,
                            _passCtrl.text,
                          );
                    }
                  } catch (e) {
                    setState(() => _authError = e.toString());
                  }
                },
              ),
              const SizedBox(height: 10),
              MizanIconButton(
                label: 'Continue as Anonymous Offline Guest',
                icon: LucideIcons.userCheck,
                bgColor: MizanColors.bgCardAlt,
                borderColor: MizanColors.borderEmerald,
                textColor: MizanColors.emerald300,
                fullWidth: true,
                onPressed: () =>
                    ref.read(userProfileProvider.notifier).signInGuest(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDashboard(UserProfile user) {
    if (_nameCtrl.text.isEmpty) _nameCtrl.text = user.displayName;
    if (_goalCtrl.text.isEmpty) _goalCtrl.text = user.spiritualGoal;

    final emblem = avatarEmblemOptions.firstWhere(
      (e) => e.id == user.avatarId,
      orElse: () => avatarEmblemOptions.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MizanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MizanColors.emerald950,
                      border: Border.all(color: MizanColors.amber400, width: 2),
                    ),
                    alignment: Alignment.center,
                    child:
                        Text(emblem.icon, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              user.displayName,
                              style: MizanTypography.title(
                                  fontSize: 19, color: Colors.white),
                            ),
                            MizanBadge(
                              label: user.isAnonymous
                                  ? 'ANONYMOUS GUEST'
                                  : 'SOVEREIGN VAULT',
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${user.email} · ${user.madhab}',
                          overflow: TextOverflow.ellipsis,
                          style: MizanTypography.body(
                              fontSize: 12, color: MizanColors.slate300),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (user.isAnonymous)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MizanColors.amber500,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _showUpgradeGuestDialog,
                      child: const Text('Upgrade Guest Account'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(userProfileProvider.notifier).logout(),
                    icon: const Icon(LucideIcons.logOut,
                        size: 14, color: MizanColors.rose400),
                    label: Text(
                      'Lock Vault',
                      style: MizanTypography.body(
                          fontSize: 12, color: MizanColors.rose400),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        MizanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spiritual Identity, Emblem & Biometric Lock',
                style: MizanTypography.title(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: avatarEmblemOptions.map((opt) {
                  final selected = user.avatarId == opt.id;
                  return ChoiceChip(
                    selected: selected,
                    selectedColor: MizanColors.amber500,
                    backgroundColor: MizanColors.bgCardAlt,
                    label: Text(
                      '${opt.icon} ${opt.label}',
                      style: MizanTypography.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.black : Colors.white,
                      ),
                    ),
                    onSelected: (_) => ref
                        .read(userProfileProvider.notifier)
                        .updateProfile(avatarId: opt.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _goalCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Primary Spiritual Intention (Niyyah)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: user.madhab,
                dropdownColor: MizanColors.bgCardElevated,
                style: MizanTypography.body(fontSize: 12.5, color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Asr Juristic School (Madhab)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Shafi / Majority',
                      child: Text('Shafi / Maliki / Hanbali (1x Shadow)')),
                  DropdownMenuItem(
                      value: 'Hanafi', child: Text('Hanafi (2x Shadow)')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref
                        .read(userProfileProvider.notifier)
                        .updateProfile(madhab: v);
                    ref.read(prayerSettingsProvider.notifier).setMadhab(
                        v == 'Hanafi' ? AsrMethod.hanafi : AsrMethod.shafi);
                  }
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Biometric Vault Lock (Face ID / Fingerprint)',
                  style: MizanTypography.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                subtitle: Text(
                  'Protects offline streak proofs and BYOK API keystore access.',
                  style: MizanTypography.body(
                      fontSize: 11, color: MizanColors.slate400),
                ),
                value: user.biometricLockEnabled,
                activeColor: MizanColors.emerald400,
                onChanged: (v) => ref
                    .read(userProfileProvider.notifier)
                    .updateProfile(biometricLockEnabled: v),
              ),
              const SizedBox(height: 10),
              MizanIconButton(
                label: 'Save Local Profile Changes',
                icon: LucideIcons.checkCircle2,
                onPressed: () async {
                  await ref.read(userProfileProvider.notifier).updateProfile(
                        displayName: _nameCtrl.text,
                        spiritualGoal: _goalCtrl.text,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: MizanColors.emerald900,
                        content: Text('Profile persisted to offline storage.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
