import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/notification/push_notification/push_notification_handler.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/constants/icons_path.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/validators/validator.dart';
import 'package:enigma/src/features/auth/presentation/components/custom_elevated_button.dart';
import 'package:enigma/src/features/auth/presentation/components/custom_form_field.dart';
import 'package:enigma/src/features/auth/presentation/components/or_widget.dart';
import 'package:enigma/src/features/auth/presentation/components/social_media_icon_button.dart';
import 'package:enigma/src/features/auth/presentation/forget_password/view/forgot_password_screen.dart';
import 'package:enigma/src/features/auth/presentation/login/view_model/login_controller.dart';
import 'package:enigma/src/features/auth/presentation/signup/view_model/signup_controller.dart';
import 'package:enigma/src/shared/controller/validator/validatio_tracker_controller.dart';
import 'package:enigma/src/shared/data/model/validation_tracker/validation_tracker_model.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/widgets/shared_appbar.dart';
import 'package:enigma/src/shared/widgets/validation_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({super.key}) {}
  static const route = "/login";

  static setRoute() => "/login";

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ValidationTrackerController validationTrackerController = ValidationTrackerController();
  final SharedPreferenceManager preferenceManager = sl.get();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((t) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loginController = ref.watch(loginProvider);
    final signUpController = ref.watch(signUpProvider);
    return Scaffold(
      appBar: SharedAppbar(
        leadingWidget: InkWell(
          onTap: () {
            ref.read(goRouterProvider).pop();
          },
          child: Container(
            height: context.height * .05,
            width: context.width * .05,
            margin: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_outlined,
                size: 25,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Log in to Enigma",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Welcome back! Sign in using your social account or email to continue',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialMediaIconButton(
                        iconSource: IconsPath.facebookIcon,
                        onPressed: () {},
                      ),
                      SocialMediaIconButton(
                        iconSource: IconsPath.googleIcon,
                        onPressed: () {},
                      ),
                      SocialMediaIconButton(
                        iconSource: IconsPath.appleLightIcon,
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: OrWidget(
                      //color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                CustomFormField(
                  controller: emailController,
                  labelText: "Your Email",
                  validator: Validators.emailValidator,
                ),
                CustomFormField(
                  controller: passwordController,
                  labelText: "Password",
                  obscureText: signUpController.passwordVisibility,
                  onPressed: ref.read(signUpProvider.notifier).changeVisibility,
                  validator: (String? value) => null,
                ),
                ValidationTracker(
                  checkerController: passwordController,
                  validationTrackerController: validationTrackerController,
                  validTrackers: [
                    ValidationTrackerModel(
                      regExp: RegExp(r'[a-z]'),
                      message: "Must contain a lower case letter",
                    ),
                    ValidationTrackerModel(
                      regExp: RegExp(r'[A-Z]'),
                      message: "Must contain a upper case letter",
                    ),
                    ValidationTrackerModel(
                      regExp: RegExp(r'[0-9]'),
                      message: "Must contain a number",
                    ),
                  ],
                ),
                // ListTile(
                //   leading: Checkbox(
                //     value: loginController.isContainDigit,
                //     onChanged: (value) {},
                //   ),
                //   title: const Text("At least a digit"),
                // ),
                // SizedBox(height: context.height * 0.2),
                if (loginController.isLoading)
                  const CircularProgressIndicator()
                else
                  CustomElevatedButton(
                    buttonName: "Log in",
                    onPressed: () async {
                      if (formKey.currentState!.validate() && validationTrackerController.isValid) {
                        await ref
                            .read(loginProvider.notifier)
                            .login(email: emailController.text.trim(), password: passwordController.text);
                      }
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      context.push(ForgotPasswordScreen.setRoute);
                    },
                    child: const Text("Forget Password?"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
