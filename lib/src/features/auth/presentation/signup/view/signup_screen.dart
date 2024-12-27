import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/validators/validator.dart';
import 'package:enigma/src/features/auth/presentation/components/custom_elevated_button.dart';
import 'package:enigma/src/features/auth/presentation/components/custom_form_field.dart';
import 'package:enigma/src/features/auth/presentation/signup/view_model/signup_controller.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/shared/data/model/validation_tracker/validation_tracker_model.dart';
import 'package:enigma/src/shared/widgets/shared_appbar.dart';
import 'package:enigma/src/shared/widgets/validation_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  SignupScreen({super.key});

  static const route = '/signup';

  static setRoute() => '/signup';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupController = ref.watch(signUpProvider);
    final profileController = ref.watch(profileProvider);
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sign up with Email",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Get chatting with friends and family today by signing up for our chat app',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                CustomFormField(
                  controller: nameController,
                  labelText: "Your Name",
                  validator: (val) => "",
                ),
                CustomFormField(
                  controller: emailController,
                  labelText: "Your Email",
                  validator: Validators.emailValidator,
                ),
                CustomFormField(
                  controller: passwordController,
                  labelText: "Password",
                  validator: Validators.passwordValidator,
                  obscureText: signupController.passwordVisibility,
                  onPressed: ref.read(signUpProvider.notifier).changeVisibility,
                  helperText: "Password must contains one A-Z, a-z and 0-9. E.g. Enigma1",
                ),
                CustomFormField(
                  controller: confirmPasswordController,
                  labelText: "Confirm Password",
                  obscureText: signupController.passwordVisibility,
                  validator: (val) {
                    if (val?.trim() != passwordController.text.trim()) {
                      return "Password Not Matched";
                    }
                    return null;
                  },
                ),
                ValidationTracker(
                  checkerController: passwordController,
                  validTrackers: [
                    ValidationTrackerModel(regExp: RegExp(r'[a-z]'), message: "Must contain a lower case letter"),
                    ValidationTrackerModel(regExp: RegExp(r'[A-Z]'), message: "Must contain a upper case letter"),
                    ValidationTrackerModel(regExp: RegExp(r'[0-9]'), message: "Must contain a number"),
                  ],
                ),
                if (signupController.isLoading || profileController.isLoading)
                  const CircularProgressIndicator()
                else
                  CustomElevatedButton(
                    buttonName: "Create an Account",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        String uid = await ref.read(signUpProvider.notifier).signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                        if (uid.isNotEmpty) {
                          showDialog<void>(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 50,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "A verification email has been sent to your email. please verify the email from the link.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () async {
                                      ProfileEntity profileEntity = ProfileEntity(
                                        uid: uid,
                                        name: nameController.text.trim(),
                                        email: emailController.text.trim(),
                                        createdAt: DateTime.now(),
                                      );
                                      await ref.read(profileProvider.notifier).createProfile(profileEntity);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
