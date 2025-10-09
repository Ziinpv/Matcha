// lib/models/report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String reporterId;
  final String reportedId;
  final String? reason;
  final String? status; // pending, reviewed, banned
  final DateTime? createdAt;

  ReportModel({
    required this.reportId,
    required this.reporterId,
    required this.reportedId,
    this.reason,
    this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'reporter_id': reporterId,
      'reported_id': reportedId,
      'reason': reason ?? '',
      'status': status ?? 'pending',
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['report_id'] ?? '',
      reporterId: map['reporter_id'] ?? '',
      reportedId: map['reported_id'] ?? '',
      reason: (map['reason'] as String?)?.isNotEmpty == true ? map['reason'] : null,
      status: (map['status'] as String?)?.isNotEmpty == true ? map['status'] : 'pending',
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  factory ReportModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return ReportModel.fromMap(data);
  }
}
