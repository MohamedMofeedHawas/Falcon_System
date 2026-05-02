import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/delete_dialog.dart';
import 'package:falcon_system/core/widgets/empty_state.dart';
import 'package:falcon_system/data/models/aircraft.dart';
import 'package:falcon_system/features/aircraft/presentation/cubit/aircraft_cubit.dart';
import 'package:falcon_system/features/aircraft/presentation/screens/aircraft_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AircraftListScreen extends StatefulWidget {
  const AircraftListScreen({super.key});

  @override
  State<AircraftListScreen> createState() => _AircraftListScreenState();
}

class _AircraftListScreenState extends State<AircraftListScreen> {
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
          children: [            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<AircraftCubit, AircraftState>(
                builder: (context, state) {
                  if (state is AircraftLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AircraftError) {
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
                              context.read<AircraftCubit>().loadAircraft();
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AircraftLoaded) {
                    final aircraft = context
                        .read<AircraftCubit>()
                        .searchAircraft(_searchQuery);

                    if (aircraft.isEmpty) {
                      return EmptyState(
                        icon: Icons.flight,
                        message: 'لا يوجد طائرات',
                        subMessage: _searchQuery.isEmpty
                            ? 'اضغط على + لإضافة طائرة جديدة'
                            : 'لم يتم العثور على نتائج',
                        actionLabel: 'إضافة طائرة',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AircraftFormScreen(),
                            ),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: aircraft.length,
                      itemBuilder: (context, index) {
                        final item = aircraft[index] as Aircraft;
                        return _buildAircraftCard(item);
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
     /* floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AircraftFormScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('إضافة طائرة'),
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
          hintText: 'البحث في الطائرات...',
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

  Widget _buildAircraftCard(Aircraft aircraft) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AircraftFormScreen(aircraft: aircraft),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aircraft.registrationNumber,
                      style: AppFonts.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${aircraft.manufacturer} ${aircraft.model}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'النوع: ${aircraft.type}',
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
                            AircraftFormScreen(aircraft: aircraft),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(aircraft);
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

  void _showDeleteDialog(Aircraft aircraft) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'حذف الطائرة',
        message: 'هل أنت متأكد من حذف هذه الطائرة؟',
        itemName: aircraft.registrationNumber,
        onConfirm: () {
          context.read<AircraftCubit>().deleteAircraft(aircraft.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الطائرة بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}

