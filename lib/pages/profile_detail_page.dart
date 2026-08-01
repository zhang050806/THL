import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../i18n/app_localizations.dart';

/// 头像操作类型：相册、拍照、恢复默认。
enum _AvatarAction { gallery, camera, restoreDefault }

/// [ProfileDetailPage] 个人详情页。
/// 支持更换头像（相册/拍照）和修改昵称，点击保存后回传结果。
class ProfileDetailPage extends StatefulWidget {
  final String nickname;
  final String? avatarPath;

  const ProfileDetailPage({super.key, required this.nickname, this.avatarPath});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late String _nickname;
  late String _initialNickname;
  File? _avatarFile;
  String? _initialAvatarPath;
  final ImagePicker _picker = ImagePicker();

  /// 判断是否有实际更改（昵称或头像与初始值不同）。
  bool get _hasChanges {
    if (_nickname != _initialNickname) return true;
    final current = _avatarFile?.path ?? '';
    final initial = _initialAvatarPath ?? '';
    return current != initial;
  }

  @override
  void initState() {
    super.initState();
    _nickname = widget.nickname;
    _initialNickname = widget.nickname;
    _initialAvatarPath = widget.avatarPath;
    if (widget.avatarPath != null && widget.avatarPath!.isNotEmpty) {
      final f = File(widget.avatarPath!);
      if (f.existsSync()) _avatarFile = f;
    }
  }

  /// 弹出选择框：相册、拍照、恢复默认
  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.pickFromGallery),
              onTap: () => Navigator.pop(ctx, _AvatarAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(ctx, _AvatarAction.camera),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.restore, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280)),
              title: Text(
                l10n.restoreDefault,
                style: TextStyle(color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280)),
              ),
              onTap: () => Navigator.pop(ctx, _AvatarAction.restoreDefault),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;

    if (action == _AvatarAction.restoreDefault) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.restoreDefaultTitle),
          content: Text(l10n.restoreDefaultMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (confirm == true && mounted) {
        // 恢复默认后直接保存，无需手动再点保存
        Navigator.pop(context, {
          'nickname': l10n.thlUser,
          'avatarPath': '',
        });
      }
      return;
    }

    final source = action == _AvatarAction.gallery ? ImageSource.gallery : ImageSource.camera;
    final picked = await _picker.pickImage(source: source, maxWidth: 512);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  /// 弹出昵称编辑对话框（改用 BottomSheet 避免 IME 兼容问题）
  Future<void> _editNickname() async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: _nickname);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.editNickname,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFE6EDF3)
                    : const Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: l10n.nicknameHint,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  final name = controller.text.trim();
                  final error = _validateName(name, l10n);
                  if (error != null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(error), duration: const Duration(seconds: 2)),
                    );
                    return;
                  }
                  Navigator.pop(ctx, name);
                },
                child: Text(l10n.confirm),
              ),
            ),
          ],
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _nickname = result;
      });
    }
  }

  /// 校验昵称：非空、中文≤7字、英文/数字≤11字母（均含空格）
  String? _validateName(String name, AppLocalizations l10n) {
    if (name.isEmpty) return l10n.nicknameEmpty;
    final hasChinese = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]').hasMatch(name);
    if (hasChinese) {
      if (name.length > 7) return l10n.nameTooLongCn;
    } else {
      if (name.length > 11) return l10n.nameTooLongEn;
    }
    return null;
  }

  /// 保存并返回结果
  void _save() {
    final l10n = AppLocalizations.of(context);
    final error = _validateName(_nickname, l10n);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), duration: const Duration(seconds: 2)),
      );
      return;
    }
    Navigator.pop(context, {
      'nickname': _nickname,
      'avatarPath': _avatarFile?.path ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.personalInfo),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _hasChanges ? _save : null,
            child: Text(
              l10n.save,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _hasChanges
                    ? const Color(0xFF4A90E2)
                    : Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF484F58)
                        : const Color(0xFFC0C6CC),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 可点击更换的圆形头像
              GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _avatarFile != null
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4A90E2),
                              Color(0xFF5CA1E9),
                            ],
                          ),
                    image: _avatarFile != null
                        ? DecorationImage(
                            image: FileImage(_avatarFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarFile != null
                      ? null
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 52,
                        ),
                ),
              ),
              const SizedBox(height: 18),
              // 可点击修改的昵称
              GestureDetector(
                onTap: _editNickname,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _nickname,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE6EDF3)
                            : const Color(0xFF1A1D26),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit,
                      size: 18,
                      color: isDark
                          ? const Color(0xFF8B949E)
                          : const Color(0xFFA0AEC0),
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
