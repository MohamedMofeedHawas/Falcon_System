// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:falcon_system/features/login/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';

// ── Exact Air Force palette ──────────────────────────────────────────────────
const _kYellow = Color(
  0xFFFFB300,
); // amber / yellow — same as Air Force secondary
const _kBg = Color(0xFF020810);
const _kMid = Color(0xFF081A36);
const _kBlue = Color(0xFF0D3260);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────────
  late final AnimationController _master;
  late final AnimationController _aurora;
  late final AnimationController _pulse;
  late final AnimationController _orbit;
  late final AnimationController _exit;
  late final AnimationController _letterCtrl;

  // ── Master animations ────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _badgeScale;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _enOpacity;
  late final Animation<double> _loaderOpacity;

  // ── Ambient animations ───────────────────────────────────────────────────
  late final Animation<double> _auroraShift;
  late final Animation<double> _pulseScale;
  late final Animation<double> _orbitAngle;

  // ── Exit animations ──────────────────────────────────────────────────────
  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  // ── FALCON letter animations (staggered) ─────────────────────────────────
  static const _letters = ['N', 'O', 'C', 'L', 'A', 'F'];
  final List<Animation<double>> _letterOpacity = [];
  final List<Animation<double>> _letterSlide = [];

  bool _exiting = false;

  @override
  void initState() {
    super.initState();

    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _letterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Logo
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Badge
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.2, 0.55, curve: Curves.elasticOut),
      ),
    );

    // FALCON letters — each letter staggers 130 ms apart
    for (int i = 0; i < _letters.length; i++) {
      final start = (i * 0.13).clamp(0.0, 1.0);
      final end = (start + 0.35).clamp(0.0, 1.0);
      _letterOpacity.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _letterCtrl,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
      _letterSlide.add(
        Tween<double>(begin: 20, end: 0).animate(
          CurvedAnimation(
            parent: _letterCtrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    // Divider
    _dividerWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );

    // Subtitle
    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _master,
            curve: const Interval(0.6, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // English tagline
    _enOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.72, 0.88, curve: Curves.easeOut),
      ),
    );

    // Loader
    _loaderOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.82, 1.0, curve: Curves.easeOut),
      ),
    );

    // Ambient
    _auroraShift = Tween<double>(begin: 0, end: 1).animate(_aurora);
    _pulseScale = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _orbitAngle = Tween<double>(begin: 0, end: 2 * math.pi).animate(_orbit);

    // Exit
    _exitScale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _exit, curve: Curves.easeIn));
    _exitOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exit, curve: Curves.easeIn));

    _master.forward();

    // Start letter animation after logo settles
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _letterCtrl.forward();
    });

    _scheduleExit();
  }

  // ── Falcon Navigation Logic ──────────────────────────────────────────────
  Future<void> _scheduleExit() async {
    await Future<void>.delayed(const Duration(milliseconds: 3400));
    if (!mounted) return;
    setState(() => _exiting = true);
    await _exit.forward();
    if (!mounted) return;
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _master.dispose();
    _aurora.dispose();
    _pulse.dispose();
    _orbit.dispose();
    _exit.dispose();
    _letterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _kBg,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _master,
          _aurora,
          _pulse,
          _orbit,
          _exit,
          _letterCtrl,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exiting ? _exitOpacity : const AlwaysStoppedAnimation(1),
            child: ScaleTransition(
              scale: _exiting ? _exitScale : const AlwaysStoppedAnimation(1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const _MeshBackground(),
                  CustomPaint(
                    size: size,
                    painter: _AuroraPainter(t: _auroraShift.value),
                  ),
                  CustomPaint(
                    size: size,
                    painter: _OrbitPainter(angle: _orbitAngle.value),
                  ),
                  const _StarField(),

                  // ── Content ──
                  SafeArea(
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // ── Logo cluster ──
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            ScaleTransition(
                              scale: _pulseScale,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _kYellow.withOpacity(0.12),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            // Mid ring
                            Container(
                              width: 155,
                              height: 155,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Badge (shield)
                            ScaleTransition(
                              scale: _badgeScale,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0xFF1E5799),
                                      Color(0xFF0D3260),
                                      Color(0xFF061428),
                                    ],
                                    stops: [0.0, 0.55, 1.0],
                                  ),
                                  border: Border.all(
                                    color: _kYellow.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _kYellow.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 40,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Logo icons
                            FadeTransition(
                              opacity: _logoOpacity,
                              child: ScaleTransition(
                                scale: _logoScale,
                                child: const _LogoIcons(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // ── FALCON — letter-by-letter animation ──
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_letters.length, (i) {
                              return Transform.translate(
                                offset: Offset(0, _letterSlide[i].value),
                                child: Opacity(
                                  opacity: _letterOpacity[i].value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      _letters[i],
                                      style: TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w900,
                                        color: _kYellow,
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(
                                            color: _kYellow.withOpacity(0.55),
                                            blurRadius: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Animated divider ──
                        LayoutBuilder(
                          builder: (_, constraints) => Align(
                            alignment: Alignment.center,
                            child: Container(
                              width:
                                  constraints.maxWidth *
                                  0.45 *
                                  _dividerWidth.value,
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    _kYellow.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Arabic subtitle ──
                        FadeTransition(
                          opacity: _subtitleOpacity,
                          child: SlideTransition(
                            position: _subtitleSlide,
                            child: const Text(
                              'Airport Inspection & Evaluation Department',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── English tagline ──
                        FadeTransition(
                          opacity: _enOpacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 1,
                                color: _kYellow.withOpacity(0.5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Falcon System  ·  Egyption Airforce Academy.',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: _kYellow.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 1,
                                color: _kYellow.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 3),

                        // ── Loader + version ──
                        FadeTransition(
                          opacity: _loaderOpacity,
                          child: const Column(
                            children: [
                              _AnimatedLoader(),
                              SizedBox(height: 16),
                              _VersionLabel(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Logo Icons ───────────────────────────────────────────────────────────────

class _LogoIcons extends StatelessWidget {
  const _LogoIcons();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.military_tech_rounded, size: 52, color: _kYellow),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flight_takeoff_rounded,
              size: 22,
              color: Colors.white.withOpacity(0.75),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.shield_outlined,
              size: 22,
              color: Colors.white.withOpacity(0.75),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Version Label ────────────────────────────────────────────────────────────

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) => Text(
    'v1.0.0',
    style: TextStyle(
      fontSize: 11,
      color: Colors.white.withOpacity(0.25),
      letterSpacing: 1.5,
    ),
  );
}

// ─── Animated Loader (dot wave) ───────────────────────────────────────────────

class _AnimatedLoader extends StatefulWidget {
  const _AnimatedLoader();

  @override
  State<_AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<_AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _d1, _d2, _d3;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _d1 = _interval(0.0, 0.5);
    _d2 = _interval(0.2, 0.7);
    _d3 = _interval(0.4, 0.9);
  }

  Animation<double> _interval(double start, double end) =>
      Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _dot(double op) => Opacity(
    opacity: op,
    child: Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kYellow,
        boxShadow: [
          BoxShadow(
            color: _kYellow.withOpacity(op * 0.6),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, _) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(_d1.value),
        const SizedBox(width: 8),
        _dot(_d2.value),
        const SizedBox(width: 8),
        _dot(_d3.value),
      ],
    ),
  );
}

// ─── Background ───────────────────────────────────────────────────────────────

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-1, -1),
        end: Alignment(1.2, 1.1),
        colors: [_kBg, _kMid, _kBlue, _kMid, _kBg],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    ),
  );
}

// ─── Star Field ───────────────────────────────────────────────────────────────

class _StarField extends StatelessWidget {
  const _StarField();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarPainter());
}

class _StarPainter extends CustomPainter {
  static final _stars = List.generate(80, (i) {
    final r = math.Random(i * 31 + 7);
    return (
      x: r.nextDouble(),
      y: r.nextDouble(),
      rad: r.nextDouble() * 1.2 + 0.3,
      op: r.nextDouble() * 0.6 + 0.2,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.rad,
        Paint()..color = Colors.white.withOpacity(s.op),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Aurora Painter ───────────────────────────────────────────────────────────

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = t * 2 * math.pi;
    _blob(
      canvas,
      size,
      cx: 0.5 + math.cos(s) * 0.35,
      cy: 0.4 + math.sin(s * 0.7) * 0.2,
      r: 0.7,
      color: _kYellow.withOpacity(0.07),
    );
    _blob(
      canvas,
      size,
      cx: 0.3 + math.sin(s * 0.8) * 0.3,
      cy: 0.6 + math.cos(s * 0.5) * 0.25,
      r: 0.5,
      color: const Color(0xFF1E5799).withOpacity(0.15),
    );
  }

  void _blob(
    Canvas canvas,
    Size size, {
    required double cx,
    required double cy,
    required double r,
    required Color color,
  }) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: Alignment(cx * 2 - 1, cy * 2 - 1),
          radius: r,
          colors: [color, Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.t != t;
}

// ─── Orbit Painter ───────────────────────────────────────────────────────────

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.angle});
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;
    const or = 105.0;

    canvas.drawCircle(
      Offset(cx, cy),
      or,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.04)
        ..strokeWidth = 1,
    );

    canvas.drawCircle(
      Offset(cx + math.cos(angle) * or, cy + math.sin(angle) * or),
      2.5,
      Paint()..color = _kYellow.withOpacity(0.7),
    );

    canvas.drawCircle(
      Offset(
        cx + math.cos(angle + math.pi) * or,
        cy + math.sin(angle + math.pi) * or,
      ),
      1.5,
      Paint()..color = Colors.white.withOpacity(0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => old.angle != angle;
}
