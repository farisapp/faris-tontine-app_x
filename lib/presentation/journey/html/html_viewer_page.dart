import 'package:faris/controller/splash_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:faris/common/html_type.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlViewerPage extends StatelessWidget {
  final HtmlType htmlType;

  const HtmlViewerPage({Key? key, required this.htmlType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? _data = htmlType == HtmlType.TERMS_AND_CONDITION ? Get.find<SplashController>().config?.termsAndConditions
        : htmlType == HtmlType.ABOUT_US ? Get.find<SplashController>().config?.aboutUs
        : htmlType == HtmlType.PRIVACY_POLICY ? Get.find<SplashController>().config?.privacyPolicy
        : htmlType == HtmlType.TUTO ? Get.find<SplashController>().config?.tuto
        : htmlType == HtmlType.FAQ ? Get.find<SplashController>().config?.faq
        : null;

    if(_data != null && _data.isNotEmpty) {
      _data = _data.replaceAll('href=', 'target="_blank" href=');
    }

    return Scaffold(
      appBar: AppBar(title: Text(htmlType == HtmlType.TERMS_AND_CONDITION ? 'Termes et conditions'
        : htmlType == HtmlType.ABOUT_US ? 'A propos de nous'
          : htmlType == HtmlType.PRIVACY_POLICY ? 'Politique de confidentialité'
          : htmlType == HtmlType.TUTO ? 'Tuto'
          : htmlType == HtmlType.FAQ ? 'FAQ'
          : 'no_data_found', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_secondary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10),
          physics: BouncingScrollPhysics(),
          child: HtmlWidget(
            _data ?? "",
            key: Key(htmlType.toString()),
            onTapUrl: (String url) async => await _launchUrl(url),
           //hyperlinkColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  Future<bool> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
    return true;
  }
}
