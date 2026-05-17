import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import 'user_detail.dart';
import 'user_form.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetch first page on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });

    // Load more when scrolled to bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<UserProvider>().fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<UserProvider>().fetchUsers(refresh: true);
  }

  void _openCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Base'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Add User',
        child: const Icon(Icons.person_add),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          // Error state (no data yet)
          if (provider.hasError && provider.users.isEmpty) {
            return _ErrorView(
              message: provider.error!,
              onRetry: () => provider.fetchUsers(refresh: true),
            );
          }

          // Loading state (first load)
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          if (provider.users.isEmpty) {
            return const Center(
              child: Text('No users found. Add one!'),
            );
          }

          // List
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                // Error banner (data already showing but refresh failed)
                if (provider.hasError)
                  _ErrorBanner(
                    message: provider.error!,
                    onDismiss: provider.clearError,
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.users.length + (provider.hasMorePages ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Bottom loader
                      if (index == provider.users.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _UserCard(user: provider.users[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// User Card Widget
class _UserCard extends StatelessWidget {
  final User user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
          child: user.avatar.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(user.fullName),
        subtitle: Text(user.email.isNotEmpty ? user.email : user.job ?? ''),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(user: user),
            ),
          );
        },
      ),
    );
  }
}

// Error full-screen view
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Error banner (shown over existing list)
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      backgroundColor: Colors.red.shade50,
      leading: const Icon(Icons.error_outline, color: Colors.red),
      actions: [
        TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
      ],
    );
  }
}