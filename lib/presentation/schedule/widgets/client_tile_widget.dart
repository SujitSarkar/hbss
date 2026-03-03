import 'package:flutter/material.dart' show ListTile;
import 'package:flutter/widgets.dart';

import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/client/entities/client.dart';

class ClientTileWidget extends StatelessWidget {
  final Client client;

  const ClientTileWidget({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(client.fullName ?? '', style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w600)),
      subtitle: Text(
        client.location ?? client.userType ?? '',
        style: context.textTheme.bodySmall?.copyWith(color: context.theme.hintColor),
      ),
    );
  }
}
