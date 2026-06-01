import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/settlement.dart';

class DebtGraphPainter extends CustomPainter {
  DebtGraphPainter({
    required this.members,
    required this.edges,
    required this.netBalances,
    this.selectedMemberId,
    this.maxEdgeAmount = 1,
  });

  final List<Member> members;
  final List<DebtEdge> edges;
  final Map<String, double> netBalances;
  final String? selectedMemberId;
  final double maxEdgeAmount;

  @override
  void paint(Canvas canvas, Size size) {
    if (members.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.32;
    final positions = <String, Offset>{};

    for (var i = 0; i < members.length; i++) {
      final angle = (2 * math.pi * i / members.length) - math.pi / 2;
      positions[members[i].id] = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }

    for (final edge in edges) {
      final from = positions[edge.fromId];
      final to = positions[edge.toId];
      if (from == null || to == null) continue;

      final intensity = (edge.amount / maxEdgeAmount).clamp(0.2, 1.0);
      final paint = Paint()
        ..color = AppColors.graphEdge.withValues(alpha: intensity)
        ..strokeWidth = 1.5 + 3 * intensity
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(center.dx, center.dy, to.dx, to.dy);
      canvas.drawPath(path, paint);
    }

    for (final member in members) {
      final pos = positions[member.id]!;
      final isSelected = member.id == selectedMemberId;
      final net = netBalances[member.id] ?? 0;
      final nodeRadius = isSelected ? 28.0 : 24.0;

      canvas.drawCircle(
        pos,
        nodeRadius,
        Paint()..color = Color(member.colorHex),
      );

      if (isSelected) {
        canvas.drawCircle(
          pos,
          nodeRadius + 4,
          Paint()
            ..color = AppColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      final initials =
          member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : '?';
      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      final namePainter = TextPainter(
        text: TextSpan(
          text: member.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      namePainter.paint(
        canvas,
        Offset(pos.dx - namePainter.width / 2, pos.dy + nodeRadius + 6),
      );

      if (net.abs() > 0.01) {
        final netLabel =
            net > 0 ? '+${net.toStringAsFixed(0)}' : net.toStringAsFixed(0);
        final netPainter = TextPainter(
          text: TextSpan(
            text: netLabel,
            style: TextStyle(
              color: net > 0 ? AppColors.primary : AppColors.danger,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        netPainter.paint(
          canvas,
          Offset(pos.dx - netPainter.width / 2, pos.dy - nodeRadius - 14),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DebtGraphPainter oldDelegate) =>
      oldDelegate.edges != edges ||
      oldDelegate.selectedMemberId != selectedMemberId ||
      oldDelegate.netBalances != netBalances;
}
