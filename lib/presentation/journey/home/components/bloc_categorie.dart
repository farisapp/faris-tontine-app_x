import 'dart:async';
import 'package:faris/presentation/journey/tontine/select_tontine_type_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../FarisPay/preselect_pay_page.dart';
import '../../../../Livraison/choix_delivery_page.dart';
import '../../faris_nana/faris_nana_acceuil.dart';

class BlocCategorie extends StatelessWidget {
  final int tontineCount;
  Widget _buildDayBasedBonus() {
    final int weekday = DateTime.now().weekday;

    // Déclaration de dailyPromos à l'intérieur de la fonction
    final Map<int, List<Map<String, String>>> dailyPromos = {
      1: [
        {"text": "🚴 Trouver facilement un livreur à proximité en\n cliquant sur Livreurs & Coursiers"},
        {"text": "💰 Épargnez et faites vos tontines en cliquant \n sur Faris épargne"},
        {"text": "💲 Payez en plusieurs tranches, importez vos \n articles pour vendre, ou les déposer physiquement \n chez nous en cliquant sur Achats Nana"},
        {"text": "🎁 Achetez vos mégas internet avec 100% de bonus\n ou vos unités sans vous déplacer, en cliquant \n sur Faris Pay"},
        {"text": "💳 Recharger carte VISA, Transférez de l'argent de\n Orange vers Telecel ou Moov en cliquant sur Faris Pay"},
        {"text": "🚴 Vous êtes livreur? Vous recherchez un livreur pour \n vos courses? Cliquez sur Livreurs & Coursiers"},
      ],
      2: [
        {"text": "🚴 Trouver facilement un livreur à proximité en\n cliquant sur Livreurs & Coursiers"},
        {"text": "🎁 Mardi c'est bonus méga Orange et Moov \n Cliquez sur Faris Pay pour en profiter!"},
        {"text": "💰 Épargnez et faites vos tontines en cliquant \n sur Faris épargne"},
        {"text": "🎉 Qui dit Mardi dit Bonus mégas internet Orange \n et Moov, cliquez sur Faris Pay pour en profiter!"},
        {"text": "🚴 Vous êtes livreur? Vous recherchez un livreur pour \n vos courses? Cliquez sur Livreurs"},
      ],

      3: [
        {"text": "🚴 Trouver facilement un livreur à proximité en\n cliquant sur Livreurs & Coursiers"},
        {"text": "💰 Épargnez et faites vos tontines en cliquant \n sur Faris Épargne"},
        {"text": "💲 Payez en plusieurs tranches, importez vos \n articles pour vendre, ou les déposer physiquement \n chez nous en cliquant sur Achats Nana"},
        {"text": "🎁 Achetez vos mégas internet avec 100% de bonus\n ou vos unités sans vous déplacer, en cliquant \n sur Faris Pay"},
        {"text": "💳 Recharger carte VISA, Transférez de l'argent de\n Orange vers Telecel ou Moov en cliquant sur Faris Pay"},
        {"text": "🚴 Vous êtes livreur? Vous recherchez un livreur pour \n vos courses? Cliquez sur Livreurs & Coursiers"},
      ],
      4: [
        {"text": "🚴 Trouver facilement un livreur à proximité en\n cliquant sur Livreurs & Coursiers"},
        {"text": "💰 Épargnez et faites vos tontines en cliquant \n sur Faris Épargne"},
        {"text": "💲 Payez en plusieurs tranches, importez vos \n articles pour vendre, ou les déposer physiquement \n chez nous en cliquant sur Achats Nana"},
        {"text": "🎁 Achetez vos mégas internet avec 100% de bonus\n ou vos unités sans vous déplacer, en cliquant \n sur Faris Pay"},
        {"text": "💳 Recharger carte VISA, Transférez de l'argent de\n Orange vers Telecel ou Moov en cliquant sur Faris Pay"},
        {"text": "🚴 Vous êtes livreur? Vous recherchez un livreur pour \n vos courses? Cliquez sur Livreurs & Coursiers"},
      ],
      5: [
        {"text": "🚴 Trouver facilement un livreur à proximité en\n cliquant sur Livreurs & Coursiers"},
        {"text": "🎉 Vendredi c'est bonus méga Orange et Moov \n Cliquez sur Faris Pay pour en profiter!"},
        {"text": "🎉 Épargnez et faites vos tontines en cliquant \n sur Faris épargne"},
        {"text": "🎁 Qui dit Vendredi dit Bonus mégas internet Orange \n et Moov, cliquez sur Faris Pay pour en profiter!"},
        {"text": "💳 Recharger carte VISA, Transférez de l'argent de\n Orange vers Telecel ou Moov en cliquant sur Faris Pay"},
      ],
      6: [
        {"text": "🚴 Trouver facilement un livreur à proximité en\n cliquant sur Livreurs & Coursiers"},
        {"text": "💰 Épargnez et faites vos tontines en cliquant \n sur Faris Épargne"},
        {"text": "💲 Payez en plusieurs tranches, importez vos \n articles pour vendre, ou les déposer physiquement \n chez nous en cliquant sur Achats Nana"},
        {"text": "🎁 Achetez vos mégas internet avec 100% de bonus\n ou vos unités sans vous déplacer, en cliquant \n sur Faris Pay"},
        {"text": "🎉 Recharger carte VISA, Transférez de l'argent de\n Orange vers Telecel ou Moov en cliquant sur Faris Pay"},
        {"text": "🚴 Vous êtes livreur? Vous recherchez un livreur pour \n vos courses? Cliquez sur Livreurs & Coursiers"},
      ],
      7: [
        {"text": "🚴 Trouver facilement un livreur à proximité en\n cliquant sur Livreurs & Coursiers"},
        {"text": "💰 Épargnez et faites vos tontines en cliquant \n sur Faris Épargne"},
        {"text": "💲 Payez en plusieurs tranches, importez vos \n articles pour vendre, ou les déposer physiquement \n chez nous en cliquant sur Achats Nana"},
        {"text": "🎁 Achetez vos mégas internet avec 100% de bonus\n ou vos unités sans vous déplacer, en cliquant \n sur Faris Pay"},
        {"text": "💳 Recharger carte VISA, Transférez de l'argent de\n Orange vers Telecel ou Moov en cliquant sur Faris Pay"},
        {"text": "🚴 Vous êtes livreur? Vous recherchez un livreur pour \n vos courses? Cliquez sur Livreurs & Coursiers"},
      ],
    };

    if (!dailyPromos.containsKey(weekday)) return const SizedBox.shrink();

    final promos = dailyPromos[weekday]!;

    return BonusWidget(promotions: promos);
  }
  const BlocCategorie({Key? key, required this.tontineCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<Color> orangePalette = [
      Colors.orange.shade800,
      Colors.orange.shade600,
      Colors.orange.shade400,
      Colors.orange.shade200,
    ];

    return Stack(
      children: [
        // Contenu principal
        SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Laisse un espace pour la bannière flottante
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleWithSubtitle(
                      context: context,
                      title: "Faris Épargne",
                      subtitle: "Épargnes et tontines en ligne",
                      imagePath: 'assets/images/savings.png',
                      backgroundColor: orangePalette[0],
                      size: screenWidth * 0.38,
                      onPress: () => Get.to(() => SelectTontineTypePage(), transition: Transition.cupertino),
                    ),
                    _buildCircleWithSubtitle(
                      context: context,
                      title: "Achats Nana",
                      subtitle: "Achat de biens à tempérament",
                      imagePath: 'assets/images/shopping.png',
                      backgroundColor: orangePalette[0],
                      size: screenWidth * 0.38,
                      onPress: () => Get.to(() => FarisNanaAcceuil(), transition: Transition.cupertino),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleWithSubtitle(
                      context: context,
                      title: "Livreurs &\n Coursiers",
                      subtitle: "Livreurs & Coursiers",
                      imagePath: 'assets/images/delivery.png',
                      backgroundColor: orangePalette[2],
                      size: screenWidth * 0.38,
                      onPress: () => Get.to(() => const ChoixDeliveryPage(), transition: Transition.cupertino),
                    ),
                    _buildCircleWithSubtitle(
                      context: context,
                      title: "Faris Pay",
                      subtitle: "Mégas, unités, Transfert & plus...",
                      imagePath: 'assets/images/payment.png',
                      backgroundColor: orangePalette[0],
                      size: screenWidth * 0.38,
                      onPress: () => Get.to(() => PreselectPayPage(), transition: Transition.cupertino),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildWhatsAppButton(context, screenWidth * 0.12),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // 🎁 Bonus flottant en haut gauche
        Positioned(
          top: 0,
          left: 10,
          child: _buildDayBasedBonus(),
        ),

      ],
    );
  }

  Widget _buildCircleWithSubtitle({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
    required Color backgroundColor,
    required double size,
    required VoidCallback onPress,
    bool isAvailable = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: isAvailable ? onPress : () => _showUnavailableMessage(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: isAvailable
                  ? LinearGradient(
                colors: [Colors.orange.shade800, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: isAvailable ? null : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: size * 0.4,
                  height: size * 0.4,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  void _showUnavailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Bientôt disponible",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton(BuildContext context, double size) {
    final String phoneNumber = "74249090";
    final String whatsappMessage = "Bonjour, Faris";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Question, assistance ou réclamation!",
          style: TextStyle(
            fontSize: 14,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouton WhatsApp
            GestureDetector(
              onTap: () async {
                final Uri whatsappUrl = Uri.parse("https://wa.me/74249090?text=Bonjour, Faris");
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Bouton Appel
            GestureDetector(
              onTap: () async {
                final Uri callUri = Uri(scheme: 'tel', path: '74249090');
                if (await canLaunchUrl(callUri)) {
                  await launchUrl(callUri);
                }
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Center(
                  child: Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Texte clignotant
class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const BlinkingText({Key? key, required this.text, required this.style}) : super(key: key);

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText> {
  bool _visible = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _visible = !_visible;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Text(widget.text, style: widget.style),
    );
  }
}

class BonusWidget extends StatefulWidget {
  final List<Map<String, String>> promotions;

  const BonusWidget({Key? key, required this.promotions}) : super(key: key);

  @override
  State<BonusWidget> createState() => _BonusWidgetState();
}

class _BonusWidgetState extends State<BonusWidget> with SingleTickerProviderStateMixin {
  int _currentPromotionIndex = 0;
  late Timer _promotionTimer;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOrange = true;

  @override
  void initState() {
    super.initState();

    _startPromotionCarousel();
    _startBlinkingEffect();

    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Durée de l'animation pour un mouvement complet
      vsync: this,
    )..repeat(reverse: true); // Mouvement haut/bas continu

    _animation = Tween<double>(begin: 0, end: 10).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }

  void _startPromotionCarousel() {
    _promotionTimer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      setState(() {
        _currentPromotionIndex = (_currentPromotionIndex + 1) % widget.promotions.length;
      });
    });
  }

  void _startBlinkingEffect() {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          _isOrange = !_isOrange;
        });
      }
    });
  }

  @override
  void dispose() {
    _promotionTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPromotion = widget.promotions[_currentPromotionIndex]["text"]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value), // Déplacement vertical de 0 à 10 pixels
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isOrange ? Colors.orange.shade100 : Colors.orange.shade300,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: _buildRichText(currentPromotion),
          ),
        );
      },
    );
  }

  Widget _buildRichText(String text) {
    final wordsToHighlight = [
      "Vendredi", "Mardi", "carte VISA", "mégas internet",
      "Faris Pay", "Faris épargne", "Achats Nana",
      "Livreurs & Coursiers", "Épargnez", "livreur", "Transférez", "tranches", "unités"
    ];

    final pattern = RegExp(wordsToHighlight.map(RegExp.escape).join('|'), caseSensitive: false);
    final spans = <TextSpan>[];

    int start = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}