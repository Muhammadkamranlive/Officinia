class CnicModel {
  String cnicNumber = "";
  String cnicIssueDate = "";
  String cnicHolderName = "";
  String genderType = "";
  String cnicHolderFatherName = "";
  String cnicExpiryDate = "";
  String cnicHolderDateOfBirth = "";

  @override
  String toString() {
    var string = '';
    string += cnicNumber.isEmpty ? "" : 'Cnic Number = $cnicNumber\n';
    string +=
        cnicExpiryDate.isEmpty ? "" : 'Cnic Expiry Date = $cnicExpiryDate\n';
    string += cnicIssueDate.isEmpty ? "" : 'Cnic Issue Date = $cnicIssueDate\n';
    string +=
        cnicHolderName.isEmpty ? "" : 'Cnic Holder Name = $cnicHolderName\n';
    string += genderType.isEmpty ? "" : 'Cnic Holder Gender = $genderType\n';

    string += cnicHolderFatherName.isEmpty
        ? ""
        : 'Cnic Holder Father Name = $cnicHolderFatherName\n';
    string += cnicHolderDateOfBirth.isEmpty
        ? ""
        : 'Cnic Holder DoB = $cnicHolderDateOfBirth\n';
    return string;
  }
}
