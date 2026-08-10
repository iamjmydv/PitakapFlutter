import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pitakapflutter/core/common/common.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/core/utils/validators.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_up_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/providers/sign_up_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/providers/sign_up_state.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _onSignUp() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) return;

    ref.read(signUpControllerProvider.notifier).submit(
          SignUpUseCaseParams(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _openLogin() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signUpState = ref.watch(signUpControllerProvider).value;

    ref.listen(signUpControllerProvider, (previous, next) {
      final state = next.value;
      if (state is SignUpFailedState) {
        CommonSnackBar.showError(context, state.message);
        ref.read(signUpControllerProvider.notifier).reset();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _openLogin,
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(Strings.signUpTitle, style: theme.textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(Strings.signUpSubtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CommonTextField(
                        controller: _firstNameController,
                        label: Strings.firstNameLabel,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (value) => Validators.notEmpty(
                          value,
                          Strings.firstNameRequired,
                        ),
                        onFieldSubmitted: (_) =>
                            _lastNameFocusNode.requestFocus(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CommonTextField(
                        controller: _lastNameController,
                        focusNode: _lastNameFocusNode,
                        label: Strings.lastNameLabel,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (value) => Validators.notEmpty(
                          value,
                          Strings.lastNameRequired,
                        ),
                        onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CommonTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: Strings.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: AppSpacing.md),
                CommonPasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  onFieldSubmitted: (_) => _confirmFocusNode.requestFocus(),
                ),
                const SizedBox(height: AppSpacing.md),
                CommonPasswordField(
                  controller: _confirmController,
                  focusNode: _confirmFocusNode,
                  label: Strings.confirmPasswordLabel,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  onFieldSubmitted: (_) => _onSignUp(),
                ),
                const SizedBox(height: AppSpacing.lg),
                CommonPrimaryButton(
                  label: Strings.signUpAction,
                  onPressed: _onSignUp,
                  isLoading: signUpState is SignUpLoadingState,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  Strings.signUpTerms,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.xl),
                CommonRichLinkText(
                  text: Strings.signUpHaveAccount,
                  linkText: Strings.signUpSignInLink,
                  onTap: _openLogin,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
