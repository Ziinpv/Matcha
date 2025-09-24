import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String reportId;
  final String reporterId;
  final String reportedId;
  final String reason;
  final String status;
  final DateTime createdAt;

  Report({
    required this.reportId,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      reportId: map['report_id'],
      reporterId: map['reporter_id'],
      reportedId: map['reported_id'],
      reason: map['reason'],
      status: map['status'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'reporter_id': reporterId,
      'reported_id': reportedId,
      'reason': reason,
      'status': status,
      'created_at': createdAt,
    };
  }
}
