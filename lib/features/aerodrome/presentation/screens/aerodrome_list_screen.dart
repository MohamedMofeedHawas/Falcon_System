import 'package:flutter/material.dart';
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
}
