import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';

/// Public Turnstile site key (safe to ship). The SECRET key lives only on
/// the API server and is never put in the app.
const kTurnstileSiteKey = "0x4AAAAAAAFUwGEaW3t9araJB";

/// Must be one of the hostnames listed on the Turnstile widget in Cloudflare.
const kTurnstileBaseUrl = "https://flexiphones.app/";

/// "I am not a robot" (Cloudflare Turnstile). Calls [onToken] with a fresh
/// token when the check passes and with null when it expires or fails.
class RobotCheck extends StatefulWidget {
  const RobotCheck({super.key, required this.onToken});

  final ValueChanged<String?> onToken;

  @override
  State<RobotCheck> createState() => _RobotCheckState();
}

class _RobotCheckState extends State<RobotCheck> {
  final _controller = TurnstileController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: CloudflareTurnstile(
        siteKey: kTurnstileSiteKey,
        baseUrl: kTurnstileBaseUrl,
        controller: _controller,
        options: TurnstileOptions(
          size: TurnstileSize.normal,
          theme: TurnstileTheme.light,
          retryAutomatically: true,
          refreshTimeout: TurnstileRefreshTimeout.auto,
        ),
        onTokenReceived: (t) => widget.onToken(t),
        onTokenExpired: () => widget.onToken(null),
        onError: (_) => widget.onToken(null),
      ),
    );
  }
}
