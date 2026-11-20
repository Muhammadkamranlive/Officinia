class ApiResponse {
  final String displayMessage;
  final String displayMessageCode;
  final List<String> displayMessageData;
  final String realMessage;
  final String statusCode;
  final Data data;
  final bool exceptionRaised;
  final List<String> newData;
  final List<String> oldData;
  final bool displayPopup;

  ApiResponse({
    required this.displayMessage,
    required this.displayMessageCode,
    required this.displayMessageData,
    required this.realMessage,
    required this.statusCode,
    required this.data,
    required this.exceptionRaised,
    required this.newData,
    required this.oldData,
    required this.displayPopup,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      displayMessage: json['displayMessage'] ?? '',
      displayMessageCode: json['displayMessageCode'] ?? '',
      displayMessageData: List<String>.from(json['displayMessageData'] ?? []),
      realMessage: json['realMessage'] ?? '',
      statusCode: json['statusCode'] ?? '',
      data: Data.fromJson(json['Data']),
      exceptionRaised: json['exceptionRaised'] ?? false,
      newData: List<String>.from(json['newData'] ?? []),
      oldData: List<String>.from(json['oldData'] ?? []),
      displayPopup: json['displayPopup'] ?? false,
    );
  }
}

class Data {
  final String productType;
  final String customerProductType;
  final String productCode;
  final String idNumber;
  final String dateOfBirth;
  final String idCardType;
  final String idIssueDate;
  final String idExpiryDate;
  final String mName;
  final String fName;
  final String lName;
  final String genderType;
  final String fatherName;
  final String motherName;
  final String personalNumber;
  final String customerEmail;
  final String countryType;
  final String placeOfBirth;
  final String maritalStatus;
  final String numberOfDependents;
  final String educationalQualification;
  final String nationalityType;
  final String selectProduct;
  final String ownCar;
  final String currentCity;
  final String permanentAddress;
  final String telephoneNumber;
  final String residentialStatus;
  final String typeOfAccommodation;
  final String cardDelivery;
  final String employmentType;
  final String companyName;
  final String companyType;
  final String employmentStatus;
  final String currentDesignation;
  final String currentDepartment;
  final String overallWorkExperience;
  final String presentExperience;
  final String designationProfession;
  final String natureOfBusiness;
  final String nameOfCompany;
  final String officeAddress;
  final String officeCity;
  final String officeNumber;
  final String monthlyGrossIncome;
  final String monthlyNetIncome;
  final String otherIncome;
  final String otherSourceIncome;
  final String consentCheckbox;
  final String productTypeId;
  final String customerProductTypeId;
  final String idCardTypeId;
  final String genderTypeId;
  final String countryTypeId;
  final String maritalStatusId;
  final String educationalQualificationId;
  final String nationalityTypeId;
  final String selectProductId;
  final String currentCityId;
  final String residentialStatusId;
  final String typeOfAccommodationId;
  final String employmentTypeId;
  final String companyTypeId;
  final String employmentStatusId;
  final String referenceId;
  final String referenceName;
  final String referenceCnic;
  final String referenceMobile;
  final String referenceRelationship;
  final String referenceAddress;
  final String referenceRelationshipId;
  final String mobileNo;
  final String setUserLimit;

