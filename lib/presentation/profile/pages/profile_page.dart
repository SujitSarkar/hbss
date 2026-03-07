import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/env_config.dart';
import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/enums/job_status.enum.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/domain/auth/entities/user.dart';

import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/profile/widgets/change_password_dialog.dart';
import 'package:maori_health/presentation/profile/widgets/profile_info_tile.dart';
import 'package:maori_health/presentation/profile/widgets/profile_section_card.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: const Text(AppStrings.profile), context: context),
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (prev, curr) => prev.user != curr.user,
        builder: (context, state) {
          final user = state.user;
          if (user == null) {
            return const Center(child: Text(AppStrings.noDataFound));
          }
          return _ProfileBody(user: user);
        },
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const .fromLTRB(12, 4, 12, 0),
          child: SolidButton(
            width: 200,
            onPressed: () => showChangePasswordDialog(context),
            child: const Text(AppStrings.changePassword),
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final User user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return SingleChildScrollView(
      padding: const .fromLTRB(12, 0, 12, 16),
      child: Column(
        children: [
          _buildAvatar(context),
          const SizedBox(height: 8),
          Text(user.fullName ?? '-', style: textTheme.titleLarge?.copyWith(fontWeight: .bold)),
          const SizedBox(height: 4),
          Text(
            _formatUserType(user.userType),
            style: textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _buildBasicInfo(context),
          const SizedBox(height: 16),
          _buildContactInfo(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final placeholder = CircleAvatar(
      radius: 56,
      backgroundColor: context.theme.dividerColor,
      child: Icon(Icons.person_outline, size: 56, color: context.colorScheme.onSurfaceVariant.withAlpha(120)),
    );

    if (user.avatar == null || user.avatar!.isEmpty) return placeholder;

    return CachedNetworkImage(
      imageUrl: '${EnvConfig.hostUrl}${user.avatar!}',
      imageBuilder: (_, imageProvider) => CircleAvatar(radius: 56, backgroundImage: imageProvider),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return ProfileSectionCard(
      icon: Icons.person_outline,
      title: AppStrings.basicInformation,
      children: [
        ProfileInfoTile(
          icon: Icons.verified_outlined,
          label: AppStrings.statusLabel,
          trailing: _StatusBadge(status: user.status),
        ),
        ProfileInfoTile(icon: Icons.face_outlined, label: AppStrings.nickName, value: user.nickName),
        ProfileInfoTile(icon: Icons.wc_outlined, label: AppStrings.gender, value: user.gender),
        ProfileInfoTile(icon: Icons.cake_outlined, label: AppStrings.dateOfBirth, value: user.dob),
        ProfileInfoTile(icon: Icons.hourglass_bottom_outlined, label: AppStrings.age, value: user.age),
        ProfileInfoTile(icon: Icons.diversity_3_outlined, label: AppStrings.ethnicity, value: user.ethnicity),
        ProfileInfoTile(icon: Icons.medical_information_outlined, label: AppStrings.nhi, value: user.nhi),
        ProfileInfoTile(
          icon: Icons.calendar_today_outlined,
          label: AppStrings.joinedDate,
          value: DateConverter.formatIsoDateTime(user.createdAt),
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return ProfileSectionCard(
      icon: Icons.contact_mail_outlined,
      title: AppStrings.contactInformation,
      children: [
        ProfileInfoTile(icon: Icons.email_outlined, label: AppStrings.email, value: user.email),
        ProfileInfoTile(icon: Icons.phone_outlined, label: AppStrings.phone, value: user.phone),
        ProfileInfoTile(icon: Icons.location_on_outlined, label: AppStrings.location, value: user.location),
      ],
    );
  }

  String _formatUserType(String? type) {
    if (type == null || type.isEmpty) return '-';
    return type.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;

  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status?.toLowerCase() == JobStatusEnum.active.value;

    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: isActive ? AppColors.success : Colors.grey, borderRadius: .circular(20)),
      child: Text(
        (status ?? '-').capitalize(),
        style: context.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: .w600),
      ),
    );
  }
}
