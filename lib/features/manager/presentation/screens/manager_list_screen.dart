/*import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/delete_dialog.dart';
import 'package:falcon_system/core/widgets/empty_state.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:falcon_system/features/manager/presentation/screens/manager_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerListScreen extends StatefulWidget {
  const ManagerListScreen({super.key});

  @override
  State<ManagerListScreen> createState() => _ManagerListScreenState();
}

class _ManagerListScreenState extends State<ManagerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<ManagerCubit, ManagerState>(
                builder: (context, state) {
                  if (state is ManagerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ManagerError) {
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
                              context.read<ManagerCubit>().loadManagers();
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ManagerLoaded) {
                    final managers = context
                        .read<ManagerCubit>()
                        .searchManagers(_searchQuery);

                    if (managers.isEmpty) {
                      return EmptyState(
                        icon: Icons.person_outline,
                        message: 'لا يوجد مديرو مطارات',
                        subMessage: _searchQuery.isEmpty
                            ? 'اضغط على + لإضافة مدير جديد'
                            : 'لم يتم العثور على نتائج',
                        actionLabel: AppStrings.newManager,
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManagerFormScreen(),
                            ),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: managers.length,
                      itemBuilder: (context, index) {
                        final manager = managers[index] as AirportManager;
                        return _buildManagerCard(manager);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    /*  floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManagerFormScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.newManager),
      ),*/
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'البحث في المديرين...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildManagerCard(AirportManager manager) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManagerFormScreen(manager: manager),
            ),
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
                  manager.fullName.isNotEmpty ? manager.fullName[0] : '?',
                  style: AppFonts.titleLarge.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manager.fullName, style: AppFonts.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.employeeNumber}: ${manager.employeeNumber}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.appointmentDate}: ${manager.appointmentDate.day}/${manager.appointmentDate.month}/${manager.appointmentDate.year}',
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
                        builder: (context) =>
                            ManagerFormScreen(manager: manager),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(manager);
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

  void _showDeleteDialog(AirportManager manager) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: AppStrings.deleteManager,
        message: 'هل أنت متأكد من حذف هذا المدير؟',
        itemName: manager.fullName,
        onConfirm: () {
          context.read<ManagerCubit>().deleteManager(manager.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حذف المدير بنجاح'),
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
import 'package:falcon_system/core/widgets/delete_dialog.dart';
import 'package:falcon_system/core/widgets/empty_state.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:falcon_system/features/manager/presentation/screens/manager_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerListScreen extends StatefulWidget {
  const ManagerListScreen({super.key});

  @override
  State<ManagerListScreen> createState() => _ManagerListScreenState();
}

class _ManagerListScreenState extends State<ManagerListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // FAB animation
  late final AnimationController _fabAnimCtrl;
  late final Animation<double> _fabScaleAnim;
  late final Animation<double> _fabFadeAnim;

  // Header animation
  late final AnimationController _headerAnimCtrl;
  late final Animation<double> _headerFadeAnim;

  @override
  void initState() {
    super.initState();

    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimCtrl,
      curve: Curves.elasticOut,
    );
    _fabFadeAnim = CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.easeIn);

    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _headerAnimCtrl.forward();
      _fabAnimCtrl.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimCtrl.dispose();
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  void _navigateToForm({AirportManager? manager}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => ManagerFormScreen(manager: manager),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
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
            FadeTransition(opacity: _headerFadeAnim, child: _buildHeader()),

            // ── Search ───────────────────────────────────────────────────
            _buildSearchBar(),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<ManagerCubit, ManagerState>(
                listener: (context, state) {
                  if (state is ManagerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                  if (state is ManagerSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.message,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ManagerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is ManagerError) {
                    return _buildErrorState(state.message);
                  }

                  if (state is ManagerLoaded || state is ManagerSuccess) {
                    final managers = context
                        .read<ManagerCubit>()
                        .searchManagers(_searchQuery);

                    if (managers.isEmpty) {
                      return EmptyState(
                        icon: Icons.person_outline,
                        message: 'لا يوجد قادة مطارات',
                        subMessage: _searchQuery.isEmpty
                            ? 'اضغط على الزر أدناه لإضافة قائد جديد'
                            : 'لم يتم العثور على نتائج للبحث',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: managers.length,
                      itemBuilder: (context, index) {
                        return _buildAnimatedCard(managers[index], index);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),

      // ── Animated FAB ──────────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: FadeTransition(
          opacity: _fabFadeAnim,
          child: _buildAnimatedFAB(),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withBlue(
                    (AppColors.primary.blue + 40).clamp(0, 255),
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'قادة المطارات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36),
                ),
              ),
              BlocBuilder<ManagerCubit, ManagerState>(
                builder: (context, state) {
                  final count = context.read<ManagerCubit>().allManagers.length;
                  return Text(
                    '$count قائد مسجل',
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

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontFamily: 'Cairo'),
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'البحث بالاسم أو الرقم الوظيفي أو الهاتف...',
            hintStyle: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.primary,
              size: 22,
            ),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _searchQuery.isNotEmpty
                  ? IconButton(
                      key: const ValueKey('clear'),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Animated Card ─────────────────────────────────────────────────────────

  Widget _buildAnimatedCard(AirportManager manager, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: child,
        ),
      ),
      child: _buildManagerCard(manager),
    );
  }

  Widget _buildManagerCard(AirportManager manager) {
    final initials = manager.fullName.isNotEmpty
        ? manager.fullName
              .trim()
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0] : '')
              .join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () => _navigateToForm(manager: manager),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with gradient
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withBlue(
                          (AppColors.primary.blue + 50).clamp(0, 255),
                        ),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
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
                      Text(
                        manager.fullName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _infoRow(
                        Icons.badge_outlined,
                        '${AppStrings.employeeNumber}: ${manager.employeeNumber}',
                      ),
                      const SizedBox(height: 3),
                      _infoRow(
                        Icons.calendar_today_outlined,
                        '${manager.appointmentDate.day}/${manager.appointmentDate.month}/${manager.appointmentDate.year}',
                      ),
                      if (manager.phoneNumbers.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        _infoRow(
                          Icons.phone_outlined,
                          manager.phoneNumbers.first,
                          color: const Color(0xFF2ECC71),
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions
                _buildCardActions(manager),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    final c = color ?? Colors.grey.shade500;
    return Row(
      children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: c),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardActions(AirportManager manager) {
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
      onSelected: (value) {
        if (value == 'edit') {
          _navigateToForm(manager: manager);
        } else if (value == 'delete') {
          _showDeleteDialog(manager);
        }
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

  // ── Error State ───────────────────────────────────────────────────────────

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
            onPressed: () => context.read<ManagerCubit>().loadManagers(),
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

  // ── Animated FAB ──────────────────────────────────────────────────────────

  Widget _buildAnimatedFAB() {
    return GestureDetector(
      onTap: () => _navigateToForm(),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withBlue(
                  (AppColors.primary.blue + 50).clamp(0, 255),
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated plus icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.rotate(angle: v * 0, child: child),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'إضافة قائد جديد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Delete Dialog ─────────────────────────────────────────────────────────

  void _showDeleteDialog(AirportManager manager) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: AppStrings.deleteManager,
        message: 'هل أنت متأكد من حذف بيانات هذا القائد؟',
        itemName: manager.fullName,
        onConfirm: () {
          context.read<ManagerCubit>().deleteManager(manager.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'تم حذف القائد بنجاح',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
