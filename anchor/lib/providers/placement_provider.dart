import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import '../data/local/daos/placement_dao.dart';
import 'database_provider.dart';

enum PlacementSortOption {
  dateAdded,
  companyAZ,
  status,
  nextDate,
}

class PlacementFilterState {
  final String searchQuery;
  final PlacementSortOption sortOption;

  PlacementFilterState({
    this.searchQuery = '',
    this.sortOption = PlacementSortOption.dateAdded,
  });

  PlacementFilterState copyWith({
    String? searchQuery,
    PlacementSortOption? sortOption,
  }) {
    return PlacementFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class PlacementFilterNotifier extends StateNotifier<PlacementFilterState> {
  PlacementFilterNotifier() : super(PlacementFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(PlacementSortOption option) {
    state = state.copyWith(sortOption: option);
  }
}

final placementFilterProvider = StateNotifierProvider<PlacementFilterNotifier, PlacementFilterState>((ref) {
  return PlacementFilterNotifier();
});

class PlacementNotifier extends StateNotifier<AsyncValue<List<PlacementApplication>>> {
  final PlacementDao _dao;

  PlacementNotifier(this._dao) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _dao.watchAllApplications().listen((apps) {
      state = AsyncValue.data(apps);
    }, onError: (err, stack) {
      state = AsyncValue.error(err, stack);
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final apps = await _dao.getAllApplications();
      state = AsyncValue.data(apps);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> addApplication(PlacementApplication app) async {
    await _dao.insertApplication(app);
  }

  Future<void> updateStatus(String id, String status) async {
    await _dao.updateStatus(id, status);
  }

  Future<void> updateApplication(PlacementApplication app) async {
    await _dao.updateApplication(app);
  }

  Future<void> deleteApplication(String id) async {
    await _dao.deleteApplication(id);
  }
}

final placementProvider = StateNotifierProvider<PlacementNotifier, AsyncValue<List<PlacementApplication>>>((ref) {
  final dao = ref.watch(placementDaoProvider);
  return PlacementNotifier(dao);
});

// Sorted and filtered applications
final filteredPlacementsProvider = Provider<List<PlacementApplication>>((ref) {
  final applicationsAsync = ref.watch(placementProvider);
  final filter = ref.watch(placementFilterProvider);

  return applicationsAsync.maybeWhen(
    data: (apps) {
      // 1. Filter by search query
      var filtered = apps.where((app) {
        final query = filter.searchQuery.toLowerCase();
        return app.company.toLowerCase().contains(query) ||
               app.role.toLowerCase().contains(query);
      }).toList();

      // 2. Sort by option
      switch (filter.sortOption) {
        case PlacementSortOption.dateAdded:
          filtered.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
          break;
        case PlacementSortOption.companyAZ:
          filtered.sort((a, b) => a.company.toLowerCase().compareTo(b.company.toLowerCase()));
          break;
        case PlacementSortOption.status:
          filtered.sort((a, b) => a.status.compareTo(b.status));
          break;
        case PlacementSortOption.nextDate:
          filtered.sort((a, b) {
            if (a.nextStepDate == null && b.nextStepDate == null) return 0;
            if (a.nextStepDate == null) return 1;
            if (b.nextStepDate == null) return -1;
            return a.nextStepDate!.compareTo(b.nextStepDate!);
          });
          break;
      }
      return filtered;
    },
    orElse: () => [],
  );
});

// Stats calculation
final placementStatsProvider = Provider<Map<String, int>>((ref) {
  final appsAsync = ref.watch(placementProvider);
  return appsAsync.maybeWhen(
    data: (apps) {
      final stats = {'applied': 0, 'interview': 0, 'offer': 0, 'rejected': 0};
      for (final app in apps) {
        final status = app.status.toLowerCase();
        if (stats.containsKey(status)) {
          stats[status] = stats[status]! + 1;
        }
      }
      return stats;
    },
    orElse: () => {'applied': 0, 'interview': 0, 'offer': 0, 'rejected': 0},
  );
});
