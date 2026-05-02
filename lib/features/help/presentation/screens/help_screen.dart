import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            'المساعدة والدعم',
            style: AppFonts.headline6.copyWith(color: AppColors.textWhite),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'عن النظام',
                icon: Icons.info_outline,
                children: [
                  _buildInfoItem(
                    label: 'اسم النظام',
                    value: AppStrings.systemTitle,
                  ),
                  _buildInfoItem(label: 'الإصدار', value: '1.0.0'),
                  _buildInfoItem(label: 'الوصف', value: AppStrings.subtitle),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'معلومات الاتصال',
                icon: Icons.contact_phone_outlined,
                children: [
                  _buildContactItem(
                    icon: Icons.email_outlined,
                    label: 'البريد الإلكتروني',
                    value: 'mohamedznuav999@gmail.com',
                    onTap: () => _launchEmail('mohamedznuav999@gmail.com'),
                  ),
                  _buildContactItem(
                    icon: Icons.phone_outlined,
                    label: 'رقم الهاتف',
                    value: '+20 1060157100',
                    onTap: () => _launchPhone('+20 1060157100'),
                  ),
                  _buildContactItem(
                    icon: Icons.location_on_outlined,
                    label: 'العنوان',
                    value: 'القاهرة، مصر',
                  ),
                  _buildContactItem(
                    icon: Icons.language_outlined,
                    label: 'الموقع الإلكتروني',
                    value: 'www.falcon-system.com',
                    onTap: () => _launchUrl('https://www.falcon-system.com'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'الأسئلة الشائعة',
                icon: Icons.help_outline,
                children: [
                  _buildFaqItem(
                    question: 'كيف أقوم بإضافة مطار جديد؟',
                    answer:
                        'انتقل إلى قسم "المطارات" من القائمة الجانبية، ثم اضغط على زر "+" لإضافة مطار جديد.',
                  ),
                  _buildFaqItem(
                    question: 'كيف أقوم بإنشاء تقرير تقييم جديد؟',
                    answer:
                        'انتقل إلى قسم "التقارير" من القائمة الجانبية، ثم اضغط على زر "+" لإنشاء تقرير تقييم جديد.',
                  ),
                  _buildFaqItem(
                    question: 'كيف أقوم بتصدير التقرير كملف PDF؟',
                    answer:
                        'افتح التقرير المطلوب، ثم اضغط على أيقونة PDF في أعلى الشاشة لتصدير التقرير كملف PDF.',
                  ),
                  _buildFaqItem(
                    question: 'هل النظام يعمل بدون إنترنت؟',
                    answer:
                        'نعم، النظام مصمم للعمل بالكامل بدون اتصال بالإنترنت. جميع البيانات مخزنة محلياً على جهازك.',
                  ),
                  _buildFaqItem(
                    question: 'كيف يمكنني استعادة البيانات؟',
                    answer:
                        'يتم نسخ البيانات احتياطياً بشكل دوري. يمكنك استعادة البيانات من النسخ الاحتياطي في إعدادات النظام.',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'الدليل الفني',
                icon: Icons.menu_book_outlined,
                children: [
                  _buildGuideItem(
                    title: 'دليل المستخدم',
                    description: 'دليل شامل لاستخدام جميع ميزات النظام',
                    icon: Icons.description_outlined,
                  ),
                  _buildGuideItem(
                    title: 'دليل التقييم',
                    description: 'شرح مفصل لعملية التقييم ومعاييرها',
                    icon: Icons.assessment_outlined,
                  ),
                  _buildGuideItem(
                    title: 'دليل التقارير',
                    description: 'كيفية إنشاء وتصدير التقارير',
                    icon: Icons.picture_as_pdf_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'عن النظام',
                icon: Icons.business_outlined,
                children: [
                  _buildInfoItem(label: 'المطور', value: 'فريق تطوير فالكون'),
                  _buildInfoItem(
                    label: 'الجهة',
                    value: 'الكلية الجوية المصرية',
                  ),
                  _buildInfoItem(
                    label: 'الحقوق',
                    value: '© 2024 جميع الحقوق محفوظة',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppFonts.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppFonts.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFonts.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: AppFonts.labelMedium.copyWith(
                      color: onTap != null
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_left, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppFonts.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: AppFonts.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Navigate to guide (placeholder)
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppFonts.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
