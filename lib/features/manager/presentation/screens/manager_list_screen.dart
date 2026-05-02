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
}
