
class AccountScreening {
  final String unitId;
  final String referenceNo;
  final String postingDate;
  final String insertedBy;
  final String accountTitle;
  final String activity;
  final String subActivity;
  final String identityRefNo;
  final String customerType;
  final String status;
  final String requestType;
  final String reserve1;
  final String reserve2;
  final String reserve3;
  final String reserve4;
  final String reserve5;

  AccountScreening({
    required this.unitId,
    required this.referenceNo,
    required this.postingDate,
    required this.insertedBy,
    required this.accountTitle,
    required this.activity,
    required this.subActivity,
    required this.identityRefNo,
    required this.customerType,
    required this.status,
    required this.requestType,
    required this.reserve1,
    required this.reserve2,
    required this.reserve3,
    required this.reserve4,
    required this.reserve5,
  });

  factory AccountScreening.fromJson(Map<String, dynamic> json) {
    return AccountScreening(
      unitId: json['unit_id'] ?? '',
      referenceNo: json['reference_no'] ?? '',
      postingDate: json['posting_date'] ?? '',
      insertedBy: json['inserted_by'] ?? '',
      accountTitle: json['account_title'] ?? '',
      activity: json['activity'] ?? '',
      subActivity: json['sub_activity'] ?? '',
      identityRefNo: json['identity_ref_no'] ?? '',
      customerType: json['customer_type'] ?? '',
      status: json['status'] ?? '',
      requestType: json['request_type'] ?? '',
      reserve1: json['reserve_1'] ?? '',
      reserve2: json['reserve_2'] ?? '',
      reserve3: json['reserve_3'] ?? '',
      reserve4: json['reserve_4'] ?? '',
      reserve5: json['reserve_5'] ?? '',
    );
  }
}
