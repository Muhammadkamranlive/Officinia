class CustomerData {
  int brInfoId;
  String relationId;
  String firstName;
  String middleName;
  String lastName;
  String fatherName;
  String gender;
  int dateofBirth;
  String cardTypeId;
  String cardTypeName;
  String cnic;
  int cnicIssuanceDate;
  int cnicExpiryDate;
  String motherName;
  String countryName;
  String birthPlace;
  String nationalityName;

  CustomerData(
      this.brInfoId,
      this.relationId,
      this.firstName,
      this.middleName,
      this.lastName,
      this.fatherName,
      this.gender,
      this.dateofBirth,
      this.cardTypeId,
      this.cardTypeName,
      this.cnic,
      this.cnicIssuanceDate,
      this.cnicExpiryDate,
      this.motherName,
      this.countryName,
      this.birthPlace,
      this.nationalityName);

  void displayCustomerData() {
    print("Customer ID: $brInfoId");
    print("Relation ID: $relationId");
    print("First Name: $firstName");
    print("Middle Name: $middleName");
    print("Last Name: $lastName");
    print("Father Name: $fatherName");
    print("Gender: $gender");
    print("Date of Birth: $dateofBirth");
    print("Card Type ID: $cardTypeId");
    print("Card Type Name: $cardTypeName");
    print("CNIC: $cnic");
    print("CNIC Issuance Date: $cnicIssuanceDate");
    print("CNIC Expiry Date: $cnicExpiryDate");
    print("Mother Name: $motherName");
    print("Country Name: $countryName");
    print("Birth Place: $birthPlace");
    print("Nationality Name: $nationalityName");
  }
}
