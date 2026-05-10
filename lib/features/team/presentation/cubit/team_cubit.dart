/*import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/data/models/inspection_member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final Uuid _uuid = const Uuid();

  TeamCubit() : super(TeamInitial()) {
    loadTeam();
  }

  Future<void> loadTeam() async {
    emit(TeamLoading());
    try {
      final head = HiveService.inspectionHeadBox.values
          .cast<InspectionHead>()
          .toList();
      final members = HiveService.inspectionMemberBox.values
          .cast<InspectionMember>()
          .toList();
      emit(TeamLoaded(head: head, members: members));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> addHead(InspectionHead head) async {
    emit(TeamLoading());
    try {
      head.id = _uuid.v4();
      head.createdAt = DateTime.now();
      await HiveService.inspectionHeadBox.put(head.id, head);
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> updateHead(InspectionHead head) async {
    emit(TeamLoading());
    try {
      head.updatedAt = DateTime.now();
      await HiveService.inspectionHeadBox.put(head.id, head);
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> deleteHead(String id) async {
    emit(TeamLoading());
    try {
      await HiveService.inspectionHeadBox.delete(id);
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> addMember(InspectionMember member) async {
    emit(TeamLoading());
    try {
      member.id = _uuid.v4();
      member.createdAt = DateTime.now();
      await HiveService.inspectionMemberBox.put(member.id, member);
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> updateMember(InspectionMember member) async {
    emit(TeamLoading());
    try {
      member.updatedAt = DateTime.now();
      await HiveService.inspectionMemberBox.put(member.id, member);
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> deleteMember(String id) async {
    emit(TeamLoading());
    try {
      await HiveService.inspectionMemberBox.delete(id);
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  InspectionHead? getHeadById(String id) {
    return HiveService.inspectionHeadBox.get(id);
  }

  InspectionMember? getMemberById(String id) {
    return HiveService.inspectionMemberBox.get(id);
  }
}*/
import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/data/models/inspection_member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final Uuid _uuid = const Uuid();

  // ── Cached lists (للـ search والـ count بدون re-emit) ─────────────────
  List<InspectionHead> _allHeads = [];
  List<InspectionMember> _allMembers = [];

  List<InspectionHead> get allHeads => List.unmodifiable(_allHeads);
  List<InspectionMember> get allMembers => List.unmodifiable(_allMembers);

  TeamCubit() : super(TeamInitial()) {
    loadTeam();
  }

  Future<void> loadTeam() async {
    emit(TeamLoading());
    try {
      _allHeads =
          HiveService.inspectionHeadBox.toMap().entries
              .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
              .map((entry) => entry.value)
              .cast<InspectionHead>()
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _allMembers =
          HiveService.inspectionMemberBox.toMap().entries
              .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
              .map((entry) => entry.value)
              .cast<InspectionMember>()
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(
        TeamLoaded(head: List.from(_allHeads), members: List.from(_allMembers)),
      );
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  // ── Head CRUD ─────────────────────────────────────────────────────────

  Future<void> addHead(InspectionHead head) async {
    emit(TeamLoading());
    try {
      final updated = head.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await HiveService.inspectionHeadBox.put(
        HiveService.scopedKey(updated.id),
        updated,
      );
      await loadTeam();
      emit(TeamSuccess('تم إضافة رئيس لجنة التفتيش بنجاح'));
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> updateHead(InspectionHead head) async {
    emit(TeamLoading());
    try {
      final updated = head.copyWith(updatedAt: DateTime.now());
      await HiveService.inspectionHeadBox.put(
        HiveService.scopedKey(updated.id),
        updated,
      );
      await loadTeam();
      emit(TeamSuccess('تم تحديث بيانات رئيس اللجنة بنجاح'));
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> deleteHead(String id) async {
    emit(TeamLoading());
    try {
      await HiveService.inspectionHeadBox.delete(HiveService.scopedKey(id));
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  // ── Member CRUD ───────────────────────────────────────────────────────

  Future<void> addMember(InspectionMember member) async {
    emit(TeamLoading());
    try {
      final updated = member.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await HiveService.inspectionMemberBox.put(
        HiveService.scopedKey(updated.id),
        updated,
      );
      await loadTeam();
      emit(TeamSuccess('تم إضافة العضو بنجاح'));
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> updateMember(InspectionMember member) async {
    emit(TeamLoading());
    try {
      final updated = member.copyWith(updatedAt: DateTime.now());
      await HiveService.inspectionMemberBox.put(
        HiveService.scopedKey(updated.id),
        updated,
      );
      await loadTeam();
      emit(TeamSuccess('تم تحديث بيانات العضو بنجاح'));
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> deleteMember(String id) async {
    emit(TeamLoading());
    try {
      await HiveService.inspectionMemberBox.delete(HiveService.scopedKey(id));
      await loadTeam();
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  // ── Getters ───────────────────────────────────────────────────────────

  InspectionHead? getHeadById(String id) =>
      HiveService.inspectionHeadBox.get(HiveService.scopedKey(id));

  InspectionMember? getMemberById(String id) =>
      HiveService.inspectionMemberBox.get(HiveService.scopedKey(id));

  List<InspectionMember> searchMembers(String query) {
    if (query.trim().isEmpty) return List.from(_allMembers);
    final q = query.trim().toLowerCase();
    return _allMembers
        .where(
          (m) =>
              m.fullName.toLowerCase().contains(q) ||
              m.specialization.toLowerCase().contains(q) ||
              (m.rank?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
}
