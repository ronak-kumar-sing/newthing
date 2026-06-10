import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

/// Placement Tracker — track job applications, interviews, and prep milestones.
class PlacementTrackerScreen extends ConsumerStatefulWidget {
  const PlacementTrackerScreen({super.key});

  @override
  ConsumerState<PlacementTrackerScreen> createState() => _PlacementTrackerScreenState();
}

class _PlacementTrackerScreenState extends ConsumerState<PlacementTrackerScreen> {
  final List<_PlacementApplication> _applications = [];

  @override
  void initState() {
    super.initState();
    // Sample data
    _applications.addAll([
      _PlacementApplication(
        id: '1',
        company: 'TCS',
        role: 'Software Engineer',
        status: _ApplicationStatus.applied,
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      _PlacementApplication(
        id: '2',
        company: 'Infosys',
        role: 'Systems Engineer',
        status: _ApplicationStatus.interview,
        appliedDate: DateTime.now().subtract(const Duration(days: 12)),
        nextStep: 'Technical Interview on June 15',
        nextStepDate: DateTime.now().add(const Duration(days: 7)),
      ),
      _PlacementApplication(
        id: '3',
        company: 'Wipro',
        role: 'Project Engineer',
        status: _ApplicationStatus.rejected,
        appliedDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ]);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddApplicationDialog(
        onAdd: (app) => setState(() => _applications.add(app)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Placement Tracker',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Application'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Track every application, interview, and outcome. Stay organized.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                _StatCard(
                  label: 'Applied',
                  value: '${stats['applied']}',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Interview',
                  value: '${stats['interview']}',
                  color: AppColors.countdown,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Offer',
                  value: '${stats['offer']}',
                  color: AppColors.productive,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Rejected',
                  value: '${stats['rejected']}',
                  color: AppColors.distracted,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Applications list
            Expanded(
              child: _applications.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      itemCount: _applications.length,
                      itemBuilder: (context, index) {
                        final app = _applications[index];
                        return _ApplicationCard(
                          application: app,
                          onStatusChange: (status) {
                            setState(() {
                              _applications[index] = app.copyWith(status: status);
                            });
                          },
                          onDelete: () {
                            setState(() => _applications.removeAt(index));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateStats() {
    final stats = <String, int>{
      'applied': 0,
      'interview': 0,
      'offer': 0,
      'rejected': 0,
    };
    for (final app in _applications) {
      stats[app.status.name] = (stats[app.status.name] ?? 0) + 1;
    }
    return stats;
  }
}

enum _ApplicationStatus { applied, interview, offer, rejected }

class _PlacementApplication {
  final String id;
  final String company;
  final String role;
  final _ApplicationStatus status;
  final DateTime appliedDate;
  final String? nextStep;
  final DateTime? nextStepDate;
  final String? notes;

  _PlacementApplication({
    required this.id,
    required this.company,
    required this.role,
    required this.status,
    required this.appliedDate,
    this.nextStep,
    this.nextStepDate,
    this.notes,
  });

  _PlacementApplication copyWith({_ApplicationStatus? status}) {
    return _PlacementApplication(
      id: id,
      company: company,
      role: role,
      status: status ?? this.status,
      appliedDate: appliedDate,
      nextStep: nextStep,
      nextStepDate: nextStepDate,
      notes: notes,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final _PlacementApplication application;
  final ValueChanged<_ApplicationStatus> onStatusChange;
  final VoidCallback onDelete;

  const _ApplicationCard({
    required this.application,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (application.status) {
      case _ApplicationStatus.applied:
        statusColor = AppColors.primary;
        statusLabel = 'Applied';
      case _ApplicationStatus.interview:
        statusColor = AppColors.countdown;
        statusLabel = 'Interview';
      case _ApplicationStatus.offer:
        statusColor = AppColors.productive;
        statusLabel = 'Offer';
      case _ApplicationStatus.rejected:
        statusColor = AppColors.distracted;
        statusLabel = 'Rejected';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                application.company.substring(0, 1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.company,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application.role,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (application.nextStep != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event, size: 14, color: AppColors.countdown),
                      const SizedBox(width: 6),
                      Text(
                        application.nextStep!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.countdown,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PopupMenuButton<_ApplicationStatus>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                color: AppColors.surfaceLight,
                onSelected: onStatusChange,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _ApplicationStatus.applied,
                    child: Text('Applied'),
                  ),
                  const PopupMenuItem(
                    value: _ApplicationStatus.interview,
                    child: Text('Interview'),
                  ),
                  const PopupMenuItem(
                    value: _ApplicationStatus.offer,
                    child: Text('Offer'),
                  ),
                  const PopupMenuItem(
                    value: _ApplicationStatus.rejected,
                    child: Text('Rejected'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.work_outline,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No applications yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your placement journey.\nEvery application is a step forward.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddApplicationDialog extends StatefulWidget {
  final ValueChanged<_PlacementApplication> onAdd;

  const _AddApplicationDialog({required this.onAdd});

  @override
  State<_AddApplicationDialog> createState() => _AddApplicationDialogState();
}

class _AddApplicationDialogState extends State<_AddApplicationDialog> {
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _nextStepController = TextEditingController();
  _ApplicationStatus _status = _ApplicationStatus.applied;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Add Application',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                hintText: 'e.g., TCS',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'Role',
                hintText: 'e.g., Software Engineer',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<_ApplicationStatus>(
              value: _status,
              dropdownColor: AppColors.surfaceLight,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: _ApplicationStatus.applied, child: Text('Applied')),
                DropdownMenuItem(value: _ApplicationStatus.interview, child: Text('Interview')),
                DropdownMenuItem(value: _ApplicationStatus.offer, child: Text('Offer')),
                DropdownMenuItem(value: _ApplicationStatus.rejected, child: Text('Rejected')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nextStepController,
              decoration: const InputDecoration(
                labelText: 'Next Step (optional)',
                hintText: 'e.g., Technical Interview on June 15',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_companyController.text.isNotEmpty && _roleController.text.isNotEmpty) {
              widget.onAdd(_PlacementApplication(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                company: _companyController.text,
                role: _roleController.text,
                status: _status,
                appliedDate: DateTime.now(),
                nextStep: _nextStepController.text.isNotEmpty ? _nextStepController.text : null,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
