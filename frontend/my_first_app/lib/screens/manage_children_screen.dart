import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models.dart';

class ManageChildScreen extends StatefulWidget {
  final Function(String) go;
  final List<ChildModel> children;
  final Function(ChildModel) onEdit;
  final Function(int) onDelete;
  final AppTheme T;
  const ManageChildScreen({
    super.key,
    required this.go,
    required this.children,
    required this.onEdit,
    required this.onDelete,
    required this.T,
  });

  @override
  State<ManageChildScreen> createState() => _ManageChildScreenState();
}

class _ManageChildScreenState extends State<ManageChildScreen> {
  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KCTopBar(
            title: 'Manage Children',
            sub: '${widget.children.length} registered',
            onBack: () => widget.go('dashboard'),
            T: T,
            rightEl: GestureDetector(
              onTap: () => widget.go('addchild'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: T.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: T.cyan),
                ),
                child: Text(
                  '+ Add',
                  style: TextStyle(
                    color: T.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          if (widget.children.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: T.border),
              ),
              child: Column(
                children: [
                  const Text('👶', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text(
                    'No children added yet',
                    style: TextStyle(
                      color: T.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "+ Add" above to register a child.',
                    style: TextStyle(color: T.sub, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...widget.children.map((child) {
              final color = Color(child.colorHex);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: T.border, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            child.avatar,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: TextStyle(
                                color: T.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${child.age}y · ${child.school}',
                              style: TextStyle(color: T.sub, fontSize: 11),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: child.online ? T.green : T.muted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  child.online ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: child.online ? T.green : T.muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
