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
  int? _expandedId;

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
              final isExpanded = _expandedId == child.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isExpanded ? color.withOpacity(0.5) : T.border,
                    width: isExpanded ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
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
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(
                                  () => _expandedId = isExpanded
                                      ? null
                                      : child.id,
                                ),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: T.cyan.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: T.cyan.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: T.cyan,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: T.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: T.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.edit_rounded,
                                      color: T.blue,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: T.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: T.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: T.red,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded) ...[
                      Divider(height: 1, color: T.border),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              icon: '👤',
                              label: 'Full Name',
                              val: child.name,
                              T: T,
                            ),
                            _DetailRow(
                              icon: '🔢',
                              label: 'Age',
                              val: '${child.age} years old',
                              T: T,
                            ),
                            _DetailRow(
                              icon: '⚥',
                              label: 'Gender',
                              val: child.gender.isEmpty ? '—' : child.gender,
                              T: T,
                            ),
                            _DetailRow(
                              icon: '🏫',
                              label: 'School',
                              val: child.school,
                              T: T,
                            ),
                            _DetailRow(
                              icon: '⌚',
                              label: 'Device ID',
                              val: child.device,
                              T: T,
                            ),
                            _DetailRow(
                              icon: '📱',
                              label: 'Parent Phone',
                              val: child.parentPhone.isEmpty
                                  ? '—'
                                  : child.parentPhone,
                              T: T,
                            ),
                            _DetailRow(
                              icon: '🧑‍🏫',
                              label: 'Teacher Name',
                              val: child.teacherName.isEmpty
                                  ? 'Not added'
                                  : child.teacherName,
                              T: T,
                            ),
                            _DetailRow(
                              icon: '📞',
                              label: 'Teacher Phone',
                              val: child.teacherPhone.isEmpty
                                  ? 'Not added'
                                  : child.teacherPhone,
                              T: T,
                            ),
                            Row(
                              children: [
                                _StatusChip(
                                  icon: '🔋',
                                  val: '${child.battery}%',
                                  color: child.battery < 20 ? T.red : T.green,
                                  T: T,
                                ),
                                const SizedBox(width: 8),
                                _StatusChip(
                                  icon: '👟',
                                  val: '${child.steps} steps',
                                  color: T.cyan,
                                  T: T,
                                ),
                                const SizedBox(width: 8),
                                _StatusChip(
                                  icon: '📍',
                                  val: child.status,
                                  color: T.indigo,
                                  T: T,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String icon, label, val;
  final AppTheme T;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.val,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text('$label:', style: TextStyle(color: T.sub, fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              val,
              style: TextStyle(
                color: T.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String icon, val;
  final Color color;
  final AppTheme T;
  const _StatusChip({
    required this.icon,
    required this.val,
    required this.color,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
