import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Navigates back one step, or to the groups list when there is no stack.
void navigateToGroupsList(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}

class BackToGroupsButton extends StatelessWidget {
  const BackToGroupsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'All groups',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => navigateToGroupsList(context),
    );
  }
}
