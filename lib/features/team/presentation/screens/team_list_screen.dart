import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/delete_dialog.dart';
import 'package:falcon_system/core/widgets/empty_state.dart';
import 'package:falcon_system/core/widgets/section_header.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/data/models/inspection_member.dart';
import 'package:falcon_system/features/team/presentation/cubit/team_cubit.dart';
import 'package:falcon_system/features/team/presentation/screens/head_form_screen.dart';
import 'package:falcon_system/features/team/presentation/screens/member_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<TeamCubit, TeamState>(
                builder: (context, state) {
                  if (state is TeamLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TeamError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.danger,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: AppFonts.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TeamCubit>().loadTeam();
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TeamLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeadSection(state.head),
                          const SizedBox(height: 24),
                          _buildMembersSection(state.members),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadSection(List<InspectionHead> headList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.person_pin,
          title: 'رئيس فريق الفحص',
          subtitle: headList.isEmpty
              ? 'لم يتم تعيين رئيس الفريق'
              : 'رئيس فريق الفحص الحالي',
        ),
        const SizedBox(height: 16),
        if (headList.isEmpty)
          EmptyCard(
            icon: Icons.person_add,
            message: 'اضغط لإضافة رئيس فريق الفحص',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HeadFormScreen()),
              );
            },
          )
        else
          _buildHeadCard(headList.first),
      ],
    );
  }

  Widget _buildHeadCard(InspectionHead head) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HeadFormScreen(head: head)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  head.fullName.isNotEmpty ? head.fullName[0] : '?',
                  style: AppFonts.titleLarge.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(head.fullName, style: AppFonts.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.rank}: ${head.rank}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'التخصص: ${head.specialization}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeadFormScreen(head: head),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteHeadDialog(head);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 20,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.delete,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersSection(List<InspectionMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*SectionHeader(
          icon: Icons.group,
          title: 'أعضاء فريق الفحص',
          subtitle: '${members.length} عضو',
        ),
        const SizedBox(height: 16),*/
        if (members.isEmpty)
          EmptyCard(
            icon: Icons.group_add,
            message: 'اضغط لإضافة عضو جديد',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MemberFormScreen(),
                ),
              );
            },
          )
        else
          ...members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMemberCard(member),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MemberFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة عضو جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(InspectionMember member) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberFormScreen(member: member),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.accent.withOpacity(0.1),
                child: Text(
                  member.fullName.isNotEmpty ? member.fullName[0] : '?',
                  style: AppFonts.titleMedium.copyWith(color: AppColors.accent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.fullName, style: AppFonts.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.rank}: ${member.rank}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'التخصص: ${member.specialization}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberFormScreen(member: member),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteMemberDialog(member);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 20,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.delete,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteHeadDialog(InspectionHead head) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'حذف رئيس الفريق',
        message: 'هل أنت متأكد من حذف رئيس الفريق؟',
        itemName: head.fullName,
        onConfirm: () {
          context.read<TeamCubit>().deleteHead(head.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف رئيس الفريق بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteMemberDialog(InspectionMember member) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'حذف العضو',
        message: 'هل أنت متأكد من حذف هذا العضو؟',
        itemName: member.fullName,
        onConfirm: () {
          context.read<TeamCubit>().deleteMember(member.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف العضو بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}
