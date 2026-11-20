// lib/Server/Model/PaymentConfig.dart

/// All payment configuration is stored in a single Firestore document:
///
/// ```
/// app_config/payment_config
///   testMode        : bool
///   testSecretKey   : String
///   cloudFunctionUrl: String
///   webhookUrl      : String
///   successUrl      : String
///   failureUrl      : String
///   annualFee       : double
///   currency        : String        (e.g. "dzd")
///   locale          : String        (e.g. "en")
///   planName        : String        (e.g. "Annual Pharmacy Recruiter Plan")
///   planSubtitle    : String
///   planDescription : String
///   features        : List<String>
///   disclaimer      : String
///   updatedAt       : Timestamp
/// ```
class PaymentConfig {
  final bool   testMode;
  final String testSecretKey;
  final String cloudFunctionUrl;
  final String webhookUrl;
  final String successUrl;
  final String failureUrl;
  final double annualFee;
  final String currency;
  final String locale;

  // ── UI strings (editable from Firestore without app update) ───────────────
  final String       planName;
  final String       planSubtitle;
  final String       planDescription;
  final List<String> features;
  final String       disclaimer;

  const PaymentConfig({
    required this.testMode,
    required this.testSecretKey,
    required this.cloudFunctionUrl,
    required this.webhookUrl,
    required this.successUrl,
    required this.failureUrl,
    required this.annualFee,
    required this.currency,
    required this.locale,
    required this.planName,
    required this.planSubtitle,
    required this.planDescription,
    required this.features,
    required this.disclaimer,
  });

  /// Safe fallback used while Firestore is loading.
  factory PaymentConfig.defaults() => const PaymentConfig(
    testMode:         true,
    testSecretKey:    '',
    cloudFunctionUrl: '',
    webhookUrl:       '',
    successUrl:       'https://officina-payment.web.app',
    failureUrl:       'https://officina-payment.web.app/failure.html',
    annualFee:        12000.0,
    currency:         'dzd',
    locale:           'en',
    planName:         'Annual Pharmacy Recruiter Plan',
    planSubtitle:     'Post pharmacy job listings for 12 months',
    planDescription:
    'Full access to pharmacy hiring tools and verified candidate profiles for one year.',
    features: [
      'Post pharmacy job listings (pharmacist, gérant, sales, etc.)',
      'Browse verified pharmacy professional profiles',
      'Receive and manage candidate applications',
      'Priority placement in candidate search results',
      'Dedicated support for pharmacy recruitment',
    ],
    disclaimer:
    'Annual pharmacy recruitment service billed once per year. '
        'Managed through your Officina pharmacy business account.',
  );

  factory PaymentConfig.fromMap(Map<String, dynamic> map) {
    return PaymentConfig(
      testMode:         map['testMode']         as bool?   ?? true,
      testSecretKey:    map['testSecretKey']     as String? ?? '',
      cloudFunctionUrl: map['cloudFunctionUrl']  as String? ?? '',
      webhookUrl:       map['webhookUrl']        as String? ?? '',
      successUrl:       map['successUrl']        as String? ??
          'https://officina-payment.web.app',
      failureUrl:       map['failureUrl']        as String? ??
          'https://officina-payment.web.app/failure.html',
      annualFee:        (map['annualFee']        as num?)?.toDouble() ?? 12000.0,
      currency:         map['currency']          as String? ?? 'dzd',
      locale:           map['locale']            as String? ?? 'en',
      planName:         map['planName']          as String? ??
          'Annual Pharmacy Recruiter Plan',
      planSubtitle:     map['planSubtitle']      as String? ??
          'Post pharmacy job listings for 12 months',
      planDescription:  map['planDescription']   as String? ?? '',
      features: (map['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      disclaimer: map['disclaimer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'testMode':         testMode,
    'testSecretKey':    testSecretKey,
    'cloudFunctionUrl': cloudFunctionUrl,
    'webhookUrl':       webhookUrl,
    'successUrl':       successUrl,
    'failureUrl':       failureUrl,
    'annualFee':        annualFee,
    'currency':         currency,
    'locale':           locale,
    'planName':         planName,
    'planSubtitle':     planSubtitle,
    'planDescription':  planDescription,
    'features':         features,
    'disclaimer':       disclaimer,
  };
}