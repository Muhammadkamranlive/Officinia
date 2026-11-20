class ReferenceData {
  String referenceId;
  String referenceName;
  String referenceCNIC;
  String referenceMobile;
  String referenceRelationship;
  String referenceAddress;
  String referenceRelationshipID;

  ReferenceData(this.referenceId, this.referenceName, this.referenceCNIC, this.referenceMobile,
      this.referenceRelationship, this.referenceAddress, this.referenceRelationshipID);

  Map<String, dynamic> toJson() => {
    "reference_id": referenceId,
    "reference_name": referenceName,
    "reference_cnic": referenceCNIC,
    "reference_mobile": referenceMobile,
    "reference_relationship": referenceRelationship,
    "reference_address": referenceAddress,
    "reference_relationship_id": referenceRelationshipID
  };
}
