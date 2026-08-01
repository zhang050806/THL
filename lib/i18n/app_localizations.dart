/// [AppLocalizations] 国际化模块。
/// 提供中英双语支持，通过 JSON 数据将语义键映射到对应语言文案。
/// 所有 UI 文案通过此类统一管理，支持运行时切换语言并自动刷新界面。

import 'package:flutter/material.dart';

/// 简易国际化模块：支持中文 / English 两种语言。
/// 通过 AppLocalizations.of(context) 获取当前语言的文案。
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(Locale(AppLocalizationsController.languageCode));
  }

  bool get isEnglish => locale.languageCode == 'en';

  static const Map<String, String> _zh = {
    // 底部导航栏
    'navHome': '首页',
    'navConnect': '连接',
    'navProfile': '我的',
    // 首页
    'helloXiaozhi': '你好，小智',
    // 问候语两行不随语言切换，两种语言输出相同
    'greetingPrefix': '让我们度过',
    'greetingHighlight': '美好的一天！',
    'greetingEnglish': "Hello, Let's have a wonderful day!",
    'noAgents': '暂无智能体',
    'tapToCreateAgent': '点击下方按钮创建智能体',
    'createAgent': '创建智能体',
    'createAgentPageContent': '创建智能体页面',
    // 连接页
    'connectTitle': '连接',
    'connectPageContent': '连接页面',
    'connectServerConfig': '服务器配置',
    'connectServerHint': 'ws://192.168.1.100:8000/xiaozhi/v1/',
    'connectBtn': '连接',
    'connected': '已连接',
    'connecting': '连接中...',
    'connectMyDevices': '我的设备',
    'connectNoServer': '请先配置服务器地址',
    'connectNoDevices': '暂无设备，点击添加',
    'connectAddDevice': '添加设备',
    'connectDeviceName': '设备名称',
    'connectDeviceNameHint': '例如：客厅小智',
    'connectDeviceId': '设备ID',
    'connectDeviceIdHint': 'XX:XX:XX:XX:XX:XX',
    'connectHowToTitle': '如何使用？',
    'connectHowToDesc': 'ESP32设备配网后，在此绑定设备ID即可远程控制',
    'connectGithub': '查看开源项目',
    'connectBluetoothDevices': '蓝牙设备',
    'connectBluetoothOff': '蓝牙未开启',
    'connectEnableBluetooth': '开启蓝牙',
    'connectNotConnected': '未连接',
    'connectStopScan': '停止搜索',
    'connectSearchDevice': '搜索设备',
    'connectScanning': '正在搜索设备...',
    'connectTapToSearch': '点击上方按钮搜索附近设备',
    'connectNoThlDevice': '未找到 THL 设备',
    'connectScanTimeoutHint': '请尝试：将设备断电重启\n或在系统蓝牙设置中取消配对后重新扫描',
    'connectScanTimeoutSnackbar': '未找到 THL 设备。\n请尝试：1) 将设备断电重启；2) 在系统蓝牙设置中取消配对后重新扫描',
    'connectFailed': '连接 {name} 失败',
    'connectPaired': '已配对',
    'connectTutorial': '使用教程',
    'connectAiServerConfig': 'AI服务器配置',
    'connectAiServerHint': '设置AI服务器地址和端口',
    // 使用教程页
    'guideTitle': '使用教程',
    'guideStep1Title': '硬件准备',
    'guideStep1Desc':
        'ESP32-S3开发板（Flash≥8MB, PSRAM≥2MB）、INMP441麦克风、MAX98357功放模块、喇叭。确保开发板sRGB彩灯开关已焊接。',
    'guideStep2Title': '烧录固件',
    'guideStep2Desc':
        '从GitHub下载最新固件（github.com/78/xiaozhi-esp32/releases），使用ESP32烧录工具刷入。初次使用建议使用官方测试服：OTA地址 api.tenclass.net/xiaozhi/ota/，WebSocket地址 wss://api.tenclass.net/xiaozhi/v1/',
    'guideStep3Title': 'WiFi配网',
    'guideStep3Desc':
        '上电后RGB蓝灯闪烁=配网模式。手机连接Xiaozhi-XXXX热点，浏览器打开192.168.4.1选择2.4G WiFi输入密码，连接成功后设备自动重启。',
    'guideStep4Title': '服务器部署',
    'guideStep4Desc':
        '方案A：使用官方测试服（免费），WebSocket wss://api.tenclass.net/xiaozhi/v1/，控制面板 xiaozhi.me。方案B：自建服务器（github.com/xinnan-tech/xiaozhi-esp32-server），支持Docker一键部署，在App中填入你的服务器地址即可。',
    'guideStep5Title': '设备绑定',
    'guideStep5Desc':
        '设备联网后喊"你好，小智"唤醒，设备播报6位验证码。登录xiaozhi.me控制面板→创建智能体→添加设备→输入6位验证码→绑定成功。',
    'guideStep6Title': '在本App中连接',
    'guideStep6Desc':
        '回到连接页输入服务器地址点击连接，点击右下角+添加已绑定的设备（名称+设备ID），即可在App中管理设备状态。',
    // 我的页
    'thlUser': 'THL用户',
    'bindThlAccount': '绑定THL账号',
    'boundDevices': '已绑定设备',
    'conversations': '对话次数',
    'onlineTime': '在线时长',
    'devicesSection': '设备',
    'noDevices': '暂无设备',
    'addDevice': '添加设备',
    'addNewDevice': '添加新设备',
    'aiXiaozhi': 'AI 小智',
    'agentProfile': '智能体档案',
    'personalInfo': '个人信息',
    'pickFromGallery': '从相册选择',
    'takePhoto': '拍照',
    'restoreDefault': '恢复默认',
    'restoreDefaultTitle': '恢复默认',
    'restoreDefaultMessage': '确定恢复为默认头像和昵称？',
    'chatHistory': '对话记录',
    'linkPlans': '联动方案',
    'shortcuts': '快捷指令',
    'shortcutsSection': '快捷指令',
    'addShortcut': '添加快捷指令',
    'shortcutName': '指令名称',
    'shortcutContent': '指令内容',
    'ok': '确定',
    'noShortcuts': '暂无快捷指令',
    'deleteShortcutConfirm': '确定要删除该快捷指令吗？',
    'servicesSection': '服务',
    'orderCenter': '订单中心',
    'orderCenterSubtitle': '硬件购买 / 售后维修 / 配件补发',
    'bindTHLAccount': '绑定THL账号',
    'settingsSection': '设置',
    'helpFeedback': '帮助与反馈',
    'pushNotifications': '推送通知',
    'noNotifications': '暂无通知',
    'accountSecurity': '账号与安全',
    'firmwareUpdate': '检查更新',
    'generalSettings': '通用设置',
    'termsOfService': '服务条款',
    'privacyPolicy': '隐私政策',
    'aboutThl': '关于THL',
    'deviceNameHint': '设备名称',
    'add': '添加',
    'deleteDevice': '删除设备',
    'deleteDeviceConfirmPrefix': '确定要删除「',
    'deleteDeviceConfirmSuffix': '」吗？',
    'delete': '删除',
    'online': '在线',
    'offline': '离线',
    'away': '离开',
    'dnd': '勿扰',
    'noContent': '暂无内容',
    // 设备详情页
    'deviceName': '设备名称',
    'enterDeviceName': '输入设备名称',
    'onlineStatus': '在线状态',
    'serialNumber': '设备序列号',
    'firmwareVersion': '固件版本',
    'lastConnected': '最后连接',
    'scheduledOnOff': '闹钟',
    'lightControl': '灯光调节',
    'unbind': '解除绑定',
    'unbindConfirm': '确定要解除该设备的绑定吗？',
    'unbindConfirmBtn': '确定解除',
    'save': '保存',
    // 灯光调节页
    'strong': '强',
    'weak': '弱',
    'off': '无',
    'brightnessLevel': '亮度档位',
    'fineAdjustment': '精细调节',
    'lightOff': '灯光已关闭',
    'currentBrightness': '当前亮度',
    // 灯光调节页 — 新增时钟灯光 + 底座灯光
    'clockLight': '时钟灯光',
    'baseLight': '底座灯光',
    'whiteLight': '白光',
    'yellowLight': '黄光',
    'mixedLight': '黄白混合',
    'baseLightOff': '关闭',
    'lightOn': '灯光已开启',
    'darkLabel': '暗',
    'brightLabel': '亮',
    // 个人账户信息页
    'accountInfoTitle': '个人账户信息',
    'basicInfo': '基本信息',
    'nickname': '用户昵称',
    'statusLabel': '状态标签',
    'accountSection': '账户信息',
    'phoneNumber': '绑定手机号',
    'birthday': '生日',
    'language': '语言',
    'darkMode': '深色模式',
    'editNickname': '修改用户昵称',
    'enterNickname': '请输入昵称',
    'bindPhone': '绑定手机号',
    'enterPhone': '请输入11位手机号',
    'selectStatus': '选择状态',
    'selectLanguage': '选择语言',
    'switchLanguageTitle': '切换语言',
    'switchToEnglishConfirm': '确定要将语言切换为英语吗？',
    'switchToChineseConfirm': '确定要将语言切换为中文吗？',
    'cancel': '取消',
    'confirm': '确定',
    'notSet': '未设置',
    'notBound': '未绑定',
    // 设备总览页
    'myDevices': '我的设备',
    'noBoundDevices': '暂无已绑定设备',
    // 登录/注册
    'login': '登录',
    'register': '注册',
    'accountHint': '手机号 / 邮箱',
    'passwordHint': '密码',
    'confirmPasswordHint': '确认密码',
    'nicknameHint': '昵称（选填）',
    'loginButton': '登 录',
    'registerButton': '注 册',
    'noAccount': '还没有账号？',
    'hasAccount': '已有账号？',
    'goRegister': '去注册',
    'goLogin': '去登录',
    'loginFailed': '登录失败，请检查账号和密码',
    'registerFailed': '注册失败，请重试',
    'loginSuccess': '登录成功',
    'registerSuccess': '注册成功',
    'loginAccountEmpty': '请输入账号',
    'loginPasswordEmpty': '请输入密码',
    'registerAccountEmpty': '请输入账号',
    'registerPasswordEmpty': '请输入密码',
    'registerPasswordMismatch': '两次输入的密码不一致',
    'registerNicknameEmpty': '请输入昵称',
    'passwordTooShort': '密码不能少于6位',
    'passwordMismatch': '两次密码不一致',
    'nicknameEmpty': '昵称不能为空',
    'nameTooLongCn': '中文名不能超过7个字',
    'nameTooLongEn': '英文名不能超过11个字母',
    'appName': '小智',
    'loginTab': '登录',
    'registerTab': '注册',
    'password': '密码',
    'loginBtn': '登录',
    'nicknameField': '昵称',
    'confirmPassword': '确认密码',
    'registerBtn': '注册',
    'networkError': '网络连接失败，请检查网络',
    // 退出登录
    'logout': '退出登录',
    'logoutConfirmTitle': '退出登录',
    'logoutConfirmMessage': '确定要退出当前账号吗？',
    // 账号绑定状态
    'accountBound': '已绑定账号',
    'accountNotBound': '未绑定账号',
    // 补充缺失的 key
    'account': '账号',
    'forgotPassword': '忘记密码',
    'comingSoon': '即将上线',
    'devices': '设备',
    'voiceHint': '点击与「小智」对话',
    'aiChat': 'AI 对话',
    'lampControl': '灯光控制',
    'timerTask': '定时任务',
    'quickCmd': '快捷指令',
    'systemSettings': '系统设置',
    'aiOnline': 'AI 已联网',

    // 购买页 / 订单中心
    'purchase': '购买',
    'orderManagement': '订单管理',
    'myOrders': '我的订单',
    'viewAllOrders': '查看全部订单记录',
    // 产品特性列表（购买页产品卡片）
    'thlMagCharge7in1Name': 'THL MagCharge 7合1无线充电站',
    'featureMagCharge1': '同时为 6 台设备充电',
    'featureMagCharge2': '65W 高功率适配器',
    'featureMagCharge3': '25W MagSafe + 15W 通用无线充电板',
    'featureMagCharge4': 'Apple Watch 充满仅需 73 分钟',
    'featureMagCharge5': '7合1 一体化设计（时钟/温度/环境光）',
    'featureMagCharge6': '5 层安全防护',
    'thl65wAdapterName': 'THL 65W USB-C 电源适配器充电器',
    'featureAdapter1': '输入：100-240VAC 50/60Hz 1.6A',
    'featureAdapter2': '输出：5V/3A | 9V/3A | 12V/5A | 15V/3A | 20V/3.25A (65W Max)',
    'featureAdapter3': 'USB-C 接口，兼容笔记本/手机/平板',
    'featureAdapter4': '全球通用宽幅电压',

    // 帮助与反馈页
    'helpSection': '帮助',
    'feedbackSection': '反馈',
    'manualTitle': 'THL MagCharge无线充电站说明书',
    'feedbackProblem': '反馈问题',
    'noContentFeedback': '暂无内容',
    // 反馈问题页 — 联系邮箱说明
    'feedbackContent':
        '若在故障排查、常见问题解答中无法解决，请给我们的邮箱 support@thl.com.cn 发送电子邮件，我们将尽快解决您的问题！',

    // 帮助与反馈页 — 三个新栏目
    'troubleshooting': '故障排查',
    'troubleshootingTips': '使用建议',
    'troubleshootingContent':
        '为获得最佳效果，请使用随附的 65W 或更高功率适配器。避免使用过厚或不具磁吸功能的手机壳。如需使用保护壳，请选择 Apple MagSafe 保护壳。厚度超过 2.5 毫米的保护壳可能会降低充电效率。',
    'shoppingFaq': '购物常见问题解答',
    'warrantyPolicy': '保修政策',

    // 关于 THL 页
    'aboutThlHeading': '关于THL',
    'aboutThlIntro':
        'THL Global秉持着"科技应提升日常生活品质"的理念，致力于打造创新家电和娱乐解决方案，为全球家庭带来欢乐。我们的使命是设计能够完美融入现代生活的产品，将尖端科技与匠心设计融为一体。',
    'ourCorePhilosophy': '我们的核心理念',
    'techJoyLife': '科技·快乐·生活',
    'techJoyLifeDesc':
        '我们相信，科技的真正力量不在于其复杂性，而在于它创造幸福生活的能力——简化日常琐事，放大快乐瞬间，并通过直观易用的创新连接人与人。这正是THL的立足之本：将尖端科技转化为每个用户、每个地方都能切实感受到的幸福。',
    'techEmpowers': '科技赋能',
    'techEmpowersBody': '我们相信科技应该服务于有意义的目的，通过创新和诚信来改善人们的生活，解决现实世界的挑战。',
    'joyInDetails': '细节中的喜悦',
    'joyInDetailsBody': '从直观的界面到优雅的设计，我们用心打造每一个细节，力求为产品带来愉悦的体验。',
    'forEveryLife': '适用于每一种人生场景',
    'forEveryLifeBody': '我们丰富多样的产品系列旨在适应不同人群的生活方式、需求和偏好。',

    // 固件升级 / 检查更新
    'checkingForUpdates': '正在检查更新…',
    'alreadyLatestVersion': '已是最新版本',
    'newVersionAvailable': '发现新版本',
    'updateNow': '立即升级',
    'updateLater': '稍后再说',
    'checkUpdateFailed': '检查更新失败，请稍后重试',
    'currentVersion': '当前版本',
    'latestVersion': '最新版本',
    'updateLog': '更新内容',
    'downloadingFirmware': '正在下载固件…',
    'upgradingFirmware': '正在升级固件…',
    'upgradeComplete': '升级完成',
    'upgradeFailed': '升级失败，请重试',
    'retry': '重试',
    // 闹钟页
    'alarmPageTitle': '闹钟',
    'alarmTime': '闹钟时间',
    'alarmEnabled': '已启用',
    'alarmDisabled': '已禁用',
    'setAlarm': '设置闹钟',
    'noAlarmSet': '未设置闹钟时间',
    // 闹钟页 — 多闹钟扩展
    'alarmAdd': '添加闹钟',
    'alarmNoAlarms': '暂无闹钟',
    'alarmSelectTime': '选择时间',
    'alarmSelectRepeat': '选择重复',
    'alarmSelectDays': '选择日期',
    'alarmRepeatOnce': '单次',
    'alarmRepeatWeekday': '仅工作日（周一至周五）',
    'alarmRepeatWeekdayShort': '仅工作日',
    'alarmRepeatCustom': '自定义',
    'alarmNext': '下一步',
    'alarmPrev': '上一步',
    'alarmConfirm': '确定',
    'alarmCancel': '取消',
    'alarmDaySeparator': '、',
    'alarmMonday': '周一',
    'alarmTuesday': '周二',
    'alarmWednesday': '周三',
    'alarmThursday': '周四',
    'alarmFriday': '周五',
    'alarmSaturday': '周六',
    'alarmSunday': '周日',
    'alarmMondayShort': '周一',
    'alarmTuesdayShort': '周二',
    'alarmWednesdayShort': '周三',
    'alarmThursdayShort': '周四',
    'alarmFridayShort': '周五',
    'alarmSaturdayShort': '周六',
    'alarmSundayShort': '周日',
    'alarmEdit': '编辑',
    'alarmDone': '完成',
    'alarmSelectAll': '全选',
    'alarmDeleteSelected': '删除选中',
    'alarmDelete': '删除',
    // 闹钟页 — BLE 同步 & 触发动作
    'alarmSelectAction': '选择触发动作',
    'alarmSync': '同步闹钟',
    'alarmSyncFailed': '同步失败，请检查蓝牙连接',
    'alarmBleNotConnected': '设备未连接，请先连接蓝牙设备',
    'alarmMaxReached': '已达到设备最大数量（20条），请先删除不用的闹钟',
  };

  static const Map<String, String> _en = {
    // Bottom navigation
    'navHome': 'Home',
    'navConnect': 'Connect',
    'navProfile': 'Profile',
    // Home page
    'helloXiaozhi': 'Hello, XiaoZhi',
    // Greeting lines stay the same in both languages
    'greetingPrefix': '让我们度过',
    'greetingHighlight': '美好的一天！',
    'greetingEnglish': "Hello, Let's have a wonderful day!",
    'noAgents': 'No Agents Yet',
    'tapToCreateAgent': 'Tap the button below to create an agent',
    'createAgent': 'Create Agent',
    'createAgentPageContent': 'Create Agent Page',
    // Connect page
    'connectTitle': 'Connect',
    'connectPageContent': 'Connect Page',
    'connectServerConfig': 'Server Config',
    'connectServerHint': 'ws://192.168.1.100:8000/xiaozhi/v1/',
    'connectBtn': 'Connect',
    'connected': 'Connected',
    'connecting': 'Connecting...',
    'connectMyDevices': 'My Devices',
    'connectNoServer': 'Please configure server address first',
    'connectNoDevices': 'No devices, tap to add',
    'connectAddDevice': 'Add Device',
    'connectDeviceName': 'Device Name',
    'connectDeviceNameHint': 'e.g. Living Room XiaoZhi',
    'connectDeviceId': 'Device ID',
    'connectDeviceIdHint': 'XX:XX:XX:XX:XX:XX',
    'connectHowToTitle': 'How to Use?',
    'connectHowToDesc':
        'After ESP32 WiFi setup, bind device ID here for remote control',
    'connectGithub': 'View on GitHub',
    'connectBluetoothDevices': 'Bluetooth Devices',
    'connectBluetoothOff': 'Bluetooth is Off',
    'connectEnableBluetooth': 'Enable Bluetooth',
    'connectNotConnected': 'Not Connected',
    'connectStopScan': 'Stop Searching',
    'connectSearchDevice': 'Search Devices',
    'connectScanning': 'Searching for devices...',
    'connectTapToSearch': 'Tap the button above to search devices',
    'connectNoThlDevice': 'No THL devices found',
    'connectScanTimeoutHint': 'Try: power cycle the device\nor unpair in Bluetooth settings and scan again',
    'connectScanTimeoutSnackbar': 'No THL devices found.\nTry: 1) Power cycle the device; 2) Unpair in system Bluetooth settings and scan again',
    'connectFailed': 'Failed to connect to {name}',
    'connectPaired': 'Paired',
    'connectTutorial': 'Tutorial',
    'connectAiServerConfig': 'AI Server Config',
    'connectAiServerHint': 'Set AI server address and port',
    // Guide page
    'guideTitle': 'User Guide',
    'guideStep1Title': 'Hardware Setup',
    'guideStep1Desc':
        'ESP32-S3 board (Flash≥8MB, PSRAM≥2MB), INMP441 mic, MAX98357 amp, speaker. Ensure sRGB LED switch is soldered.',
    'guideStep2Title': 'Flash Firmware',
    'guideStep2Desc':
        'Download latest firmware from GitHub, flash using ESP32 tool. For first use, try official test server: OTA api.tenclass.net/xiaozhi/ota/, WebSocket wss://api.tenclass.net/xiaozhi/v1/',
    'guideStep3Title': 'WiFi Setup',
    'guideStep3Desc':
        'Power on, blue LED flashing = setup mode. Connect phone to Xiaozhi-XXXX hotspot, open 192.168.4.1, select 2.4G WiFi and enter password. Device restarts on success.',
    'guideStep4Title': 'Server Setup',
    'guideStep4Desc':
        'Option A: Official test server (free), WebSocket wss://api.tenclass.net/xiaozhi/v1/, dashboard xiaozhi.me. Option B: Self-host (github.com/xinnan-tech/xiaozhi-esp32-server), Docker one-click deploy, enter your server URL in App.',
    'guideStep5Title': 'Bind Device',
    'guideStep5Desc':
        'After online, say "Hello XiaoZhi", device reads 6-digit code. Login xiaozhi.me → Create Agent → Add Device → Enter code → Done.',
    'guideStep6Title': 'Connect in App',
    'guideStep6Desc':
        'Back to Connect page, enter server URL and connect. Tap + to add your bound device (name + ID), manage status in App.',
    // Profile page
    'thlUser': 'THL User',
    'bindThlAccount': 'Bind THL Account',
    'boundDevices': 'Bound Devices',
    'conversations': 'Conversations',
    'onlineTime': 'Online Time',
    'devicesSection': 'Devices',
    'noDevices': 'No Devices',
    'addDevice': 'Add Device',
    'addNewDevice': 'Add New Device',
    'aiXiaozhi': 'AI XiaoZhi',
    'agentProfile': 'Agent Profile',
    'personalInfo': 'Personal Info',
    'pickFromGallery': 'Pick from Gallery',
    'takePhoto': 'Take Photo',
    'restoreDefault': 'Restore Default',
    'restoreDefaultTitle': 'Restore Default',
    'restoreDefaultMessage': 'Restore default avatar and nickname?',
    'chatHistory': 'Chat History',
    'linkPlans': 'Link Plans',
    'shortcuts': 'Shortcuts',
    'shortcutsSection': 'Shortcuts',
    'addShortcut': 'Add Shortcut',
    'shortcutName': 'Name',
    'shortcutContent': 'Content',
    'ok': 'OK',
    'noShortcuts': 'No shortcuts',
    'deleteShortcutConfirm': 'Are you sure you want to delete this shortcut?',
    'servicesSection': 'Services',
    'orderCenter': 'Order Center',
    'orderCenterSubtitle': 'Hardware / After-sales / Accessories',
    'bindTHLAccount': 'Bind THL Account',
    'settingsSection': 'Settings',
    'helpFeedback': 'Help & Feedback',
    'pushNotifications': 'Push Notifications',
    'noNotifications': 'No notifications',
    'accountSecurity': 'Account & Security',
    'firmwareUpdate': 'Check for Updates',
    'generalSettings': 'General',
    'termsOfService': 'Terms of Service',
    'privacyPolicy': 'Privacy Policy',
    'aboutThl': 'About THL',
    'deviceNameHint': 'Device name',
    'add': 'Add',
    'deleteDevice': 'Delete Device',
    'deleteDeviceConfirmPrefix': 'Are you sure you want to delete "',
    'deleteDeviceConfirmSuffix': '"?',
    'delete': 'Delete',
    'online': 'Online',
    'offline': 'Offline',
    'away': 'Away',
    'dnd': 'DND',
    'noContent': 'No Content',
    // Device detail page
    'deviceName': 'Device Name',
    'enterDeviceName': 'Enter device name',
    'onlineStatus': 'Status',
    'serialNumber': 'Serial Number',
    'firmwareVersion': 'Firmware Version',
    'lastConnected': 'Last Connected',
    'scheduledOnOff': 'Alarm',
    'lightControl': 'Light Control',
    'unbind': 'Unbind',
    'unbindConfirm': 'Are you sure you want to unbind this device?',
    'unbindConfirmBtn': 'Unbind',
    'save': 'Save',
    // Light control page
    'strong': 'Strong',
    'weak': 'Weak',
    'off': 'Off',
    'brightnessLevel': 'Brightness Level',
    'fineAdjustment': 'Fine Adjustment',
    'lightOff': 'Light Off',
    'currentBrightness': 'Current Brightness',
    // Light control — Clock Light + Base Light
    'clockLight': 'Clock Light',
    'baseLight': 'Base Light',
    'whiteLight': 'White',
    'yellowLight': 'Yellow',
    'mixedLight': 'Mixed',
    'baseLightOff': 'Off',
    'lightOn': 'Light On',
    'darkLabel': 'Dim',
    'brightLabel': 'Bright',
    // Account info page
    'accountInfoTitle': 'Account Info',
    'basicInfo': 'Basic Info',
    'nickname': 'Nickname',
    'statusLabel': 'Status',
    'accountSection': 'Account',
    'phoneNumber': 'Phone Number',
    'birthday': 'Birthday',
    'language': 'Language',
    'darkMode': 'Dark Mode',
    'editNickname': 'Edit Nickname',
    'enterNickname': 'Enter nickname',
    'bindPhone': 'Bind Phone',
    'enterPhone': 'Enter 11-digit phone number',
    'selectStatus': 'Select Status',
    'selectLanguage': 'Select Language',
    'switchLanguageTitle': 'Switch Language',
    'switchToEnglishConfirm':
        'Are you sure you want to switch the language to English?',
    'switchToChineseConfirm':
        'Are you sure you want to switch the language to Chinese?',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'notSet': 'Not set',
    'notBound': 'Not bound',
    // Device list page
    'myDevices': 'My Devices',
    'noBoundDevices': 'No Bound Devices',
    // Login / Register
    'login': 'Login',
    'register': 'Register',
    'accountHint': 'Phone / Email',
    'passwordHint': 'Password',
    'confirmPasswordHint': 'Confirm Password',
    'nicknameHint': 'Nickname (optional)',
    'loginButton': 'Login',
    'registerButton': 'Register',
    'noAccount': "Don't have an account?",
    'hasAccount': 'Already have an account?',
    'goRegister': 'Sign up',
    'goLogin': 'Sign in',
    'loginFailed': 'Login failed. Please check your credentials.',
    'registerFailed': 'Registration failed. Please try again.',
    'loginSuccess': 'Login successful',
    'registerSuccess': 'Registration successful',
    'loginAccountEmpty': 'Please enter your account',
    'loginPasswordEmpty': 'Please enter your password',
    'registerAccountEmpty': 'Please enter your account',
    'registerPasswordEmpty': 'Please enter your password',
    'registerPasswordMismatch': 'Passwords do not match',
    'registerNicknameEmpty': 'Please enter a nickname',
    'passwordTooShort': 'Password must be at least 6 characters',
    'passwordMismatch': 'Passwords do not match',
    'nicknameEmpty': 'Nickname cannot be empty',
    'nameTooLongCn': 'Chinese name max 7 characters',
    'nameTooLongEn': 'English name max 11 characters',
    'appName': 'XiaoZhi',
    'loginTab': 'Login',
    'registerTab': 'Register',
    'password': 'Password',
    'loginBtn': 'Login',
    'nicknameField': 'Nickname',
    'confirmPassword': 'Confirm Password',
    'registerBtn': 'Register',
    'networkError': 'Network error. Please check your connection.',
    // Logout
    'logout': 'Logout',
    'logoutConfirmTitle': 'Logout',
    'logoutConfirmMessage': 'Are you sure you want to log out?',
    // Account binding status
    'accountBound': 'Account Bound',
    'accountNotBound': 'Not Bound',
    // Missing keys
    'account': 'Account',
    'forgotPassword': 'Forgot Password',
    'comingSoon': 'Coming Soon',
    'devices': 'Devices',
    'voiceHint': 'Tap to talk with XiaoZhi',
    'aiChat': 'AI Chat',
    'lampControl': 'Lamp Control',
    'timerTask': 'Timer Task',
    'quickCmd': 'Quick Command',
    'systemSettings': 'System Settings',
    'aiOnline': 'AI Online',

    // Purchase / Order Center
    'purchase': 'Purchase',
    'orderManagement': 'Order Management',
    'myOrders': 'My Orders',
    'viewAllOrders': 'View all order records',
    // Product features
    'thlMagCharge7in1Name': 'THL MagCharge 7-in-1 Wireless Charging Station',
    'featureMagCharge1': 'Charge 6 devices simultaneously',
    'featureMagCharge2': '65W high-power adapter',
    'featureMagCharge3': '25W MagSafe + 15W universal wireless pad',
    'featureMagCharge4': 'Apple Watch full charge in just 73 minutes',
    'featureMagCharge5': '7-in-1 design (clock / temperature / ambient light)',
    'featureMagCharge6': '5-layer safety protection',
    'thl65wAdapterName': 'THL 65W USB-C Power Adapter Charger',
    'featureAdapter1': 'Input: 100-240VAC 50/60Hz 1.6A',
    'featureAdapter2': 'Output: 5V/3A | 9V/3A | 12V/5A | 15V/3A | 20V/3.25A (65W Max)',
    'featureAdapter3': 'USB-C port, compatible with laptops/phones/tablets',
    'featureAdapter4': 'Universal wide-range voltage',

    // Help & Feedback
    'helpSection': 'Help',
    'feedbackSection': 'Feedback',
    'manualTitle': 'THL MagCharge Wireless Charging Station Manual',
    'feedbackProblem': 'Submit Feedback',
    'noContentFeedback': 'No content yet',
    // Feedback page — contact email info
    'feedbackContent':
        'If the troubleshooting and FAQ sections don\'t resolve your issue, please send an email to support@thl.com.cn and we will address your problem as soon as possible!',

    // Help & Feedback — three new sections
    'troubleshooting': 'Troubleshooting',
    'troubleshootingTips': 'Usage Tips',
    'troubleshootingContent':
        'For the best results, use the included 65W or higher adapter. Avoid thick or non-magnetic phone cases. If you use a case, choose an Apple MagSafe case. Cases thicker than 2.5 mm may reduce charging efficiency.',
    'shoppingFaq': 'Shopping FAQ',
    'warrantyPolicy': 'Warranty Policy',

    // About THL
    'aboutThlHeading': 'About THL',
    'aboutThlIntro':
        'THL Global embraces the philosophy that "technology should enhance everyday quality of life," dedicated to creating innovative home appliances and entertainment solutions that bring joy to families worldwide. Our mission is to design products that seamlessly integrate into modern life, blending cutting-edge technology with masterful design.',
    'ourCorePhilosophy': 'Our Core Philosophy',
    'techJoyLife': 'Tech · Joy · Life',
    'techJoyLifeDesc':
        'We believe the true power of technology lies not in its complexity, but in its ability to create happiness -- simplifying daily tasks, amplifying joyful moments, and connecting people through intuitive innovation. This is THL\'s foundation: transforming cutting-edge technology into happiness that every user, everywhere, can truly feel.',
    'techEmpowers': 'Tech Empowers',
    'techEmpowersBody': 'We believe technology should serve meaningful purposes, improving lives through innovation and integrity to solve real-world challenges.',
    'joyInDetails': 'Joy in Details',
    'joyInDetailsBody': 'From intuitive interfaces to elegant design, we craft every detail with care to bring delightful experiences to our products.',
    'forEveryLife': 'For Every Life',
    'forEveryLifeBody': 'Our diverse product range is designed to adapt to different lifestyles, needs, and preferences.',

    // Firmware Update / Check for Updates
    'checkingForUpdates': 'Checking for updates...',
    'alreadyLatestVersion': 'Already up to date',
    'newVersionAvailable': 'New Version Available',
    'updateNow': 'Update Now',
    'updateLater': 'Later',
    'checkUpdateFailed': 'Check failed, please try again later',
    'currentVersion': 'Current Version',
    'latestVersion': 'Latest Version',
    'updateLog': "What's New",
    'downloadingFirmware': 'Downloading firmware...',
    'upgradingFirmware': 'Upgrading firmware...',
    'upgradeComplete': 'Upgrade Complete',
    'upgradeFailed': 'Upgrade failed, please retry',
    'retry': 'Retry',
    // Alarm page
    'alarmPageTitle': 'Alarm',
    'alarmTime': 'Alarm Time',
    'alarmEnabled': 'Enabled',
    'alarmDisabled': 'Disabled',
    'setAlarm': 'Set Alarm',
    'noAlarmSet': 'No alarm time set',
    // Alarm page — multi-alarm extension
    'alarmAdd': 'Add Alarm',
    'alarmNoAlarms': 'No alarms',
    'alarmSelectTime': 'Select Time',
    'alarmSelectRepeat': 'Select Repeat',
    'alarmSelectDays': 'Select Days',
    'alarmRepeatOnce': 'Once',
    'alarmRepeatWeekday': 'Weekdays (Mon–Fri)',
    'alarmRepeatWeekdayShort': 'Weekdays',
    'alarmRepeatCustom': 'Custom',
    'alarmNext': 'Next',
    'alarmPrev': 'Previous',
    'alarmConfirm': 'Confirm',
    'alarmCancel': 'Cancel',
    'alarmDaySeparator': ', ',
    'alarmMonday': 'Monday',
    'alarmTuesday': 'Tuesday',
    'alarmWednesday': 'Wednesday',
    'alarmThursday': 'Thursday',
    'alarmFriday': 'Friday',
    'alarmSaturday': 'Saturday',
    'alarmSunday': 'Sunday',
    'alarmMondayShort': 'Mon',
    'alarmTuesdayShort': 'Tue',
    'alarmWednesdayShort': 'Wed',
    'alarmThursdayShort': 'Thu',
    'alarmFridayShort': 'Fri',
    'alarmSaturdayShort': 'Sat',
    'alarmSundayShort': 'Sun',
    'alarmEdit': 'Edit',
    'alarmDone': 'Done',
    'alarmSelectAll': 'Select All',
    'alarmDeleteSelected': 'Delete Selected',
    'alarmDelete': 'Delete',
    // Alarm page — BLE sync & trigger action
    'alarmSelectAction': 'Select Action',
    'alarmSync': 'Sync Alarms',
    'alarmSyncFailed': 'Sync failed. Please check Bluetooth connection',
    'alarmBleNotConnected': 'Device not connected. Please connect via Bluetooth first',
    'alarmMaxReached': 'Maximum alarms reached (20). Please delete unused alarms first',
  };

  Map<String, String> get _map => isEnglish ? _en : _zh;

  String _t(String key) => _map[key] ?? _zh[key] ?? key;

  // 底部导航栏
  String get navHome => _t('navHome');
  String get navConnect => _t('navConnect');
  String get navProfile => _t('navProfile');

  // 首页
  String get helloXiaozhi => _t('helloXiaozhi');
  String get greetingPrefix => _t('greetingPrefix');
  String get greetingHighlight => _t('greetingHighlight');
  String get greetingEnglish => _t('greetingEnglish');
  String get noAgents => _t('noAgents');
  String get tapToCreateAgent => _t('tapToCreateAgent');
  String get createAgent => _t('createAgent');
  String get createAgentPageContent => _t('createAgentPageContent');

  // 连接页
  String get connectTitle => _t('connectTitle');
  String get connectPageContent => _t('connectPageContent');
  String get connectServerConfig => _t('connectServerConfig');
  String get connectServerHint => _t('connectServerHint');
  String get connectBtn => _t('connectBtn');
  String get connected => _t('connected');
  String get connecting => _t('connecting');
  String get connectMyDevices => _t('connectMyDevices');
  String get connectNoServer => _t('connectNoServer');
  String get connectNoDevices => _t('connectNoDevices');
  String get connectAddDevice => _t('connectAddDevice');
  String get connectDeviceName => _t('connectDeviceName');
  String get connectDeviceNameHint => _t('connectDeviceNameHint');
  String get connectDeviceId => _t('connectDeviceId');
  String get connectDeviceIdHint => _t('connectDeviceIdHint');
  String get connectHowToTitle => _t('connectHowToTitle');
  String get connectHowToDesc => _t('connectHowToDesc');
  String get connectGithub => _t('connectGithub');
  String get connectBluetoothDevices => _t('connectBluetoothDevices');
  String get connectBluetoothOff => _t('connectBluetoothOff');
  String get connectEnableBluetooth => _t('connectEnableBluetooth');
  String get connectNotConnected => _t('connectNotConnected');
  String get connectStopScan => _t('connectStopScan');
  String get connectSearchDevice => _t('connectSearchDevice');
  String get connectScanning => _t('connectScanning');
  String get connectTapToSearch => _t('connectTapToSearch');
  String get connectNoThlDevice => _t('connectNoThlDevice');
  String get connectScanTimeoutHint => _t('connectScanTimeoutHint');
  String get connectScanTimeoutSnackbar => _t('connectScanTimeoutSnackbar');

  String connectFailed(String name) =>
      _t('connectFailed').replaceAll('{name}', name);
  String get connectPaired => _t('connectPaired');
  String get connectTutorial => _t('connectTutorial');
  String get connectAiServerConfig => _t('connectAiServerConfig');
  String get connectAiServerHint => _t('connectAiServerHint');

  // 我的页
  String get thlUser => _t('thlUser');
  String get bindThlAccount => _t('bindThlAccount');
  String get boundDevices => _t('boundDevices');
  String get conversations => _t('conversations');
  String get onlineTime => _t('onlineTime');
  String get devicesSection => _t('devicesSection');
  String get noDevices => _t('noDevices');
  String get addDevice => _t('addDevice');
  String get addNewDevice => _t('addNewDevice');
  String get aiXiaozhi => _t('aiXiaozhi');
  String get agentProfile => _t('agentProfile');
  String get personalInfo => _t('personalInfo');
  String get pickFromGallery => _t('pickFromGallery');
  String get takePhoto => _t('takePhoto');
  String get restoreDefault => _t('restoreDefault');
  String get restoreDefaultTitle => _t('restoreDefaultTitle');
  String get restoreDefaultMessage => _t('restoreDefaultMessage');
  String get chatHistory => _t('chatHistory');
  String get linkPlans => _t('linkPlans');
  String get shortcuts => _t('shortcuts');
  String get shortcutsSection => _t('shortcutsSection');
  String get addShortcut => _t('addShortcut');
  String get shortcutName => _t('shortcutName');
  String get shortcutContent => _t('shortcutContent');
  String get ok => _t('ok');
  String get noShortcuts => _t('noShortcuts');
  String get deleteShortcutConfirm => _t('deleteShortcutConfirm');
  String get servicesSection => _t('servicesSection');
  String get orderCenter => _t('orderCenter');
  String get orderCenterSubtitle => _t('orderCenterSubtitle');
  String get bindTHLAccount => _t('bindTHLAccount');
  String get settingsSection => _t('settingsSection');
  String get helpFeedback => _t('helpFeedback');
  String get pushNotifications => _t('pushNotifications');
  String get noNotifications => _t('noNotifications');
  String get accountSecurity => _t('accountSecurity');
  String get firmwareUpdate => _t('firmwareUpdate');
  String get checkingForUpdates => _t('checkingForUpdates');
  String get alreadyLatestVersion => _t('alreadyLatestVersion');
  String get newVersionAvailable => _t('newVersionAvailable');
  String get updateNow => _t('updateNow');
  String get updateLater => _t('updateLater');
  String get checkUpdateFailed => _t('checkUpdateFailed');
  String get currentVersion => _t('currentVersion');
  String get latestVersion => _t('latestVersion');
  String get updateLog => _t('updateLog');
  String get downloadingFirmware => _t('downloadingFirmware');
  String get upgradingFirmware => _t('upgradingFirmware');
  String get upgradeComplete => _t('upgradeComplete');
  String get upgradeFailed => _t('upgradeFailed');
  String get retry => _t('retry');
  String get generalSettings => _t('generalSettings');
  String get termsOfService => _t('termsOfService');
  String get privacyPolicy => _t('privacyPolicy');
  String get aboutThl => _t('aboutThl');
  String get deviceNameHint => _t('deviceNameHint');
  String get add => _t('add');
  String get deleteDevice => _t('deleteDevice');
  String get delete => _t('delete');
  String get online => _t('online');
  String get offline => _t('offline');
  String get away => _t('away');
  String get dnd => _t('dnd');
  String get noContent => _t('noContent');

  // 使用教程页
  String get guideTitle => _t('guideTitle');
  String get guideStep1Title => _t('guideStep1Title');
  String get guideStep1Desc => _t('guideStep1Desc');
  String get guideStep2Title => _t('guideStep2Title');
  String get guideStep2Desc => _t('guideStep2Desc');
  String get guideStep3Title => _t('guideStep3Title');
  String get guideStep3Desc => _t('guideStep3Desc');
  String get guideStep4Title => _t('guideStep4Title');
  String get guideStep4Desc => _t('guideStep4Desc');
  String get guideStep5Title => _t('guideStep5Title');
  String get guideStep5Desc => _t('guideStep5Desc');
  String get guideStep6Title => _t('guideStep6Title');
  String get guideStep6Desc => _t('guideStep6Desc');

  String deleteDeviceConfirm(String name) =>
      '${_t('deleteDeviceConfirmPrefix')}$name${_t('deleteDeviceConfirmSuffix')}';

  // 设备详情页
  String get deviceName => _t('deviceName');
  String get enterDeviceName => _t('enterDeviceName');
  String get onlineStatus => _t('onlineStatus');
  String get serialNumber => _t('serialNumber');
  String get firmwareVersion => _t('firmwareVersion');
  String get lastConnected => _t('lastConnected');
  String get scheduledOnOff => _t('scheduledOnOff');
  String get lightControl => _t('lightControl');
  String get unbind => _t('unbind');
  String get unbindConfirm => _t('unbindConfirm');
  String get unbindConfirmBtn => _t('unbindConfirmBtn');
  String get save => _t('save');

  // 灯光调节页
  String get strong => _t('strong');
  String get weak => _t('weak');
  String get off => _t('off');
  String get brightnessLevel => _t('brightnessLevel');
  String get fineAdjustment => _t('fineAdjustment');
  String get lightOff => _t('lightOff');
  String get currentBrightness => _t('currentBrightness');
  // 灯光调节页 — 时钟灯光 + 底座灯光
  String get clockLight => _t('clockLight');
  String get baseLight => _t('baseLight');
  String get whiteLight => _t('whiteLight');
  String get yellowLight => _t('yellowLight');
  String get mixedLight => _t('mixedLight');
  String get baseLightOff => _t('baseLightOff');
  String get lightOn => _t('lightOn');
  String get darkLabel => _t('darkLabel');
  String get brightLabel => _t('brightLabel');
  // 闹钟页
  String get alarmPageTitle => _t('alarmPageTitle');
  String get alarmTime => _t('alarmTime');
  String get alarmEnabled => _t('alarmEnabled');
  String get alarmDisabled => _t('alarmDisabled');
  String get setAlarm => _t('setAlarm');
  String get noAlarmSet => _t('noAlarmSet');
  // 闹钟页 — 多闹钟扩展
  String get alarmAdd => _t('alarmAdd');
  String get alarmNoAlarms => _t('alarmNoAlarms');
  String get alarmSelectTime => _t('alarmSelectTime');
  String get alarmSelectRepeat => _t('alarmSelectRepeat');
  String get alarmSelectDays => _t('alarmSelectDays');
  String get alarmRepeatOnce => _t('alarmRepeatOnce');
  String get alarmRepeatWeekday => _t('alarmRepeatWeekday');
  String get alarmRepeatWeekdayShort => _t('alarmRepeatWeekdayShort');
  String get alarmRepeatCustom => _t('alarmRepeatCustom');
  String get alarmNext => _t('alarmNext');
  String get alarmPrev => _t('alarmPrev');
  String get alarmConfirm => _t('alarmConfirm');
  String get alarmCancel => _t('alarmCancel');
  String get alarmDaySeparator => _t('alarmDaySeparator');
  String get alarmMonday => _t('alarmMonday');
  String get alarmTuesday => _t('alarmTuesday');
  String get alarmWednesday => _t('alarmWednesday');
  String get alarmThursday => _t('alarmThursday');
  String get alarmFriday => _t('alarmFriday');
  String get alarmSaturday => _t('alarmSaturday');
  String get alarmSunday => _t('alarmSunday');
  String get alarmMondayShort => _t('alarmMondayShort');
  String get alarmTuesdayShort => _t('alarmTuesdayShort');
  String get alarmWednesdayShort => _t('alarmWednesdayShort');
  String get alarmThursdayShort => _t('alarmThursdayShort');
  String get alarmFridayShort => _t('alarmFridayShort');
  String get alarmSaturdayShort => _t('alarmSaturdayShort');
  String get alarmSundayShort => _t('alarmSundayShort');
  String get alarmEdit => _t('alarmEdit');
  String get alarmDone => _t('alarmDone');
  String get alarmSelectAll => _t('alarmSelectAll');
  String get alarmDeleteSelected => _t('alarmDeleteSelected');
  String get alarmDelete => _t('alarmDelete');
  // 闹钟页 — BLE 同步 & 触发动作
  String get alarmSelectAction => _t('alarmSelectAction');
  String get alarmSync => _t('alarmSync');
  String get alarmSyncFailed => _t('alarmSyncFailed');
  String get alarmBleNotConnected => _t('alarmBleNotConnected');
  String get alarmMaxReached => _t('alarmMaxReached');

  /// 闹钟同步成功提示（参数化）。
  String alarmSyncSuccess(int count) =>
      isEnglish ? 'Synced $count alarm(s)' : '已同步 $count 条闹钟';

  // 个人账户信息页
  String get accountInfoTitle => _t('accountInfoTitle');
  String get basicInfo => _t('basicInfo');
  String get nickname => _t('nickname');
  String get statusLabel => _t('statusLabel');
  String get accountSection => _t('accountSection');
  String get phoneNumber => _t('phoneNumber');
  String get birthday => _t('birthday');
  String get language => _t('language');
  String get darkMode => _t('darkMode');
  String get editNickname => _t('editNickname');
  String get enterNickname => _t('enterNickname');
  String get bindPhone => _t('bindPhone');
  String get enterPhone => _t('enterPhone');
  String get selectStatus => _t('selectStatus');
  String get selectLanguage => _t('selectLanguage');
  String get switchLanguageTitle => _t('switchLanguageTitle');
  String get switchToEnglishConfirm => _t('switchToEnglishConfirm');
  String get switchToChineseConfirm => _t('switchToChineseConfirm');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');
  String get notSet => _t('notSet');
  String get notBound => _t('notBound');

  // 设备总览页
  String get myDevices => _t('myDevices');
  String get noBoundDevices => _t('noBoundDevices');

  // 登录/注册
  String get login => _t('login');
  String get register => _t('register');
  String get accountHint => _t('accountHint');
  String get passwordHint => _t('passwordHint');
  String get confirmPasswordHint => _t('confirmPasswordHint');
  String get nicknameHint => _t('nicknameHint');
  String get loginButton => _t('loginButton');
  String get registerButton => _t('registerButton');
  String get noAccount => _t('noAccount');
  String get hasAccount => _t('hasAccount');
  String get goRegister => _t('goRegister');
  String get goLogin => _t('goLogin');
  String get loginFailed => _t('loginFailed');
  String get registerFailed => _t('registerFailed');
  String get loginSuccess => _t('loginSuccess');
  String get registerSuccess => _t('registerSuccess');
  String get loginAccountEmpty => _t('loginAccountEmpty');
  String get loginPasswordEmpty => _t('loginPasswordEmpty');
  String get registerAccountEmpty => _t('registerAccountEmpty');
  String get registerPasswordEmpty => _t('registerPasswordEmpty');
  String get registerPasswordMismatch => _t('registerPasswordMismatch');
  String get registerNicknameEmpty => _t('registerNicknameEmpty');
  String get passwordTooShort => _t('passwordTooShort');
  String get passwordMismatch => _t('passwordMismatch');
  String get nicknameEmpty => _t('nicknameEmpty');
  String get nameTooLongCn => _t('nameTooLongCn');
  String get nameTooLongEn => _t('nameTooLongEn');
  String get appName => _t('appName');
  String get loginTab => _t('loginTab');
  String get registerTab => _t('registerTab');
  String get password => _t('password');
  String get loginBtn => _t('loginBtn');
  String get nicknameField => _t('nicknameField');
  String get confirmPassword => _t('confirmPassword');
  String get registerBtn => _t('registerBtn');
  String get networkError => _t('networkError');
  // 退出登录
  String get logout => _t('logout');
  String get logoutConfirmTitle => _t('logoutConfirmTitle');
  String get logoutConfirmMessage => _t('logoutConfirmMessage');
  // 账号绑定状态
  String get accountBound => _t('accountBound');
  String get accountNotBound => _t('accountNotBound');

  // 补充缺失的 getter
  String get account => _t('account');
  String get forgotPassword => _t('forgotPassword');
  String get comingSoon => _t('comingSoon');
  String get devices => _t('devices');
  String get voiceHint => _t('voiceHint');
  String get aiChat => _t('aiChat');
  String get lampControl => _t('lampControl');
  String get timerTask => _t('timerTask');
  String get quickCmd => _t('quickCmd');
  String get systemSettings => _t('systemSettings');
  String get aiOnline => _t('aiOnline');

  // 购买页 / 订单中心
  String get purchase => _t('purchase');
  String get orderManagement => _t('orderManagement');
  String get myOrders => _t('myOrders');
  String get viewAllOrders => _t('viewAllOrders');
  String get thlMagCharge7in1Name => _t('thlMagCharge7in1Name');
  String get featureMagCharge1 => _t('featureMagCharge1');
  String get featureMagCharge2 => _t('featureMagCharge2');
  String get featureMagCharge3 => _t('featureMagCharge3');
  String get featureMagCharge4 => _t('featureMagCharge4');
  String get featureMagCharge5 => _t('featureMagCharge5');
  String get featureMagCharge6 => _t('featureMagCharge6');
  String get thl65wAdapterName => _t('thl65wAdapterName');
  String get featureAdapter1 => _t('featureAdapter1');
  String get featureAdapter2 => _t('featureAdapter2');
  String get featureAdapter3 => _t('featureAdapter3');
  String get featureAdapter4 => _t('featureAdapter4');
  // 帮助与反馈页
  String get helpSection => _t('helpSection');
  String get feedbackSection => _t('feedbackSection');
  String get manualTitle => _t('manualTitle');
  String get feedbackProblem => _t('feedbackProblem');
  String get noContentFeedback => _t('noContentFeedback');
  // 反馈问题页 — 联系邮箱说明
  String get feedbackContent => _t('feedbackContent');

  // 帮助与反馈页 — 三个新栏目
  String get troubleshooting => _t('troubleshooting');
  String get troubleshootingTips => _t('troubleshootingTips');
  String get troubleshootingContent => _t('troubleshootingContent');
  String get shoppingFaq => _t('shoppingFaq');
  String get warrantyPolicy => _t('warrantyPolicy');
  // 关于 THL 页
  String get aboutThlHeading => _t('aboutThlHeading');
  String get aboutThlIntro => _t('aboutThlIntro');
  String get ourCorePhilosophy => _t('ourCorePhilosophy');
  String get techJoyLife => _t('techJoyLife');
  String get techJoyLifeDesc => _t('techJoyLifeDesc');
  String get techEmpowers => _t('techEmpowers');
  String get techEmpowersBody => _t('techEmpowersBody');
  String get joyInDetails => _t('joyInDetails');
  String get joyInDetailsBody => _t('joyInDetailsBody');
  String get forEveryLife => _t('forEveryLife');
  String get forEveryLifeBody => _t('forEveryLifeBody');

  String sunny(String temp) => isEnglish ? 'Sunny $temp' : '晴天 $temp';

  /// 将存储的状态值（可能是中文原值）翻译为当前语言的展示文案。
  String statusText(String raw) {
    switch (raw) {
      case '在线':
      case 'Online':
        return online;
      case '离开':
      case 'Away':
        return away;
      case '勿扰':
      case 'DND':
        return dnd;
      case '离线':
      case 'Offline':
        return offline;
      default:
        return raw;
    }
  }
}

/// 全局语言控制器：保存当前语言码，并允许 account_page 通知 App 重建。
class AppLocalizationsController {
  static String languageCode = 'zh';

  /// 由 XiaozhiApp 注册，account_page 切换语言后调用以重建整个 App。
  static void Function(Locale locale)? onLocaleChanged;

  static void setLocale(String code) {
    languageCode = code;
    onLocaleChanged?.call(Locale(code));
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
