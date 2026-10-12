import 'package:flexiphones/extensions/value_validation.dart';
import 'package:flexiphones/helpers/assets_helper.dart';
import 'package:flexiphones/helpers/navigation_helper.dart';
import 'package:flexiphones/provider/provider_class.dart';
import 'package:flexiphones/screens/onboarding/forgot_password.dart';
import 'package:flexiphones/shared_widgets/fade_slide_in.dart';
import 'package:flexiphones/shared_widgets/generalwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const _blue = Color(0xFF0071E3);
const _bg = Color(0xFFF2F4F7);

/// Sign in and sign up on one screen. A pill switch slides between the two
/// forms (or swipe the forms sideways); the illustration and headline
/// follow. Sign up needs the terms ticked before it can continue.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialTab = 0});

  /// 0 = sign in, 1 = sign up.
  final int initialTab;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialTab,
  );
  late double _pos = widget.initialTab.toDouble();
  final _signInKey = GlobalKey<FormState>();
  final _signUpKey = GlobalKey<FormState>();
  bool _showPass = false;
  bool _agreed = false;
  int _shake = 0;

  @override
  void initState() {
    super.initState();
    _pages.addListener(() {
      if (_pages.hasClients && _pages.page != null) {
        setState(() => _pos = _pages.page!);
      }
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int tab) {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _pages.animateToPage(
      tab,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  String? _emailCheck(String? v) {
    final e = (v ?? "").trim();
    if (e.isEmpty) return "Enter your email";
    if (!e.isValidEmail) return "That email doesn't look right";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ch = Theme.of(context).colorScheme;
    final p = Provider.of<SharedProvider>(context);
    final tab = _pos.round();
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: SizedBox(
                    height: 44,
                    child:
                        canPop
                            ? Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                ),
                              ),
                            )
                            : null,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  child: SizedBox(
                    height: 170,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder:
                          (c, a) => FadeTransition(
                            opacity: a,
                            child: ScaleTransition(
                              scale: Tween(begin: 0.9, end: 1.0).animate(a),
                              child: c,
                            ),
                          ),
                      child: Image.asset(
                        tab == 0
                            ? AssetsHelper.signinImage
                            : AssetsHelper.signupImage,
                        key: ValueKey(tab),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: Column(
                      key: ValueKey(tab),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tab == 0 ? "Welcome back." : "Let's get you started.",
                          style: ptstyle(
                            size: 28,
                            weight: 800,
                            color: ch.onSurface,
                          ).copyWith(letterSpacing: -1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab == 0
                              ? "Sign in to see your orders and payments."
                              : "Create your FlexiPhones account in a minute.",
                          style: ptstyle(
                            size: 13.5,
                            weight: 400,
                            color: ch.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _TabSwitch(position: _pos, onTap: _goTo),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: PageView(
                  controller: _pages,
                  children: [_signIn(ch, p), _signUp(ch, p)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Sign in ----------------
  Widget _signIn(ColorScheme ch, SharedProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
      child: Form(
        key: _signInKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Field(
              controller: p.emailEditingController,
              icon: Icons.mail_outline_rounded,
              hint: "Email address",
              keyboard: TextInputType.emailAddress,
              validator: _emailCheck,
              enabled: !p.userUDLoading,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: p.passwordController,
              icon: Icons.lock_outline_rounded,
              hint: "Password",
              obscure: !_showPass,
              enabled: !p.userUDLoading,
              validator:
                  (v) => (v ?? "").isEmpty ? "Enter your password" : null,
              trailing: IconButton(
                onPressed: () => setState(() => _showPass = !_showPass),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _showPass
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    key: ValueKey(_showPass),
                    size: 20,
                    color: ch.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: _ForgotButton(
                onTap:
                    () => NavigationHelper.push(context, ForgotPassword()),
              ),
            ),
            const SizedBox(height: 22),
            _PrimaryButton(
              label: "Sign in",
              icon: Icons.arrow_forward_rounded,
              loading: p.userUDLoading,
              onTap: () {
                FocusScope.of(context).unfocus();
                if (_signInKey.currentState!.validate()) {
                  p.emailSignIn(context);
                }
              },
            ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () => _goTo(1),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "New to FlexiPhones?  ",
                        style: ptstyle(
                          size: 13,
                          weight: 400,
                          color: ch.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: "Create an account",
                        style: ptstyle(size: 13, weight: 700, color: _blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Sign up ----------------
  Widget _signUp(ColorScheme ch, SharedProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
      child: Form(
        key: _signUpKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Field(
              controller: p.emailEditingController,
              focusNode: p.emailFocusNode,
              icon: Icons.mail_outline_rounded,
              hint: "Email address",
              keyboard: TextInputType.emailAddress,
              validator: _emailCheck,
              enabled: !p.emailVerification,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                "We'll send a code to confirm it's you.",
                style: ptstyle(
                  size: 11.5,
                  weight: 400,
                  color: ch.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 18),
            TweenAnimationBuilder<double>(
              key: ValueKey(_shake),
              tween: Tween(begin: _shake == 0 ? 0 : 1, end: 0),
              duration: const Duration(milliseconds: 450),
              builder:
                  (_, v, child) => Transform.translate(
                    offset: Offset(
                      8 * v * (((v * 10).floor()).isEven ? 1 : -1),
                      0,
                    ),
                    child: child,
                  ),
              child: _TermsTick(
                value: _agreed,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _agreed = v);
                },
                onOpenTerms: () => _showTerms(context),
              ),
            ),
            const SizedBox(height: 22),
            _PrimaryButton(
              label: "Create account",
              icon: Icons.person_add_alt_1_rounded,
              loading: p.emailVerification,
              dimmed: !_agreed,
              onTap: () {
                FocusScope.of(context).unfocus();
                if (!_signUpKey.currentState!.validate()) return;
                if (!_agreed) {
                  HapticFeedback.heavyImpact();
                  setState(() => _shake++);
                  return;
                }
                p.verifyEmail(context, ch);
              },
            ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () => _goTo(0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Already have an account?  ",
                        style: ptstyle(
                          size: 13,
                          weight: 400,
                          color: ch.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: "Sign in",
                        style: ptstyle(size: 13, weight: 700, color: _blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    final ch = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: ch.surface,
      builder:
          (ctx) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.8,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              children: [
                Text(
                  "Terms & Privacy",
                  style: ptstyle(size: 22, weight: 800, color: ch.onSurface),
                ),
                const SizedBox(height: 14),
                for (final (title, body) in _terms) ...[
                  Text(
                    title,
                    style: ptstyle(size: 14, weight: 700, color: ch.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: ptstyle(
                      size: 13,
                      weight: 400,
                      color: ch.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 6),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _agreed = true);
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      "I agree",
                      style: ptstyle(size: 15, weight: 700),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Short summary shown in the app. Replace with the full legal text (or a
  // link to it) when it's published.
  static const _terms = [
    (
      "Paying for your phone",
      "You pay a down payment, then daily payments for the plan you choose. The phone is yours once the full amount is paid.",
    ),
    (
      "Missed payments",
      "If a payment day is missed, the phone can be locked until you catch up. Paying the amount owed unlocks it.",
    ),
    (
      "Your account",
      "Keep your sign-in details private. You're responsible for activity on your account.",
    ),
    (
      "Your data",
      "We use your details to run your account, process payments and contact you about your orders. We don't sell your data.",
    ),
  ];
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

/// "Sign in | Sign up" pill. The white thumb follows the page as it slides,
/// so dragging the forms moves it too.
class _TabSwitch extends StatelessWidget {
  const _TabSwitch({required this.position, required this.onTap});
  final double position;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final ch = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 10) / 2;
        return Container(
          height: 54,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: ch.onSurface.withOpacity(0.07),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              Positioned(
                left: w * position.clamp(0.0, 1.0),
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (i, label) in [(0, "Sign in"), (1, "Sign up")])
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(i),
                        child: Center(
                          child: Text(
                            label,
                            style: ptstyle(
                              size: 14.5,
                              weight: 700,
                              color: Color.lerp(
                                ch.onSurface,
                                ch.onSurfaceVariant.withOpacity(0.7),
                                (position - i).abs().clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.trailing,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboard;
  final bool obscure;
  final String? Function(String?)? validator;
  final Widget? trailing;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                _focused
                    ? _blue.withOpacity(0.18)
                    : Colors.black.withOpacity(0.03),
            blurRadius: _focused ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        enabled: widget.enabled,
        keyboardType: widget.keyboard,
        obscureText: widget.obscure,
        validator: widget.validator,
        style: ptstyle(size: 15, weight: 500, color: ch.onSurface),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hint,
          hintStyle: ptstyle(
            size: 14.5,
            weight: 400,
            color: ch.onSurfaceVariant.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 20,
            color: _focused ? _blue : ch.onSurfaceVariant,
          ),
          suffixIcon: widget.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _blue, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5484D)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5484D), width: 1.6),
          ),
          errorStyle: ptstyle(
            size: 11.5,
            weight: 500,
            color: const Color(0xFFE5484D),
          ),
        ),
      ),
    );
  }
}

/// "🔑 Forgot password? →" pill that nudges on press.
class _ForgotButton extends StatelessWidget {
  const _ForgotButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: _blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2E8BFF), Color(0xFF8E5CFF)],
                ),
              ),
              child: const Icon(Icons.key_rounded, size: 13, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              "Forgot password?",
              style: ptstyle(size: 12.5, weight: 700, color: _blue),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, size: 17, color: _blue),
          ],
        ),
      ),
    );
  }
}

class _TermsTick extends StatelessWidget {
  const _TermsTick({
    required this.value,
    required this.onChanged,
    required this.onOpenTerms,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    final ch = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value ? _blue.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: value ? _blue.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? _blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: value ? _blue : ch.onSurface.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: AnimatedScale(
                scale: value ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "I agree to the FlexiPhones ",
                      style: ptstyle(
                        size: 13,
                        weight: 400,
                        color: ch.onSurface,
                        height: 1.45,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: onOpenTerms,
                        child: Text(
                          "Terms & Privacy Policy",
                          style: ptstyle(
                            size: 13,
                            weight: 700,
                            color: _blue,
                            height: 1.45,
                          ).copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ", including daily payments and phone locking if I miss a payment.",
                      style: ptstyle(
                        size: 13,
                        weight: 400,
                        color: ch.onSurface,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onTap,
    this.dimmed = false,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.5 : 1,
      child: PressScale(
        onTap: loading ? null : onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF2E8BFF), Color(0xFF0058C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _blue.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child:
              loading
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: ptstyle(
                          size: 16,
                          weight: 700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: Colors.white, size: 19),
                    ],
                  ),
        ),
      ),
    );
  }
}
