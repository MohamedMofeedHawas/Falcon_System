/*import 'package:falcon_system/core/constants/app_colors.dart';
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
          title: 'رئيس لجنة التفتيش',
          subtitle: headList.isEmpty
              ? 'لم يتم تعيين رئيس لجنة التفتيش بعد'
              : 'رئيس لجنة التفتيش الحالي',
        ),
        const SizedBox(height: 16),
        if (headList.isEmpty)
          EmptyCard(
            icon: Icons.person_add,
            message: 'اضغط لإضافة رئيس لجنة التفتيش',
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
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemberFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة عضو جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _memberAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HeadFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_pin),
                label: const Text('إضافة رئيس لجنة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _headAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
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
        title: 'حذف رئيس لجنة التفتيش',
        message: 'هل أنت متأكد من حذف رئيس لجنة التفتيش؟',
        itemName: head.fullName,
        onConfirm: () {
          context.read<TeamCubit>().deleteHead(head.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف رئيس لجنة التفتيش بنجاح'),
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
}*/
import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
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

class _TeamListScreenState extends State<TeamListScreen>
    with TickerProviderStateMixin {
  // ── Colors ────────────────────────────────────────────────────────────
  static const Color _headAccent = Color(0xFF8E44AD); // purple — رئيس اللجنة
  static const Color _memberAccent = Color(0xFF2471A3); // blue   — الأعضاء

  // ── Animations ─────────────────────────────────────────────────────────
  late final AnimationController _headerAnimCtrl;
  late final AnimationController _fabAnimCtrl;
  late final Animation<double> _headerFade;
  late final Animation<double> _fabScale;
  late final Animation<double> _fabFade;

  @override
  void initState() {
    super.initState();

    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFade = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _fabScale = CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.elasticOut);
    _fabFade = CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 150), () {
      _headerAnimCtrl.forward();
      _fabAnimCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helper ─────────────────────────────────────────────────

  void _go(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, _) => screen,
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // ── Snack helper ───────────────────────────────────────────────────────

  void _snack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
          ],
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            FadeTransition(opacity: _headerFade, child: _buildHeader()),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<TeamCubit, TeamState>(
                listener: (context, state) {
                  if (state is TeamError) {
                    _snack(state.message, success: false);
                  }
                  if (state is TeamSuccess) _snack(state.message);
                },
                builder: (context, state) {
                  if (state is TeamLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _headAccent),
                    );
                  }
                  if (state is TeamError) {
                    return _buildErrorState(state.message);
                  }
                  if (state is TeamLoaded || state is TeamSuccess) {
                    final cubit = context.read<TeamCubit>();
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      child: Column(
                        children: [
                          _buildHeadSection(cubit.allHeads),
                          const SizedBox(height: 24),
                          _buildMembersSection(cubit.allMembers),
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

      // ── FAB ───────────────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FadeTransition(opacity: _fabFade, child: _buildFAB()),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          // Dual-color icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_headAccent, _memberAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _headAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'لجنة الفحص والتفتيش',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36),
                ),
              ),
              BlocBuilder<TeamCubit, TeamState>(
                builder: (context, _) {
                  final cubit = context.read<TeamCubit>();
                  return Text(
                    '${cubit.allMembers.length} عضو · ${cubit.allHeads.isEmpty ? "لا يوجد رئيس" : "رئيس مُعيَّن"}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Head Section ───────────────────────────────────────────────────────

  Widget _buildHeadSection(List<InspectionHead> heads) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          icon: Icons.person_pin,
          label: 'رئيس لجنة التفتيش',
          color: _headAccent,
          badge: heads.isNotEmpty ? '${heads.length}' : null,
        ),
        const SizedBox(height: 12),
        if (heads.isEmpty)
          _buildEmptyCard(
            color: _headAccent,
            icon: Icons.person_add_outlined,
            message: 'لم يتم تعيين رئيس اللجنة بعد',
            buttonLabel: 'إضافة رئيس اللجنة',
            onTap: () => _go(const HeadFormScreen()),
          )
        else
          ...List.generate(
            heads.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(heads[i].id),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + i * 60),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, (1 - v) * 24),
                    child: child,
                  ),
                ),
                child: _buildHeadCard(heads[i]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeadCard(InspectionHead head) {
    final initials = _initials(head.fullName);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _headAccent.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _headAccent.withOpacity(0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _go(HeadFormScreen(head: head)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_headAccent, Color(0xFF6C3483)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _headAccent.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crown badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _headAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _headAccent.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 11,
                                  color: _headAccent,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'رئيس اللجنة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _headAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        head.fullName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (head.rank != null)
                        _infoRow(
                          Icons.military_tech_outlined,
                          head.rank!,
                          _headAccent,
                        ),
                      const SizedBox(height: 2),
                      _infoRow(
                        Icons.science_outlined,
                        head.specialization,
                        Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),

                _cardMenu(
                  onEdit: () => _go(HeadFormScreen(head: head)),
                  onDelete: () => _showDeleteHeadDialog(head),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Members Section ────────────────────────────────────────────────────

  Widget _buildMembersSection(List<InspectionMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          icon: Icons.group_outlined,
          label: 'أعضاء لجنة الفحص',
          color: _memberAccent,
          badge: members.isNotEmpty ? '${members.length}' : null,
        ),
        const SizedBox(height: 12),
        if (members.isEmpty)
          _buildEmptyCard(
            color: _memberAccent,
            icon: Icons.group_add_outlined,
            message: 'لم يتم إضافة أعضاء بعد',
           // buttonLabel: 'إضافة عضو جديد',
          //  onTap: () => _go(const MemberFormScreen()),
          )
        else
          ...List.generate(
            members.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(members[i].id),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + i * 60),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, (1 - v) * 24),
                    child: child,
                  ),
                ),
                child: _buildMemberCard(members[i]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMemberCard(InspectionMember member) {
    final initials = _initials(member.fullName);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _go(MemberFormScreen(member: member)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_memberAccent, Color(0xFF1A5276)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _memberAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (member.rank != null)
                        _infoRow(
                          Icons.military_tech_outlined,
                          member.rank!,
                          _memberAccent,
                        ),
                      const SizedBox(height: 2),
                      _infoRow(
                        Icons.science_outlined,
                        member.specialization,
                        Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),

                _cardMenu(
                  onEdit: () => _go(MemberFormScreen(member: member)),
                  onDelete: () => _showDeleteMemberDialog(member),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared widgets ─────────────────────────────────────────────────────

  Widget _sectionLabel({
    required IconData icon,
    required String label,
    required Color color,
    String? badge,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyCard({
    required Color color,
    required IconData icon,
    required String message,
     String? buttonLabel,
     VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 14),
   
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _cardMenu({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.edit,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.delete,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Head Button
          Expanded(
            child: GestureDetector(
              onTap: () => _go(const HeadFormScreen()),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_headAccent, Color(0xFF6C3483)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: _headAccent.withOpacity(0.45),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_pin,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                         'إضافة رئيس لجنة جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Member Button
          Expanded(
            child: GestureDetector(
              onTap: () => _go(const MemberFormScreen()),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_memberAccent, Color(0xFF1A5276)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: _memberAccent.withOpacity(0.45),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'إضافة عضو جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 52,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 16),
          Text(message, style: AppFonts.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<TeamCubit>().loadTeam(),
            icon: const Icon(Icons.refresh),
            label: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete Dialogs ─────────────────────────────────────────────────────

  void _showDeleteHeadDialog(InspectionHead head) {
    final TextEditingController controller = TextEditingController();
    final ValueNotifier<bool> canDelete = ValueNotifier(false);
    final ValueNotifier<double> matchProgress = ValueNotifier(0.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: _DeleteDialogHeadContent(
            headName: head.fullName,
            controller: controller,
            canDelete: canDelete,
            matchProgress: matchProgress,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: () async {
              Navigator.of(dialogContext).pop();
              await context.read<TeamCubit>().deleteHead(head.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'تم حذف رئيس اللجنة بنجاح',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF27500A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteMemberDialog(InspectionMember member) {
    final TextEditingController controller = TextEditingController();
    final ValueNotifier<bool> canDelete = ValueNotifier(false);
    final ValueNotifier<double> matchProgress = ValueNotifier(0.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: _DeleteDialogContent(
            memberName: member.fullName,
            controller: controller,
            canDelete: canDelete,
            matchProgress: matchProgress,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: () async {
              Navigator.of(dialogContext).pop();
              await context.read<TeamCubit>().deleteMember(member.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'تم حذف العضو بنجاح',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF27500A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Utilities ──────────────────────────────────────────────────────────

  String _initials(String name) => name
      .trim()
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0] : '')
      .join();
}

class _DeleteDialogContent extends StatefulWidget {
  final String memberName;
  final TextEditingController controller;
  final ValueNotifier<bool> canDelete;
  final ValueNotifier<double> matchProgress;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _DeleteDialogContent({
    required this.memberName,
    required this.controller,
    required this.canDelete,
    required this.matchProgress,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_DeleteDialogContent> createState() => _DeleteDialogContentState();
}

class _DeleteDialogContentState extends State<_DeleteDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  bool _matched = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 6,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    final target = widget.memberName.trim().toLowerCase();
    final input = value.trim().toLowerCase();
    final progress = (input.length / target.length).clamp(0.0, 1.0);
    widget.matchProgress.value = progress;
    final matched = input == target;
    widget.canDelete.value = matched;
    setState(() => _matched = matched);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Progress bar ──────────────────────────────────────────────
          ValueListenableBuilder<double>(
            valueListenable: widget.matchProgress,
            builder: (_, progress, _) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 200),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 3,
                backgroundColor: const Color(0xFFF7C1C1),
                valueColor: AlwaysStoppedAnimation(
                  _matched ? const Color(0xFF639922) : const Color(0xFFE24B4A),
                ),
              ),
            ),
          ),

          // ── Red header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            color: const Color(0xFFFCEBEB),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF09595),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFCEBEB),
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 30,
                    color: Color(0xFF791F1F),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تأكيد حذف العضو',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF501313),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'هذا الإجراء لا يمكن التراجع عنه.\nسيتم حذف جميع البيانات نهائياً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFFA32D2D),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFAC775)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF854F0B),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'اكتب اسم العضو بالضبط لتفعيل زرار الحذف',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Color(0xFF633806),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Member name display
                const Text(
                  'اسم العضو',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF7C1C1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight_outlined,
                        size: 16,
                        color: Color(0xFFA32D2D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.memberName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF791F1F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Input
                const Text(
                  'اكتب الاسم للتأكيد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      _shakeCtrl.isAnimating
                          ? _shakeAnim.value *
                                ((_shakeCtrl.value * 10).floor().isEven
                                    ? 1
                                    : -1)
                          : 0,
                      0,
                    ),
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _matched
                            ? const Color(0xFF639922)
                            : widget.controller.text.isNotEmpty
                            ? const Color(0xFFE24B4A)
                            : const Color(0xFFD3D1C7),
                        width: 1.5,
                      ),
                      boxShadow: _matched
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF639922,
                                ).withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : widget.controller.text.isNotEmpty
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFE24B4A,
                                ).withOpacity(0.12),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: widget.controller,
                      onChanged: _onTextChanged,
                      style: const TextStyle(fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسم العضو هنا...',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF888780),
                        ),
                        suffixIcon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _matched
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF639922),
                                  key: ValueKey('ok'),
                                )
                              : const SizedBox.shrink(key: ValueKey('none')),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Match hint
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _matched
                      ? const Row(
                          key: ValueKey('matched'),
                          children: [
                            Icon(
                              Icons.lock_open_outlined,
                              size: 12,
                              color: Color(0xFF3B6D11),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'الاسم مطابق — يمكنك الحذف الآن',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Color(0xFF3B6D11),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('locked'),
                          children: const [
                            Icon(
                              Icons.lock_outline,
                              size: 12,
                              color: Color(0xFF888780),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'الزر غير مفعّل حتى تكتب الاسم بالضبط',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Color(0xFF888780),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Actions ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFFD3D1C7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Color(0xFF5F5E5A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.canDelete,
                    builder: (_, enabled, _) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: enabled
                            ? const Color(0xFFE24B4A)
                            : const Color(0xFFB4B2A9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: enabled
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE24B4A,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: enabled ? widget.onConfirm : null,
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 17,
                        ),
                        label: const Text(
                          'حذف نهائي',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withOpacity(
                            0.7,
                          ),
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteDialogHeadContent extends StatefulWidget {
  final String headName;
  final TextEditingController controller;
  final ValueNotifier<bool> canDelete;
  final ValueNotifier<double> matchProgress;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _DeleteDialogHeadContent({
    required this.headName,
    required this.controller,
    required this.canDelete,
    required this.matchProgress,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_DeleteDialogHeadContent> createState() =>
      _DeleteDialogHeadContentState();
}

class _DeleteDialogHeadContentState extends State<_DeleteDialogHeadContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  bool _matched = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 6,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    final target = widget.headName.trim().toLowerCase();
    final input = value.trim().toLowerCase();
    final progress = (input.length / target.length).clamp(0.0, 1.0);
    widget.matchProgress.value = progress;
    final matched = input == target;
    widget.canDelete.value = matched;
    setState(() => _matched = matched);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Progress bar ──────────────────────────────────────────────
          ValueListenableBuilder<double>(
            valueListenable: widget.matchProgress,
            builder: (_, progress, _) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 200),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 3,
                backgroundColor: const Color(0xFFF7C1C1),
                valueColor: AlwaysStoppedAnimation(
                  _matched ? const Color(0xFF639922) : const Color(0xFFE24B4A),
                ),
              ),
            ),
          ),

          // ── Red header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            color: const Color(0xFFFCEBEB),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF09595),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFCEBEB),
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 30,
                    color: Color(0xFF791F1F),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تأكيد حذف رئيس اللجنة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF501313),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'هذا الإجراء لا يمكن التراجع عنه.\nسيتم حذف جميع البيانات نهائياً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFFA32D2D),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFAC775)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF854F0B),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'اكتب اسم رئيس اللجنة بالضبط لتفعيل زرار الحذف',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Color(0xFF633806),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Member name display
                const Text(
                  'اسم العضو',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF7C1C1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight_outlined,
                        size: 16,
                        color: Color(0xFFA32D2D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.headName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF791F1F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Input
                const Text(
                  'اكتب الاسم للتأكيد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      _shakeCtrl.isAnimating
                          ? _shakeAnim.value *
                                ((_shakeCtrl.value * 10).floor().isEven
                                    ? 1
                                    : -1)
                          : 0,
                      0,
                    ),
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _matched
                            ? const Color(0xFF639922)
                            : widget.controller.text.isNotEmpty
                            ? const Color(0xFFE24B4A)
                            : const Color(0xFFD3D1C7),
                        width: 1.5,
                      ),
                      boxShadow: _matched
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF639922,
                                ).withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : widget.controller.text.isNotEmpty
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFE24B4A,
                                ).withOpacity(0.12),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: widget.controller,
                      onChanged: _onTextChanged,
                      style: const TextStyle(fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسم العضو هنا...',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF888780),
                        ),
                        suffixIcon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _matched
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF639922),
                                  key: ValueKey('ok'),
                                )
                              : const SizedBox.shrink(key: ValueKey('none')),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Match hint
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _matched
                      ? const Row(
                          key: ValueKey('matched'),
                          children: [
                            Icon(
                              Icons.lock_open_outlined,
                              size: 12,
                              color: Color(0xFF3B6D11),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'الاسم مطابق — يمكنك الحذف الآن',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Color(0xFF3B6D11),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('locked'),
                          children: const [
                            Icon(
                              Icons.lock_outline,
                              size: 12,
                              color: Color(0xFF888780),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'الزر غير مفعّل حتى تكتب الاسم بالضبط',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Color(0xFF888780),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Actions ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFFD3D1C7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Color(0xFF5F5E5A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.canDelete,
                    builder: (_, enabled, _) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: enabled
                            ? const Color(0xFFE24B4A)
                            : const Color(0xFFB4B2A9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: enabled
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE24B4A,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: enabled ? widget.onConfirm : null,
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 17,
                        ),
                        label: const Text(
                          'حذف نهائي',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withOpacity(
                            0.7,
                          ),
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
