import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/placement_provider.dart';
import '../../data/local/database.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final PlacementApplication application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  static Route route(PlacementApplication application) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ApplicationDetailScreen(application: application),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = const Offset(1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends ConsumerState<ApplicationDetailScreen> {
  late PlacementApplication _currentApp;
  bool _isEditing = false;
  late TextEditingController _companyController;
  late TextEditingController _roleController;
  late TextEditingController _nextStepController;
  late TextEditingController _notesController;
  late String _status;
  DateTime? _nextStepDate;

  @override
  void initState() {
    super.initState();
    _currentApp = widget.application;
    _companyController = TextEditingController(text: _currentApp.company);
    _roleController = TextEditingController(text: _currentApp.role);
    _nextStepController = TextEditingController(text: _currentApp.nextStep ?? '');
    _notesController = TextEditingController(text: _currentApp.notes ?? '');
    _status = _currentApp.status;
    _nextStepDate = _currentApp.nextStepDate;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _nextStepController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset fields if editing canceled
        _companyController.text = _currentApp.company;
        _roleController.text = _currentApp.role;
        _nextStepController.text = _currentApp.nextStep ?? '';
        _notesController.text = _currentApp.notes ?? '';
        _status = _currentApp.status;
        _nextStepDate = _currentApp.nextStepDate;
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_companyController.text.trim().isEmpty || _roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company and Role cannot be empty')),
      );
      return;
    }

    final updated = PlacementApplication(
      id: _currentApp.id,
      company: _companyController.text.trim(),
      role: _roleController.text.trim(),
      status: _status,
      appliedDate: _currentApp.appliedDate,
      nextStep: _nextStepController.text.trim().isNotEmpty ? _nextStepController.text.trim() : null,
      nextStepDate: _nextStepDate,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    await ref.read(placementProvider.notifier).updateApplication(updated);
    setState(() {
      _currentApp = updated;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application updated successfully')),
    );
  }

  Future<void> _deleteApp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: Text('Delete Application', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this placement record?', style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.inter(color: const Color(0xFFFF4444))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(placementProvider.notifier).deleteApplication(_currentApp.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    Color statusBorder;
    String statusLabel;

    switch (_status.toLowerCase()) {
      case 'applied':
        statusColor = Colors.white;
        statusBg = Colors.white.withOpacity(0.06);
        statusBorder = Colors.white.withOpacity(0.20);
        statusLabel = 'APPLIED';
        break;
      case 'interview':
        statusColor = const Color(0xFFC6F52C);
        statusBg = const Color(0xFFC6F52C).withOpacity(0.12);
        statusBorder = const Color(0xFFC6F52C).withOpacity(0.45);
        statusLabel = 'INTERVIEWING';
        break;
      case 'offer':
        statusColor = const Color(0xFF4ADE80);
        statusBg = const Color(0xFF4ADE80).withOpacity(0.12);
        statusBorder = const Color(0xFF4ADE80).withOpacity(0.45);
        statusLabel = 'OFFER';
        break;
      case 'rejected':
      default:
        statusColor = const Color(0xFFFF4444);
        statusBg = const Color(0xFFFF4444).withOpacity(0.12);
        statusBorder = const Color(0xFFFF4444).withOpacity(0.45);
        statusLabel = 'REJECTED';
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              key: ValueKey('g1_$_status'),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(0.08),
              ),
            ),
          ),

          
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                      Text(
                        _isEditing ? 'EDIT APPLICATION' : 'DETAILS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Row(
                        children: [
                          if (!_isEditing)
                            GestureDetector(
                              onTap: _deleteApp,
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF4444)),
                              ),
                            ),
                          GestureDetector(
                            onTap: _isEditing ? _saveChanges : _toggleEdit,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _isEditing ? const Color(0xFFC6F52C) : Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isEditing ? Icons.check_rounded : Icons.edit_outlined,
                                size: 18,
                                color: _isEditing ? const Color(0xFF050505) : Colors.white,
                              ),
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _toggleEdit,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                              ),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        
                        // Hero Summary Card
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isEditing) ...[
                                _buildTextField('Company Name', _companyController),
                                const SizedBox(height: 16),
                                _buildTextField('Job Title / Role', _roleController),
                              ] else ...[
                                Text(
                                  _currentApp.company,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _currentApp.role,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.55),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              
                              // Status Selection/Display
                              if (_isEditing) ...[
                                Text(
                                  'STATUS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white54,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _status,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF161616),
                                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                                      items: const [
                                        DropdownMenuItem(value: 'applied', child: Text('Applied')),
                                        DropdownMenuItem(value: 'interview', child: Text('Interview')),
                                        DropdownMenuItem(value: 'offer', child: Text('Offer')),
                                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                                      ],
                                      onChanged: (v) => setState(() => _status = v!),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: statusColor.withOpacity(0.6), blurRadius: 4),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        statusLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Timeline & Milestone Card
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white54),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TIMELINE & NEXT STEPS',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white54,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, color: Colors.white10),
                              
                              // Applied Date
                              _buildDetailRow(
                                'Applied Date',
                                DateFormat('MMMM dd, yyyy').format(_currentApp.appliedDate),
                              ),
                              const SizedBox(height: 16),
                              
                              // Next Step
                              if (_isEditing) ...[
                                _buildTextField('Next Step (e.g. Technical Interview)', _nextStepController),
                                const SizedBox(height: 16),
                                Text(
                                  'Next Step Date',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _nextStepDate ?? DateTime.now(),
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2030),
                                      builder: (context, child) => Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFFC6F52C),
                                            onPrimary: Colors.black,
                                            surface: Color(0xFF161616),
                                            onSurface: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) {
                                      setState(() => _nextStepDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _nextStepDate != null
                                              ? DateFormat('MMMM dd, yyyy').format(_nextStepDate!)
                                              : 'Select Date',
                                          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                                        ),
                                        if (_nextStepDate != null)
                                          GestureDetector(
                                            onTap: () => setState(() => _nextStepDate = null),
                                            child: const Icon(Icons.close, size: 16, color: Colors.white54),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                _buildDetailRow(
                                  'Next Step',
                                  _currentApp.nextStep ?? 'None scheduled',
                                ),
                                if (_currentApp.nextStepDate != null) ...[
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    'Next Step Date',
                                    DateFormat('MMMM dd, yyyy').format(_currentApp.nextStepDate!),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Notes Section Card
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notes_rounded, size: 16, color: Colors.white54),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TRACKER NOTES',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white54,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, color: Colors.white10),
                              if (_isEditing)
                                TextField(
                                  controller: _notesController,
                                  maxLines: 4,
                                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Add notes about interview preparation, contacts, questions, etc.',
                                    hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white30),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFC6F52C)),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  _currentApp.notes ?? 'No notes recorded. Tap edit to write prep notes.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: _currentApp.notes != null ? Colors.white70 : Colors.white24,
                                    height: 1.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
