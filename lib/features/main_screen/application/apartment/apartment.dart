class Apartment {
  final String block;
  final int doorNumber;
  final String status;
  final String? interests;
  final String? job;

  Map<String, dynamic> toMap() {
    return {
      "block": block,
      "doorNumber": doorNumber,
      "status": status,
      "interests": interests,
      "job": job,
    };
  }

  factory Apartment.fromMap(Map<String, dynamic> data) {
    return Apartment(
      block: data["block"] as String,
      doorNumber: data["doorNumber"] as int,
      status: data["status"] as String,
      interests: data["interests"] as String?,
      job: data["job"] as String?,
    );
  }

  Apartment({
    required this.block,
    required this.doorNumber,
    required this.status,
    this.interests,
    this.job,
  });
}
