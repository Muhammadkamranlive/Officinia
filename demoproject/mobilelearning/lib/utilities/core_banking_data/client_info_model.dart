class ClientInfoModel {
  final String? clientNo;
  final String? clientName;
  final String? fatherName;
  final String? gender;
  final String? maritalStatus;
  final String? globalID;
  final String? birthDate;
  final String? email;
  final String? mobileNo;
  final String? address;
  final String? country;
  final String? province;
  final String? city;

  ClientInfoModel({
    this.clientNo,
    this.clientName,
    this.fatherName,
    this.gender,
    this.maritalStatus,
    this.globalID,
    this.birthDate,
    this.email,
    this.mobileNo,
    this.address,
    this.country,
    this.province,
    this.city,
  });

  // Convert JSON response to a Dart object
  factory ClientInfoModel.fromJson(Map<String, dynamic> json) {
    return ClientInfoModel(
      clientNo: json['clientNo'],
      clientName: json['clientName'],
      fatherName: json['fatherName'],
      gender: json['gender'],
      maritalStatus: json['maritalStatus'],
      globalID: json['globalID'],
      birthDate: json['birthDate'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      address: json['address'],
      country: json['country'],
      province: json['province'],
      city: json['city'],
    );
  }
}
