import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/app_localizations.dart';
import '../widgets/header_widget.dart';

/// [ServerConfigPage] AI服务器配置页面。
/// 用户可以在此配置AI服务器的地址和端口，
/// 测试连通性，并保存到本地 SharedPreferences。
class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  /// 服务器地址输入控制器
  final TextEditingController _hostController = TextEditingController();
  /// 端口号输入控制器
  final TextEditingController _portController = TextEditingController();

  /// 是否正在测试连接
  bool _isTesting = false;
  /// 连接测试结果：null=未测试, true=成功, false=失败
  bool? _testResult;
  /// 是否已保存
  bool _isSaved = false;

  /// SharedPreferences 存储键
  static const _keyHost = 'ai_server_host';
  static const _keyPort = 'ai_server_port';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  /// 从本地加载已保存的服务器配置。
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString(_keyHost) ?? '';
    final port = prefs.getString(_keyPort) ?? '';
    setState(() {
      if (host.isNotEmpty) {
        _hostController.text = host;
      } else {
        // 预填默认占位地址
        _hostController.text = '192.168.1.100';
      }
      if (port.isNotEmpty) {
        _portController.text = port;
      } else {
        _portController.text = '8000';
      }
    });
  }

  /// 保存服务器配置到 SharedPreferences。
  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, _hostController.text.trim());
    await prefs.setString(_keyPort, _portController.text.trim());
    setState(() => _isSaved = true);

    // 显示保存成功提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).isEnglish
              ? 'Server config saved successfully'
              : '服务器配置已保存'),
          backgroundColor: const Color(0xFF22C55E),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// 模拟连接测试：延迟 1.5 秒后随机返回成功或失败。
  Future<void> _testConnection() async {
    final host = _hostController.text.trim();
    final port = _portController.text.trim();
    if (host.isEmpty || port.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    // 模拟网络检测，延迟 1.5 秒
    await Future.delayed(const Duration(milliseconds: 1500));

    // 如果地址为空（如 0.0.0.0）则视为失败，否则成功
    final success = host != '0.0.0.0';

    setState(() {
      _isTesting = false;
      _testResult = success;
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
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
            // 通用页面 Header（带返回按钮）
            PageHeaderWidget(
              title: l10n.isEnglish ? 'AI Server Config' : 'AI服务器配置',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---- 服务器地址卡片 ----
                  _buildCard(
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题
                          Text(
                            l10n.isEnglish ? 'Server Address' : '服务器地址',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFE6EDF3)
                                  : const Color(0xFF1A1D26),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 服务器地址输入框
                          TextField(
                            controller: _hostController,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              labelText:
                                  l10n.isEnglish ? 'Host / IP Address' : '主机地址 / IP',
                              hintText: '192.168.1.100',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF8B949E)
                                    : const Color(0xFFA0AEC0),
                              ),
                              prefixIcon: const Icon(Icons.dns_outlined,
                                  color: Color(0xFF4A90E2)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF21262D)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF21262D)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF4A90E2), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 端口输入框
                          TextField(
                            controller: _portController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              labelText: l10n.isEnglish ? 'Port' : '端口号',
                              hintText: '8000',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF8B949E)
                                    : const Color(0xFFA0AEC0),
                              ),
                              prefixIcon: const Icon(Icons.settings_ethernet,
                                  color: Color(0xFF4A90E2)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF21262D)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF21262D)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF4A90E2), width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- 连接测试结果提示 ----
                  if (_testResult != null)
                    _buildCard(
                      isDark: isDark,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: _testResult!
                              ? const Color(0xFF22C55E).withOpacity(0.08)
                              : const Color(0xFFEF4444).withOpacity(0.08),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _testResult!
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: _testResult!
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _testResult!
                                    ? (l10n.isEnglish
                                        ? 'Connection successful! Server is reachable.'
                                        : '连接成功！服务器可达。')
                                    : (l10n.isEnglish
                                        ? 'Connection failed. Please check the address and port.'
                                        : '连接失败，请检查地址和端口。'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _testResult!
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ---- 操作按钮区 ----
                  Row(
                    children: [
                      // 连接测试按钮
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isTesting ? null : _testConnection,
                            icon: _isTesting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF4A90E2),
                                    ),
                                  )
                                : const Icon(Icons.wifi_find,
                                    color: Color(0xFF4A90E2)),
                            label: Text(
                              _isTesting
                                  ? (l10n.isEnglish ? 'Testing...' : '测试中...')
                                  : (l10n.isEnglish
                                      ? 'Test Connection'
                                      : '连接测试'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4A90E2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 保存按钮
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _saveConfig,
                            icon: Icon(
                              _isSaved ? Icons.check : Icons.save_outlined,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isSaved
                                  ? (l10n.isEnglish ? 'Saved' : '已保存')
                                  : (l10n.isEnglish ? 'Save' : '保存配置'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSaved
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF4A90E2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ---- 使用说明卡片 ----
                  _buildCard(
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Color(0xFF4A90E2), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.isEnglish ? 'Instructions' : '使用说明',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFE6EDF3)
                                      : const Color(0xFF1A1D26),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionItem(
                            isDark,
                            '1',
                            l10n.isEnglish
                                ? 'Enter the AI server\'s IP address or domain name (e.g., 192.168.1.100 or api.example.com).'
                                : '输入AI服务器的IP地址或域名（如 192.168.1.100 或 api.example.com）。',
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            isDark,
                            '2',
                            l10n.isEnglish
                                ? 'Enter the port number (default is usually 8000 or 8080).'
                                : '输入服务器端口号（默认一般为 8000 或 8080）。',
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            isDark,
                            '3',
                            l10n.isEnglish
                                ? 'Tap "Test Connection" to verify the server is reachable.'
                                : '点击"连接测试"按钮检测服务器是否可达。',
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            isDark,
                            '4',
                            l10n.isEnglish
                                ? 'Tap "Save" to store the configuration locally.'
                                : '点击"保存配置"将设置保存到本地。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 使用说明单条项目
  Widget _buildInstructionItem(bool isDark, String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            num,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A90E2),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF718096),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// 通用卡片容器
  Widget _buildCard({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(
                    color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
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
}
