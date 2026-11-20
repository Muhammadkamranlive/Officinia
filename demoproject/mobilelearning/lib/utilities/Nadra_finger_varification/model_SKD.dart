class FingerCaptureResponse {
  final Map<String, FingerData>? data;

  FingerCaptureResponse({this.data});

  factory FingerCaptureResponse.fromJson(Map<String, dynamic> json) {
    return FingerCaptureResponse(
      data: (json['data'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, FingerData.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class FingerData {
  // final DateTime? date;
  final int? captureTimeTaken;
  final int? overallTimeTaken;
  final int? processingTimeTaken;
  final String? hand;
  final String? finger;
  final int? identyQuality;
  final int? fingerprintQuality;
  final int? height;
  final int? width;
  final int? bitsPerPixel;
  final String? resolution;
  final int? nfiq1;
  final double? spoofScore;
  final Templates? templates;

  FingerData({
    // this.date,
    this.captureTimeTaken,
    this.overallTimeTaken,
    this.processingTimeTaken,
    this.hand,
    this.finger,
    this.identyQuality,
    this.fingerprintQuality,
    this.height,
    this.width,
    this.bitsPerPixel,
    this.resolution,
    this.nfiq1,
    this.spoofScore,
    this.templates,
  });

  factory FingerData.fromJson(Map<String, dynamic> json) {
    return FingerData(
      // date: json['date'] != null ? DateTime.parse(json['date']) : null,
      captureTimeTaken: json['captureTimeTaken'] as int?,
      overallTimeTaken: json['overallTimeTaken'] as int?,
      processingTimeTaken: json['processingTimeTaken'] as int?,
      hand: json['hand'] as String?,
      finger: json['finger'] as String?,
      identyQuality: json['identy_quality'] as int?,
      fingerprintQuality: json['fingerprintQuality'] as int?,
      height: json['height'] as int?,
      width: json['width'] as int?,
      bitsPerPixel: json['bits_per_pixel'] as int?,
      resolution: json['resolution'] as String?,
      nfiq1: json['nfiq_1'] as int?,
      spoofScore: (json['spoof_score'] != null)
          ? (json['spoof_score'] as num).toDouble()
          : null,
      templates: json['templates'] != null
          ? Templates.fromJson(json['templates'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'date': date?.toIso8601String(),
      'captureTimeTaken': captureTimeTaken,
      'overallTimeTaken': overallTimeTaken,
      'processingTimeTaken': processingTimeTaken,
      'hand': hand,
      'finger': finger,
      'identy_quality': identyQuality,
      'fingerprintQuality': fingerprintQuality,
      'height': height,
      'width': width,
      'bits_per_pixel': bitsPerPixel,
      'resolution': resolution,
      'nfiq_1': nfiq1,
      'spoof_score': spoofScore,
      'templates': templates?.toJson(),
    };
  }
}

class Templates {
  final Iso197942? iso197942;
  Templates({this.iso197942});

  factory Templates.fromJson(Map<String, dynamic> json) {
    return Templates(
      iso197942: json['ISO_19794_2'] != null
          ? Iso197942.fromJson(json['ISO_19794_2'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ISO_19794_2': iso197942?.toJson(),
    };
  }
}

class Iso197942 {
  // Renamed 'DEFAULT' to 'defaultValue'
  final String? defaultValue;
  Iso197942({this.defaultValue});

  factory Iso197942.fromJson(Map<String, dynamic> json) {
    return Iso197942(
      defaultValue: json['DEFAULT'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DEFAULT': defaultValue,
    };
  }
}
