import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maori_health/core/config/env_config.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/data/asset/models/asset_response_model.dart';

import 'package:maori_health/core/utils/asset_utils.dart';
import 'package:maori_health/presentation/shared/widgets/app_shimmer.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';

class AssetDetailsPage extends StatelessWidget {
  final AssetResponseModel asset;

  const AssetDetailsPage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: Text(AppStrings.viewDetails)),
      body: SingleChildScrollView(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildDescriptionSection(context),
            const SizedBox(height: 20),
            _buildAttachmentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final textTheme = context.textTheme;
    final labelStyle = textTheme.bodyMedium;
    final valueStyle = textTheme.bodyMedium?.copyWith(fontWeight: .w600);

    return Container(
      width: double.infinity,
      padding: const .all(16),
      decoration: BoxDecoration(
        borderRadius: .circular(14),
        border: .all(color: context.theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _InfoRow(
            label: '${AppStrings.aid}: ',
            value: '${asset.asset.id}',
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: '${AppStrings.statusLabel}: ',
            value: AssetUtils.statusLabel(asset.asset.acknowledgementStatus ?? 0),
            labelStyle: labelStyle,
            valueStyle: valueStyle?.copyWith(color: AssetUtils.statusColor(asset.asset.acknowledgementStatus ?? 0)),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: '${AppStrings.product}: ',
            value: asset.stock.uniqueId ?? AppStrings.na,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: '${AppStrings.assignDate}: ',
            value: DateConverter.formatDate(asset.asset.assignedDate!),
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: '${AppStrings.operator}: ',
            value: asset.user.fullName ?? AppStrings.na,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: '${AppStrings.acknowledgement}: ',
            value: asset.receivedBy?.fullName ?? AppStrings.na,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          if (asset.asset.receivedAt != null) ...[
            const SizedBox(height: 8),

            _InfoRow(
              label: '${AppStrings.at}: ',
              value: DateConverter.formatDateTime(asset.asset.receivedAt!),
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(AppStrings.description, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
        const SizedBox(height: 8),
        Text(
          asset.asset.note ?? AppStrings.na,
          style: textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(AppStrings.attachment, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
        const SizedBox(height: 12),
        asset.stock.product?.image != null
            ? ClipRRect(
                borderRadius: .circular(12),
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.fitHeight,
                  imageUrl: '${EnvConfig.hostUrl}${asset.stock.product?.image}',
                  placeholder: (context, url) => AppShimmer.card(height: 200, borderRadius: 12),
                  errorWidget: (context, url, error) => _buildAttachmentPlaceholder(context, icon: Icons.error_outline),
                ),
              )
            : _buildAttachmentPlaceholder(context),
      ],
    );
  }

  Widget _buildAttachmentPlaceholder(BuildContext context, {IconData? icon, String? text}) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(color: context.colorScheme.surfaceContainerHighest, borderRadius: .circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.image_outlined, size: 48, color: context.colorScheme.onSurfaceVariant.withAlpha(120)),
          const SizedBox(height: 8),
          Text(
            text ?? AppStrings.noAttachment,
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant.withAlpha(150)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _InfoRow({required this.label, required this.value, this.labelStyle, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: label, style: labelStyle),
          TextSpan(text: value, style: valueStyle),
        ],
      ),
    );
  }
}
