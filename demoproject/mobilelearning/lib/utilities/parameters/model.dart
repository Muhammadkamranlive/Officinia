class Policy {
  final int id;
  final n_VALUE;
  final bool pnameValue;

  Policy({required this.id, required this.pnameValue,required this.n_VALUE});

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'],
      n_VALUE: json['n_VALUE'],
      pnameValue: json['b_VALUE'] == 1,
    );
  }
}