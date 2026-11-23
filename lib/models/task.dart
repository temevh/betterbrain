enum TaskStatus { assigned, completed, missed, restDay }

TaskStatus _parseStatus(String? value) {
  switch (value) {
    case 'completed':
      return TaskStatus.completed;
    case 'missed':
      return TaskStatus.missed;
    case 'rest_day':
      return TaskStatus.restDay;
    default:
      return TaskStatus.assigned;
  }
}

double? _toDouble(dynamic value) =>
    value == null ? null : (value as num).toDouble();

/// One day's task for the user, as stored in `daily_assignments`.
class Task {
  final String id;
  final String? templateId;
  final String taskText;
  final String category;
  final TaskStatus status;

  /// -1 too hard, 0 just right, 1 too easy, null when not given or missed.
  final int? feedback;
  final String reflection;

  /// The user's local day this task belongs to.
  final DateTime date;
  final String? tip;
  final bool canSwap;
  final double? levelBefore;
  final double? levelAfter;

  const Task({
    required this.id,
    required this.templateId,
    required this.taskText,
    required this.category,
    required this.status,
    required this.feedback,
    required this.reflection,
    required this.date,
    this.tip,
    this.canSwap = false,
    this.levelBefore,
    this.levelAfter,
  });

  bool get isCompleted => status == TaskStatus.completed;

  factory Task.fromJson(Map<String, dynamic> json) {
    final status = _parseStatus(json['status'] as String?);
    return Task(
      id: json['id'] as String,
      templateId: json['template_id'] as String?,
      taskText: json['rendered_text'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: status,
      feedback: (json['feedback'] as num?)?.toInt(),
      reflection: json['reflection'] as String? ?? '',
      // assigned_date is a plain yyyy-MM-dd date, parsed as local midnight.
      date: DateTime.parse(json['assigned_date'] as String),
      tip: json['tip'] as String?,
      canSwap:
          json['can_swap'] as bool? ??
          (status == TaskStatus.assigned &&
              ((json['swap_count'] as num?)?.toInt() ?? 0) < 1),
      levelBefore: _toDouble(json['level_before']),
      levelAfter: _toDouble(json['level_after']),
    );
  }
}
