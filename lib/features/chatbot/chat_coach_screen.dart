import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/text_styles.dart';
import '../../features/home/widgets/modern_bottom_nav_bar.dart';
import '../../features/onboarding/providers/user_profile_provider.dart';
import '../../providers/chat_coach_provider.dart';
import '../../providers/transaction_provider.dart';

class ChatCoachScreen extends StatefulWidget {
  const ChatCoachScreen({super.key});

  @override
  State<ChatCoachScreen> createState() => _ChatCoachScreenState();
}

class _ChatCoachScreenState extends State<ChatCoachScreen> {
  int _currentIndex = 3;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final transactions = context.read<TransactionProvider>().items;
    final profile = context.read<UserProfileProvider>().profile;
    await context.read<ChatCoachProvider>().sendMessage(
      userMessage: text,
      transactions: transactions,
      profile: profile,
    );
    _controller.clear();
  }

  void _onNavTabChanged(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushNamed('/budget');
        break;
      case 2:
        Navigator.of(context).pushNamed('/activity');
        break;
      case 3:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: ModernBottomNavBar(
        selectedIndex: _currentIndex,
        onTabChanged: _onNavTabChanged,
      ),
      body: SafeArea(
        child: Consumer<ChatCoachProvider>(
          builder: (context, provider, _) {
            final profileProvider = context.watch<UserProfileProvider>();
            final profile = profileProvider.profile;
            final showPersonalized = profile?.isComplete ?? false;
            final userName = profile?.userName ?? 'Friend';
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.headerTop,
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                    ),
                    children: [
                      _buildStandardHeader(
                        userName,
                        'AI Financial Advisor',
                        isDark,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _DatePill(label: 'Today'),
                      const SizedBox(height: AppSpacing.md),
                      if (provider.messages.isEmpty)
                        const _AnimatedBubble(
                          child: _AdvisorBubble(
                            message:
                                "Hi! I'm your BudgetBuddy Advisor. 🎓\nAsk me anything about budgeting or saving money.",
                          ),
                        )
                      else
                        ...provider.messages.map(
                          (msg) => _AnimatedBubble(
                            child: msg.role == 'user'
                                ? _UserBubble(message: msg.text)
                                : _AdvisorBubble(message: msg.text),
                          ),
                        ),
                      if (provider.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: AppSpacing.md),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Advisor is thinking...'),
                            ],
                          ),
                        ),
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _AdvisorError(message: provider.error!),
                        ),
                    ],
                  ),
                ),
                _AdvisorInputBar(
                  controller: _controller,
                  isLoading: provider.isLoading,
                  onSend: _send,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStandardHeader(
    String userName,
    String screenTitle,
    bool isDark,
  ) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'B',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTextStyles.label.copyWith(color: textSecondary),
                  ),
                  Text(
                    userName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/settings'),
                    icon: Icon(Icons.settings_outlined, color: textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          screenTitle,
          style: AppTextStyles.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AdvisorHeader extends StatelessWidget {
  const _AdvisorHeader({
    required this.onTapNotifications,
    required this.showPersonalized,
    required this.userName,
  });

  final VoidCallback onTapNotifications;
  final bool showPersonalized;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final initial = userName.isNotEmpty ? userName[0] : 'B';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/settings'),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight.withOpacity(0.6),
                child: Text(
                  initial.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: AppTextStyles.label.copyWith(color: textSecondary),
                ),
                const SizedBox(height: AppSpacing.micro),
                Text(
                  userName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showPersonalized) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Text(
                      'Personalized for your financial goals',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.input),
                boxShadow: AppShadows.subtle,
              ),
              child: IconButton(
                icon: Icon(Icons.notifications_none, color: textPrimary),
                onPressed: onTapNotifications,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: BoxDecoration(
                  color: AppColors.expense,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.darkDivider.withOpacity(0.6)
        : AppColors.lightDivider;
    final textColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBubble extends StatelessWidget {
  const _AnimatedBubble({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
    );
  }
}

class _AdvisorBubble extends StatelessWidget {
  const _AdvisorBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = Theme.of(context).colorScheme.surface;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.school_outlined, color: AppColors.income),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.subtle,
              ),
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.sm),
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
                boxShadow: AppShadows.subtle,
              ),
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorInputBar extends StatelessWidget {
  const _AdvisorInputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final canSend = value.text.trim().isNotEmpty && !isLoading;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ask about your finances...',
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: canSend ? AppColors.primary : AppColors.primaryLight,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.subtle,
                ),
                child: IconButton(
                  onPressed: canSend ? onSend : null,
                  icon: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdvisorError extends StatelessWidget {
  const _AdvisorError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.expense.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.expense),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
