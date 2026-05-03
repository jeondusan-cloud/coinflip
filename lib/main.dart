// 결정해줘 — 동전 던지기 앱
// React 웹앱의 로직과 디자인을 Flutter로 이식

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // 작업 6: 화면 방향 세로 고정
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const CoinFlipApp());
  });
}

class CoinFlipApp extends StatelessWidget {
  const CoinFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '결정해줘',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansKR',
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        useMaterial3: true,
      ),
      home: const CoinFlipScreen(),
    );
  }
}

// --- 앱 상태 ---
enum AppState { idle, flipping, landed }

enum CoinResult { heads, tails }

class CoinFlipScreen extends StatefulWidget {
  const CoinFlipScreen({super.key});

  @override
  State<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  AppState _state = AppState.idle;
  CoinResult? _result;
  bool _isHolding = false;
  DateTime? _holdStartTime;

  // Animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  double _currentRotation = 0;
  double _targetRotation = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _state = AppState.landed;
          _currentRotation = _targetRotation;
        });
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (_state == AppState.flipping) return;
    setState(() {
      _isHolding = true;
      _holdStartTime = DateTime.now();
    });
    // 햅틱 피드백
    HapticFeedback.lightImpact();
  }

  void _onPointerUp() {
    if (!_isHolding || _state == AppState.flipping) return;

    final holdDuration =
        DateTime.now().difference(_holdStartTime!).inMilliseconds;
    final boundedDuration = holdDuration.clamp(0, 2000);

    final isHeads = Random().nextBool();
    final result = isHeads ? CoinResult.heads : CoinResult.tails;

    // 회전 계산 (React 로직 이식)
    final baseRotations = 3;
    final extraRotations = (boundedDuration / 2000 * 15).floor();
    final currentSpins = (_currentRotation / (2 * pi)).floor();
    final targetRotation =
        (currentSpins + baseRotations + extraRotations) * 2 * pi +
            (isHeads ? 0 : pi);

    // 애니메이션 시간 계산
    final animDuration = 1200 + (boundedDuration / 2000 * 1800).round();

    setState(() {
      _isHolding = false;
      _state = AppState.flipping;
      _result = result;
      _targetRotation = targetRotation;
    });

    _flipAnimation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeOutCubic,
    ));

    _flipController.duration = Duration(milliseconds: animDuration);
    _flipController.forward(from: 0);

    // 햅틱 피드백
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onPointerDown(),
      onTapUp: (_) => _onPointerUp(),
      onTapCancel: () {
        if (_isHolding) {
          _onPointerUp();
        }
      },
      onLongPressStart: (_) => _onPointerDown(),
      onLongPressEnd: (_) => _onPointerUp(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              // 앱 제목
              _buildTitle(),
              // 동전 영역
              Expanded(child: _buildCoinArea()),
              // 결과 & 안내 텍스트
              _buildFooter(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Flip It.',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: Color(0xFF292524),
        letterSpacing: -1.5,
      ),
    );
  }

  Widget _buildCoinArea() {
    return Center(
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final rotation = _state == AppState.flipping
              ? _flipAnimation.value
              : _currentRotation;

          // 스케일 효과
          double scale = 1.0;
          if (_state == AppState.flipping) {
            final progress = _flipController.value;
            scale = 1.0 + 0.4 * sin(progress * pi);
          } else if (_isHolding) {
            scale = 0.95;
          }

          // 현재 앞면인지 뒷면인지 판별
          final normalizedAngle = rotation % (2 * pi);
          final showBack =
              normalizedAngle > pi / 2 && normalizedAngle < 3 * pi / 2;

          return Transform.scale(
            scale: scale,
            child: _buildCoinFace(showBack, rotation),
          );
        },
      ),
    );
  }

  Widget _buildCoinFace(bool showBack, double rotation) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 192,
      height: 192,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: showBack
              ? [const Color(0xFFFFE0B2), const Color(0xFFFFCC80)]
              : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
        ),
        border: Border.all(
          color: const Color(0xFFFED7AA).withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 내부 원 테두리
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF431407).withValues(alpha: 0.1),
              ),
            ),
          ),
          // 텍스트
          Text(
            showBack ? '안 한다.' : '한다.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
              color: showBack
                  ? const Color(0xFF7C2D12).withValues(alpha: 0.6)
                  : const Color(0xFF431407),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return SizedBox(
      height: 160,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _state == AppState.landed
              ? _buildResultDisplay()
              : _state == AppState.flipping
                  ? _buildFlippingDisplay()
                  : _buildIdleDisplay(),
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    final resultText =
        _result == CoinResult.heads ? '한다.' : '안 한다.';
    return Column(
      key: const ValueKey('result'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          resultText,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            color: Color(0xFF292524),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '다시 던지려면 터치하세요',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB45309).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFlippingDisplay() {
    return const Text(
      key: ValueKey('flipping'),
      '결정하는 중...',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFA8A29E),
      ),
    );
  }

  Widget _buildIdleDisplay() {
    return Column(
      key: const ValueKey('idle'),
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: _isHolding ? 19 : 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF44403C),
          ),
          child: Text(
            _isHolding ? '이제 손을 떼세요! 🎯' : '가볍게 누르거나 길게 꾹 눌러보세요 👆',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '길게 누르면 동전이 더 많이 회전합니다',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFA8A29E),
          ),
        ),
      ],
    );
  }
}

// AnimatedBuilder is just an alias for AnimatedWidget pattern
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  }) : super();

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
