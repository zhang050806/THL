import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [PrivacyPolicyPage] 隐私政策页面。
/// 展示 THL 隐私政策完整内容（英文原文 + 中文翻译双语展示）。
/// 内容来源：https://www.thl.com.cn/zh-cn/policies/privacy-policy
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 当前是否为英文模式，决定双语展示的显示权重
    final isEnglish = l10n.isEnglish;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏，带返回按钮
            PageHeaderWidget(
                title: l10n.privacyPolicy,
                onBack: () => Navigator.pop(context)),
            // 可滚动内容区域
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _PrivacyData.sections.map((section) {
                  return _sectionCard(section, isDark, isEnglish);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 单个隐私政策章节卡片
  Widget _sectionCard(
      _PrivacySection section, bool isDark, bool isEnglish) {
    final textColor =
        isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26);
    final cardColor =
        isDark ? const Color(0xFF161B22) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ]
            : const [
                BoxShadow(
                    color: Color(0x204A90E2),
                    blurRadius: 16,
                    offset: Offset(0, 4)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 章节标题（加粗大号字体）
          Text(
            isEnglish ? section.titleEn : section.titleZh,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          // 正文段落（仅显示当前语言版本）
          Text(
            isEnglish ? section.contentEn : section.contentZh,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// 隐私政策章节数据结构
class _PrivacySection {
  final String titleEn;
  final String titleZh;
  final String contentEn;
  final String contentZh;

  const _PrivacySection({
    required this.titleEn,
    required this.titleZh,
    required this.contentEn,
    required this.contentZh,
  });
}

/// 隐私政策完整数据
class _PrivacyData {
  static List<_PrivacySection> get sections => [
        _PrivacySection(
          titleEn: 'Introduction',
          titleZh: '引言',
          contentEn:
              'Last updated: March 15, 2025\n\n'
              'This Privacy Policy describes how THL (the "Site", "we", "us", or "our") collects, uses, and discloses your personal information when you visit, use our services, or make a purchase from thl.com.cn (the "Site") or otherwise communicate with us regarding the Site (collectively, the "Services"). For purposes of this Privacy Policy, "you" and "your" means you as the user of the Services, whether you are a customer, website visitor, or another individual whose information we have collected pursuant to this Privacy Policy.\n\n'
              'Please read this Privacy Policy carefully.',
          contentZh:
              '最后更新日期：2025 年 3 月 15 日\n\n'
              '本隐私政策描述了 THL（"网站"、"我们"、"我方"或"我们的"）在您访问、使用我们的服务或从 thl.com.cn（"网站"）购买商品，或以其他方式就网站与我们沟通时（统称为"服务"），如何收集、使用和披露您的个人信息。在本隐私政策中，"您"和"您的"指作为服务用户的您，无论您是客户、网站访问者还是我们根据本隐私政策收集了其信息的其他个人。\n\n'
              '请仔细阅读本隐私政策。',
        ),
        _PrivacySection(
          titleEn: 'Changes to This Privacy Policy',
          titleZh: '本隐私政策的变更',
          contentEn:
              'We may update this Privacy Policy from time to time, including to reflect changes to our practices or for other operational, legal, or regulatory reasons. We will post the revised Privacy Policy on the Site, update the "Last updated" date and take any other steps required by applicable law.',
          contentZh:
              '我们可能会不时更新本隐私政策，包括为反映我们的实践变化或其他运营、法律或监管原因。我们将在网站上发布修订后的隐私政策，更新"最后更新"日期，并采取适用法律要求的任何其他措施。',
        ),
        _PrivacySection(
          titleEn: 'How We Collect and Use Your Personal Information',
          titleZh: '我们如何收集和使用您的个人信息',
          contentEn:
              'To provide the Services, we collect and have collected over the past 12 months personal information about you from a variety of sources, as set out below. The information that we collect and use varies depending on how you interact with us.\n\n'
              'In addition to the specific uses set out below, we may use information we collect about you to communicate with you, provide or improve the Services, comply with any applicable legal obligations, enforce any applicable terms of service, and to protect or defend the Services, our rights, and the rights of our users or others.\n\n'
              '--- What Personal Information We Collect ---\n'
              'The types of personal information we obtain about you depends on how you interact with our Site and use our Services. When we use the term "personal information", we are referring to information that identifies, relates to, describes or can be associated with you.\n\n'
              '--- Information We Collect Directly from You ---\n'
              'Information that you directly submit to us through our Services may include:\n'
              '- Contact details including your name, address, phone number, and email.\n'
              '- Order information including your name, billing address, shipping address, payment confirmation, email address, and phone number.\n'
              '- Account information including your username, password, security questions and other information used for account security purposes.\n'
              '- Customer support information including the information you choose to include in communications with us.\n\n'
              'Some features of the Services may require you to directly provide us with certain information about yourself. You may elect not to provide this information, but doing so may prevent you from using or accessing these features.\n\n'
              '--- Information We Collect about Your Usage ---\n'
              'We may also automatically collect certain information about your interaction with the Services ("Usage Data"). To do this, we may use cookies, pixels and similar technologies ("Cookies"). Usage Data may include information about how you access and use our Site and your account, including device information, browser information, information about your network connection, your IP address and other information regarding your interaction with the Services.\n\n'
              '--- Information We Obtain from Third Parties ---\n'
              'Finally, we may obtain information about you from third parties, including from vendors and service providers who may collect information on our behalf, such as:\n'
              '- Companies who support our Site and Services, such as Shopify.\n'
              '- Our payment processors, who collect payment information to process your payment in order to fulfill your orders.\n'
              '- When you visit our Site, open or click on emails we send you, or interact with our Services or advertisements, we, or third parties we work with, may automatically collect certain information using online tracking technologies such as pixels, web beacons, software developer kits, third-party libraries, and cookies.\n\n'
              'Any information we obtain from third parties will be treated in accordance with this Privacy Policy.\n\n'
              '--- How We Use Your Personal Information ---\n'
              '- Providing Products and Services: We use your personal information to provide you with the Services in order to perform our contract with you, including to process your payments, fulfill your orders, to send notifications to you related to your account, purchases, returns, exchanges or other transactions, to create, maintain and otherwise manage your account, to arrange for shipping, facilitate any returns and exchanges and other features and functionalities related to your account.\n'
              '- Marketing and Advertising: We may use your personal information for marketing and promotional purposes, such as to send marketing, advertising and promotional communications by email, text message or postal mail, and to show you advertisements for products or services.\n'
              '- Security and Fraud Prevention: We use your personal information to detect, investigate or take action regarding possible fraudulent, illegal or malicious activity.\n'
              '- Communicating with You and Service Improvement: We use your personal information to provide you with customer support and improve our Services.',
          contentZh:
              '为提供服务，我们通过多种来源收集（并在过去 12 个月内已收集）您的个人信息，如下所述。我们收集和使用的信息因您与我们的互动方式而异。\n\n'
              '除下述特定用途外，我们可能使用我们收集的关于您的信息来与您沟通、提供或改进服务、遵守任何适用的法律义务、执行任何适用的服务条款，以及保护或捍卫服务、我们的权利以及用户或其他人的权利。\n\n'
              '--- 我们收集哪些个人信息 ---\n'
              '我们获取的关于您的个人信息类型取决于您如何与我们的网站互动以及如何使用我们的服务。当我们使用术语"个人信息"时，我们指的是能够识别、关联、描述或可与您关联的信息。\n\n'
              '--- 我们直接从您那里收集的信息 ---\n'
              '您通过我们的服务直接向我们提交的信息可能包括：\n'
              '- 联系方式，包括您的姓名、地址、电话号码和电子邮件。\n'
              '- 订单信息，包括您的姓名、账单地址、送货地址、付款确认、电子邮件地址和电话号码。\n'
              '- 账户信息，包括您的用户名、密码、安全问题以及用于账户安全的其他信息。\n'
              '- 客户支持信息，包括您选择在与我们沟通中包含的信息。\n\n'
              '服务的某些功能可能要求您直接向我们提供某些关于您自己的信息。您可以选择不提供这些信息，但这样做可能会阻止您使用或访问这些功能。\n\n'
              '--- 我们收集的关于您的使用情况的信息 ---\n'
              '我们还可能自动收集有关您与服务的互动的某些信息（"使用数据"）。为此，我们可能使用 Cookie、像素和类似技术（"Cookie"）。使用数据可能包括有关您如何访问和使用我们的网站及您的账户的信息，包括设备信息、浏览器信息、网络连接信息、您的 IP 地址以及有关您与服务互动的其他信息。\n\n'
              '--- 我们从第三方获取的信息 ---\n'
              '最后，我们可能从第三方获取关于您的信息，包括可能代表我们收集信息的供应商和服务提供商，例如：\n'
              '- 支持我们网站和服务的公司，如 Shopify。\n'
              '- 我们的支付处理商，他们收集付款信息以处理您的付款以完成您的订单。\n'
              '- 当您访问我们的网站、打开或点击我们发送的电子邮件，或与我们的服务或广告互动时，我们或与我们合作的第三方可能使用在线跟踪技术（如像素、网络信标、软件开发工具包、第三方库和 Cookie）自动收集某些信息。\n\n'
              '我们从第三方获得的任何信息将按照本隐私政策处理。\n\n'
              '--- 我们如何使用您的个人信息 ---\n'
              '- 提供产品和服务：我们使用您的个人信息为您提供服务以履行我们与您的合同，包括处理付款、完成订单、向您发送与账户、购买、退货、换货或其他交易相关的通知，创建、维护和管理您的账户，安排发货，促进退货和换货以及与账户相关的其他功能。\n'
              '- 营销和广告：我们可能将您的个人信息用于营销和促销目的，例如通过电子邮件、短信或邮寄方式发送营销、广告和促销通讯，以及向您展示产品或服务的广告。\n'
              '- 安全和防欺诈：我们使用您的个人信息来检测、调查或对可能的欺诈、非法或恶意活动采取行动。\n'
              '- 与您沟通和服务改进：我们使用您的个人信息为您提供客户支持并改进我们的服务。',
        ),
        _PrivacySection(
          titleEn: 'Cookies',
          titleZh: 'Cookie',
          contentEn:
              'Like many websites, we use Cookies on our Site. For specific information about the Cookies that we use related to powering our store with Shopify, see https://www.shopify.com/legal/cookies. We use Cookies to power and improve our Site and our Services (including to remember your actions and preferences), to run analytics and better understand user interaction with the Services (in our legitimate interests to administer, improve and optimize the Services). We may also permit third parties and services providers to use Cookies on our Site to better tailor the services, products and advertising on our Site and other websites.\n\n'
              'Most browsers automatically accept Cookies by default, but you can choose to set your browser to remove or reject Cookies through your browser controls. Please keep in mind that removing or blocking Cookies can negatively impact your user experience and may cause some of the Services, including certain features and general functionality, to work incorrectly or no longer be available. Additionally, blocking Cookies may not completely prevent how we share information with third parties such as our advertising partners.\n\n'
              'Our website also recognizes the Global Privacy Control (GPC) signal, which enables you to opt-out of certain uses or disclosures of your information. If you notify us of your preference through GPC, we will treat such signal as a valid request to opt out of sharing / targeted advertising for the associated browser or device.',
          contentZh:
              '与许多网站一样，我们在网站上使用 Cookie。有关我们用于支持 Shopify 商店的 Cookie 的具体信息，请参阅 https://www.shopify.com/legal/cookies。我们使用 Cookie 来支持和改进我们的网站和服务（包括记住您的操作和偏好），运行分析以更好地了解用户与服务互动（出于我们管理、改进和优化服务的合法利益）。我们还可能允许第三方和服务提供商在我们的网站上使用 Cookie，以更好地定制我们网站和其他网站上的服务、产品和广告。\n\n'
              '大多数浏览器默认自动接受 Cookie，但您可以通过浏览器控件设置浏览器删除或拒绝 Cookie。请记住，删除或阻止 Cookie 可能会对您的用户体验产生负面影响，并可能导致某些服务（包括某些功能和一般功能）运行不正常或不再可用。此外，阻止 Cookie 可能无法完全阻止我们与第三方（如我们的广告合作伙伴）共享信息。\n\n'
              '我们的网站还识别全球隐私控制（GPC）信号，该信号使您能够选择退出某些使用或披露您的信息。如果您通过 GPC 通知我们您的偏好，我们将把该信号视为对相关浏览器或设备选择退出共享/定向广告的有效请求。',
        ),
        _PrivacySection(
          titleEn: 'How We Disclose Personal Information',
          titleZh: '我们如何披露个人信息',
          contentEn:
              'In certain circumstances, we may disclose your personal information to third parties for contract fulfillment purposes, legitimate purposes and other reasons subject to this Privacy Policy. Such circumstances may include:\n'
              '- With vendors or other third parties who perform services on our behalf (e.g., IT management, payment processing, data analytics, customer support, cloud storage, fulfillment and shipping).\n'
              '- With business and marketing partners to provide services and advertise to you.\n'
              '- When you direct, request us or otherwise consent to our disclosure of certain information to third parties, such as to ship you products or through your use of social media widgets or login integrations, with your consent.\n'
              '- With our affiliates or otherwise within our corporate group, in our legitimate interests to run a successful business.\n'
              '- In connection with a business transaction such as a merger or bankruptcy, to comply with any applicable legal obligations (including to respond to subpoenas, search warrants and similar requests), to enforce any applicable terms of service, and to protect or defend the Services, our rights, and the rights of our users or others.\n\n'
              'We have in the past 12 months disclosed the following categories of personal information: Identifiers (basic contact details, order and account information), Commercial information (order information, shopping information, customer support information), Internet or other similar network activity (Usage Data), Geolocation data, to vendors and third parties who perform services on our behalf, business and marketing partners, and affiliates.\n\n'
              'We do not use or disclose sensitive personal information without your consent or for the purposes of inferring characteristics about you.',
          contentZh:
              '在某些情况下，我们可能出于合同履行目的、合法目的以及本隐私政策项下的其他原因向第三方披露您的个人信息。此类情况可能包括：\n'
              '- 与代表我们执行服务的供应商或其他第三方（例如，IT 管理、支付处理、数据分析、客户支持、云存储、履行和运输）。\n'
              '- 与业务和营销合作伙伴一起提供服务并向您进行广告宣传。\n'
              '- 当您指示、要求我们或以其他方式同意我们向第三方披露某些信息时，例如为您运送产品或通过您使用社交媒体小部件或登录集成，经您同意。\n'
              '- 与我们的关联公司或公司集团内部，出于我们经营成功业务的合法利益。\n'
              '- 与商业交易（如合并或破产）相关，为遵守任何适用的法律义务（包括回应传票、搜查令和类似请求），执行任何适用的服务条款，以及保护或捍卫服务、我们的权利以及用户或其他人的权利。\n\n'
              '在过去 12 个月中，我们已向代表我们执行服务的供应商和第三方、业务和营销合作伙伴以及关联公司披露了以下类别的个人信息：标识符（基本联系方式、订单和账户信息）、商业信息（订单信息、购物信息、客户支持信息）、互联网或其他类似网络活动（使用数据）、地理位置数据。\n\n'
              '未经您的同意或出于推断您特征的目的，我们不使用或披露敏感个人信息。',
        ),
        _PrivacySection(
          titleEn: 'Third Party Websites and Links',
          titleZh: '第三方网站和链接',
          contentEn:
              'Our Site may provide links to websites or other online platforms operated by third parties. If you follow links to sites not affiliated or controlled by us, you should review their privacy and security policies and other terms and conditions. We do not guarantee and are not responsible for the privacy or security of such sites, including the accuracy, completeness, or reliability of information found on these sites. Information you provide on public or semi-public venues, including information you share on third-party social networking platforms may also be viewable by other users of the Services and/or users of those third-party platforms without limitation as to its use by us or by a third party. Our inclusion of such links does not, by itself, imply any endorsement of the content on such platforms or of their owners or operators, except as disclosed on the Services.',
          contentZh:
              '我们的网站可能提供指向第三方运营的网站或其他在线平台的链接。如果您跟随链接访问与我们无关或不受我们控制的网站，您应查看其隐私和安全政策及其他条款和条件。我们不保证也不对此类网站的隐私或安全性负责，包括在这些网站上找到的信息的准确性、完整性或可靠性。您在公共或半公共场所提供的信息，包括您在第三方社交网络平台上分享的信息，也可能被服务的其他用户和/或这些第三方平台的用户查看，对其使用由我们或第三方不受限制。我们包含此类链接本身并不意味着对此类平台上的内容或其所有者或运营者的任何认可，除非在服务中另有披露。',
        ),
        _PrivacySection(
          titleEn: "Children's Data",
          titleZh: '儿童数据',
          contentEn:
              'The Services are not intended to be used by children, and we do not knowingly collect any personal information about children. If you are the parent or guardian of a child who has provided us with their personal information, you may contact us using the contact details set out below to request that it be deleted.\n\n'
              'As of the Effective Date of this Privacy Policy, we do not have actual knowledge that we "share" or "sell" (as those terms are defined in applicable law) personal information of individuals under 16 years of age.',
          contentZh:
              '本服务不旨在供儿童使用，我们不会故意收集任何关于儿童的个人信息。如果您是向我们提供了其个人信息的儿童的父母或监护人，您可以使用下方列出的联系信息联系我们，要求删除该信息。\n\n'
              '截至本隐私政策生效日期，我们并不实际知道我们"共享"或"出售"（根据适用法律的定义）16 岁以下个人的个人信息。',
        ),
        _PrivacySection(
          titleEn: 'Security and Retention of Your Information',
          titleZh: '信息的安全和保留',
          contentEn:
              'Please be aware that no security measures are perfect or impenetrable, and we cannot guarantee "perfect security." In addition, any information you send to us may not be secure while in transit. We recommend that you do not use insecure channels to communicate sensitive or confidential information to us.\n\n'
              'How long we retain your personal information depends on different factors, such as whether we need the information to maintain your account, to provide the Services, comply with legal obligations, resolve disputes or enforce other applicable contracts and policies.',
          contentZh:
              '请注意，没有任何安全措施是完美或无懈可击的，我们无法保证"绝对安全"。此外，您发送给我们的任何信息在传输过程中可能不安全。我们建议您不要使用不安全的渠道向我们传达敏感或机密信息。\n\n'
              '我们保留您个人信息的时间长度取决于不同因素，例如我们是否需要该信息来维护您的账户、提供服务、遵守法律义务、解决争议或执行其他适用的合同和政策。',
        ),
        _PrivacySection(
          titleEn: 'Your Rights',
          titleZh: '您的权利',
          contentEn:
              'Depending on where you live, you may have some or all of the rights listed below in relation to your personal information. However, these rights are not absolute, may apply only in certain circumstances and, in certain cases, we may decline your request as permitted by law.\n\n'
              '- Right to Access / Know: You may have a right to request access to personal information that we hold about you, including details relating to the ways in which we use and share your information.\n'
              '- Right to Delete: You may have a right to request that we delete personal information we maintain about you.\n'
              '- Right to Correct: You may have a right to request that we correct inaccurate personal information we maintain about you.\n'
              '- Right of Portability: You may have a right to receive a copy of the personal information we hold about you and to request that we transfer it to a third party, in certain circumstances and with certain exceptions.\n'
              '- Right to Opt out of Sale or Sharing or Targeted Advertising: You may have a right to direct us not to "sell" or "share" your personal information or to opt out of the processing of your personal information for purposes considered to be "targeted advertising".\n'
              '- Restriction of Processing: You may have the right to ask us to stop or restrict our processing of personal information.\n'
              '- Withdrawal of Consent: Where we rely on consent to process your personal information, you may have the right to withdraw this consent.\n'
              '- Appeal: You may have a right to appeal our decision if we decline to process your request.\n'
              '- Managing Communication Preferences: We may send you promotional emails, and you may opt out of receiving these at any time by using the unsubscribe option displayed in our emails to you.\n\n'
              'You may exercise any of these rights where indicated on our Site or by contacting us using the contact details provided below. We will not discriminate against you for exercising any of these rights.',
          contentZh:
              '根据您居住的地方，您可能拥有以下关于您的个人信息的全部或部分权利。然而，这些权利不是绝对的，可能仅在某些情况下适用，并且在某些情况下，我们可能根据法律允许拒绝您的请求。\n\n'
              '- 访问/知情权：您可能有权要求访问我们持有的关于您的个人信息，包括有关我们使用和分享您信息的方式的详细信息。\n'
              '- 删除权：您可能有权要求我们删除我们维护的关于您的个人信息。\n'
              '- 更正权：您可能有权要求我们更正我们维护的关于您的不准确个人信息。\n'
              '- 可携带权：在某些情况下且有某些例外，您可能有权接收我们持有的关于您的个人信息的副本，并要求我们将其转移给第三方。\n'
              '- 选择退出销售或共享或定向广告的权利：您可能有权指示我们不要"出售"或"共享"您的个人信息，或选择退出为"定向广告"目的处理您的个人信息。\n'
              '- 限制处理：您可能有权要求我们停止或限制我们对个人信息的处理。\n'
              '- 撤回同意：在我们依赖同意处理您的个人信息的情况下，您可能有权撤回此同意。\n'
              '- 申诉：如果我们拒绝处理您的请求，您可能有权对我们的决定提出申诉。\n'
              '- 管理通讯偏好：我们可能向您发送促销电子邮件，您可以随时使用我们电子邮件中显示的取消订阅选项选择不接收这些邮件。\n\n'
              '您可以在我们网站上指示的地方或使用下面提供的联系方式联系我们行使任何这些权利。我们不会因您行使任何这些权利而歧视您。',
        ),
        _PrivacySection(
          titleEn: 'Complaints',
          titleZh: '投诉',
          contentEn:
              'If you have complaints about how we process your personal information, please contact us using the contact details provided below. If you are not satisfied with our response to your complaint, depending on where you live you may have the right to appeal our decision by contacting us using the contact details set out below, or lodge your complaint with your local data protection authority.',
          contentZh:
              '如果您对我们处理您个人信息的方式有投诉，请使用下方提供的联系方式联系我们。如果您对我们对您投诉的回应不满意，根据您居住的地方，您可能有权通过使用下方列出的联系方式联系我们申诉我们的决定，或向您当地的数据保护机构提出投诉。',
        ),
        _PrivacySection(
          titleEn: 'International Users',
          titleZh: '国际用户',
          contentEn:
              'Please note that we may transfer, store and process your personal information outside the country you live in. Your personal information is also processed by staff and third party service providers and partners in these countries.\n\n'
              'If we transfer your personal information out of Europe, we will rely on recognized transfer mechanisms like the European Commission\'s Standard Contractual Clauses, or any equivalent contracts issued by the relevant competent authority of the UK, as relevant, unless the data transfer is to a country that has been determined to provide an adequate level of protection.',
          contentZh:
              '请注意，我们可能在您居住的国家以外传输、存储和处理您的个人信息。您的个人信息也由这些国家的员工和第三方服务提供商及合作伙伴处理。\n\n'
              '如果我们将您的个人信息转移出欧洲，我们将依赖公认的传输机制，如欧盟委员会的标准合同条款，或英国相关主管机构发布的任何等效合同（如适用），除非数据传输至已被确定提供足够保护水平的国家。',
        ),
        _PrivacySection(
          titleEn: 'Contact',
          titleZh: '联系方式',
          contentEn:
              'Should you have any questions about our privacy practices or this Privacy Policy, or if you would like to exercise any of the rights available to you, please call or email us at ishunhang@163.com or contact us at Shenzhen, GD, 518103, CN.\n\n'
              'For the purpose of applicable data protection laws and if not explicitly stated otherwise, we are the data controller of your personal information.',
          contentZh:
              '如果您对我们的隐私实践或本隐私政策有任何疑问，或者如果您想行使任何可用的权利，请致电或发送电子邮件至 ishunhang@163.com，或通过深圳市，广东省，518103，中国联系我们。\n\n'
              '就适用的数据保护法律而言，除非另有明确说明，我们是您个人信息的数据控制者。',
        ),
      ];
}
