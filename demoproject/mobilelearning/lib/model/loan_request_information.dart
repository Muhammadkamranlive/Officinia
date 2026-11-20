class LoanRequestInformation {
  int requestId;
  int stepsCompleted;
  String status;

  LoanRequestInformation(this.requestId, this.stepsCompleted, this.status);

  Map<String, dynamic> toMap() {
    return {"stepsCompleted": stepsCompleted, "status": status};
  }
}
