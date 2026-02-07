import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/moment.dart';
import '../../../presentation/providers/moments/moments_provider.dart';
import '../../../presentation/shared/aura/aura.dart';

/// Filter Drawer - Bottom sheet for timeline filtering
///
/// Allows users to filter moments by:
/// - Author (family member)
/// - Year
/// - Media type
/// - Favorites only
class FilterDrawerNew extends ConsumerWidget {
  const FilterDrawerNew({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timelineFilterProvider);
    final hasFilters = filter.hasActiveFilters;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warmGray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  Text('筛选', style: AppTypography.subtitle(context)),
                  const Spacer(),
                  if (hasFilters)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(timelineFilterProvider.notifier)
                            .clearFilters();
                      },
                      child: const Text(
                        '清除筛选',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filter sections
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year filter
                    _buildSectionTitle(context, '年份'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildYearFilter(context, ref, filter),

                    const SizedBox(height: AppSpacing.xl),

                    // Media type filter
                    _buildSectionTitle(context, '类型'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMediaTypeFilter(context, ref, filter),

                    const SizedBox(height: AppSpacing.xl),

                    // Favorites toggle
                    _buildFavoritesToggle(context, ref, filter),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: AuraButton.primary(
                label: '应用筛选',
                fullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTypography.caption(
        context,
      ).copyWith(fontWeight: FontWeight.w600, color: AppColors.warmGray500),
    );
  }

  Widget _buildYearFilter(BuildContext context, WidgetRef ref, dynamic filter) {
    // TODO: Fetch available years from provider
    final years = [2024, 2023, 2022, 2021];
    final selectedYear = filter.year;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        // All years option
        _FilterChip(
          label: '全部',
          isSelected: selectedYear == null,
          onTap: () => ref.read(timelineFilterProvider.notifier).setYear(null),
        ),
        ...years.map(
          (year) => _FilterChip(
            label: '$year年',
            isSelected: selectedYear == year,
            onTap:
                () => ref.read(timelineFilterProvider.notifier).setYear(year),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTypeFilter(
    BuildContext context,
    WidgetRef ref,
    dynamic filter,
  ) {
    final selectedType = filter.mediaType;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _FilterChip(
          label: '全部',
          isSelected: selectedType == null,
          onTap:
              () =>
                  ref.read(timelineFilterProvider.notifier).setMediaType(null),
        ),
        _FilterChip(
          label: '图片',
          icon: Icons.image_outlined,
          isSelected: selectedType == MediaType.image,
          onTap:
              () => ref
                  .read(timelineFilterProvider.notifier)
                  .setMediaType(MediaType.image),
        ),
        _FilterChip(
          label: '视频',
          icon: Icons.videocam_outlined,
          isSelected: selectedType == MediaType.video,
          onTap:
              () => ref
                  .read(timelineFilterProvider.notifier)
                  .setMediaType(MediaType.video),
        ),
        _FilterChip(
          label: '文字',
          icon: Icons.text_fields_outlined,
          isSelected: selectedType == MediaType.text,
          onTap:
              () => ref
                  .read(timelineFilterProvider.notifier)
                  .setMediaType(MediaType.text),
        ),
      ],
    );
  }

  Widget _buildFavoritesToggle(
    BuildContext context,
    WidgetRef ref,
    dynamic filter,
  ) {
    final favoritesOnly = filter.favoritesOnly == true;

    return GestureDetector(
      onTap: () {
        ref
            .read(timelineFilterProvider.notifier)
            .setFavoritesOnly(favoritesOnly ? null : true);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: favoritesOnly ? AppColors.primaryLight : AppColors.warmGray100,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border:
              favoritesOnly
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              favoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: favoritesOnly ? AppColors.heart : AppColors.warmGray500,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '只看收藏',
              style: AppTypography.body(context).copyWith(
                color:
                    favoritesOnly
                        ? AppColors.warmGray800
                        : AppColors.warmGray600,
              ),
            ),
            const Spacer(),
            if (favoritesOnly)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Filter chip component
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? AppSpacing.md : AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.warmGray100,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border:
              isSelected
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color:
                    isSelected ? AppColors.primaryDark : AppColors.warmGray500,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? AppColors.primaryDark : AppColors.warmGray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
