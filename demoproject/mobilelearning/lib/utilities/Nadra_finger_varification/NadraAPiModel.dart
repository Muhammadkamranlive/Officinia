class FingerPrintVerificationRequest {
  final String? strAppID;
  final String? strADC_TranCode;
  final String? strDelimiter;
  final String? strDate;
  final String? strTime;
  final String? strNetID;
  final String? intRefNum;
  final String? intSTAN;
  final String? strTranMsg;
  final String? strMerName;
  final String? strMCC;
  final String? strToken;
  final String? citizenNumber;
  final String? contactNumber;
  final String? fingerIndex;
  final String? fingerTemplate;
  final String? templateType;
  final String? areaName;
  final String? reasonCode;
  final String? r1;
  final String? r2;
  final String? r3;
  final String? r4;

  FingerPrintVerificationRequest({
    this.strAppID,
    this.strADC_TranCode,
    this.strDelimiter,
    this.strDate,
    this.strTime,
    this.strNetID,
    this.intRefNum,
    this.intSTAN,
    this.strTranMsg,
    this.strMerName,
    this.strMCC,
    this.strToken,
    this.citizenNumber,
    this.contactNumber,
    this.fingerIndex,
    this.fingerTemplate,
    this.templateType,
    this.areaName,
    this.reasonCode,
    this.r1,
    this.r2,
    this.r3,
    this.r4,
  });

  Map<String, dynamic> toJson() {
    return {
      'strAppID': strAppID,
      'strADC_TranCode': strADC_TranCode,
      'strDelimiter': strDelimiter,
      'strDate': strDate,
      'strTime': strTime,
      'strNetID': strNetID,
      'intRefNum': intRefNum,
      'intSTAN': intSTAN,
      'strTranMsg': strTranMsg,
      'strMerName': strMerName,
      'strMCC': strMCC,
      'strToken': strToken,
      'citizenNumber': citizenNumber,
      'contactNumber': contactNumber,
      'fingerIndex': fingerIndex,
      'fingerTemplate': fingerTemplate,
      'templateType': templateType,
      'areaName': areaName,
      'reasonCode': reasonCode,
      'r1': r1,
      'r2': r2,
      'r3': r3,
      'r4': r4,
    };
  }
}
