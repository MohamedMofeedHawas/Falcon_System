import 'package:falcon_system/core/services/hive_service.dart';
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
}
