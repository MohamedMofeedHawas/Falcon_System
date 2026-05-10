/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../cubit/aerodrome_cubit.dart';
import 'aerodrome_form_screen.dart';

class AerodromeListScreen extends StatefulWidget {
  const AerodromeListScreen({super.key});

  @override
  State<AerodromeListScreen> createState() => _AerodromeListScreenState();
}

class _AerodromeListScreenState extends State<AerodromeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AerodromeCubit>().loadAerodromes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المطارات'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث عن مطار...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            // Aerodrome List
            Expanded(
              child: BlocBuilder<AerodromeCubit, AerodromeState>(
                builder: (context, state) {
                  if (state is AerodromeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AerodromeError) {
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
                            style: AppFonts.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AerodromeLoaded) {
                    final aerodromes = _searchQuery.isEmpty
                        ? state.aerodromes
                        : context.read<AerodromeCubit>().searchAerodromes(
                            _searchQuery,
                          );

                    if (aerodromes.isEmpty) {
                      return EmptyState(
                        icon: Icons.flight_takeoff_outlined,
                        message: 'لا توجد مطارات',
                        subMessage: _searchQuery.isEmpty
                            ? 'اضغط على + لإضافة مطار جديد'
                            : 'لم يتم العثور على نتائج',
                        actionLabel: 'إضافة مطار',
                        onAction: () => _navigateToForm(),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: aerodromes.length,
                      itemBuilder: (context, index) {
                        final aerodrome = aerodromes[index];
                        return _buildAerodromeCard(aerodrome);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
       /* floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToForm(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.textWhite),
        ),*/
      ),
    );
  }

  Widget _buildAerodromeCard(dynamic aerodrome) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              aerodrome.icaoCode,
              style: AppFonts.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: AppFonts.bold,
              ),
            ),
          ),
        ),
        title: Text(
          aerodrome.arabicName,
          style: AppFonts.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              aerodrome.englishName,
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  '${aerodrome.city} - ${aerodrome.governorate}',
                  style: AppFonts.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
              onPressed: () => _navigateToForm(aerodrome: aerodrome),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.danger,
              onPressed: () => _showDeleteDialog(aerodrome),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm({dynamic aerodrome}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AerodromeFormScreen(aerodrome: aerodrome),
      ),
    ).then((_) {
      context.read<AerodromeCubit>().loadAerodromes();
    });
  }

  void _showDeleteDialog(dynamic aerodrome) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'حذف المطار',
        message: 'هل أنت متأكد من حذف هذا المطار؟',
        itemName: aerodrome.arabicName,
        onConfirm: () {
          context.read<AerodromeCubit>().deleteAerodrome(aerodrome.id);
          Navigator.pop(context);
        },
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/models/aerodrome.dart';
import '../cubit/aerodrome_cubit.dart';
import 'aerodrome_form_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// قائمة المطارات — مع فلتر الأنواع وبحث وإضافة مطار جديد
/// ─────────────────────────────────────────────────────────────────────────
class AerodromeListScreen extends StatefulWidget {
  const AerodromeListScreen({super.key});

  @override
  State<AerodromeListScreen> createState() => _AerodromeListScreenState();
}

