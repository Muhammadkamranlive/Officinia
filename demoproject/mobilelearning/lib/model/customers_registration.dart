class CustomersRegistration {
  String mobilenumber;
  String deviceid;
  String emailid;
  String smsotp;
  String emailotp;
  String startdate;
  String enddate;
  Map<String, dynamic> profilepic;
  bool isActive;
  String message;

  CustomersRegistration(
      this.mobilenumber,
      this.deviceid,
      this.emailid,
      this.smsotp,
      this.emailotp,
      this.startdate,
      this.enddate,
      this.profilepic,
      this.isActive,
      this.message);

  Map<String, dynamic> toJson() => {
    "mobilenumber": mobilenumber,
    "deviceid": deviceid,
    "emailid": emailid,
    "smsotp": smsotp,
    "emailotp": emailotp,
    "startdate": startdate,
    "enddate": enddate,
    "profilepic": profilepic,
    "isActive": isActive,
    "message": message
  };
}