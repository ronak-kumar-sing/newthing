import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/widgets/slice_widgets.dart';

/// Placement Tracker — matches Stitch design "Placement Tracker"
/// Track job applications, interviews, and prep milestones.
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
      backgroundColor: AnchorTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Placement Tracker',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AnchorTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    'Add',
                    _showAddDialog,
                    icon: Icons.add,
                    isOutlined: true,
                    height: 40,
                  ),
                ],
              ).animate().fade().slideY(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'Track every application, interview, and outcome. Stay organized.',
                style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textSecondary),
              ).animate(delay: 100.ms).fade(),
              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  _StatCard(label: 'Applied', value: '${stats['applied']}', color: AnchorTheme.statusBlue).animate(delay: 200.ms).fade().slideX(begin: -0.1),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Interview', value: '${stats['interview']}', color: AnchorTheme.statusOrange).animate(delay: 300.ms).fade().slideY(begin: 0.1),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Offer', value: '${stats['offer']}', color: AnchorTheme.statusGreen).animate(delay: 400.ms).fade().slideY(begin: 0.1),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Rejected', value: '${stats['rejected']}', color: AnchorTheme.statusRed).animate(delay: 500.ms).fade().slideX(begin: 0.1),
                ],
              ),
              const SizedBox(height: 24),

              // Applications list
              Expanded(
                child: _applications.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: _applications.length,
                        itemBuilder: (context, index) {
                          final app = _applications[index];
                          return _ApplicationCard(
                            application: app,
                            onStatusChange: (status) {
                              setState(() => _applications[index] = app.copyWith(status: status));
                            },
                            onDelete: () {
                              setState(() => _applications.removeAt(index));
                            },
                          ).animate(delay: (300 + index * 100).ms).fade().slideX(begin: 0.1);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateStats() {
    final stats = <String, int>{'applied': 0, 'interview': 0, 'offer': 0, 'rejected': 0};
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

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CleanCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AnchorTheme.textMuted,
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
        statusColor = AnchorTheme.statusBlue;
        statusLabel = 'Applied';
      case _ApplicationStatus.interview:
        statusColor = AnchorTheme.statusOrange;
        statusLabel = 'Interview';
      case _ApplicationStatus.offer:
        statusColor = AnchorTheme.statusGreen;
        statusLabel = 'Offer';
      case _ApplicationStatus.rejected:
        statusColor = AnchorTheme.statusRed;
        statusLabel = 'Rejected';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AccentCard(
        padding: const EdgeInsets.all(20),
        accentColor: statusColor,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  application.company.substring(0, 1),
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: statusColor),
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
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AnchorTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.role,
                    style: GoogleFonts.inter(fontSize: 13, color: AnchorTheme.textSecondary),
                  ),
                  if (application.nextStep != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.event, size: 14, color: AnchorTheme.statusOrange),
                        const SizedBox(width: 6),
                        Text(
                          application.nextStep!,
                          style: GoogleFonts.inter(fontSize: 12, color: AnchorTheme.statusOrange),
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
                const SizedBox(height: 8),
                PopupMenuButton<_ApplicationStatus>(
                  icon: const Icon(Icons.more_vert, size: 18, color: AnchorTheme.textMuted),
                  color: AnchorTheme.cardFloat,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: onStatusChange,
                  itemBuilder: (context) => [
                    PopupMenuItem(value: _ApplicationStatus.applied, child: Text('Applied', style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textPrimary))),
                    PopupMenuItem(value: _ApplicationStatus.interview, child: Text('Interview', style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textPrimary))),
                    PopupMenuItem(value: _ApplicationStatus.offer, child: Text('Offer', style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textPrimary))),
                    PopupMenuItem(value: _ApplicationStatus.rejected, child: Text('Rejected', style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textPrimary))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_outline, size: 48, color: AnchorTheme.textMuted),
          const SizedBox(height: 16),
          Text('No applications yet', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AnchorTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Start tracking your placement journey.\nEvery application is a step forward.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textMuted)),
        ],
      ),
    ).animate().fade();
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
    return Dialog(
      backgroundColor: AnchorTheme.cardFloat,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(label: 'Add Application', color: AnchorTheme.accent),
              const SizedBox(height: 24),
              _CleanTextField(controller: _companyController, hintText: 'Company (e.g. TCS)'),
              const SizedBox(height: 12),
              _CleanTextField(controller: _roleController, hintText: 'Role (e.g. Software Engineer)'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AnchorTheme.cardInset,
                  borderRadius: BorderRadius.circular(AnchorTheme.radiusInput),
                  border: Border.all(color: AnchorTheme.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_ApplicationStatus>(
                    value: _status,
                    isExpanded: true,
                    dropdownColor: AnchorTheme.cardBg,
                    style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textPrimary),
                    items: const [
                      DropdownMenuItem(value: _ApplicationStatus.applied, child: Text('Applied')),
                      DropdownMenuItem(value: _ApplicationStatus.interview, child: Text('Interview')),
                      DropdownMenuItem(value: _ApplicationStatus.offer, child: Text('Offer')),
                      DropdownMenuItem(value: _ApplicationStatus.rejected, child: Text('Rejected')),
                    ],
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CleanTextField(controller: _nextStepController, hintText: 'Next Step (optional)'),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton('Cancel', () => Navigator.pop(context), height: 48, isOutlined: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      'Add',
                      () {
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
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }
}

class _CleanTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _CleanTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AnchorTheme.cardInset,
        borderRadius: BorderRadius.circular(AnchorTheme.radiusInput),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