class _AerodromeListScreenState extends State<AerodromeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// أنواع المطارات للفلتر (الكل + أنواع معروفة)
  static const List<String> _filterTypes = [
    'الكل',
    'مدني',
    'عسكري',
    'مختلط',
    'متخصص',
  ];

  // ── أيقونة لكل نوع ───────────────────────────────────────────────────
  static const Map<String, IconData> _typeIcons = {
    'الكل': Icons.flight_outlined,
    'مدني': Icons.public,
    'عسكري': Icons.shield_outlined,
    'مختلط': Icons.swap_horiz,
    'متخصص': Icons.precision_manufacturing_outlined,
  };

  // ── لون لكل نوع ──────────────────────────────────────────────────────
  static const Map<String, Color> _typeColors = {
    'مدني': Color(0xFF1976D2),
    'عسكري': Color(0xFFC62828),
    'مختلط': Color(0xFF6A1B9A),
    'متخصص': Color(0xFF00695C),
  };

  @override
  void initState() {
    super.initState();
    context.read<AerodromeCubit>().loadAerodromes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            const Divider(height: 1),
            Expanded(child: _buildBody()),
          ],
        ),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════════════════

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('إدارة المطارات'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      actions: [
        BlocBuilder<AerodromeCubit, AerodromeState>(
          builder: (context, state) {
            if (state is AerodromeLoaded) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.allAerodromes.length} مطار',
                      style: AppFonts.labelSmall.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو كود ICAO أو المدينة...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<AerodromeCubit, AerodromeState>(
      builder: (context, state) {
        final counts = state is AerodromeLoaded
            ? state.typeCounts
            : <String, int>{};
        final activeFilter = state is AerodromeLoaded
            ? (state.activeFilter ?? 'الكل')
            : 'الكل';

        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filterTypes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final type = _filterTypes[index];
              final isSelected = activeFilter == type;

              // عدد المطارات لهذا النوع
              int count = 0;
              if (type == 'الكل') {
                count = counts.values.fold(0, (a, b) => a + b);
              } else {
                count = counts[type] ?? 0;
              }

              final chipColor = isSelected
                  ? (_typeColors[type] ?? AppColors.primary)
                  : AppColors.card;

              return GestureDetector(
                onTap: () {
                  context.read<AerodromeCubit>().applyFilter(
                    type == 'الكل' ? null : type,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.textHint.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _typeIcons[type] ?? Icons.flight,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type,
                        style: AppFonts.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? AppFonts.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : AppColors.textHint.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: AppFonts.labelSmall.copyWith(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textHint,
                              fontWeight: AppFonts.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AerodromeCubit, AerodromeState>(
      builder: (context, state) {
        // ── تحميل ────────────────────────────────────────────────────────
        if (state is AerodromeLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جارٍ تحميل بيانات المطارات...'),
              ],
            ),
          );
        }

        // ── خطأ ──────────────────────────────────────────────────────────
        if (state is AerodromeError) {
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
                  style: AppFonts.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<AerodromeCubit>().loadAerodromes(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        // ── تحميل ناجح ───────────────────────────────────────────────────
        if (state is AerodromeLoaded) {
          // تطبيق البحث على القائمة المفلترة
          final list = _searchQuery.isEmpty
              ? state.displayedAerodromes
              : context.read<AerodromeCubit>().searchAerodromes(_searchQuery);

          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.flight_takeoff_outlined,
              message: _searchQuery.isNotEmpty
                  ? 'لا توجد نتائج للبحث'
                  : 'لا توجد مطارات في هذه الفئة',
              subMessage: _searchQuery.isNotEmpty
                  ? 'جرّب كلمة بحث مختلفة'
                  : 'اضغط على + لإضافة مطار جديد',
            //  actionLabel: _searchQuery.isEmpty ? 'إضافة مطار' : null,
              onAction: _searchQuery.isEmpty ? () => _navigateToForm() : null,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildAerodromeCard(list[index]),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // AERODROME CARD
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildAerodromeCard(Aerodrome aerodrome) {
    final typeColor = _typeColors[aerodrome.airportType] ?? AppColors.primary;
    final statusColor = _statusColor(aerodrome.operationalStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: typeColor.withOpacity(0.15), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _navigateToForm(aerodrome: aerodrome),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── أيقونة كود ICAO ──────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: typeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      aerodrome.icaoCode,
                      style: AppFonts.labelLarge.copyWith(
                        color: typeColor,
                        fontWeight: AppFonts.bold,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      _typeIcons[aerodrome.airportType] ?? Icons.flight,
                      size: 12,
                      color: typeColor.withOpacity(0.7),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── بيانات المطار ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم + badge النوع
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            aerodrome.arabicName,
                            style: AppFonts.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: AppFonts.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildBadge(aerodrome.airportType, typeColor),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aerodrome.englishName,
                      style: AppFonts.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // الموقع + الحالة
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${aerodrome.city}، ${aerodrome.governorate}',
                            style: AppFonts.labelSmall.copyWith(
                              color: AppColors.textHint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            aerodrome.operationalStatus,
                            style: AppFonts.labelSmall.copyWith(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: AppFonts.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // فئة ICAO + أطول مدرج
                    Row(
                      children: [
                        _infoChip(
                          Icons.category_outlined,
                          aerodrome.icaoCategory,
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.straighten,
                          '${aerodrome.longestRunway.toInt()} م',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── أزرار الإجراءات ───────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionIconButton(
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    tooltip: 'تعديل',
                    onTap: () => _navigateToForm(aerodrome: aerodrome),
                  ),
                  _actionIconButton(
                    icon: Icons.delete_outline,
                    color: AppColors.danger,
                    tooltip: 'حذف',
                    onTap: () => _showDeleteDialog(aerodrome),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppFonts.labelSmall.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: AppFonts.bold,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppFonts.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToForm(),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      icon: const Icon(Icons.add),
      label: const Text('إضافة مطار'),
      elevation: 4,
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  Color _statusColor(String status) {
    switch (status) {
      case 'نشط':
        return const Color(0xFF2E7D32);
      case 'مغلق مؤقتاً':
        return const Color(0xFFE65100);
      case 'مغلق نهائياً':
        return AppColors.danger;
      case 'تحت الصيانة':
        return const Color(0xFF1565C0);
      default:
        return AppColors.textSecondary;
    }
  }

  void _navigateToForm({Aerodrome? aerodrome}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AerodromeFormScreen(aerodrome: aerodrome),
      ),
    ).then((_) => context.read<AerodromeCubit>().loadAerodromes());
  }

  void _showDeleteDialog(Aerodrome aerodrome) {
    showDialog(
      context: context,
      builder: (_) => DeleteDialog(
        title: 'حذف المطار',
        message: 'هل أنت متأكد من حذف هذا المطار؟',
        itemName: aerodrome.arabicName,
        onConfirm: () {
          context.read<AerodromeCubit>().deleteAerodrome(aerodrome.id);
          Navigator.pop(context);
        },
      ),
    );
  }
}
