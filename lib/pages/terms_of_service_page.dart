import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [TermsOfServicePage] 服务条款页面。
/// 展示 THL 服务条款完整内容（英文原文 + 中文翻译双语展示）。
/// 内容来源：https://www.thl.com.cn/zh-cn/policies/terms-of-service
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 当前是否为英文模式，决定双语展示的顺序
    final isEnglish = l10n.isEnglish;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏，带返回按钮
            PageHeaderWidget(
                title: l10n.termsOfService,
                onBack: () => Navigator.pop(context)),
            // 可滚动内容区域
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _buildSections(isDark, isEnglish),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建所有条款章节的卡片列表
  List<Widget> _buildSections(bool isDark, bool isEnglish) {
    return sections
        .map((section) => _sectionCard(section, isDark, isEnglish))
        .toList();
  }

  /// 单个条款章节卡片
  /// 章节标题加粗大字体，正文双语展示
  Widget _sectionCard(
      _SectionData section, bool isDark, bool isEnglish) {
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

  /// ===== 服务条款数据（共 OVERVIEW + 20 个 SECTION）=====

  /// 获取所有条款章节数据
  static List<_SectionData> get sections => [
        _SectionData(
          titleEn: 'OVERVIEW',
          titleZh: '概述',
          contentEn:
              'This website is operated by THL. Throughout the site, the terms "we", "us" and "our" refer to THL. THL offers this website, including all information, tools and Services available from this site to you, the user, conditioned upon your acceptance of all terms, conditions, policies and notices stated here.\n\n'
              'By visiting our site and/or purchasing something from us, you engage in our "Service" and agree to be bound by the following terms and conditions ("Terms of Service", "Terms"), including those additional terms and conditions and policies referenced herein and/or available by hyperlink. These Terms of Service apply to all users of the site, including without limitation users who are browsers, vendors, customers, merchants, and/or contributors of content.\n\n'
              'Please read these Terms of Service carefully before accessing or using our website. By accessing or using any part of the site, you agree to be bound by these Terms of Service. If you do not agree to all the terms and conditions of this agreement, then you may not access the website or use any Services. If these Terms of Service are considered an offer, acceptance is expressly limited to these Terms of Service.\n\n'
              'Any new features or tools which are added to the current store shall also be subject to the Terms of Service. You can review the most current version of the Terms of Service at any time on this page. We reserve the right to update, change or replace any part of these Terms of Service by posting updates and/or changes to our website. It is your responsibility to check this page periodically for changes. Your continued use of or access to the website following the posting of any changes constitutes acceptance of those changes.\n\n'
              'Our store is hosted on Shopify Inc. They provide us with the online e-commerce platform that allows us to sell our products and Services to you.',
          contentZh:
              '本网站由 THL 运营。在本网站中，"我们"、"我方"和"我们的"均指 THL。THL 向您（用户）提供本网站及其中包含的所有信息、工具和服务，前提是您接受此处列出的所有条款、条件、政策和通知。\n\n'
              '访问我们的网站和/或从我们这里购买商品，即表示您参与了我们的"服务"，并同意受以下条款和条件（"服务条款"、"条款"）的约束，包括本文引用和/或通过超链接提供的附加条款、条件和政策。本服务条款适用于本网站的所有用户，包括但不限于浏览者、供应商、客户、商家和/或内容贡献者。\n\n'
              '在访问或使用我们的网站之前，请仔细阅读本服务条款。访问或使用本网站的任何部分，即表示您同意受本服务条款的约束。如果您不同意本协议的所有条款和条件，则不得访问本网站或使用任何服务。如果本服务条款被视为要约，则接受明确限于本服务条款。\n\n'
              '添加到当前商店的任何新功能或工具也应受本服务条款的约束。您可以随时在此页面上查看最新版本的服务条款。我们保留通过在网站上发布更新和/或更改来更新、更改或替换本服务条款任何部分的权利。您有责任定期检查此页面以了解更改。您在发布任何更改后继续使用或访问本网站即表示接受这些更改。\n\n'
              '我们的商店托管在 Shopify Inc. 上。他们为我们提供在线电子商务平台，使我们能够向您销售我们的产品和服务。',
        ),
        _SectionData(
          titleEn: 'SECTION 1 - ONLINE STORE TERMS',
          titleZh: '第 1 节 - 在线商店条款',
          contentEn:
              'By agreeing to these Terms of Service, you represent that you are at least the age of majority in your state or province of residence, or that you are the age of majority in your state or province of residence and you have given us your consent to allow any of your minor dependents to use this site.\n'
              'You may not use our products for any illegal or unauthorized purpose nor may you, in the use of the Service, violate any laws in your jurisdiction (including but not limited to copyright laws).\n'
              'You must not transmit any worms or viruses or any code of a destructive nature.\n'
              'A breach or violation of any of the Terms will result in an immediate termination of your Services.',
          contentZh:
              '同意本服务条款，即表示您声明您已年满您居住所在州或省的法定成年年龄，或者您已年满法定成年年龄并且您已同意允许您的未成年家属使用本网站。\n'
              '您不得将我们的产品用于任何非法或未经授权的目的，也不得在使用服务时违反您所在司法管辖区的任何法律（包括但不限于版权法）。\n'
              '您不得传播任何蠕虫、病毒或任何具有破坏性质的代码。\n'
              '违反任何条款将导致您的服务立即终止。',
        ),
        _SectionData(
          titleEn: 'SECTION 2 - GENERAL CONDITIONS',
          titleZh: '第 2 节 - 一般条件',
          contentEn:
              'We reserve the right to refuse Service to anyone for any reason at any time.\n'
              'You understand that your content (not including credit card information), may be transferred unencrypted and involve (a) transmissions over various networks; and (b) changes to conform and adapt to technical requirements of connecting networks or devices. Credit card information is always encrypted during transfer over networks.\n'
              'You agree not to reproduce, duplicate, copy, sell, resell or exploit any portion of the Service, use of the Service, or access to the Service or any contact on the website through which the Service is provided, without express written permission by us.\n'
              'The headings used in this agreement are included for convenience only and will not limit or otherwise affect these Terms.',
          contentZh:
              '我们保留随时以任何理由拒绝向任何人提供服务的权利。\n'
              '您理解您的内容（不包括信用卡信息）可能会以未加密方式传输，并涉及 (a) 通过各种网络的传输；以及 (b) 为符合和适应连接网络或设备的技术要求而进行的更改。信用卡信息在网络传输过程中始终加密。\n'
              '未经我们明确的书面许可，您同意不复制、复刻、拷贝、出售、转售或利用服务的任何部分、服务的使用或对服务的访问，或通过服务提供的网站上的任何联系信息。\n'
              '本协议中使用的标题仅为方便起见，不会限制或以其他方式影响本条款。',
        ),
        _SectionData(
          titleEn: 'SECTION 3 - ACCURACY, COMPLETENESS AND TIMELINESS OF INFORMATION',
          titleZh: '第 3 节 - 信息的准确性、完整性和及时性',
          contentEn:
              'We are not responsible if information made available on this site is not accurate, complete or current. The material on this site is provided for general information only and should not be relied upon or used as the sole basis for making decisions without consulting primary, more accurate, more complete or more timely sources of information. Any reliance on the material on this site is at your own risk.\n'
              'This site may contain certain historical information. Historical information, necessarily, is not current and is provided for your reference only. We reserve the right to modify the contents of this site at any time, but we have no obligation to update any information on our site. You agree that it is your responsibility to monitor changes to our site.',
          contentZh:
              '如果本网站上的信息不准确、不完整或不及时，我们不承担责任。本网站上的材料仅供一般参考，不应依赖或用作决策的唯一依据，而不咨询更主要、更准确、更完整或更及时的信息来源。依赖本网站材料的风险由您自行承担。\n'
              '本网站可能包含某些历史信息。历史信息必然不是最新的，仅供您参考。我们保留随时修改本网站内容的权利，但我们没有义务更新我们网站上的任何信息。您同意您有责任监控我们网站的更改。',
        ),
        _SectionData(
          titleEn: 'SECTION 4 - MODIFICATIONS TO THE SERVICE AND PRICES',
          titleZh: '第 4 节 - 服务和价格的修改',
          contentEn:
              'Prices for our products are subject to change without notice.\n'
              'We reserve the right at any time to modify or discontinue the Service (or any part or content thereof) without notice at any time.\n'
              'We shall not be liable to you or to any third-party for any modification, price change, suspension or discontinuance of the Service.',
          contentZh:
              '我们产品的价格如有更改，恕不另行通知。\n'
              '我们保留随时修改或终止服务（或其任何部分或内容）的权利，恕不另行通知。\n'
              '对于服务的任何修改、价格变动、暂停或终止，我们不对您或任何第三方承担责任。',
        ),
        _SectionData(
          titleEn: 'SECTION 5 - PRODUCTS OR SERVICES',
          titleZh: '第 5 节 - 产品或服务',
          contentEn:
              'Certain products or Services may be available exclusively online through the website. These products or Services may have limited quantities and are subject to return or exchange only according to our Refund Policy.\n'
              'We have made every effort to display as accurately as possible the colors and images of our products that appear at the store. We cannot guarantee that your computer monitor\'s display of any color will be accurate.\n'
              'We reserve the right, but are not obligated, to limit the sales of our products or Services to any person, geographic region or jurisdiction. We may exercise this right on a case-by-case basis. We reserve the right to limit the quantities of any products or Services that we offer. All descriptions of products or product pricing are subject to change at anytime without notice, at the sole discretion of us. We reserve the right to discontinue any product at any time. Any offer for any product or Service made on this site is void where prohibited.\n'
              'We do not warrant that the quality of any products, Services, information, or other material purchased or obtained by you will meet your expectations, or that any errors in the Service will be corrected.',
          contentZh:
              '某些产品或服务可能仅通过网站在线提供。这些产品或服务的数量可能有限，且仅根据我们的退款政策进行退货或换货。\n'
              '我们已尽一切努力尽可能准确地显示商店中出现的产品颜色和图像。我们无法保证您的电脑显示器显示的任何颜色都是准确的。\n'
              '我们保留（但无义务）限制向任何个人、地理区域或司法管辖区销售我们的产品或服务的权利。我们可以根据具体情况行使此权利。我们保留限制所提供任何产品或服务数量的权利。所有产品描述或产品定价可随时更改，恕不另行通知，由我们自行决定。我们保留随时停止任何产品的权利。本网站上的任何产品或服务要约在禁止的地方无效。\n'
              '我们不保证您购买或获得的任何产品、服务、信息或其他材料的质量将满足您的期望，也不保证服务中的任何错误将被纠正。',
        ),
        _SectionData(
          titleEn: 'SECTION 6 - ACCURACY OF BILLING AND ACCOUNT INFORMATION',
          titleZh: '第 6 节 - 账单和账户信息的准确性',
          contentEn:
              'We reserve the right to refuse any order you place with us. We may, in our sole discretion, limit or cancel quantities purchased per person, per household or per order. These restrictions may include orders placed by or under the same customer account, the same credit card, and/or orders that use the same billing and/or shipping address. In the event that we make a change to or cancel an order, we may attempt to notify you by contacting the email and/or billing address/phone number provided at the time the order was made. We reserve the right to limit or prohibit orders that, in our sole judgment, appear to be placed by dealers, resellers or distributors.\n\n'
              'You agree to provide current, complete and accurate purchase and account information for all purchases made at our store. You agree to promptly update your account and other information, including your email address and credit card numbers and expiration dates, so that we can complete your transactions and contact you as needed.\n\n'
              'For more details, please review our Refund Policy.',
          contentZh:
              '我们保留拒绝您向我们下的任何订单的权利。我们可以自行决定限制或取消每人、每户或每笔订单的购买数量。这些限制可能包括由同一客户账户、同一信用卡下的订单，和/或使用相同账单和/或送货地址的订单。如果我们更改或取消订单，我们可能会尝试通过联系下订单时提供的电子邮件和/或账单地址/电话号码来通知您。我们保留限制或禁止我们自行判断似乎由经销商、转售商或分销商下达的订单的权利。\n\n'
              '您同意为在我们商店进行的所有购买提供最新、完整和准确的购买和账户信息。您同意及时更新您的账户和其他信息，包括您的电子邮件地址、信用卡号和有效期，以便我们能够完成交易并在需要时联系您。\n\n'
              '有关更多详细信息，请查看我们的退款政策。',
        ),
        _SectionData(
          titleEn: 'SECTION 7 - OPTIONAL TOOLS',
          titleZh: '第 7 节 - 可选工具',
          contentEn:
              'We may provide you with access to third-party tools over which we neither monitor nor have any control nor input.\n'
              'You acknowledge and agree that we provide access to such tools "as is" and "as available" without any warranties, representations or conditions of any kind and without any endorsement. We shall have no liability whatsoever arising from or relating to your use of optional third-party tools.\n'
              'Any use by you of the optional tools offered through the site is entirely at your own risk and discretion and you should ensure that you are familiar with and approve of the terms on which tools are provided by the relevant third-party provider(s).\n'
              'We may also, in the future, offer new Services and/or features through the website (including the release of new tools and resources). Such new features and/or Services shall also be subject to these Terms of Service.',
          contentZh:
              '我们可能会向您提供对第三方工具的访问权限，我们对这些工具既不监控也没有任何控制或输入权。\n'
              '您承认并同意我们提供的此类工具访问"按原样"和"按可用状态"提供，不附带任何形式的保证、陈述或条件，也没有任何认可。对于您使用可选第三方工具产生的或与之相关的任何责任，我们概不负责。\n'
              '您使用通过本网站提供的可选工具完全由您自行承担风险和判断，您应确保您熟悉并认可相关第三方提供商提供工具的条款。\n'
              '我们还可能在未来通过网站提供新的服务和/或功能（包括发布新工具和资源）。此类新功能和/或服务也应受本服务条款的约束。',
        ),
        _SectionData(
          titleEn: 'SECTION 8 - THIRD-PARTY LINKS',
          titleZh: '第 8 节 - 第三方链接',
          contentEn:
              'Certain content, products and Services available via our Service may include materials from third-parties.\n'
              'Third-party links on this site may direct you to third-party websites that are not affiliated with us. We are not responsible for examining or evaluating the content or accuracy and we do not warrant and will not have any liability or responsibility for any third-party materials or websites, or for any other materials, products, or Services of third-parties.\n'
              'We are not liable for any harm or damages related to the purchase or use of goods, Services, resources, content, or any other transactions made in connection with any third-party websites. Please review carefully the third-party\'s policies and practices and make sure you understand them before you engage in any transaction. Complaints, claims, concerns, or questions regarding third-party products should be directed to the third-party.',
          contentZh:
              '通过我们的服务提供的某些内容、产品和服务可能包含来自第三方的材料。\n'
              '本网站上的第三方链接可能会将您引导至与我们的无关的第三方网站。我们不负责检查或评估内容或准确性，我们对任何第三方材料或网站，或任何其他第三方材料、产品或服务不作任何保证，也不承担任何责任。\n'
              '对于与任何第三方网站相关的商品、服务、资源、内容的购买或使用，或任何其他交易，我们不承担任何损害赔偿责任。在进行任何交易之前，请仔细查看第三方的政策和做法，并确保您理解它们。有关第三方产品的投诉、索赔、担忧或问题应直接向第三方提出。',
        ),
        _SectionData(
          titleEn: 'SECTION 9 - USER COMMENTS, FEEDBACK AND OTHER SUBMISSIONS',
          titleZh: '第 9 节 - 用户评论、反馈和其他提交内容',
          contentEn:
              'If, at our request, you send certain specific submissions (for example contest entries) or without a request from us, you send creative ideas, suggestions, proposals, plans, or other materials, whether online, by email, by postal mail, or otherwise (collectively, "comments"), you agree that we may, at any time, without restriction, edit, copy, publish, distribute, translate and otherwise use in any medium any comments that you forward to us. We are and shall be under no obligation (1) to maintain any comments in confidence; (2) to pay compensation for any comments; or (3) to respond to any comments.\n'
              'We may, but have no obligation to, monitor, edit or remove content that we determine in our sole discretion to be unlawful, offensive, threatening, libelous, defamatory, pornographic, obscene or otherwise objectionable or violates any party\'s intellectual property or these Terms of Service.\n'
              'You agree that your comments will not violate any right of any third-party, including copyright, trademark, privacy, personality or other personal or proprietary right. You further agree that your comments will not contain libelous or otherwise unlawful, abusive or obscene material, or contain any computer virus or other malware that could in any way affect the operation of the Service or any related website. You may not use a false email address, pretend to be someone other than yourself, or otherwise mislead us or third-parties as to the origin of any comments. You are solely responsible for any comments you make and their accuracy. We take no responsibility and assume no liability for any comments posted by you or any third-party.',
          contentZh:
              '如果您应我们的要求发送某些特定的投稿（例如竞赛参赛作品），或者您在没有我们要求的情况下主动发送创意想法、建议、提案、计划或其他材料，无论是通过在线、电子邮件、邮寄还是其他方式（统称为"评论"），您同意我们可以在任何时间、不受限制地编辑、复制、发布、分发、翻译和以其他方式在任何媒介中使用您转发给我们的任何评论。我们没有义务 (1) 对任何评论保密；(2) 为任何评论支付报酬；或 (3) 回应任何评论。\n'
              '我们可以（但没有义务）监控、编辑或删除我们自行判断为非法的、冒犯性的、威胁性的、诽谤的、中伤的、色情的、淫秽的或其他令人反感的，或侵犯任何一方的知识产权或本服务条款的内容。\n'
              '您同意您的评论不会侵犯任何第三方的任何权利，包括版权、商标、隐私、人格或其他个人或专有权利。您进一步同意，您的评论不会包含诽谤或其他非法、辱骂或淫秽的材料，也不会包含任何可能以任何方式影响服务或任何相关网站运行的计算机病毒或其他恶意软件。您不得使用虚假的电子邮件地址，冒充他人，或以其他方式误导我们或第三方关于评论的来源。您对您发表的任何评论及其准确性承担全部责任。对于您或任何第三方发布的任何评论，我们不承担任何责任。',
        ),
        _SectionData(
          titleEn: 'SECTION 10 - PERSONAL INFORMATION',
          titleZh: '第 10 节 - 个人信息',
          contentEn:
              'Your submission of personal information through the store is governed by our Privacy Policy, which can be viewed on our website.',
          contentZh:
              '您通过商店提交个人信息受我们的隐私政策管辖，该政策可在我们的网站上查看。',
        ),
        _SectionData(
          titleEn: 'SECTION 11 - ERRORS, INACCURACIES AND OMISSIONS',
          titleZh: '第 11 节 - 错误、不准确和遗漏',
          contentEn:
              'Occasionally there may be information on our site or in the Service that contains typographical errors, inaccuracies or omissions that may relate to product descriptions, pricing, promotions, offers, product shipping charges, transit times and availability. We reserve the right to correct any errors, inaccuracies or omissions, and to change or update information or cancel orders if any information in the Service or on any related website is inaccurate at any time without prior notice (including after you have submitted your order).\n'
              'We undertake no obligation to update, amend or clarify information in the Service or on any related website, including without limitation, pricing information, except as required by law. No specified update or refresh date applied in the Service or on any related website, should be taken to indicate that all information in the Service or on any related website has been modified or updated.',
          contentZh:
              '我们的网站或服务中偶尔可能出现包含印刷错误、不准确或遗漏的信息，这些信息可能与产品描述、定价、促销、优惠、产品运费、运输时间和可用性有关。我们保留随时更正任何错误、不准确或遗漏的权利，并在服务或任何相关网站上的任何信息不准确时更改或更新信息或取消订单，恕不另行通知（包括在您提交订单之后）。\n'
              '除法律要求外，我们没有义务更新、修改或澄清服务或任何相关网站上的信息，包括但不限于定价信息。服务或任何相关网站中未指定更新或刷新日期，不应视为表明服务或任何相关网站上的所有信息已被修改或更新。',
        ),
        _SectionData(
          titleEn: 'SECTION 12 - PROHIBITED USES',
          titleZh: '第 12 节 - 禁止用途',
          contentEn:
              'In addition to other prohibitions as set forth in the Terms of Service, you are prohibited from using the site or its content: (a) for any unlawful purpose; (b) to solicit others to perform or participate in any unlawful acts; (c) to violate any international, federal, provincial or state regulations, rules, laws, or local ordinances; (d) to infringe upon or violate our intellectual property rights or the intellectual property rights of others; (e) to harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate based on gender, sexual orientation, religion, ethnicity, race, age, national origin, or disability; (f) to submit false or misleading information; (g) to upload or transmit viruses or any other type of malicious code that will or may be used in any way that will affect the functionality or operation of the Service or of any related website, other websites, or the Internet; (h) to collect or track the personal information of others; (i) to spam, phish, pharm, pretext, spider, crawl, or scrape; (j) for any obscene or immoral purpose; or (k) to interfere with or circumvent the security features of the Service or any related website, other websites, or the Internet. We reserve the right to terminate your use of the Service or any related website for violating any of the prohibited uses.',
          contentZh:
              '除服务条款中规定的其他禁止事项外，您不得将本网站或其内容用于：(a) 任何非法目的；(b) 教唆他人实施或参与任何非法行为；(c) 违反任何国际、联邦、省或州的法规、规则、法律或地方法令；(d) 侵犯或违反我们的知识产权或他人的知识产权；(e) 基于性别、性取向、宗教、族裔、种族、年龄、国籍或残疾进行骚扰、虐待、侮辱、伤害、诽谤、中伤、贬低、恐吓或歧视；(f) 提交虚假或误导性信息；(g) 上传或传播病毒或任何其他类型的恶意代码，这些代码将或可能以任何方式影响服务或任何相关网站、其他网站或互联网的功能或运行；(h) 收集或追踪他人的个人信息；(i) 发送垃圾邮件、网络钓鱼、域欺骗、虚假借口、蜘蛛爬取、数据抓取；(j) 用于任何淫秽或不道德的目的；或 (k) 干扰或规避服务或任何相关网站、其他网站或互联网的安全功能。我们保留因违反任何禁止用途而终止您使用服务或任何相关网站的权利。',
        ),
        _SectionData(
          titleEn: 'SECTION 13 - DISCLAIMER OF WARRANTIES; LIMITATION OF LIABILITY',
          titleZh: '第 13 节 - 免责声明；责任限制',
          contentEn:
              'We do not guarantee, represent or warrant that your use of our Service will be uninterrupted, timely, secure or error-free.\n'
              'We do not warrant that the results that may be obtained from the use of the Service will be accurate or reliable.\n'
              'You agree that from time to time we may remove the Service for indefinite periods of time or cancel the Service at any time, without notice to you.\n'
              'You expressly agree that your use of, or inability to use, the Service is at your sole risk. The Service and all products and Services delivered to you through the Service are (except as expressly stated by us) provided "as is" and "as available" for your use, without any representation, warranties or conditions of any kind, either express or implied, including all implied warranties or conditions of merchantability, merchantable quality, fitness for a particular purpose, durability, title, and non-infringement.\n'
              'In no case shall THL, our directors, officers, employees, affiliates, agents, contractors, interns, suppliers, Service providers or licensors be liable for any injury, loss, claim, or any direct, indirect, incidental, punitive, special, or consequential damages of any kind, including, without limitation lost profits, lost revenue, lost savings, loss of data, replacement costs, or any similar damages, whether based in contract, tort (including negligence), strict liability or otherwise, arising from your use of any of the Service or any products procured using the Service, or for any other claim related in any way to your use of the Service or any product, including, but not limited to, any errors or omissions in any content, or any loss or damage of any kind incurred as a result of the use of the Service or any content (or product) posted, transmitted, or otherwise made available via the Service, even if advised of their possibility. Because some states or jurisdictions do not allow the exclusion or the limitation of liability for consequential or incidental damages, in such states or jurisdictions, our liability shall be limited to the maximum extent permitted by law.',
          contentZh:
              '我们不保证、声明或担保您使用我们的服务将不会中断、及时、安全或无错误。\n'
              '我们不保证使用服务所获得的结果将是准确或可靠的。\n'
              '您同意我们可以随时无限期地删除服务或随时取消服务，恕不另行通知。\n'
              '您明确同意，您使用或无法使用服务的风险完全由您自行承担。服务以及通过服务交付给您的所有产品和服务（除非我们明确声明）均"按原样"和"按可用状态"提供，供您使用，不附带任何形式的明示或暗示的陈述、保证或条件，包括所有关于适销性、适销质量、特定用途适用性、耐用性、所有权和非侵权的暗示保证或条件。\n'
              '在任何情况下，THL、我们的董事、高级管理人员、员工、关联公司、代理人、承包商、实习生、供应商、服务提供商或许可方均不对因您使用任何服务或通过服务获得的任何产品而产生的任何伤害、损失、索赔，或任何直接、间接、附带、惩罚性、特殊或后果性损害承担责任，包括但不限于利润损失、收入损失、储蓄损失、数据丢失、重置成本或任何类似损害，无论是基于合同、侵权（包括过失）、严格责任还是其他原因，即使已被告知此类损害的可能性。由于某些州或司法管辖区不允许排除或限制后果性或附带损害的责任，在此类州或司法管辖区，我们的责任应限于法律允许的最大范围。',
        ),
        _SectionData(
          titleEn: 'SECTION 14 - INDEMNIFICATION',
          titleZh: '第 14 节 - 赔偿',
          contentEn:
              'You agree to indemnify, defend and hold harmless THL and our parent, subsidiaries, affiliates, partners, officers, directors, agents, contractors, licensors, Service providers, subcontractors, suppliers, interns and employees, harmless from any claim or demand, including reasonable attorneys\' fees, made by any third-party due to or arising out of your breach of these Terms of Service or the documents they incorporate by reference, or your violation of any law or the rights of a third-party.',
          contentZh:
              '您同意对 THL 及我们的母公司、子公司、关联公司、合作伙伴、高级管理人员、董事、代理人、承包商、许可方、服务提供商、分包商、供应商、实习生和员工进行赔偿、辩护并使其免受任何第三方因您违反本服务条款或其引用的文件，或您违反任何法律或第三方权利而提出的任何索赔或要求（包括合理的律师费）的损害。',
        ),
        _SectionData(
          titleEn: 'SECTION 15 - SEVERABILITY',
          titleZh: '第 15 节 - 可分割性',
          contentEn:
              'In the event that any provision of these Terms of Service is determined to be unlawful, void or unenforceable, such provision shall nonetheless be enforceable to the fullest extent permitted by applicable law, and the unenforceable portion shall be deemed to be severed from these Terms of Service, such determination shall not affect the validity and enforceability of any other remaining provisions.',
          contentZh:
              '如果本服务条款的任何条款被认定为非法、无效或不可执行，该条款仍应在适用法律允许的最大范围内执行，不可执行的部分应被视为从本服务条款中分离，该认定不应影响任何其他剩余条款的有效性和可执行性。',
        ),
        _SectionData(
          titleEn: 'SECTION 16 - TERMINATION',
          titleZh: '第 16 节 - 终止',
          contentEn:
              'The obligations and liabilities of the parties incurred prior to the termination date shall survive the termination of this agreement for all purposes.\n'
              'These Terms of Service are effective unless and until terminated by either you or us. You may terminate these Terms of Service at any time by notifying us that you no longer wish to use our Services, or when you cease using our site.\n'
              'If in our sole judgment you fail, or we suspect that you have failed, to comply with any term or provision of these Terms of Service, we also may terminate this agreement at any time without notice and you will remain liable for all amounts due up to and including the date of termination; and/or accordingly may deny you access to our Services (or any part thereof).',
          contentZh:
              '双方在终止日期之前产生的义务和责任应在本协议终止后继续有效。\n'
              '本服务条款在您或我们终止之前一直有效。您可以随时通过通知我们您不再希望使用我们的服务，或当您停止使用我们的网站时，终止本服务条款。\n'
              '如果我们自行判断您未能或我们怀疑您未能遵守本服务条款的任何条款或规定，我们也可以随时终止本协议，恕不另行通知，您仍需对截至终止日期（含当日）的所有应付金额承担责任；和/或相应地可能拒绝您访问我们的服务（或其任何部分）。',
        ),
        _SectionData(
          titleEn: 'SECTION 17 - ENTIRE AGREEMENT',
          titleZh: '第 17 节 - 完整协议',
          contentEn:
              'The failure of us to exercise or enforce any right or provision of these Terms of Service shall not constitute a waiver of such right or provision.\n'
              'These Terms of Service and any policies or operating rules posted by us on this site or in respect to the Service constitutes the entire agreement and understanding between you and us and governs your use of the Service, superseding any prior or contemporaneous agreements, communications and proposals, whether oral or written, between you and us (including, but not limited to, any prior versions of the Terms of Service).\n'
              'Any ambiguities in the interpretation of these Terms of Service shall not be construed against the drafting party.',
          contentZh:
              '我们未能行使或执行本服务条款的任何权利或规定，不构成对该权利或规定的放弃。\n'
              '本服务条款以及我们在本网站上或关于服务发布的任何政策或运营规则构成您与我们之间的完整协议和理解，管辖您对服务的使用，并取代您与我们之间任何先前或同期的口头或书面协议、沟通和提案（包括但不限于服务条款的任何先前版本）。\n'
              '本服务条款解释中的任何歧义不应被解释为对起草方不利。',
        ),
        _SectionData(
          titleEn: 'SECTION 18 - GOVERNING LAW',
          titleZh: '第 18 节 - 管辖法律',
          contentEn:
              'These Terms of Service and any separate agreements whereby we provide you Services shall be governed by and construed in accordance with the laws of China, USA and the laws of the local jurisdiction.',
          contentZh:
              '本服务条款以及我们向您提供服务的任何单独协议应受中国法律、美国法律以及当地司法管辖区法律管辖并据其解释。',
        ),
        _SectionData(
          titleEn: 'SECTION 19 - CHANGES TO TERMS OF SERVICE',
          titleZh: '第 19 节 - 服务条款的变更',
          contentEn:
              'You can review the most current version of the Terms of Service at any time at this page.\n'
              'We reserve the right, at our sole discretion, to update, change or replace any part of these Terms of Service by posting updates and changes to our website. It is your responsibility to check our website periodically for changes. Your continued use of or access to our website or the Service following the posting of any changes to these Terms of Service constitutes acceptance of those changes.',
          contentZh:
              '您可以随时在此页面上查看最新版本的服务条款。\n'
              '我们保留自行决定通过在我们的网站上发布更新和更改来更新、更改或替换本服务条款任何部分的权利。您有责任定期检查我们的网站以了解更改。在发布本服务条款的任何更改后，您继续使用或访问我们的网站或服务即构成对这些更改的接受。',
        ),
        _SectionData(
          titleEn: 'SECTION 20 - CONTACT INFORMATION',
          titleZh: '第 20 节 - 联系信息',
          contentEn:
              'Questions about the Terms of Service should be sent to us at ishunhang@163.com.\n'
              'Our contact information is posted below:\n'
              'THL\n'
              'support@thl.com.cn',
          contentZh:
              '有关服务条款的问题请发送至 ishunhang@163.com。\n'
              '我们的联系信息如下：\n'
              'THL\n'
              'support@thl.com.cn',
        ),
      ];
}

/// 条款章节数据结构
class _SectionData {
  final String titleEn; // 英文章节标题
  final String titleZh; // 中文章节标题
  final String contentEn; // 英文正文
  final String contentZh; // 中文正文

  const _SectionData({
    required this.titleEn,
    required this.titleZh,
    required this.contentEn,
    required this.contentZh,
  });
}
