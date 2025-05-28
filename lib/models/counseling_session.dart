import 'package:equatable/equatable.dart';

enum SessionType {
  online,
  offline,
}

enum SessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}

enum SessionDuration {
  thirtyMinutes,
  sixtyMinutes,
  ninetyMinutes,
}

extension SessionTypeExtension on SessionType {
  String get value {
    switch (this) {
      case SessionType.online:
        return 'online';
      case SessionType.offline:
        return 'offline';
    }
  }

  String get displayName {
    switch (this) {
      case SessionType.online:
        return 'Online';
      case SessionType.offline:
        return 'Offline';
    }
  }

  static SessionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'online':
        return SessionType.online;
      case 'offline':
        return SessionType.offline;
      default:
        return SessionType.online;
    }
  }
}

extension SessionStatusExtension on SessionStatus {
  String get value {
    switch (this) {
      case SessionStatus.scheduled:
        return 'scheduled';
      case SessionStatus.inProgress:
        return 'in_progress';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
      case SessionStatus.noShow:
        return 'no_show';
    }
  }

  String get displayName {
    switch (this) {
      case SessionStatus.scheduled:
        return 'Scheduled';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.noShow:
        return 'No Show';
    }
  }

  static SessionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'scheduled':
        return SessionStatus.scheduled;
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'no_show':
        return SessionStatus.noShow;
      default:
        return SessionStatus.scheduled;
    }
  }
}

extension SessionDurationExtension on SessionDuration {
  String get value {
    switch (this) {
      case SessionDuration.thirtyMinutes:
        return '30';
      case SessionDuration.sixtyMinutes:
        return '60';
      case SessionDuration.ninetyMinutes:
        return '90';
    }
  }

  int get minutes {
    switch (this) {
      case SessionDuration.thirtyMinutes:
        return 30;
      case SessionDuration.sixtyMinutes:
        return 60;
      case SessionDuration.ninetyMinutes:
        return 90;
    }
  }

  String get displayName {
    switch (this) {
      case SessionDuration.thirtyMinutes:
        return '30 minutes';
      case SessionDuration.sixtyMinutes:
        return '60 minutes';
      case SessionDuration.ninetyMinutes:
        return '90 minutes';
    }
  }

  static SessionDuration fromString(String value) {
    switch (value) {
      case '30':
        return SessionDuration.thirtyMinutes;
      case '60':
        return SessionDuration.sixtyMinutes;
      case '90':
        return SessionDuration.ninetyMinutes;
      default:
        return SessionDuration.sixtyMinutes;
    }
  }
}

class CounselingSession extends Equatable {
  final int id;
  final int studentId;
  final int counselorId;
  final SessionType sessionType;
  final SessionDuration duration;
  final DateTime scheduledDateTime;
  final SessionStatus status;
  final double amount;
  final String? meetingLink; // For online sessions
  final String? meetingPassword;
  final String? sessionNotes;
  final String? recordingPath; // If session is recorded
  final int? rating; // Student's rating (1-5)
  final String? feedback; // Student's feedback
  final String? counselorNotes;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final bool isPaymentCompleted;
  final String? paymentTransactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CounselingSession({
    required this.id,
    required this.studentId,
    required this.counselorId,
    required this.sessionType,
    required this.duration,
    required this.scheduledDateTime,
    required this.status,
    required this.amount,
    this.meetingLink,
    this.meetingPassword,
    this.sessionNotes,
    this.recordingPath,
    this.rating,
    this.feedback,
    this.counselorNotes,
    this.actualStartTime,
    this.actualEndTime,
    this.isPaymentCompleted = false,
    this.paymentTransactionId,
    required this.createdAt,
    this.updatedAt,
  });

  CounselingSession copyWith({
    int? id,
    int? studentId,
    int? counselorId,
    SessionType? sessionType,
    SessionDuration? duration,
    DateTime? scheduledDateTime,
    SessionStatus? status,
    double? amount,
    String? meetingLink,
    String? meetingPassword,
    String? sessionNotes,
    String? recordingPath,
    int? rating,
    String? feedback,
    String? counselorNotes,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    bool? isPaymentCompleted,
    String? paymentTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CounselingSession(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      counselorId: counselorId ?? this.counselorId,
      sessionType: sessionType ?? this.sessionType,
      duration: duration ?? this.duration,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      meetingLink: meetingLink ?? this.meetingLink,
      meetingPassword: meetingPassword ?? this.meetingPassword,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      recordingPath: recordingPath ?? this.recordingPath,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      counselorNotes: counselorNotes ?? this.counselorNotes,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      isPaymentCompleted: isPaymentCompleted ?? this.isPaymentCompleted,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'counselor_id': counselorId,
      'session_type': sessionType.value,
      'duration': duration.value,
      'scheduled_date_time': scheduledDateTime.toIso8601String(),
      'status': status.value,
      'amount': amount,
      'meeting_link': meetingLink,
      'meeting_password': meetingPassword,
      'session_notes': sessionNotes,
      'recording_path': recordingPath,
      'rating': rating,
      'feedback': feedback,
      'counselor_notes': counselorNotes,
      'actual_start_time': actualStartTime?.toIso8601String(),
      'actual_end_time': actualEndTime?.toIso8601String(),
      'is_payment_completed': isPaymentCompleted,
      'payment_transaction_id': paymentTransactionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory CounselingSession.fromMap(Map<String, dynamic> map) {
    return CounselingSession(
      id: map['id'],
      studentId: map['student_id'],
      counselorId: map['counselor_id'],
      sessionType: SessionTypeExtension.fromString(map['session_type']),
      duration: SessionDurationExtension.fromString(map['duration']),
      scheduledDateTime: DateTime.parse(map['scheduled_date_time']),
      status: SessionStatusExtension.fromString(map['status']),
      amount: map['amount'].toDouble(),
      meetingLink: map['meeting_link'],
      meetingPassword: map['meeting_password'],
      sessionNotes: map['session_notes'],
      recordingPath: map['recording_path'],
      rating: map['rating'],
      feedback: map['feedback'],
      counselorNotes: map['counselor_notes'],
      actualStartTime: map['actual_start_time'] != null ? DateTime.parse(map['actual_start_time']) : null,
      actualEndTime: map['actual_end_time'] != null ? DateTime.parse(map['actual_end_time']) : null,
      isPaymentCompleted: map['is_payment_completed'] ?? false,
      paymentTransactionId: map['payment_transaction_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    counselorId,
    sessionType,
    duration,
    scheduledDateTime,
    status,
    amount,
    meetingLink,
    meetingPassword,
    sessionNotes,
    recordingPath,
    rating,
    feedback,
    counselorNotes,
    actualStartTime,
    actualEndTime,
    isPaymentCompleted,
    paymentTransactionId,
    createdAt,
    updatedAt,
  ];
}
