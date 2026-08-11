import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pitakapflutter/core/common/common.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/core/utils/validators.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/providers/forgot_password_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/providers/forgot_password_state.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) return;

    ref.read(forgotPasswordControllerProvider.notifier).submit(
          SendPasswordResetUseCaseParams(
            email: _emailController.text.trim(),
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
    final resetState = ref.watch(forgotPasswordControllerProvider).value;
    final isBusy = resetState is ForgotPasswordLoadingState;

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      final state = next.value;

      if (state is ForgotPasswordFailedState) {
        CommonSnackBar.showError(context, state.message);
        ref.read(forgotPasswordControllerProvider.notifier).reset();
        return;
      }

      if (state is ForgotPasswordSentState) {
        CommonSnackBar.showSuccess(context, Strings.forgotPasswordSent);
        ref.read(forgotPasswordControllerProvider.notifier).reset();
        _openLogin();
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
                Text(
                  Strings.forgotPasswordTitle,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Strings.forgotPasswordSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                CommonTextField(
                  controller: _emailController,
                  label: Strings.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  enabled: !isBusy,
                  validator: Validators.email,
                  onFieldSubmitted: (_) => _onSendResetLink(),
                ),
                const SizedBox(height: AppSpacing.lg),
                CommonPrimaryButton(
                  label: Strings.forgotPasswordAction,
                  onPressed: _onSendResetLink,
                  isLoading: resetState is ForgotPasswordLoadingState,
                ),
                const SizedBox(height: AppSpacing.xl),
                CommonRichLinkText(
                  text: Strings.forgotPasswordRemembered,
                  linkText: Strings.forgotPasswordSignInLink,
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
