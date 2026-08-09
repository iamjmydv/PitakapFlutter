import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pitakapflutter/core/common/common.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/core/utils/validators.dart';
import 'package:pitakapflutter/core/widgets/app_logo.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onSignIn() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.validate();
  }

  void _openSignUp() => context.push(AppRoutes.signUp);

  void _openForgotPassword() {
    final email = _emailController.text.trim();
    final location = Uri(
      path: AppRoutes.forgotPassword,
      queryParameters: email.isEmpty
          ? null
          : {AppRoutes.emailQueryParam: email},
    ).toString();

    context.push(location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  const Center(child: AppLogo(size: 72)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    Strings.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    Strings.loginTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CommonTextField(
                    controller: _emailController,
                    label: Strings.emailLabel,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    onFieldSubmitted: (_) =>
                        _passwordFocusNode.requestFocus(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CommonPasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    validator: Validators.password,
                    onFieldSubmitted: (_) => _onSignIn(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openForgotPassword,
                      child: const Text(Strings.loginForgotPassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CommonPrimaryButton(
                    label: Strings.loginSignIn,
                    onPressed: _onSignIn,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _OrDivider(),
                  const SizedBox(height: AppSpacing.md),
                  const _GoogleButton(),
                  const SizedBox(height: AppSpacing.xl),
                  CommonRichLinkText(
                    text: Strings.loginNoAccount,
                    linkText: Strings.loginSignUpLink,
                    onTap: _openSignUp,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(Strings.loginOr, style: theme.textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  static const Color _googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'G',
            style: theme.textTheme.titleMedium?.copyWith(
              color: _googleBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text(Strings.loginContinueWithGoogle),
        ],
      ),
    );
  }
}
