import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    await context.read<ChatCoachProvider>().sendMessage(
          userMessage: text,
          transactions: transactions,
        );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  isActive: _currentIndex == 0,
                  onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                _NavItem(
                  label: 'Budget',
                  icon: Icons.pie_chart_outline,
                  isActive: _currentIndex == 1,
                  onTap: () => Navigator.of(context).pushNamed('/budget'),
                ),
                _NavItem(
                  label: 'Activity',
                  icon: Icons.list_alt,
                  isActive: _currentIndex == 2,
                  onTap: () => Navigator.of(context).pushNamed('/activity'),
                ),
                _NavItem(
                  label: 'Advisor',
                  icon: Icons.chat_bubble,
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<ChatCoachProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    children: [
                      _AdvisorHeader(
                        onTapNotifications: () {},
                      ),
                      const SizedBox(height: 40),
                      const Center(
                        child: Text(
                          'Today',
                          style: TextStyle(
                            color: Color(0xFF9AA3B2),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (provider.messages.isEmpty)
                        const _AdvisorBubble(
                          message:
                              "Hi! I'm your BudgetBuddy Advisor. 🎓\nAsk me anything about saving money as a student!",
                        )
                      else
                        ...provider.messages.map((msg) => _AdvisorBubble(message: msg.text)),
                      if (provider.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
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
}

class _AdvisorHeader extends StatelessWidget {
  const _AdvisorHeader({required this.onTapNotifications});

  final VoidCallback onTapNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/settings'),
              borderRadius: BorderRadius.circular(24),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFE4E8FF),
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Color(0xFF4C5BFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Alex Student',
                  style: TextStyle(
                    color: Color(0xFF1F2A37),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF1F2A37)),
            onPressed: onTapNotifications,
          ),
        ),
      ],
    );
  }
}

class _AdvisorBubble extends StatelessWidget {
  const _AdvisorBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFDFF7EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school_outlined, color: Color(0xFF22C55E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF1F2A37), height: 1.4),
            ),
          ),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ask your advisor...'
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: isLoading ? null : onSend,
            icon: isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _AdvisorError extends StatelessWidget {
  const _AdvisorError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB91C1C)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
