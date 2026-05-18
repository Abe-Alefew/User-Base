import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'user_form.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await context.read<UserProvider>().deleteUser(user.id);

      if (context.mounted) {
        if (success) {
          Navigator.pop(context); // back to list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')),
          );
        } else {
          final error = context.read<UserProvider>().error ?? 'Delete failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _openEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(existingUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _openEditScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            color: Colors.red,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 56,
                  backgroundImage: user.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : null,
                  child: user.avatar.isEmpty
                      ? const Icon(Icons.person, size: 56)
                      : null,
                ),
                const SizedBox(height: 20),

                // Name
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),

                // Job
                if (user.job != null && user.job!.isNotEmpty)
                  Text(
                    user.job!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),

                const SizedBox(height: 32),
                const SizedBox(height: 16),

                // Info rows
                _InfoRow(icon: Icons.badge, label: 'ID', value: '#${user.id}'),
                if (user.email.isNotEmpty)
                  _InfoRow(
                      icon: Icons.email, label: 'Email', value: user.email),
                if (user.createdAt != null)
                  _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: user.createdAt!),
                if (user.updatedAt != null)
                  _InfoRow(
                      icon: Icons.update,
                      label: 'Updated',
                      value: user.updatedAt!),

                const SizedBox(height: 32),

                // Loading indicator during delete
                if (provider.isLoading)
                  const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}