import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'level_model.dart';
import 'user_data_provider.dart';


class LevelDetailScreen extends StatefulWidget {
  final Level level;
  final int? totalSavedSoFar;

  const LevelDetailScreen({
    super.key,
    required this.level,
    this.totalSavedSoFar,
  });

  @override
  State<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _buttonController;
  late AnimationController _coinController;
  late ConfettiController _confettiController;
  bool _isPaymentDone = false;

  @override
  void initState() {
    super.initState();
    _checkLevelCompletion();
  }

  void _checkLevelCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('level_${widget.level.idx}_completed') ?? false;
    setState(() {
      _isPaymentDone = completed;
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _buttonController.dispose();
    _coinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onButtonPressDown(TapDownDetails _) => _buttonController.forward();
  void _onButtonPressUp(TapUpDetails _) => _buttonController.reverse();

  // Displays a modal with multiple banking/saving options
  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Choose your savings/banking app",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            _buildPaymentOption("PayPal Savings", "https://www.paypal.com/myaccount/savings"),
            _buildPaymentOption("Revolut Vault", "https://www.revolut.com/"),
            _buildPaymentOption("Wise Account", "https://wise.com/"),
            _buildPaymentOption("Google Pay", "https://pay.google.com/"),
            const Divider(color: Colors.white30, height: 24),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.blueAccent),
              title: const Text("I already saved somewhere else", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _completePaymentFlow();
              },
            )
          ],
        ),
      ),
    );
  }

  ListTile _buildPaymentOption(String name, String url) {
    return ListTile(
      leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
      title: Text(name, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        _redirectToAppAndConfirm(url);
      },
    );
  }

  Future<void> _redirectToAppAndConfirm(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      await Future.delayed(const Duration(seconds: 3));
      _completePaymentFlow();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open $urlString")),
      );
    }
  }

  Future<void> _completePaymentFlow() async {
    setState(() => _isPaymentDone = true);
    _coinController.forward(from: 0);
    _confettiController.play();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('level_${widget.level.idx}_completed', true);
    prefs.setBool('level_${widget.level.idx + 1}_unlocked', true);

    final userData = Provider.of<UserDataProvider>(context);
    Text(
      '${userData.currency} ${userData.perLevelAmount.toStringAsFixed(2)}',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
    final nextIdx = widget.level.idx + 1;
    final totalLevels = userData.levelsCount;
    final nextAmount = userData.perLevelAmount;

    if (nextIdx < totalLevels) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          _createSlideRoute(
            LevelDetailScreen(
              level: Level(
                idx: nextIdx,
                amount: nextAmount.toInt(), // ✅ converted double → int
              ),
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 You've completed all levels for your goal!"),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0), end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = 1 - _buttonController.value;

    // ✅ get user goal data from provider
    final userData = Provider.of<UserDataProvider>(context);
    final currency = userData.currency;
    final amountPerLevel = userData.perLevelAmount.toStringAsFixed(2);

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.green, Colors.blue, Colors.amber],
              numberOfParticles: 45,
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          Center(
            child: !_isPaymentDone
                ? _buildMainContent(scale, currency, amountPerLevel)
                : _buildCongrats(),
          ),
        ],
      ),
    );
  }

  // ✅ pass goal data into main content
  Widget _buildMainContent(double scale, String currency, String amountPerLevel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final pulse = 1 + _pulseController.value * 0.08;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160 * pulse,
                  height: 160 * pulse,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.greenAccent, Colors.blueAccent],
                    ),
                  ),
                ),
                Text("Level ${widget.level.idx}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        // ✅ dynamically show amount from user goal
        Text(
          "Save $currency $amountPerLevel to unlock next level",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "Tap 'Save Now' to open your preferred savings or banking app. "
                "After saving, your progress and next level will be unlocked automatically. "
                "No extra steps required—just save and watch your journey unfold!",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 26),
        GestureDetector(
          onTapDown: _onButtonPressDown,
          onTapUp: _onButtonPressUp,
          onTapCancel: () => _buttonController.reverse(),
          onTap: _showPaymentOptions,
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.greenAccent, Colors.blueAccent]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.savings, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Save Now",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCongrats() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: [
              Colors.greenAccent,
              Colors.blueAccent,
              Colors.amberAccent,
              Colors.pinkAccent,
            ],
            numberOfParticles: 60,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.blueAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.6),
                    blurRadius: 24,
                    spreadRadius: 4,
                  )
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 92,
                shadows: [
                  Shadow(
                    blurRadius: 18,
                    color: Colors.greenAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Congratulations!",
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "You’ve successfully saved and unlocked the next level. Great things start with small steps — keep building your future! 🎉",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 35),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                "Go Back",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 6,
                shadowColor: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Thank you for saving with us!",
              style: TextStyle(
                color: Colors.blueAccent,
                fontStyle: FontStyle.italic,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Animated Gradient Background (unchanged)
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _color1 = ColorTween(begin: Colors.black, end: Colors.green.shade900)
        .animate(_controller);
    _color2 = ColorTween(begin: Colors.blue.shade800, end: Colors.greenAccent)
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color1.value!, _color2.value!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

