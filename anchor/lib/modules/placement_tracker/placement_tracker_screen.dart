import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/placement_provider.dart';
import '../../data/local/database.dart';
import 'application_detail_screen.dart';

class PlacementTrackerScreen extends ConsumerStatefulWidget {
  const PlacementTrackerScreen({super.key});

  @override
  ConsumerState<PlacementTrackerScreen> createState() => _PlacementTrackerScreenState();
}

class _PlacementTrackerScreenState extends ConsumerState<PlacementTrackerScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<PlacementApplication> _localList = [];
  bool _isFirstLoad = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(placementProvider);
    final filteredApps = ref.watch(filteredPlacementsProvider);

    // Sync AnimatedList with stream
    ref.listen<List<PlacementApplication>>(filteredPlacementsProvider, (previous, next) {
      if (_isFirstLoad) {
        _localList = List.from(next);
        _isFirstLoad = false;
        return;
      }

      final listState = _listKey.currentState;
      if (listState == null) {
        _localList = List.from(next);
        return;
      }

      // 1. Remove items that no longer exist
      for (int i = _localList.length - 1; i >= 0; i--) {
        final item = _localList[i];
        if (!next.any((element) => element.id == item.id)) {
          final removedItem = _localList.removeAt(i);
          listState.removeItem(
            i,
            (context, animation) => _buildListItem(removedItem, animation),
            duration: const Duration(milliseconds: 200),
          );
        }
      }

      // 2. Insert new items
      for (int i = 0; i < next.length; i++) {
        final item = next[i];
        final localIndex = _localList.indexWhere((element) => element.id == item.id);
        if (localIndex == -1) {
          _localList.insert(i, item);
          listState.insertItem(
            i,
            duration: const Duration(milliseconds: 300),
          );
        } else {
          _localList[localIndex] = item;
        }
      }

      // Synchronize final order
      _localList = List.from(next);
    });

    if (_isFirstLoad && filteredApps.isNotEmpty) {
      _localList = List.from(filteredApps);
      _isFirstLoad = false;
    }

    final stats = ref.watch(placementStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: _AtmosphericGlows(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Main content wrapped in RefreshIndicator
              RefreshIndicator(
                color: const Color(0xFFC6F52C),
                backgroundColor: const Color(0xFF161616),
                onRefresh: () => ref.read(placementProvider.notifier).refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // TOP BAR
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Placement Tracker',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'CAMPUS 2026',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFC6F52C),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.search_rounded, size: 22, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _isSearching = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // STAT CARDS — 2x2 GRID
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.3,
                          children: [
                            _buildStatCard('APPLIED', stats['applied'] ?? 0, Colors.white, 80),
                            _buildStatCard('INTERVIEW', stats['interview'] ?? 0, const Color(0xFFC6F52C), 160),
                            _buildStatCard('OFFER', stats['offer'] ?? 0, const Color(0xFF4ADE80), 240),
                            _buildStatCard('REJECTED', stats['rejected'] ?? 0, const Color(0xFFFF4444), 320),
                          ],
                        ),
                      ),
                    ),

                    // APPLICATIONS SECTION HEADER
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Applications',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showSortSheet(context, ref),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'SORT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.55),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.55),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // APPLICATION LIST (Driven by AnimatedList or empty state)
                    appsAsync.when(
                      data: (_) {
                        if (_localList.isEmpty) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyState(),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          sliver: SliverAnimatedList(
                            key: _listKey,
                            initialItemCount: _localList.length,
                            itemBuilder: (context, index, animation) {
                              if (index >= _localList.length) return const SizedBox.shrink();
                              final app = _localList[index];
                              return _buildListItem(app, animation);
                            },
                          ),
                        );
                      },
                      loading: () => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFFC6F52C)),
                        ),
                      ),
                      error: (err, stack) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Error loading applications',
                            style: GoogleFonts.inter(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lime Circle FAB bottom-right
              Positioned(
                bottom: 96,
                right: 16,
                child: ScaleOnPress(
                  onTap: () => _showAddBottomSheet(context),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC6F52C),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC6F52C).withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: Color(0xFF050505),
                    ),
                  ),
                ),
              ),

              // Search Overlay
              if (_isSearching) _buildSearchOverlay(context, ref, filteredApps),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildStatCard(String label, int value, Color color, double staggerDelay) {
    return GlassCard(
      variant: GlassVariant.surface,
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // GHOST NUMBER (background)
          Positioned(
            right: -8,
            bottom: -12,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Text(
                value.toString(),
                key: ValueKey('ghost_$value'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: color.withOpacity(0.07),
                  height: 1.0,
                ),
              ),
            ),
          ),

          // FOREGROUND content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: value),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return Text(
                    val.toString(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1.0,
                    ),
                  );
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.40),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: staggerDelay.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, duration: 300.ms);
  }

  Widget _buildListItem(PlacementApplication app, Animation<double> animation) {
    Color statusCol;
    switch (app.status.toLowerCase()) {
      case 'applied': statusCol = Colors.white; break;
      case 'interview': statusCol = const Color(0xFFC6F52C); break;
      case 'offer': statusCol = const Color(0xFF4ADE80); break;
      case 'rejected': default: statusCol = const Color(0xFFFF4444); break;
    }

    final dateStr = DateFormat('MMM dd').format(app.appliedDate);
    final initialLetter = app.company.isNotEmpty ? app.company[0].toUpperCase() : '?';

    return SlideTransition(
      position: animation.drive(Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic))),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ScaleOnPress(
            onTap: () {
              Navigator.push(context, ApplicationDetailScreen.route(app));
            },
            child: GlassCard(
              variant: GlassVariant.surface,
              padding: const EdgeInsets.all(14),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // GHOST LETTER (background)
                  Positioned(
                    right: -4,
                    top: -8,
                    child: Text(
                      initialLetter,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 80,
                        fontWeight: FontWeight.w800,
                        color: statusCol.withOpacity(0.06),
                        height: 1.0,
                      ),
                    ),
                  ),

                  // FOREGROUND ROW
                  Row(
                    children: [
                      // Company Avatar
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initialLetter,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Center Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.company,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.role,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.45),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _StatusPill(status: app.status),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right side
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            dateStr.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.40),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showActionsSheet(context, ref, app),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.more_vert,
                                size: 18,
                                color: Colors.white.withOpacity(0.35),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchOverlay(
    BuildContext context,
    WidgetRef ref,
    List<PlacementApplication> filteredApps,
  ) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFB050505),
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        ref.read(placementFilterProvider.notifier).setSearchQuery('');
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, size: 18, color: Colors.white54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Search company or role...',
                                hintStyle: TextStyle(color: Colors.white30),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (text) {
                                ref.read(placementFilterProvider.notifier).setSearchQuery(text);
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                ref.read(placementFilterProvider.notifier).setSearchQuery('');
                              },
                              child: const Icon(Icons.clear_rounded, size: 16, color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: filteredApps.isEmpty
                  ? Center(
                      child: Text(
                        'No matches found',
                        style: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredApps.length,
                      itemBuilder: (context, index) {
                        final app = filteredApps[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ScaleOnPress(
                            onTap: () {
                              setState(() {
                                _isSearching = false;
                                _searchController.clear();
                                ref.read(placementFilterProvider.notifier).setSearchQuery('');
                              });
                              Navigator.push(context, ApplicationDetailScreen.route(app));
                            },
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      app.company.isNotEmpty ? app.company[0].toUpperCase() : '?',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.company,
                                          style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          app.role,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12, color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusPill(status: app.status),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddApplicationBottomSheet(
        onAdd: (app) {
          ref.read(placementProvider.notifier).addApplication(app);
        },
      ),
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(placementFilterProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SORT BY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            _SortOptionItem(
              label: 'Date Added',
              option: PlacementSortOption.dateAdded,
              isSelected: currentFilter.sortOption == PlacementSortOption.dateAdded,
              onTap: () {
                ref.read(placementFilterProvider.notifier).setSortOption(PlacementSortOption.dateAdded);
                Navigator.pop(context);
              },
            ),
            _SortOptionItem(
              label: 'Company A-Z',
              option: PlacementSortOption.companyAZ,
              isSelected: currentFilter.sortOption == PlacementSortOption.companyAZ,
              onTap: () {
                ref.read(placementFilterProvider.notifier).setSortOption(PlacementSortOption.companyAZ);
                Navigator.pop(context);
              },
            ),
            _SortOptionItem(
              label: 'Status',
              option: PlacementSortOption.status,
              isSelected: currentFilter.sortOption == PlacementSortOption.status,
              onTap: () {
                ref.read(placementFilterProvider.notifier).setSortOption(PlacementSortOption.status);
                Navigator.pop(context);
              },
            ),
            _SortOptionItem(
              label: 'Next Date',
              option: PlacementSortOption.nextDate,
              isSelected: currentFilter.sortOption == PlacementSortOption.nextDate,
              onTap: () {
                ref.read(placementFilterProvider.notifier).setSortOption(PlacementSortOption.nextDate);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActionsSheet(BuildContext context, WidgetRef ref, PlacementApplication app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ACTIONS: ${app.company.toUpperCase()}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            _ActionItem(
              label: 'Move to Interview',
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () {
                ref.read(placementProvider.notifier).updateStatus(app.id, 'interview');
                Navigator.pop(context);
              },
            ),
            _ActionItem(
              label: 'Mark Offer',
              icon: Icons.check_circle_outline_rounded,
              onTap: () {
                ref.read(placementProvider.notifier).updateStatus(app.id, 'offer');
                Navigator.pop(context);
              },
            ),
            _ActionItem(
              label: 'Mark Rejected',
              icon: Icons.cancel_outlined,
              onTap: () {
                ref.read(placementProvider.notifier).updateStatus(app.id, 'rejected');
                Navigator.pop(context);
              },
            ),
            _ActionItem(
              label: 'Edit Details',
              icon: Icons.edit_outlined,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, ApplicationDetailScreen.route(app));
              },
            ),
            _ActionItem(
              label: 'Delete Record',
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, app.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
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
      await ref.read(placementProvider.notifier).deleteApplication(id);
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    Color statusBorder;
    String statusLabel;

    switch (status.toLowerCase()) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOptionItem extends StatelessWidget {
  final String label;
  final PlacementSortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionItem({
    required this.label,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFFC6F52C) : Colors.white,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFC6F52C),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFFF4444) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 14,
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
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
          const SizedBox(height: 60),
          Icon(Icons.work_outline_rounded, size: 48, color: Colors.white.withOpacity(0.25)),
          const SizedBox(height: 16),
          Text(
            'No applications yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your placement journey.\nEvery application is a step forward.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddApplicationBottomSheet extends StatefulWidget {
  final ValueChanged<PlacementApplication> onAdd;

  const _AddApplicationBottomSheet({required this.onAdd});

  @override
  State<_AddApplicationBottomSheet> createState() => _AddApplicationBottomSheetState();
}

class _AddApplicationBottomSheetState extends State<_AddApplicationBottomSheet> {
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _nextStepController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'applied';
  DateTime? _nextStepDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'NEW APPLICATION',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            _buildField('Company Name', _companyController, 'e.g. Google'),
            const SizedBox(height: 14),
            _buildField('Role / Position', _roleController, 'e.g. Software Engineer'),
            const SizedBox(height: 14),
            Text(
              'STATUS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['applied', 'interview', 'offer', 'rejected'].map((s) {
                final isSel = _status == s;
                Color activeColor;
                switch (s) {
                  case 'applied': activeColor = Colors.white; break;
                  case 'interview': activeColor = const Color(0xFFC6F52C); break;
                  case 'offer': activeColor = const Color(0xFF4ADE80); break;
                  case 'rejected': default: activeColor = const Color(0xFFFF4444); break;
                }
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: Container(
                      height: 38,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSel ? activeColor.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? activeColor.withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isSel ? activeColor : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _buildField('Next Step (optional)', _nextStepController, 'e.g. Technical Interview'),
            const SizedBox(height: 14),
            Text(
              'NEXT STEP DATE (optional)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
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
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _nextStepDate != null
                          ? DateFormat('MMMM dd, yyyy').format(_nextStepDate!)
                          : 'Select Date',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
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
            const SizedBox(height: 14),
            _buildField('Notes (optional)', _notesController, 'e.g. Prepare System Design', maxLines: 3),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (_companyController.text.trim().isNotEmpty && _roleController.text.trim().isNotEmpty) {
                  widget.onAdd(PlacementApplication(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    company: _companyController.text.trim(),
                    role: _roleController.text.trim(),
                    status: _status,
                    appliedDate: DateTime.now(),
                    nextStep: _nextStepController.text.trim().isNotEmpty ? _nextStepController.text.trim() : null,
                    nextStepDate: _nextStepDate,
                    notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
                  ));
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFC6F52C),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CREATE APPLICATION',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF050505),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
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
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white30),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _AtmosphericGlows extends StatelessWidget {
  final Widget child;
  const _AtmosphericGlows({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Amber Glow top left
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.12),
                  blurRadius: 120,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        // Lime Glow bottom right
        Positioned(
          bottom: -100,
          right: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC6F52C).withOpacity(0.08),
                  blurRadius: 150,
                  spreadRadius: 60,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}


class ScaleOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ScaleOnPress({super.key, required this.child, this.onTap});

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _scale = 0.97);
      },
      onTapUp: (_) {
        if (widget.onTap != null) setState(() => _scale = 1.0);
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _scale = 1.0);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
