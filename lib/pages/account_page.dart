import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';
import '../services/auth_service.dart';

/// [LoginPage] 登录/注册页面。
/// 支持账号密码登录和注册，表单带输入校验，登录成功后返回。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// [LoginPage] 状态管理类。
/// 管理登录/注册 Tab 切换、表单字段、加载态、错误提示。
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  /// Tab 控制器：管理「登录」和「注册」两个 Tab 页
  late TabController _tabController;

  /// 登录/注册账号输入控制器
  final _accountController = TextEditingController();
  /// 登录密码输入控制器
  final _loginPwdController = TextEditingController();
  /// 注册密码输入控制器
  final _regPwdController = TextEditingController();
  /// 注册确认密码输入控制器
  final _regPwdConfirmController = TextEditingController();
  /// 注册昵称输入控制器
  final _nicknameController = TextEditingController();

  /// 是否正在提交（显示加载态，禁止重复点击）
  bool _loading = false;
  /// 错误信息显示
  String? _errorMsg;
  /// 登录密码是否可视
  bool _loginObscure = true;
  /// 注册密码是否可视
  bool _regObscure = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accountController.dispose();
    _loginPwdController.dispose();
    _regPwdController.dispose();
    _regPwdConfirmController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  /// 处理登录提交。
  /// 校验表单 → 禁用按钮 → 调用 AuthService.login() → 返回结果。
  Future<void> _handleLogin() async {
    final account = _accountController.text.trim();
    final password = _loginPwdController.text;

    // 空值校验
    if (account.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = '请输入账号和密码');
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    // 调用认证服务登录
    final resp = await AuthService.instance.login(account, password);
    if (!mounted) return;

    if (resp.isSuccess) {
      Navigator.pop(context, true); // 返回 true 触发上层页面刷新用户信息
    } else {
      setState(() {
        _errorMsg = resp.errorMessage ?? '登录失败';
      });
    }
    setState(() => _loading = false);
  }

  /// 处理注册提交。
  /// 校验两次密码一致性 → 调用 AuthService.register() → 成功后返回。
  Future<void> _handleRegister() async {
    final account = _accountController.text.trim();
    final password = _regPwdController.text;
    final confirm = _regPwdConfirmController.text;
    final nickname = _nicknameController.text.trim();

    if (account.isEmpty || password.isEmpty || nickname.isEmpty) {
      setState(() => _errorMsg = '请填写所有字段');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMsg = '两次密码不一致');
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final resp = await AuthService.instance.register(account, password, nickname);
    if (!mounted) return;

    if (resp.isSuccess) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMsg = resp.errorMessage ?? '注册失败';
      });
    }
    setState(() => _loading = false);
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
            PageHeaderWidget(title: l10n.bindTHLAccount, onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ---- 登录/注册 Tab 栏 ----
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161B22)
                          : const Color(0xFFF0F0F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark
                          ? const Color(0xFF8B949E)
                          : const Color(0xFFA0AEC0),
                      labelStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(fontSize: 14),
                      indicator: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerHeight: 0,
                      splashBorderRadius: BorderRadius.circular(10),
                      tabs: [
                        Tab(text: l10n.login),
                        Tab(text: l10n.register),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- 错误信息提示 ----
                  if (_errorMsg != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_errorMsg!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ),

                  // ---- 账号输入框（登录和注册共用） ----
                  TextField(
                    controller: _accountController,
                    decoration: InputDecoration(
                      labelText: l10n.account,
                      hintText: l10n.accountHint,
                      prefixIcon:
                          const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---- 根据 Tab 显示不同表单 ----
                  // 使用 Expanded + TabBarView 实现表单区域切换
                  SizedBox(
                    height: 260,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoginForm(l10n),
                        _buildRegisterForm(l10n),
                      ],
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

  /// 构建登录表单区域。
  /// 包含密码输入框、登录按钮、忘记密码链接。
  Widget _buildLoginForm(AppLocalizations l10n) {
    return Column(
      children: [
        // 密码输入框（带显隐切换）
        TextField(
          controller: _loginPwdController,
          obscureText: _loginObscure,
          decoration: InputDecoration(
            labelText: l10n.password,
            hintText: l10n.passwordHint,
            prefixIcon:
                const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                  _loginObscure ? Icons.visibility_off : Icons.visibility,
                  size: 20),
              onPressed: () =>
                  setState(() => _loginObscure = !_loginObscure),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        // 忘记密码链接
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(l10n.forgotPassword,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF4A90E2))),
          ),
        ),
        const SizedBox(height: 6),
        // 登录按钮
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF4A90E2).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l10n.login,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  /// 构建注册表单区域。
  /// 包含密码、确认密码、昵称输入框和注册按钮。
  Widget _buildRegisterForm(AppLocalizations l10n) {
    return Column(
      children: [
        // 注册密码
        TextField(
          controller: _regPwdController,
          obscureText: _regObscure,
          decoration: InputDecoration(
            labelText: l10n.password,
            hintText: l10n.passwordHint,
            prefixIcon:
                const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                  _regObscure ? Icons.visibility_off : Icons.visibility,
                  size: 20),
              onPressed: () =>
                  setState(() => _regObscure = !_regObscure),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
        // 确认密码
        TextField(
          controller: _regPwdConfirmController,
          obscureText: _regObscure,
          decoration: InputDecoration(
            labelText: l10n.confirmPassword,
            hintText: l10n.confirmPasswordHint,
            prefixIcon:
                const Icon(Icons.lock_outline, size: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
        // 昵称
        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: l10n.nickname,
            hintText: l10n.nicknameHint,
            prefixIcon:
                const Icon(Icons.face_outlined, size: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        // 注册按钮
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF4A90E2).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l10n.register,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