  Data({
    required this.productType,
    required this.customerProductType,
    required this.productCode,
    required this.idNumber,
    required this.dateOfBirth,
    required this.idCardType,
    required this.idIssueDate,
    required this.idExpiryDate,
    required this.mName,
    required this.fName,
    required this.lName,
    required this.genderType,
    required this.fatherName,
    required this.motherName,
    required this.personalNumber,
    required this.customerEmail,
    required this.countryType,
    required this.placeOfBirth,
    required this.maritalStatus,
    required this.numberOfDependents,
    required this.educationalQualification,
    required this.nationalityType,
    required this.selectProduct,
    required this.ownCar,
    required this.currentCity,
    required this.permanentAddress,
    required this.telephoneNumber,
    required this.residentialStatus,
    required this.typeOfAccommodation,
    required this.cardDelivery,
    required this.employmentType,
    required this.companyName,
    required this.companyType,
    required this.employmentStatus,
    required this.currentDesignation,
    required this.currentDepartment,
    required this.overallWorkExperience,
    required this.presentExperience,
    required this.designationProfession,
    required this.natureOfBusiness,
    required this.nameOfCompany,
    required this.officeAddress,
    required this.officeCity,
    required this.officeNumber,
    required this.monthlyGrossIncome,
    required this.monthlyNetIncome,
    required this.otherIncome,
    required this.otherSourceIncome,
    required this.consentCheckbox,
    required this.productTypeId,
    required this.customerProductTypeId,
    required this.idCardTypeId,
    required this.genderTypeId,
    required this.countryTypeId,
    required this.maritalStatusId,
    required this.educationalQualificationId,
    required this.nationalityTypeId,
    required this.selectProductId,
    required this.currentCityId,
    required this.residentialStatusId,
    required this.typeOfAccommodationId,
    required this.employmentTypeId,
    required this.companyTypeId,
    required this.employmentStatusId,
    required this.referenceId,
    required this.referenceName,
    required this.referenceCnic,
    required this.referenceMobile,
    required this.referenceRelationship,
    required this.referenceAddress,
    required this.referenceRelationshipId,
    required this.mobileNo,
    required this.setUserLimit,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      productType: json['product_type'] ?? '',
      customerProductType: json['customer_product_type'] ?? '',
      productCode: json['product_code'] ?? '',
      idNumber: json['id_number'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      idCardType: json['id_card_type'] ?? '',
      idIssueDate: json['id_issue_date'] ?? '',
      idExpiryDate: json['id_expiry_date'] ?? '',
      mName: json['m_name'] ?? '',
      fName: json['f_name'] ?? '',
      lName: json['l_name'] ?? '',
      genderType: json['gender_type'] ?? '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      personalNumber: json['personal_number'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      countryType: json['country_type'] ?? '',
      placeOfBirth: json['place_of_birth'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      numberOfDependents: json['number_of_dependents'] ?? '',
      educationalQualification: json['educational_qualification'] ?? '',
      nationalityType: json['nationality_type'] ?? '',
      selectProduct: json['select_Product'] ?? '',
      ownCar: json['own_car'] ?? '',
      currentCity: json['current_city'] ?? '',
      permanentAddress: json['permanent_address'] ?? '',
      telephoneNumber: json['telephone_number'] ?? '',
      residentialStatus: json['residential_status'] ?? '',
      typeOfAccommodation: json['type_of_accommodation'] ?? '',
      cardDelivery: json['card_delivery'] ?? '',
      employmentType: json['employment_type'] ?? '',
      companyName: json['company_name'] ?? '',
      companyType: json['company_type'] ?? '',
      employmentStatus: json['employment_status'] ?? '',
      currentDesignation: json['current_designation'] ?? '',
      currentDepartment: json['current_department'] ?? '',
      overallWorkExperience: json['overall_work_experience'] ?? '',
      presentExperience: json['present_experience'] ?? '',
      designationProfession: json['designation_profession'] ?? '',
      natureOfBusiness: json['nature_of_business'] ?? '',
      nameOfCompany: json['name_of_company'] ?? '',
      officeAddress: json['office_address'] ?? '',
      officeCity: json['office_city'] ?? '',
      officeNumber: json['office_number'] ?? '',
      monthlyGrossIncome: json['monthly_gross_income'] ?? '',
      monthlyNetIncome: json['monthly_net_income'] ?? '',
      otherIncome: json['other_income'] ?? '',
      otherSourceIncome: json['other_source_income'] ?? '',
      consentCheckbox: json['consent_checkbox'] ?? '',
      productTypeId: json['product_type_id'] ?? '',
      customerProductTypeId: json['customer_product_type_id'] ?? '',
      idCardTypeId: json['id_card_type_id'] ?? '',
      genderTypeId: json['gender_type_id'] ?? '',
      countryTypeId: json['country_type_id'] ?? '',
      maritalStatusId: json['marital_status_id'] ?? '',
      educationalQualificationId: json['educational_qualification_id'] ?? '',
      nationalityTypeId: json['nationality_type_id'] ?? '',
      selectProductId: json['select_Product_id'] ?? '',
      currentCityId: json['current_city_id'] ?? '',
      residentialStatusId: json['residential_status_id'] ?? '',
      typeOfAccommodationId: json['type_of_accommodation_id'] ?? '',
      employmentTypeId: json['employment_type_id'] ?? '',
      companyTypeId: json['company_type_id'] ?? '',
      employmentStatusId: json['employment_status_id'] ?? '',
      referenceId: json['reference_id'] ?? '',
      referenceName: json['reference_name'] ?? '',
      referenceCnic: json['reference_cnic'] ?? '',
      referenceMobile: json['reference_mobile'] ?? '',
      referenceRelationship: json['reference_relationship'] ?? '',
      referenceAddress: json['reference_address'] ?? '',
      referenceRelationshipId: json['reference_relationship_id'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      setUserLimit: json['set_user_limit'] ?? '',
    );
  }
}
