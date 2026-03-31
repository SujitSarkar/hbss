import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/assets.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/presentation/app_settings/bloc/app_settings_bloc.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocBuilder<AppSettingsBloc, AppSettingsState>(
          builder: (context, settingsState) {
            final settings = settingsState is AppSettingsLoadedState ? settingsState.appSettings : null;
            final bgImageUrl = settings?.mobileLoginBgImage?.toString();
            final logoUrl = settings?.mobileLogo?.toString();

            return Column(
              children: [
                _buildHeaderSection(screenHeight, bgImageUrl: bgImageUrl, logoUrl: logoUrl),
                _buildFormSection(screenHeight),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double screenHeight, {String? bgImageUrl, String? logoUrl}) {
    return SizedBox(
      height: screenHeight * 0.5,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundImage(bgImageUrl),
          Center(
            child: Padding(padding: const EdgeInsets.only(bottom: 20), child: _buildLogoImage(logoUrl)),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: ApiEndpoints.imageUrl(url),
        fit: BoxFit.cover,
        placeholder: (_, _) => Image.asset(Assets.assetsImagesLoginBg, fit: BoxFit.cover),
        errorWidget: (_, _, _) => Image.asset(Assets.assetsImagesLoginBg, fit: BoxFit.cover),
      );
    }
    return Image.asset(Assets.assetsImagesLoginBg, fit: BoxFit.cover);
  }

  Widget _buildLogoImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: ApiEndpoints.imageUrl(url),
        width: 200,
        placeholder: (_, _) => Image.asset(Assets.assetsImagesBannerLogo, width: 200),
        errorWidget: (_, _, _) => Image.asset(Assets.assetsImagesBannerLogo, width: 200),
      );
    }
    return Image.asset(Assets.assetsImagesBannerLogo, width: 200);
  }

  Widget _buildFormSection(double screenHeight) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 32, 16, 0),
      width: double.infinity,
      color: AppColors.primary,
      child: child,
    );
  }
}
