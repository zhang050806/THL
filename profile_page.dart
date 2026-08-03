import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'blank_page.dart';
import 'connect_device_page.dart';
import 'device_detail_page.dart';
import 'general_settings_page.dart';
import 'profile_detail_page.dart';

/// [ProfilePage] 「我的」页面。
/// 展示用户信息卡片、设备列表、AI 服务入口、系统设置等模块。
/// 是本 App 个人中心的汇聚页。
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// [ProfilePage] 状态管理类。
/// 负责设备列表的加载/持久化、用户登录状态读取、退出登录。
class _ProfilePageState extends State<ProfilePage> {
  /// 已绑定设备列表
  List<Map<String, dynamic>> _devices = [];
  /// 数据是否已加载完成
  bool _loaded = false;
  /// 用户昵称
  String _nickname = '';
  /// 用户头像本地路径
  String? _avatarPath;
  /// 是否已登录
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadUserInfo();
  }

  /// 依赖变化时（如从其他页面返回）重新加载数据，保证数据新鲜。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDevices();
    _loadUserInfo();
  }

  /// 从 StorageService 加载用户登录状态、昵称和头像。
  Future<void> _loadUserInfo() async {
    final storage = StorageService.instance;
    final loggedIn = await storage.isLoggedIn();
    final nickname = await storage.getNickname();
    final avatar = await storage.getAvatar();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _nickname = nickname;
        _avatarPath = avatar;
      });
    }
  }

  /// 从 StorageService 加载已绑定设备列表。
  Future<void> _loadDevices() async {
    final devices = await StorageService.instance.getDeviceList();
    if (mounted) {
      setState(() {
        _devices = devices;
        _loaded = true;
      });
    }
  }

  /// 持久化设备列表到 StorageService。
  Future<void> _saveDevices() async {
    await StorageService.instance.setBoundDevices(json.encode(_devices));
  }

  /// 退出登录：弹出确认对话框，确认后调用 AuthService.logout() 并刷新 UI。
  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: Color(0xFFA0AEC0))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.instance.logout();
      _loadUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  _buildProfileCard(l10n, isDark),
                  _buildSectionTitle(l10n.connectTitle, isDark),
                  _card(
                    child: _listItem(
                      Icons.bluetooth,
                      l10n.connectDevice,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConnectDevicePage(),
                        ),
                      ),
                      isDark: isDark,
                    ),
                  ),
                  _buildSectionTitle(l10n.devicesSection, isDark),
                  _buildDeviceSection(l10n, isDark),
                  _buildSectionTitle(l10n.aiXiaozhi, isDark),
                  _buildAISection(l10n, isDark),
                  _buildSectionTitle(l10n.settingsSection, isDark),
                  _buildSettingsSection(l10n, isDark),
                  const SizedBox(height: 16),
                  _buildLogoutButton(l10n, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息卡片（头像 + 昵称 + 统计数）。
  /// 头像和昵称区域可点击，进入个人详情页。
  Widget _buildProfileCard(AppLocalizations l10n, bool isDark) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 5, 16),
        child: Row(
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileDetailPage(
                        nickname:
                            _nickname.isNotEmpty ? _nickname : l10n.thlUser,
                        avatarPath: _avatarPath,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    final storage = StorageService.instance;
                    await storage.setNickname(result['nickname'] as String);
                    final avatar = result['avatarPath'] as String? ?? '';
                    await storage.setAvatar(avatar);
                    setState(() {
                      _nickname = result['nickname'] as String;
                      _avatarPath = avatar.isNotEmpty ? avatar : null;
                    });
                  }
                },
                child: Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        _nickname.isNotEmpty ? _nickname : l10n.thlUser,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFE6EDF3)
                              : const Color(0xFF1A1D26),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 右侧三列统计数据，右对齐，在线时长距卡片右缘 5px
            _buildStatItem(
                _devices.length.toString(), l10n.boundDevices, isDark),
            _buildStatDivider(isDark),
            _buildStatItem('0', l10n.conversations, isDark),
            _buildStatDivider(isDark),
            _buildStatItem('0h', l10n.onlineTime, isDark),
          ],
        ),
      ),
    );
  }

  /// 用户头像组件：优先显示用户自定义头像，无则显示蓝色渐变默认头像。
  Widget _buildAvatar() {
    final hasAvatar =
        _avatarPath != null && _avatarPath!.isNotEmpty && File(_avatarPath!).existsSync();
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasAvatar
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A90E2), Color(0xFF5CA1E9)],
              ),
        image: hasAvatar
            ? DecorationImage(
                image: FileImage(File(_avatarPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasAvatar ? null : const Icon(Icons.person, color: Colors.white, size: 30),
    );
  }

  /// 单个统计数据项（数值 + 标签），固定宽度、标签文字自动缩放防止截断。
  Widget _buildStatItem(String value, String label, bool isDark) {
    return SizedBox(
      width: 42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFE6EDF3)
                      : const Color(0xFF1A1D26))),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 8,
                  color: isDark
                      ? const Color(0xFF8B949E)
                      : const Color(0xFFA0AEC0))),
        ],
      ),
    );
  }

  /// 统计数据项之间的垂直分割线。
  Widget _buildStatDivider(bool isDark) {
    return SizedBox(
      height: 32,
      child: VerticalDivider(
          width: 1,
          color: isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0),
          thickness: 1),
    );
  }

  /// 分区标题：带装饰线的灰色文字。
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        '$title   ────────────',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF4A5568),
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// 构建设备分区：展示已绑定设备列表，每项可进入详情或删除。
  Widget _buildDeviceSection(AppLocalizations l10n, bool isDark) {
    final children = <Widget>[];

    if (_devices.isEmpty) {
      // 空状态
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(l10n.noDevices,
            style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF8B949E)
                    : const Color(0xFFA0AEC0))),
      ));
    } else {
      for (int i = 0; i < _devices.length; i++) {
        final device = _devices[i];
        final name = device['name'] as String;
        final status = (device['status'] as String?) ?? '在线';
        final isOnline = status == '在线';
        final address = device['address'] as String?;
        if (i > 0) children.add(_buildRowDivider(isDark));
        children.add(_deviceItem(
          icon: Icons.devices_other,
          name: name,
          status: status,
          online: isOnline,
          l10n: l10n,
          onTap: () async {
            // 进入设备详情页，根据返回结果更新本地设备列表
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      DeviceDetailPage(name: name, address: address)),
            );
            if (result != null && mounted) {
              if (result == '__UNBIND__') {
                // 解除绑定
                setState(() => _devices.removeAt(i));
                _saveDevices();
              } else {
                // 修改设备名称
                setState(() => _devices[i]['name'] = result);
                _saveDevices();
              }
            }
          },
          onDelete: () => _confirmDeleteDevice(i, l10n),
          isDark: isDark,
        ));
      }
    }

    return _card(child: Column(children: children));
  }

  /// 单个设备列表项。
  /// 包含设备图标、名称、在线状态指示、删除按钮、进入详情箭头。
  Widget _deviceItem({
    required IconData icon,
    required String name,
    required String status,
    required bool online,
    required AppLocalizations l10n,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: const Color(0xFF4A90E2), size: 24),
      title: Text(name,
          style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFFE6EDF3)
                  : const Color(0xFF1A1D26))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 状态指示圆点
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online
                  ? const Color(0xFF22C55E)
                  : (isDark
                      ? const Color(0xFF8B949E)
                      : const Color(0xFFA0AEC0)),
            ),
          ),
          const SizedBox(width: 6),
          // 在线状态文案（通过 statusText 翻译）
          Text(l10n.statusText(status),
              style: TextStyle(
                  fontSize: 12,
                  color: online
                      ? const Color(0xFF22C55E)
                      : (isDark
                          ? const Color(0xFF8B949E)
                          : const Color(0xFFA0AEC0)))),
          const SizedBox(width: 12),
          // 删除按钮
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close,
                color: isDark
                    ? const Color(0xFF8B949E)
                    : const Color(0xFFA0AEC0),
                size: 18),
          ),
          const SizedBox(width: 4),
          // 进入详情箭头
          Icon(Icons.chevron_right,
              color: isDark
                  ? const Color(0xFF8B949E)
                  : const Color(0xFFA0AEC0),
              size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  /// 列表项之间的分割线。
  Widget _buildRowDivider(bool isDark) {
    return Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: isDark ? const Color(0xFF21262D) : const Color(0xFFF0F0F5));
  }

  /// 删除设备确认对话框。
  void _confirmDeleteDevice(int index, AppLocalizations l10n) {
    final name = _devices[index]['name'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDevice, style: const TextStyle(fontSize: 16)),
        content: Text(l10n.deleteDeviceConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: const TextStyle(color: Color(0xFFA0AEC0))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _devices.removeAt(index));
              _saveDevices();
            },
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 构建 AI 服务分区：智能体档案、对话记录、联动方案、快捷指令。
  Widget _buildAISection(AppLocalizations l10n, bool isDark) {
    return _card(
      child: Column(
        children: [
          _listItem(Icons.folder_outlined, l10n.agentProfile,
              () => _navBlank(l10n.agentProfile), isDark: isDark),
          _buildRowDivider(isDark),
          _listItem(Icons.chat_bubble_outline, l10n.chatHistory,
              () => _navBlank(l10n.chatHistory), isDark: isDark),

        ],
      ),
    );
  }

  /// 构建设置分区。
  Widget _buildSettingsSection(AppLocalizations l10n, bool isDark) {
    return _card(
      child: Column(
        children: [
          _listItem(
            Icons.settings_outlined,
            l10n.generalSettings,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeneralSettingsPage()),
            ),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// 退出登录按钮（仅已登录时显示）。
  Widget _buildLogoutButton(AppLocalizations l10n, bool isDark) {
    if (!_isLoggedIn) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout, size: 18),
          label: Text(l10n.logout),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade400,
            side: BorderSide(
                color: isDark
                    ? const Color(0xFF30363D)
                    : const Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  /// 通用卡片容器：白色/暗色背景 + 双色投影。
  Widget _card({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16,
                    offset: Offset(0, 8)),
              ]
            : const [
                BoxShadow(
                    color: Colors.white, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(
                    color: Color(0x204A90E2),
                    blurRadius: 16,
                    offset: Offset(0, 8)),
              ],
      ),
      child: child,
    );
  }

  /// 通用列表项（带图标、标题、可选副标题、右侧箭头）。
  Widget _listItem(IconData icon, String title, VoidCallback onTap,
      {String? subtitle, required bool isDark}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
      title: Text(title,
          style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFFE6EDF3)
                  : const Color(0xFF1A1D26))),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF8B949E)
                      : const Color(0xFFA0AEC0)))
          : null,
      trailing: Icon(Icons.chevron_right,
          color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0),
          size: 20),
      onTap: onTap,
    );
  }

  /// 跳转到空白占位页。
  void _navBlank(String title) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => BlankPage(title: title)));
  }
}
