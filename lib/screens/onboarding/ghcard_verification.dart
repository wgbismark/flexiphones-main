import 'package:flexiphones/extensions/value_validation.dart';
import 'package:flexiphones/helpers/assets_helper.dart';
import 'package:flexiphones/helpers/navigation_helper.dart';
import 'package:flexiphones/provider/provider_class.dart';
import 'package:flexiphones/screens/init_screen.dart';
import 'package:flexiphones/shared_widgets/bgw.dart';
import 'package:flexiphones/shared_widgets/generalwidgets.dart';
import 'package:flexiphones/shared_widgets/input_field.dart';
import 'package:flexiphones/shared_widgets/smart_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GHCardVerification extends StatefulWidget {
  const GHCardVerification({super.key, this.lateVerification = false});
  final bool lateVerification;
  @override
  State<GHCardVerification> createState() => _GHCardVerificationState();
}

class _GHCardVerificationState extends State<GHCardVerification> {
  //  var appController = Get.find<AppController>(tag: "ac");

  @override
  void initState() {
    super.initState();
  }

  FocusNode ghCardFocusNode = FocusNode();
  FocusNode ghCardFocusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    var ch = Theme.of(context).colorScheme;
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        actionsPadding: EdgeInsets.only(right: 10),
        // automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed:
                () =>
                    widget.lateVerification
                        ? NavigationHelper.pop(context)
                        : NavigationHelper.pushAndRemoveUntil(
                          context,
                          InitScreen(),
                        ),
            child: Text(
              "Skip",
              style: ptstyle(
                size: 12,
                weight: 300,
                color: ch.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Bgw(),
          ListView(
            padding: EdgeInsets.all(20),
            children: [
              SizedBox(height: 20),
              Image.asset(
                AssetsHelper.ghcImage,
                height: 250,
                width: 200,
                fit: BoxFit.contain,
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Link Your Ghana Card",
                      textAlign: TextAlign.center,
                      style: ptstyle(size: 25, weight: 600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter your Ghana Card number to proceed",
                      textAlign: TextAlign.center,
                      style: ptstyle(size: 12, weight: 300),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              SizedBox(
                height: 45,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      height: 55,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: ch.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Text(
                        "GHA",
                        textAlign: TextAlign.center,
                        style: ptstyle(
                          size: 12,
                          weight: 600,
                          color: ch.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Text(
                        "-",
                        textAlign: TextAlign.center,
                        style: ptstyle(size: 12, weight: 600),
                      ),
                    ),

                    SizedBox(
                      width: 120,
                      child: FilledInput(
                        focusNode: ghCardFocusNode2,
                        enabled: !sharedProvider.ghCardVrLoading,
                        maxLength: 9,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 2,
                        ),
                        textAlign: TextAlign.center,
                        label: "",
                        hintText: "0 0 0 0 0 0 0 0 0",
                        controller: sharedProvider.ghCardEditingController,
                        keyboardType: TextInputType.number,
                        style: ptstyle(
                          size: 16,
                          weight: 600,
                          color: ch.onSurfaceVariant,
                        ),
                        onChange: (x) {
                          setState(() {
                            sharedProvider.ghCardValidation =
                                x.isEmpty
                                    ? false
                                    : !"$x-${sharedProvider.ghCardEditingController2.text.trim()}"
                                        .isValidGhanaCardDigits;
                          });

                          if (x.length == 9) {
                            ghCardFocusNode.requestFocus();
                          }
                        },
                        error: sharedProvider.ghCardValidation,
                      ),
                    ),

                    Container(
                      height: 55,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Text(
                        "-",
                        textAlign: TextAlign.center,
                        style: ptstyle(size: 12, weight: 600),
                      ),
                    ),

                    SizedBox(
                      width: 40,
                      child: FilledInput(
                        maxLength: 1,
                        focusNode: ghCardFocusNode,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 0,
                        ),
                        enabled: !sharedProvider.ghCardVrLoading,
                        label: "",
                        style: ptstyle(
                          size: 16,
                          weight: 600,
                          color: ch.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        hintText: "0",
                        controller: sharedProvider.ghCardEditingController2,
                        keyboardType: TextInputType.number,
                        onChange: (x) {
                          setState(() {
                            sharedProvider.ghCardValidation =
                                x.isEmpty
                                    ? false
                                    : !"${sharedProvider.ghCardEditingController.text.trim()}-$x"
                                        .isValidGhanaCardDigits;
                          });
                          if (x.length == 1) {
                            ghCardFocusNode.unfocus();
                          }
                          if (x.isEmpty) {
                            ghCardFocusNode2.requestFocus();
                          }
                        },
                        error: sharedProvider.ghCardValidation,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              SizedBox(
                height: 47,
                child: SmartButton(
                  enabled:
                      !sharedProvider.ghCardValidation &&
                      sharedProvider.ghCardEditingController.text.isNotEmpty,
                  loading: sharedProvider.ghCardVrLoading,
                  onPressed: () => sharedProvider.validateGHC(context),
                  child: Text("Verify", style: ptstyle(size: 12, weight: 400)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
