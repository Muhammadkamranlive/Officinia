// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_title => 'Ophicina';

  @override
  String get tagline => 'فرصتك هنا';

  @override
  String get role_job_seeker => 'باحث عن عمل';

  @override
  String get role_recruiter => 'صاحب عمل';

  @override
  String get onboarding_title => 'مرحباً بك في أوفيسينا';

  @override
  String get onboarding_subtitle =>
      'ربط المتخصصين في مجال الصيدلة بالفرص المناسبة.';

  @override
  String get login_title => 'تسجيل الدخول إلى أوفيسينا';

  @override
  String get login_subtitle_email => 'تسجيل دخول آمن باستخدام بريدك الإلكتروني';

  @override
  String get login_subtitle_phone => 'تسجيل دخول آمن باستخدام رقم هاتفك';

  @override
  String get email_label => 'البريد الإلكتروني';

  @override
  String get password_label => 'كلمة المرور';

  @override
  String get forgot_password => 'هل نسيت كلمة المرور؟';

  @override
  String get sign_in_button => 'تسجيل الدخول';

  @override
  String get create_account => 'إنشاء حساب جديد';

  @override
  String get welcome_to_ophicina => 'مرحباً بك في أوفيسينا';

  @override
  String get signup_subtitle => 'انضم إلى شبكة المحترفين في قطاع الصحة';

  @override
  String get confirm_password_label => 'تأكيد كلمة المرور';

  @override
  String get already_have_account => 'لديك حساب بالفعل؟';

  @override
  String get join_ophicina => 'انضم إلى أوفيسينا';

  @override
  String get join_subtitle => 'أنشئ حساباً لاكتشاف الفرص المتاحة';

  @override
  String get signup_with_email => 'تسجيل عبر البريد الإلكتروني';

  @override
  String get signup_with_google => 'تسجيل عبر جوجل';

  @override
  String get signup_with_apple => 'تسجيل عبر أبل';

  @override
  String get deletion_queue_error =>
      'طلب حذف حسابك قيد المعالجة. يرجى استخدام بريد أو هاتف آخر.';

  @override
  String get email_required => 'البريد الإلكتروني مطلوب';

  @override
  String get valid_email_error => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get password_required => 'كلمة المرور مطلوبة';

  @override
  String get password_format_error =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل، وتشمل حرفاً كبيراً وصغيراً ورقماً';

  @override
  String get confirm_password_required => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwords_dont_match => 'كلمات المرور غير متطابقة';

  @override
  String get signup_successful => 'تم التسجيل بنجاح!';

  @override
  String get enter_valid_email => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get enter_password => 'يرجى إدخال كلمة المرور';

  @override
  String get enter_phone => 'أدخل رقم الهاتف';

  @override
  String get enter_valid_algerian =>
      'أدخل رقم هاتف جزائري صحيح (يبدأ بـ 5 أو 6 أو 7 متبوعاً بـ 8 أرقام)';

  @override
  String get enter_valid_pakistani =>
      'أدخل رقم هاتف باكستاني صحيح (يبدأ بـ 3 متبوعاً بـ 9 أرقام)';

  @override
  String otp_sent_to(String phone) {
    return 'تم إرسال رمز التحقق إلى $phone';
  }

  @override
  String get otp_not_sent => 'لم يتم إرسال الرمز بعد';

  @override
  String get otp_complete => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get account_not_found => 'لم يتم العثور على حسابك، يرجى التسجيل أولاً';

  @override
  String get login_here => 'تسجيل الدخول هنا';

  @override
  String get login_subtitle_welcome =>
      'ادخل إلى حسابك في أوفيسينا بأمان بالطريقة التي تفضلها';

  @override
  String get login_with_email => 'تسجيل الدخول بالبريد الإلكتروني';

  @override
  String get login_with_google => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get login_with_apple => 'تسجيل الدخول باستخدام أبل';

  @override
  String get sign_in => 'دخول';

  @override
  String get sign_up => 'تسجيل';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get french => 'الفرنسية';

  @override
  String get arabic => 'العربية';

  @override
  String hi_user(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get my_account => 'حسابي';

  @override
  String get post_job => 'نشر وظيفة';

  @override
  String get post_job_desc =>
      'الوصول إلى الصيادلة من خلال إدراج وظائفك الشاغرة';

  @override
  String get edit_profile => 'تعديل الملف الشخصي';

  @override
  String get edit_profile_desc => 'تعديل الملف الشخصي وتفاصيل الصيدلية';

  @override
  String get report_issue => 'الإبلاغ عن مشكلة';

  @override
  String get report_issue_desc => 'الإبلاغ عن الأخطاء والمشاكل';

  @override
  String get reported_issues => 'المشاكل المبلغ عنها';

  @override
  String get reported_issues_desc => 'عرض مشاكلك المبلغ عنها';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logout_desc => 'تسجيل الخروج من حسابك';

  @override
  String get delete_account => 'حذف الحساب';

  @override
  String get delete_account_desc => 'سيؤدي هذا إلى حذف حسابك';

  @override
  String get jobs_status_overview => 'نظرة عامة على حالة عروض العمل';

  @override
  String jobs_open_count(int active, int total) {
    return 'لديك حاليًا $active من أصل $total وظائف مفتوحة';
  }

  @override
  String get manage_account => 'إدارة الحساب';

  @override
  String get active => 'نشط';

  @override
  String get open_jobs => 'الوظائف المفتوحة';

  @override
  String open_jobs_count(int open, int total) {
    return '$open من أصل $total مفتوحة';
  }

  @override
  String get filled_positions => 'الوظائف المملوءة';

  @override
  String filled_positions_count(int filled, int total) {
    return '$filled من أصل $total مملوءة';
  }

  @override
  String get skill_verification_requests => 'طلبات التحقق من المهارات';

  @override
  String pending_requests_count(int count) {
    return '$count طلبات معلقة';
  }

  @override
  String get view => 'عرض';

  @override
  String get hiring_activity => 'نشاط التوظيف الخاص بك';

  @override
  String get review_profiles => 'مراجعة الملفات الشخصية';

  @override
  String reviewed_count(int reviewed, int total) {
    return 'تمت المراجعة: $reviewed/$total';
  }

  @override
  String get chat_card => 'دردشة';

  @override
  String read_count(int read, int total) {
    return 'تمت القراءة: $read/$total';
  }

  @override
  String get all_time_job_stats => 'إحصائيات عروض العمل في كل الأوقات';

  @override
  String get no_job_offers_stats => 'لا توجد عروض عمل متاحة لعرض الإحصائيات.';

  @override
  String get no_stats_available => 'لا توجد إحصائيات متاحة';

  @override
  String get candidates => 'المرشحون';

  @override
  String candidates_count(int count) {
    return '$count مرشحاً';
  }

  @override
  String get upcoming_hiring_actions => 'إجراءات التوظيف القادمة';

  @override
  String get see_all => 'عرض الكل';

  @override
  String get create_account_title => 'إنشاء حساب';

  @override
  String get edit_profile_title => 'تعديل الملف الشخصي';

  @override
  String get my_account_title => 'حسابي';

  @override
  String get update_profile_picture => 'تحديث صورة الملف الشخصي';

  @override
  String get personal_information => 'المعلومات الشخصية';

  @override
  String get first_name => 'الاسم الأول';

  @override
  String get first_name_hint => 'أنابيلا';

  @override
  String get last_name => 'اسم العائلة';

  @override
  String get last_name_hint => 'أنجيلا';

  @override
  String get pharmacy_location_title => 'الصيدلية والموقع';

  @override
  String get pharmacy_name => 'اسم الصيدلية';

  @override
  String get pharmacy_name_hint => 'صيدلية جرين كير';

  @override
  String get wilaya => 'الولاية';

  @override
  String get select_province => 'اختر الولاية';

  @override
  String get city => 'المدينة';

  @override
  String get select_province_first => 'اختر الولاية أولاً';

  @override
  String get loading_dots => 'جاري التحميل...';

  @override
  String get select_city => 'اختر المدينة';

  @override
  String get pharmacy_location_tile => 'موقع الصيدلية';

  @override
  String get tap_to_set_location => 'اضغط للتحديد على الخريطة';

  @override
  String get set_btn => 'تعيين';

  @override
  String get change_btn => 'تغيير';

  @override
  String get save_changes => 'حفظ التغييرات';

  @override
  String get create_account_btn => 'إنشاء حساب';

  @override
  String get all_rights_reserved => 'جميع الحقوق محفوظة';

  @override
  String get profile_photo_title => 'صورة الملف الشخصي';

  @override
  String get crop_photo => 'قص الصورة';

  @override
  String get profile_picture_updated => 'تم تحديث صورة الملف الشخصي';

  @override
  String failed_to_update(String error) {
    return 'فشل: $error';
  }

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get remove_photo => 'إزالة الصورة';

  @override
  String get save_btn => 'حفظ';

  @override
  String get change_action => 'تغيير';

  @override
  String get recrop_action => 'إعادة القص';

  @override
  String get add_profile_photo_btn => 'إضافة صورة ملف شخصي';

  @override
  String get normal_filter => 'عادي';

  @override
  String get verify_jobseeker_skills_title => 'التحقق من مهارات الباحث عن عمل';

  @override
  String get failed_to_load_requests => 'فشل تحميل الطلبات';

  @override
  String get no_pending_skill_requests => 'لا توجد طلبات مهارة معلقة';

  @override
  String get anonymous_candidate => 'مرشح مجهول';

  @override
  String get verify_skills_btn => 'التحقق من المهارات';

  @override
  String get skill_verification_completed_notif_title =>
      'اكتمل التحقق من المهارات';

  @override
  String get skill_verification_completed_notif_desc =>
      'تمت مراجعة مهاراتك من قبل صاحب العمل.';

  @override
  String get skills_to_review_label => 'مهارات للمراجعة';

  @override
  String get note_from_jobseeker_label => 'ملاحظة من الباحث عن عمل';

  @override
  String get no_note_provided => 'لم يتم تقديم أي ملاحظة من الباحث عن عمل.';

  @override
  String get mark_verification_completed_btn => 'تحديد التحقق كمكتمل';

  @override
  String get all_skills_reviewed_msg =>
      'تمت مراجعة جميع المهارات بالفعل لهذا الباحث عن عمل.';

  @override
  String get pending_review_status => 'قيد المراجعة';

  @override
  String get phone_label => 'الهاتف';

  @override
  String get city_label => 'المدينة';

  @override
  String get education_label => 'التعليم';

  @override
  String get experience_label => 'الخبرة';

  @override
  String get wilaya_label => 'الولاية';

  @override
  String get na_value => 'غير متوفر';

  @override
  String get verify_action => 'تحقق';

  @override
  String get reject_action => 'رفض';

  @override
  String verified_count_label(Object count) {
    return '$count تم التحقق منها';
  }

  @override
  String rejected_count_label(Object count) {
    return '$count مرفوضة';
  }

  @override
  String get closed_jobs => 'الوظائف المغلقة';

  @override
  String get view_details => 'عرض التفاصيل';

  @override
  String get job_type_label => 'نوع الوظيفة';

  @override
  String get open_status => 'مفتوحة';

  @override
  String get closed_status => 'مغلقة';

  @override
  String get edit_job => 'تعديل الوظيفة';

  @override
  String get delete_job => 'حذف الوظيفة';

  @override
  String get close_job => 'إغلاق الوظيفة';

  @override
  String get delete_job_confirm_title => 'حذف الوظيفة';

  @override
  String get delete_job_confirm_msg =>
      'هل تريد حقاً حذف هذه الوظيفة؟\n\nهذا الإجراء دائم ولن تتمكن من استعادة هذه الوظيفة.';

  @override
  String get close_job_confirm_title => 'إغلاق الوظيفة';

  @override
  String get close_job_confirm_msg =>
      'هل تريد حقاً إغلاق هذه الوظيفة؟\n\nبمجرد إغلاقها، لن تكون هذه الوظيفة نشطة للمتقدمين.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get no_job_offers_yet => 'لا توجد عروض عمل بعد';

  @override
  String get create_first_job_offer => 'أنشئ أول عرض عمل لك للبدء';

  @override
  String get posted_jobs => 'الوظائف المنشورة';

  @override
  String get just_now => 'الآن';

  @override
  String min_ago(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hours_ago(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String days_ago(int count) {
    return 'منذ $count يوم';
  }

  @override
  String weeks_ago(int count) {
    return 'منذ $count أسبوع';
  }

  @override
  String months_ago(int count) {
    return 'منذ $count شهر';
  }

  @override
  String years_ago(int count) {
    return 'منذ $count سنة';
  }

  @override
  String get per_year => '/ سنة';

  @override
  String get k_per_year => 'ألف / سنة';

  @override
  String get m_per_year => 'مليون / سنة';

  @override
  String get job_title_pharmacist => 'صيدلي';

  @override
  String get job_title_gerant => 'مسير';

  @override
  String get job_title_physician => 'طبيب';

  @override
  String get job_title_senior_salesperson => 'بائع أول';

  @override
  String get job_title_sales_specialist => 'إخصائي مبيعات';

  @override
  String get job_title_intern => 'متربص';

  @override
  String get job_title_labeling_specialist => 'إخصائي وسم';

  @override
  String get job_title_data_entry_specialist => 'إخصائي إدخال بيانات';

  @override
  String get job_title_stock_management_specialist => 'إخصائي إدارة مخزون';

  @override
  String get job_type_full_time => 'دوام كامل';

  @override
  String get job_type_part_time => 'دوام جزئي';

  @override
  String get job_type_replacement => 'تعويض/استخلاف';

  @override
  String get chats => 'المحادثات';

  @override
  String get search_chats => 'البحث في المحادثات';

  @override
  String get no_chats_yet => 'لا توجد محادثات بعد';

  @override
  String you(String message) {
    return 'أنت: $message';
  }

  @override
  String get typing => 'يكتب...';

  @override
  String get no_messages_yet => 'لا توجد رسائل بعد';

  @override
  String get type_a_message => 'اكتب رسالة...';

  @override
  String get please_select_job_title => 'الرجاء تحديد المسمى الوظيفي.';

  @override
  String get please_select_job_type => 'الرجاء تحديد نوع الوظيفة.';

  @override
  String get please_add_skill => 'الرجاء إضافة مهارة واحدة على الأقل.';

  @override
  String get recruiter_profile_not_found =>
      'لم يتم العثور على ملف تعريف صاحب العمل.';

  @override
  String get account_not_active =>
      'حسابك غير نشط. يرجى تسجيل الخروج وتسجيل الدخول مرة أخرى أو الاتصال بالدعم.';

  @override
  String get active_listing_required =>
      'مطلوب فترة إدراج نشطة لنشر وظائف الصيدلية الشاغرة.';

  @override
  String get select_skills => 'تحديد المهارات';

  @override
  String get no_skills_available => 'لا توجد مهارات متاحة';

  @override
  String get create_job_offer => 'إنشاء عرض عمل';

  @override
  String get edit_job_offer => 'تعديل عرض العمل';

  @override
  String get job_details => 'تفاصيل الوظيفة';

  @override
  String get job_details_desc => 'املأ التفاصيل لنشر عرض العمل الخاص بك';

  @override
  String get job_title => 'المسمى الوظيفي';

  @override
  String get job_type => 'نوع الوظيفة';

  @override
  String get required_skills => 'المهارات المطلوبة';

  @override
  String get required_skills_desc =>
      'أضف المهارات التي يجب أن يتمتع بها المرشحون';

  @override
  String get add_skills => 'إضافة مهارات';

  @override
  String get post_job_btn => 'نشر الوظيفة';

  @override
  String get update_job_btn => 'تحديث الوظيفة';

  @override
  String get search_skills_or_positions => 'البحث عن مهارات أو مناصب…';

  @override
  String no_matches_for_query(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get skill => 'مهارة';

  @override
  String get position => 'منصب';

  @override
  String get clear_all => 'مسح الكل';

  @override
  String get clear_text => 'مسح';

  @override
  String show_profiles_selected_count(int count) {
    return 'عرض الملفات الشخصية · حدد $count';
  }

  @override
  String get show_all_profiles => 'عرض جميع الملفات الشخصية';

  @override
  String get job_seeker_profiles => 'ملفات الباحثين عن عمل';

  @override
  String get job_seeker_location => 'موقع الباحث عن عمل';

  @override
  String get candidate_location => 'موقع المرشح';

  @override
  String get location_not_shared => 'لم يتم مشاركة الموقع';

  @override
  String get location_not_shared_desc => 'لم يشارك الباحث عن عمل\nموقعه بعد.';

  @override
  String get verified_skills => 'مهارات موثقة';

  @override
  String get unverified => 'غير موثق';

  @override
  String get skills => 'المهارات';

  @override
  String get contact_and_location => 'الاتصال والموقع';

  @override
  String get block_profile => 'حظر الملف الشخصي';

  @override
  String get block_user_account => 'حظر حساب المستخدم';

  @override
  String get block_user_reason_desc =>
      'يرجى تقديم سبب. سيتم عرض هذه الرسالة للمستخدم.';

  @override
  String get enter_block_reason => 'أدخل سبب الحظر...';

  @override
  String get reason_is_required => 'السبب مطلوب';

  @override
  String get confirm_block => 'تأكيد الحظر';

  @override
  String get user_account_blocked => 'تم حظر حساب المستخدم';

  @override
  String profiles_on_map(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملفات شخصية على الخريطة',
      one: '1 ملف شخصي على الخريطة',
    );
    return '$_temp0';
  }

  @override
  String get tap_pin_or_scroll => 'انقر على الدبوس أو قم بالتمرير أدناه';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get no_skills_listed => 'لا توجد مهارات مدرجة';

  @override
  String plus_more_count(int count) {
    return '+$count أكثر';
  }

  @override
  String get view_profile => 'عرض الملف الشخصي';

  @override
  String get no_profiles_match_filters =>
      'لا توجد ملفات شخصية تطابق عوامل التصفية';

  @override
  String get filter_profiles_hint => 'تصفية الملفات الشخصية…';

  @override
  String active_filters_count(int count) {
    return '$count نشط';
  }

  @override
  String get show_results => 'عرض النتائج';

  @override
  String get search_wilaya => 'ابحث عن ولاية…';

  @override
  String get address => 'العنوان';

  @override
  String get district => 'المنطقة';

  @override
  String get experience => 'الخبرة';

  @override
  String get education => 'التعليم';

  @override
  String get chat => 'محادثة';

  @override
  String get no_profiles_location_hint =>
      'لم يقم أي ملف شخصي بمشاركة موقعه بعد';

  @override
  String get notifications => 'الإشعارات';

  @override
  String notifications_unread(int count) {
    return '$count غير مقروءة';
  }

  @override
  String get mark_all_read => 'تحديد الكل كمقروء';

  @override
  String get all_notifications_marked_as_read =>
      'تم تحديد جميع الإشعارات كمقروءة';

  @override
  String get no_notifications_title => 'لا توجد إشعارات بعد';

  @override
  String get no_notifications_subtitle => 'لقد قرأت كل شيء!';

  @override
  String get notification_detail => 'تفاصيل الإشعار';

  @override
  String get job_not_found_error => 'لم يتم العثور على الوظيفة أو تم حذفها.';

  @override
  String get see_skill_requests => 'عرض طلبات المهارات';

  @override
  String get view_my_applications => 'عرض طلباتي';

  @override
  String get view_job => 'عرض الوظيفة';

  @override
  String get type_login => 'تسجيل الدخول';

  @override
  String get type_logout => 'تسجيل الخروج';

  @override
  String get type_payment => 'الدفع';

  @override
  String get type_job_post => 'منشور وظيفة';

  @override
  String get type_application => 'طلب توظيف';

  @override
  String get type_skill_verified => 'تم التحقق من المهارة';

  @override
  String get type_message => 'رسالة';

  @override
  String get type_general => 'عام';

  @override
  String get post_job_appbar_title => 'نشر وظيفة';

  @override
  String get test_mode_badge => 'وضع الاختبار';

  @override
  String get submitting_listing_request_banner =>
      'جاري إرسال طلب الإدراج... يرجى الانتظار.';

  @override
  String get test_mode_banner_title => 'وضع الاختبار - لا يتم خصم أموال حقيقية';

  @override
  String get test_card_details_label => 'تفاصيل بطاقة الاختبار (الذهبية):';

  @override
  String get test_card_number_label => 'رقم البطاقة';

  @override
  String get test_card_expiry_label => 'تاريخ الانتهاء';

  @override
  String get test_card_future_date_label => 'أي تاريخ مستقبلي';

  @override
  String get test_card_otp_label => 'رمز التحقق';

  @override
  String get active_plan_label => 'خطة نشطة';

  @override
  String get no_active_plan_label => 'لا توجد خطة نشطة';

  @override
  String annual_job_listing_title(int year) {
    return 'إدراج وظيفة سنوي - صيدلية $year';
  }

  @override
  String get list_vacancy_hint_subtitle =>
      'أدرج وظيفة شاغرة للوصول إلى الصيادلة المعتمدين';

  @override
  String get payment_expires_label => 'تنتهي في';

  @override
  String get payment_days_left_label => 'الأيام المتبقية';

  @override
  String payment_days_count(int count) {
    return '$count أيام';
  }

  @override
  String get payment_paid_label => 'مدفوع';

  @override
  String get payment_method_label => 'الطريقة';

  @override
  String get payment_method_edahabia => 'EDAHABIA';

  @override
  String get payment_method_cib => 'CIB';

  @override
  String get payment_method_unknown => '—';

  @override
  String listing_expires_warning_banner(int days) {
    return 'تنتهي صلاحية إدراج وظيفتك خلال $days أيام. أعد الإدراج لتبقى مرئيًا.';
  }

  @override
  String get list_pharmacy_vacancy_btn => 'أدرج وظيفة صيدلية شاغرة';

  @override
  String get list_another_vacancy_btn => 'أدرج وظيفة شاغرة أخرى';

  @override
  String get job_posting_history_title => 'سجل نشر الوظائف';

  @override
  String get payment_test_success_toast =>
      'نجح دفع الاختبار. تم تفعيل إدراج الوظيفة.';

  @override
  String get payment_success_toast =>
      'تم تفعيل إدراج الوظيفة. وظيفتك الشاغرة مرئية الآن للصيادلة.';

  @override
  String get submit_listing_request_error =>
      'تعذر إرسال طلب الإدراج الخاص بك. يرجى المحاولة مرة أخرى.';

  @override
  String get payment_connection_error =>
      'خطأ في الاتصال. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String listing_request_failed_error(String message) {
    return 'فشل طلب الإدراج: $message';
  }

  @override
  String get listing_service_unreachable_error =>
      'تعذر الوصول إلى خدمة الإدراج. حاول مرة أخرى.';

  @override
  String get payment_generic_error => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get payment_incomplete_error =>
      'لم يكتمل الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get report_issue_title => 'إبلاغ عن مشكلة';

  @override
  String get edit_issue_title => 'تعديل المشكلة';

  @override
  String get issue_details_label => 'تفاصيل المشكلة';

  @override
  String get issue_title_label => 'العنوان';

  @override
  String get issue_title_hint => 'ملخص قصير للمشكلة';

  @override
  String get issue_category_label => 'الفئة';

  @override
  String get issue_priority_label => 'الأولوية';

  @override
  String get issue_description_label => 'الوصف';

  @override
  String get issue_description_hint => 'اشرح المشكلة بالتفصيل';

  @override
  String get admin_comment_label => 'تعليق المسؤول';

  @override
  String get submit_issue_btn => 'إرسال المشكلة';

  @override
  String get update_issue_btn => 'تحديث المشكلة';

  @override
  String get enter_issue_title_error => 'يرجى إدخال عنوان المشكلة';

  @override
  String get select_category_error => 'يرجى اختيار الفئة';

  @override
  String get describe_issue_error => 'يرجى وصف المشكلة';

  @override
  String get reported_issues_admin_title => 'المشاكل المبلغ عنها';

  @override
  String get my_reported_issues_title => 'بلاغاتي عن المشاكل';

  @override
  String get failed_load_issues_error => 'فشل تحميل المشاكل';

  @override
  String get no_issues_reported_title => 'لا توجد مشاكل مبلغ عنها بعد';

  @override
  String get report_problem_hint =>
      'إذا كنت تواجه أي مشكلة، فقم بالإبلاغ عنها هنا.';

  @override
  String get cat_crash => 'تعطل';

  @override
  String get cat_ui_issue => 'مشكلة في الواجهة';

  @override
  String get cat_performance => 'الأداء';

  @override
  String get cat_payment => 'الدفع';

  @override
  String get cat_login_auth => 'تسجيل الدخول / المصادقة';

  @override
  String get cat_other => 'أخرى';

  @override
  String get priority_low => 'منخفضة';

  @override
  String get priority_medium => 'متوسطة';

  @override
  String get priority_high => 'عالية';

  @override
  String get priority_critical => 'حرجة';

  @override
  String get status_open => 'مفتوح';

  @override
  String get status_in_progress => 'قيد المعالجة';

  @override
  String get status_resolved => 'تم الحل';

  @override
  String get status_rejected => 'مرفوض';

  @override
  String get issue_details_title => 'تفاصيل المشكلة';

  @override
  String get description_label => 'الوصف';

  @override
  String get response_label => 'الرد';

  @override
  String get user_not_found_error => 'لم يتم العثور على المستخدم';

  @override
  String get reply_btn => 'رد';

  @override
  String get anonymous_job_seeker => 'باحث عن عمل مجهول';

  @override
  String get active_recruiter => 'موظف نشط';

  @override
  String get inactive_recruiter => 'موظف غير نشط';

  @override
  String get joined_label => 'انضم في';

  @override
  String get notif_job_posted_title => 'تم نشر الوظيفة';

  @override
  String notif_job_posted_desc(String jobTitle) {
    return 'لقد قمت بنشر وظيفة جديدة: $jobTitle';
  }

  @override
  String get notif_job_apply_title => 'طلب توظيف جديد';

  @override
  String notif_job_apply_desc(String jobTitle) {
    return 'لديك طلب توظيف جديد لوظيفة $jobTitle';
  }

  @override
  String get notif_skill_verified_title => 'تم التحقق من المهارة';

  @override
  String notif_skill_verified_desc(String skillName) {
    return 'تم التحقق من مهارتك $skillName';
  }

  @override
  String get notif_payment_success_title => 'تم الدفع بنجاح';

  @override
  String notif_payment_success_desc(String planName) {
    return 'تم دفع اشتراك $planName بنجاح';
  }

  @override
  String get notif_login_title => 'تنبيه تسجيل الدخول';

  @override
  String notif_login_desc(String time) {
    return 'لقد قمت بتسجيل الدخول في $time';
  }

  @override
  String get notif_logout_title => 'تسجيل الخروج';

  @override
  String get notif_logout_desc => 'لقد تم تسجيل خروجك';

  @override
  String get notif_issue_reported_title => 'تم الإبلاغ عن المشكلة';

  @override
  String notif_issue_reported_desc(String title) {
    return 'تم الإبلاغ عن مشكلتك \'$title\' بنجاح.';
  }

  @override
  String get notif_issue_resolved_title => 'تم حل المشكلة';

  @override
  String notif_issue_resolved_desc(String title) {
    return 'تم وضع علامة على مشكلتك \'$title\' كـ محلولة.';
  }

  @override
  String get notif_admin_new_issue_title => 'تم الإبلاغ عن مشكلة جديدة';

  @override
  String notif_admin_new_issue_desc(String title) {
    return 'قام أحد المستخدمين بالإبلاغ عن مشكلة جديدة \'$title\'.';
  }

  @override
  String get notif_admin_issue_resolved_title => 'تم حل المشكلة';

  @override
  String notif_admin_issue_resolved_desc(String title) {
    return 'تم حل المشكلة \'$title\'.';
  }

  @override
  String get apply_btn => 'تقدم للوظيفة';

  @override
  String get applied_btn => 'تم التقدم';

  @override
  String get hire_query_btn => 'توظيف ؟';

  @override
  String get hire_btn => 'توظيف';

  @override
  String get hired_btn => 'تم التوظيف';

  @override
  String get reject_btn => 'رفض';

  @override
  String get job_applicants_title => 'المتقدمين للوظيفة';

  @override
  String get recruiter_info_title => 'معلومات صاحب العمل';

  @override
  String get required_skills_title => 'المهارات المطلوبة';

  @override
  String get no_applicants_yet_label => 'لا يوجد متقدمين بعد';

  @override
  String get hire_candidate_title => 'توظيف المرشح';

  @override
  String get hire_confirm_msg =>
      'بمجرد التوظيف، لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get reject_applicant_title => 'رفض المتقدم';

  @override
  String get reject_confirm_msg =>
      'هل أنت متأكد أنك تريد رفض هذا المتقدم؟\n\nبمجرد الرفض، لن تتمكن من الاتصال بهذا المرشح لهذه الوظيفة مرة أخرى.';

  @override
  String get skill_rejected_label => 'مرفوض';

  @override
  String get applicants_tab => 'المتقدمين';

  @override
  String get stats_tab => 'الإحصائيات';

  @override
  String get please_apply_first_chat => 'يرجى التقدم أولاً قبل المحادثة.';

  @override
  String get show_route_btn => 'عرض المسار';

  @override
  String get hide_route_btn => 'إخفاء المسار';

  @override
  String get open_in_maps_btn => 'فتح في الخرائط';

  @override
  String get getting_route_loading => 'جاري جلب المسار…';

  @override
  String get your_location_label => 'موقعك';

  @override
  String get chat_btn => 'محادثة';

  @override
  String get accept_btn => 'قبول';

  @override
  String get job_open_label => 'مفتوح';

  @override
  String get job_closed_label => 'مغلق';

  @override
  String job_views_stats_title(Object count) {
    return 'مشاهدات الوظيفة (الإجمالي $count)';
  }

  @override
  String job_applications_stats_title(Object count) {
    return 'الطلبات المقدمة (الإجمالي $count)';
  }

  @override
  String get mon_short => 'الإثنين';

  @override
  String get tue_short => 'الثلاثاء';

  @override
  String get wed_short => 'الأربعاء';

  @override
  String get thu_short => 'الخميس';

  @override
  String get fri_short => 'الجمعة';

  @override
  String get sat_short => 'السبت';

  @override
  String get sun_short => 'الأحد';

  @override
  String unread_messages_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسائل غير مقروءة',
      two: 'رسالتان غير مقروءتان',
      one: 'رسالة واحدة غير مقروءة',
      zero: 'لا توجد رسائل غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String get staff_pharmacist_hiring => 'توظيف صيدلي مساعد';

  @override
  String get staff_pharmacist_vacancy => 'وظيفة صيدلي شاغرة';

  @override
  String get staff_pharmacist_opportunity => 'فرصة عمل صيدلي';

  @override
  String get find_pharmacy_job_title => 'وظائف الصيدلة';

  @override
  String get featured_jobs_title => 'وظائف مميزة';

  @override
  String get interested_in_pharmacy_msg => 'بناءً على اهتمامك بالصيدلة';

  @override
  String get failed_to_load_jobs => 'فشل تحميل الوظائف';

  @override
  String get no_jobs_available => 'لا توجد وظائف';

  @override
  String get filter_jobs_title => 'الفلاتر';

  @override
  String get search_job_titles_hint => 'البحث عن عناوين الوظائف';

  @override
  String get search_skills_hint => 'البحث عن المهارات';

  @override
  String get apply_filters_btn => 'تطبيق';

  @override
  String get candidate_label => 'مرشح';

  @override
  String get enter_job_keyword_hint => 'أدخل مسمى الوظيفة أو كلمة رئيسية';

  @override
  String get job_seeker_label => 'باحث عن عمل';

  @override
  String get apply_now_btn => 'قدم الآن';

  @override
  String featured_job_salary(String amount) {
    return '$amount / سنويا';
  }

  @override
  String get all_cities => 'الكل';

  @override
  String get city_algiers => 'الجزائر العاصمة';

  @override
  String get city_oran => 'وهران';

  @override
  String get city_constantine => 'قسنطينة';

  @override
  String get city_annaba => 'عنابة';

  @override
  String get city_blida => 'البليدة';

  @override
  String get city_tizi_ouzou => 'تيزي وزو';

  @override
  String get city_bejaia => 'بجاية';

  @override
  String get city_setif => 'سطيف';

  @override
  String get city_batna => 'باتنة';

  @override
  String get city_skikda => 'سكيكدا';

  @override
  String get city_chlef => 'الشلف';

  @override
  String get city_mostaganem => 'مستغانم';

  @override
  String get city_tlemcen => 'تلمسان';

  @override
  String get city_biskra => 'بسكرة';

  @override
  String get city_ouargla => 'ورقلة';

  @override
  String get city_ghardaia => 'غرداية';

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_jobs => 'الوظائف';

  @override
  String get nav_messages => 'الرسائل';

  @override
  String get nav_profiles => 'الملفات';

  @override
  String get nav_applications => 'الطلبات';

  @override
  String get nav_insights => 'الرؤى';

  @override
  String get nav_recruiters => 'أصحاب العمل';

  @override
  String get nav_jobseekers => 'الباحثين';

  @override
  String get del_account_title => 'حذف الحساب';

  @override
  String get del_account_warning => 'تحذير';

  @override
  String get del_account_body =>
      'حذف حسابك سيزيل نهائياً:\n• ملفك الشخصي\n• بيانات تسجيل الدخول\n• جميع سجلاتك\n\nلا يمكن التراجع عن هذا.';

  @override
  String get del_account_btn => 'حذف حسابي';

  @override
  String get del_account_dialog_title => 'حذف الحساب';

  @override
  String get del_account_dialog_msg =>
      'سيؤدي هذا إلى حذف حسابك وجميع بياناتك نهائياً. لا يمكن التراجع.';

  @override
  String get del_account_not_auth =>
      'غير مسجّل الدخول. يرجى تسجيل الدخول مجدداً.';

  @override
  String get del_account_error => 'سجّل الدخول مجدداً وأعد المحاولة.';

  @override
  String get profile_strength => 'قوة الملف';

  @override
  String get job_applications_nav => 'الطلبات';

  @override
  String get matches => 'المطابقات';

  @override
  String get job_matches => 'الوظائف المطابقة';

  @override
  String get based_on_your_profile => 'بناءً على ملفك';

  @override
  String get skills_verified_count => 'المهارات الموثقة';

  @override
  String get improve_visibility => 'تحسين الظهور';

  @override
  String get profile_views_count => 'المشاهدات';

  @override
  String get recruiters_viewed_you => 'شاهدوك';

  @override
  String get profile_visibility => 'ظهور الملف';

  @override
  String get visibility_high => 'عالي';

  @override
  String get visibility_anonymous => 'مجهول';

  @override
  String get privacy_mode => 'الخصوصية';

  @override
  String get skill_verification_title => 'توثيق المهارات';

  @override
  String get verify_your_skills => 'وثق مهاراتك';

  @override
  String get verify_skills_desc => 'اطلب التأكيد';

  @override
  String get status_verified_label => 'موثق';

  @override
  String get status_pending_label => 'معلق';

  @override
  String get status_rejected_label => 'مرفوض';

  @override
  String get my_profile => 'ملفي الشخصي';

  @override
  String get profile_views_drawer => 'مشاهدات الملف';

  @override
  String get profile_views_desc => 'أصحاب العمل الذين شاهدوك';

  @override
  String get personal_pro_info => 'المعلومات الشخصية والمهنية';

  @override
  String get find_your_next_role => 'جد وظيفتك القادمة';

  @override
  String pharmacies_on_map(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صيدليات على الخريطة',
      one: 'صيدلية واحدة على الخريطة',
    );
    return '$_temp0';
  }

  @override
  String get tap_pin_or_scroll_below => 'اضغط على دبوس أو مرر للأسفل';

  @override
  String get pharmacy_profile => 'ملف الصيدلية';

  @override
  String available_jobs_count(Object count) {
    return 'الوظائف المتاحة ($count)';
  }

  @override
  String get no_active_jobs_available => 'لا توجد وظائف نشطة حاليا.';

  @override
  String get no_jobs_location_hint => 'لا توجد وظائف متاحة في هذا الموقع';

  @override
  String get filter_btn => 'تصفية';

  @override
  String get clear_btn => 'مسح';

  @override
  String get my_applications_title => 'طلباتي';

  @override
  String get failed_to_load_applications => 'فشل تحميل الطلبات';

  @override
  String get status_accepted => 'مقبول';

  @override
  String get status_viewed => 'شوهد';

  @override
  String get status_applied => 'مُقدم';

  @override
  String get chat_with_recruiter => 'تحدث مع صاحب العمل';

  @override
  String get open_chat_failed => 'فشل فتح الدردشة. يرجى المحاولة مرة أخرى.';

  @override
  String get no_applications_title => 'لا توجد طلبات حتى الآن';

  @override
  String get no_applications_subtitle => 'قدم على الوظائف وتتبعها هنا';

  @override
  String get time_just_now => 'الآن';

  @override
  String time_min_ago(int count) {
    return 'منذ $countد';
  }

  @override
  String time_hours_ago(int count) {
    return 'منذ $countس';
  }

  @override
  String time_days_ago(int count) {
    return 'منذ $countي';
  }

  @override
  String time_weeks_ago(int count) {
    return 'منذ $countأس';
  }

  @override
  String time_months_ago(int count) {
    return 'منذ $countش';
  }

  @override
  String time_years_ago(int count) {
    return 'منذ $countس';
  }

  @override
  String salary_per_year(String salary) {
    return '$salary / سنة';
  }

  @override
  String get profile_analytics_title => 'تحليلات الملف الشخصي';

  @override
  String get views_trend_title => 'اتجاه المشاهدات';

  @override
  String get last_7_days_subtitle => 'آخر 7 أيام';

  @override
  String get total_profile_views => 'إجمالي مشاهدات الملف الشخصي';

  @override
  String this_week_views(int count) {
    return '+$count هذا الأسبوع';
  }

  @override
  String get recruiters_label => 'أصحاب العمل';

  @override
  String get todays_views_label => 'مشاهدات اليوم';

  @override
  String get daily_breakdown_title => 'التفصيل اليومي';

  @override
  String get today_label => 'اليوم';

  @override
  String views_count_tooltip(int count) {
    return '$count مشاهدات';
  }

  @override
  String get no_trend_data => 'لا توجد بيانات اتجاه حتى الآن';

  @override
  String get no_profile_views_title => 'لا توجد مشاهدات للملف الشخصي';

  @override
  String get no_profile_views_subtitle =>
      'عندما يعرض أصحاب العمل ملفك الشخصي،\nستظهر تحليلاتك هنا.';

  @override
  String get day_mon => 'إثنين';

  @override
  String get day_tue => 'ثلاثاء';

  @override
  String get day_wed => 'أربعاء';

  @override
  String get day_thu => 'خميس';

  @override
  String get day_fri => 'جمعة';

  @override
  String get day_sat => 'سبت';

  @override
  String get day_sun => 'أحد';

  @override
  String get select_pharmacy_title => 'اختر الصيدلية';

  @override
  String get search_pharmacy_hint => 'ابحث عن صيدلية بالاسم';

  @override
  String get no_pharmacies_found => 'لم يتم العثور على صيدليات';

  @override
  String get skill_verification_requests_title => 'طلبات التحقق من المهارات';

  @override
  String get verification_request_sent_success => 'تم إرسال طلب التحقق بنجاح!';

  @override
  String failed_to_send_request(String error) {
    return 'فشل في إرسال الطلب: $error';
  }

  @override
  String get add_note_dialog_title => 'إضافة ملاحظة (اختياري)';

  @override
  String get add_note_dialog_hint => 'أضف أي معلومات إضافية لصاحب العمل...';

  @override
  String get dialog_cancel_btn => 'إلغاء';

  @override
  String get send_request_btn => 'إرسال الطلب';

  @override
  String get status_not_requested => 'لم يطلب';

  @override
  String get status_pending => 'قيد الانتظار';

  @override
  String get status_completed => 'مكتمل';

  @override
  String get request_skill_verification_purpose =>
      'اطلب التحقق من المهارات من صاحب العمل لتعزيز مصداقية ملفك الشخصي وتصنيفه.';

  @override
  String get send_skill_verification_request_btn =>
      'إرسال طلب التحقق من المهارة';

  @override
  String get verification_request_pending_desc =>
      'طلب التحقق قيد الانتظار. سيقوم صاحب العمل بمراجعة مهاراتك قريبًا.';

  @override
  String get verification_completed_desc =>
      'اكتمل التحقق! قم صاحب العمل بمراجعة مهاراتك.';

  @override
  String get chat_with_recruiter_btn => 'محادثة مع صاحب العمل';

  @override
  String failed_to_open_chat(String error) {
    return 'فشل في فتح المحادثة: $error';
  }

  @override
  String get no_applications_yet_title => 'لا توجد طلبات بعد';

  @override
  String get apply_to_jobs_for_verification_desc =>
      'قدم على الوظائف لطلب التحقق من المهارات من أصحاب العمل';

  @override
  String get create_profile_title => 'إنشاء ملف شخصي';

  @override
  String get my_profile_title => 'ملفي الشخصي';

  @override
  String get personal_information_title => 'المعلومات الشخصية';

  @override
  String get first_name_label => 'الاسم الأول';

  @override
  String get last_name_label => 'اسم العائلة';

  @override
  String get show_my_name_label => 'إظهار اسمي لأصحاب العمل';

  @override
  String get location_information_title => 'معلومات الموقع';

  @override
  String get my_location_title => 'موقعي';

  @override
  String get change_location_btn => 'تغيير';

  @override
  String get set_location_btn => 'تحديد';

  @override
  String get current_job_title_title => 'المسمى الوظيفي الحالي';

  @override
  String get select_job_title_hint => 'حدد مسماك الوظيفي الحالي';

  @override
  String get skills_title => 'المهارات';

  @override
  String get add_skill_btn => 'إضافة مهارة';

  @override
  String get background_title => 'الخلفية التعليمية/العملية';

  @override
  String get job_experience_hint => 'حدد مستوى خبرتك الوظيفية';

  @override
  String get save_changes_btn => 'حفظ التغييرات';

  @override
  String get select_skills_title => 'تحديد المهارات';

  @override
  String get no_experience_available => 'لا توجد مستويات خبرة متاحة';

  @override
  String get no_options_available => 'لا توجد خيارات متاحة';

  @override
  String get select_province_hint => 'اختر الولاية';

  @override
  String get loading_hint => 'جاري التحميل...';

  @override
  String get select_city_hint => 'اختر المدينة';

  @override
  String get fill_required_fields_error => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get phone_required_error => 'رقم الهاتف مطلوب';

  @override
  String get phone_nine_digits_error => 'يجب أن يتكون الرقم من 9 أرقام';

  @override
  String get phone_invalid_start_error =>
      'يجب أن يبدأ بـ 5 أو 6 أو 7 (الجزائر فقط)';

  @override
  String get status_verified => 'مُوثق';

  @override
  String get crop_photo_title => 'قص الصورة';

  @override
  String get camera_btn => 'الكاميرا';

  @override
  String get gallery_btn => 'المعرض';

  @override
  String get remove_photo_btn => 'إزالة الصورة';

  @override
  String get general_save_btn => 'حفظ';

  @override
  String get general_change_btn => 'تغيير';

  @override
  String get recrop_btn => 'إعادة القص';

  @override
  String get add_profile_photo_label => 'إضافة صورة ملف شخصي';

  @override
  String get admin_active_jobs_title => 'الوظائف';

  @override
  String get admin_active_jobs_sub => 'متاحة';

  @override
  String get admin_skill_req_title => 'المهارات';

  @override
  String get admin_skill_req_sub => 'قيد الانتظار';

  @override
  String get admin_recruiters_title => 'المجنّدون';

  @override
  String get admin_recruiters_sub => 'مسجلون';

  @override
  String get admin_seekers_title => 'المرشحون';

  @override
  String get admin_seekers_sub => 'نشطون';

  @override
  String get admin_platform_activity => 'النشاط';

  @override
  String get admin_platform_activity_desc => 'نظرة عامة';

  @override
  String get admin_open_jobs => 'مفتوحة';

  @override
  String get admin_closed_jobs => 'مغلقة';

  @override
  String get admin_user_activity => 'المستخدمون';

  @override
  String get admin_user_activity_desc => 'المرشحون والشركات';

  @override
  String get admin_reported_issues => 'البلاغات';

  @override
  String get admin_total_earnings => 'الأرباح';

  @override
  String get admin_job_status_overview => 'نظرة عامة على حالة عروض العمل';

  @override
  String admin_jobs_open_count(int active, int total) {
    return 'لديك حاليًا $active من أصل $total وظيفة مفتوحة';
  }

  @override
  String get admin_manage_account => 'إدارة الحساب';

  @override
  String get admin_active_label => 'نشط';

  @override
  String get admin_drawer_payments_title => 'مدفوعات الشركات';

  @override
  String get admin_drawer_payments_sub => 'عرض المدفوعات من الشركات';

  @override
  String get admin_drawer_job_options_title => 'إضافة مسمى وظيفي/مهارة';

  @override
  String get admin_drawer_job_options_sub =>
      'إضافة مسميات أو مهارات جديدة إلى النظام';

  @override
  String get admin_drawer_job_types_title => 'إدارة أنواع الوظائف';

  @override
  String get admin_drawer_job_types_sub => 'إدارة أنواع الوظائف المتاحة';

  @override
  String get admin_drawer_exp_levels_title => 'إدارة مستويات الخبرة';

  @override
  String get admin_drawer_exp_levels_sub => 'إدارة مستويات الخبرة المتاحة';

  @override
  String get admin_drawer_locations_title => 'إدارة المواقع';

  @override
  String get admin_drawer_locations_sub => 'إدارة المواقع المتاحة';

  @override
  String get admin_drawer_payment_config_title => 'إدارة إعدادات الدفع';

  @override
  String get admin_drawer_payment_config_sub => 'إدارة معلمات الدفع';

  @override
  String get admin_drawer_appeals_title => 'الطعون المعلقة';

  @override
  String get admin_drawer_appeals_sub => 'مراجعة الطعون المعلقة';

  @override
  String get admin_add_user_title => 'إضافة مستخدم';

  @override
  String get admin_appeals_title => 'الالتماسات المعلقة';

  @override
  String get admin_job_list_title => 'قوائم الوظائف';

  @override
  String get admin_payments_title => 'إدارة المدفوعات';

  @override
  String get admin_promotion_title => 'ترقية المجنّدين';

  @override
  String get admin_verification_title => 'التحقق من المجنّدين';

  @override
  String get blocked_account_title => 'الحساب محظور';

  @override
  String get create_user_btn => 'إنشاء مستخدم';

  @override
  String get update_user_btn => 'تحديث';

  @override
  String get no_pending_appeals_msg => 'لا توجد التماسات';

  @override
  String get review_btn => 'مراجعة';

  @override
  String get appeal_review_title => 'مراجعة الالتماس';

  @override
  String get user_email_label => 'بريد المستخدم';

  @override
  String get block_reason_label => 'سبب الحظر';

  @override
  String get appeal_msg_label => 'رسالة الطعن';

  @override
  String get admin_msg_required_label => 'رسالة المشرف (مطلوبة)';

  @override
  String get approve_btn => 'موافقة';

  @override
  String get reject_btn_caps => 'رفض';

  @override
  String get appeal_approved_notif_title => 'تمت الموافقة على الطعن';

  @override
  String get appeal_rejected_notif_title => 'تم رفض الطعن';

  @override
  String get appeal_under_review_msg => 'طعنك قيد المراجعة';

  @override
  String get appeal_approved_msg => 'تمت الموافقة على طعنك';

  @override
  String get appeal_rejected_msg => 'تم رفض طعنك';

  @override
  String get no_reason_provided => 'لم يُقدَّم أي سبب';

  @override
  String get explain_unblock_hint => 'اشرح سبب رفع الحظر عن حسابك';

  @override
  String get submit_appeal_btn => 'تقديم الطعن';

  @override
  String get blocked_acc_msg => 'تم حظر حسابك';

  @override
  String get recruiter_verification_card => 'التحقق من المجنّدين';

  @override
  String get make_featured_card => 'ترقية المجنّدين';

  @override
  String pending_count_label(int count) {
    return '$count في الانتظار';
  }

  @override
  String transactions_count_label(int count) {
    return '$count معاملة';
  }

  @override
  String get recruiter_promotion_panel => 'لوحة الترقية';

  @override
  String get search_recruiters_label => 'بحث عن مجنّدين';

  @override
  String eligible_recruiters_count(int count) {
    return 'المؤهلون ($count)';
  }

  @override
  String get no_recruiters_match_search => 'لا يوجد مجنّد يطابق بحثك.';

  @override
  String get pharmacy_search_hint => 'الصيدلية، الاسم أو المدينة';

  @override
  String get recent_payments_title => 'المدفوعات الأخيرة';

  @override
  String get no_payments_found => 'لا توجد مدفوعات';

  @override
  String get recruiter_verification_panel => 'لوحة التحقق';

  @override
  String get search_pending_recruiters => 'بحث في المعلقين';

  @override
  String pending_verification_count(int count) {
    return '$count للتحقق';
  }

  @override
  String get no_recruiters_for_verification => 'لا يوجد مجنّدون للتحقق.';

  @override
  String get search_jobs_hint => 'البحث في الوظائف…';

  @override
  String get all_filter_label => 'الكل';

  @override
  String get open_filter_label => 'مفتوحة';

  @override
  String get closed_filter_label => 'مغلقة';

  @override
  String get total_revenue_label => 'إجمالي الإيرادات';

  @override
  String get total_transactions_label => 'إجمالي المعاملات';

  @override
  String get pending_payments_label => 'معلق';

  @override
  String get paid_payments_label => 'مدفوع';

  @override
  String get amount_label => 'المبلغ';

  @override
  String get plan_label => 'الخطة';

  @override
  String get status_label => 'الحالة';

  @override
  String get account_blocked_title => 'الحساب محظور';

  @override
  String get admin_header_title => 'لوحة المشرف';

  @override
  String get pending_verification_label => 'التحقق معلق';

  @override
  String get personal_info_section => 'المعلومات الشخصية';

  @override
  String get company_info_section => 'معلومات الشركة';

  @override
  String registered_as_label(String role) {
    return 'مسجل كـ $role';
  }

  @override
  String get verification_requests_card => 'التحقق';

  @override
  String get featured_recruiters_card => 'مميز';

  @override
  String get payments_card => 'المدفوعات';

  @override
  String pending_label(int count) {
    return '$count معلق';
  }

  @override
  String get open_jobs_tab => 'مفتوحة';

  @override
  String get closed_jobs_tab => 'مغلقة';

  @override
  String get failed_load_jobs => 'فشل التحميل';

  @override
  String get view_details_btn => 'التفاصيل';

  @override
  String get clear_all_btn => 'مسح الكل';

  @override
  String get search_province_hint => 'الولاية...';

  @override
  String get search_recruiters_hint => 'بحث عن مجنّد...';

  @override
  String get verified_status => 'تم التحقق';

  @override
  String get unverified_status => 'لم يتم التحقق';

  @override
  String get view_profile_btn => 'الملف الشخصي';

  @override
  String get paid_subscriptions_title => 'الاشتراكات المدفوعة';

  @override
  String get no_paid_subs => 'لا توجد اشتراكات';

  @override
  String get active_label => 'نشط';

  @override
  String get revenue_label => 'الإيرادات';

  @override
  String get expired_label => 'منتهي';

  @override
  String until_label(String date) {
    return 'حتى $date';
  }

  @override
  String get recruiter_label => 'مجنّد';

  @override
  String get street_label => 'الشارع';

  @override
  String get license_label => 'الترخيص';

  @override
  String get inactive_label => 'غير نشط';

  @override
  String get lic_expires_label => 'ينتهي في';

  @override
  String get paid_on_label => 'تم الدفع في';

  @override
  String get method_label => 'الطريقة';

  @override
  String get year_label => 'السنة';

  @override
  String get checkout_id_label => 'معرف المعاملة';

  @override
  String get admin_msg_label => 'رسالة المشرف';

  @override
  String get no_recruiters_match => 'لا يوجد تطابق';

  @override
  String get skills_label => 'المهارات';

  @override
  String get premium_label => 'مميز';

  @override
  String get no_to_verify => 'لا يوجد للتحقق';

  @override
  String get admin_role_desc => 'وصول كامل للمنصة';

  @override
  String get admin_dashboard_subtitle => 'لوحة تحكم المشرف';

  @override
  String get admin_label => 'مشرف';

  @override
  String get all_jobs_label => 'جميع الوظائف';

  @override
  String get open_closed_jobs_subtitle => 'الوظائف المفتوحة والمغلقة';

  @override
  String get search_job_hint => 'أدخل مسمى الوظيفة أو كلمة رئيسية';

  @override
  String get street_address_label => 'عنوان الشارع';

  @override
  String get province_label => 'المقاطعة';

  @override
  String get location_label => 'الموقع';

  @override
  String get any_label => 'أي';

  @override
  String get job_title_label => 'المسمى الوظيفي';

  @override
  String get only_admin_create_user_toast =>
      'فقط المشرفون يمكنهم إنشاء مستخدمين.';

  @override
  String get email_required_error => 'البريد الإلكتروني مطلوب.';

  @override
  String get invalid_email_error => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get password_required_error => 'كلمة المرور مطلوبة.';

  @override
  String get invalid_password_format_error =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل وتشمل حرفاً كبيراً وحرفاً صغيراً ورقماً واحداً.';

  @override
  String get confirm_password_required_error => 'يرجى تأكيد كلمة المرور.';

  @override
  String get passwords_do_not_match_error => 'كلمات المرور غير متطابقة.';

  @override
  String get admin_created_user_name => 'مستخدم تم إنشاؤه بواسطة المشرف';

  @override
  String user_created_success_msg(String role) {
    return 'تم إنشاء المستخدم بنجاح كـ $role.';
  }

  @override
  String get access_denied_admin => 'تم رفض الوصول. للمشرف فقط.';

  @override
  String get add_new_user_title => 'إضافة مستخدم جديد';

  @override
  String get create_user_account_header => 'إنشاء حساب مستخدم';

  @override
  String get create_user_account_desc =>
      'املأ التفاصيل وعين دوراً.\nسيتم إرسال بريد إلكتروني للتحقق تلقائياً.';

  @override
  String get assign_role_label => 'تعيين دور';

  @override
  String get admin_role_label => 'مشرف';

  @override
  String get recruiters_list => 'المسمى الوظيفي';

  @override
  String get recruiters => 'الموظفون';

  @override
  String get searchHint => 'ابحث حسب الصيدلية أو الاسم أو المدينة';

  @override
  String get noRecruitersFound => 'لم يتم العثور على موظفين';

  @override
  String get loadingRecruiters => 'جاري تحميل الموظفين…';

  @override
  String recruitersLoaded(Object count) {
    return 'تم تحميل $count موظف';
  }

  @override
  String get loadMoreRecruiters => 'تحميل المزيد من الموظفين';

  @override
  String allRecruitersLoaded(Object count) {
    return 'تم تحميل جميع $count الموظفين';
  }

  @override
  String get verified => 'موثّق';

  @override
  String get viewProfile => 'عرض الملف';

  @override
  String get recruiterVerificationPanel => 'لوحة التحقق';

  @override
  String get searchPendingRecruiters => 'بحث الموظفين';

  @override
  String get searchHintRecruiters => 'صيدلية أو اسم أو مدينة';

  @override
  String get pendingVerification => 'قيد الانتظار';

  @override
  String get noRecruitersForVerification => 'لا يوجد موظفون';

  @override
  String get premium => 'مميز';

  @override
  String get recruiterPromotionPanel => 'لوحة الترويج';

  @override
  String get searchRecruiters => 'بحث الموظفين';

  @override
  String get eligibleRecruiters => 'المؤهلون';

  @override
  String get noRecruitersMatch => 'لا يوجد موظفون';

  @override
  String get recruiterProfile => 'الملف';

  @override
  String get pharmacyInfo => 'الصيدلية';

  @override
  String get pharmacist => 'الصيدلي';

  @override
  String get metaInfo => 'التفاصيل';

  @override
  String get jobStats => 'إحصائيات الوظائف';

  @override
  String get pharmacyName => 'الصيدلية';

  @override
  String get province => 'المقاطعة';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get userId => 'معرّف المستخدم';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get totalJobs => 'إجمالي';

  @override
  String get activeJobs => 'النشطة';

  @override
  String get draftJobs => 'مسودات';

  @override
  String get verifyRecruiter => 'تأكيد';

  @override
  String get unverifyRecruiter => 'إلغاء';

  @override
  String get recruiterApproved => 'تم التأكيد';

  @override
  String get recruiterDeactivated => 'تم التعطيل';

  @override
  String get makeRecruiterPro => 'ترقية Pro';

  @override
  String get recruiterUpgraded => 'تمت الترقية';

  @override
  String get failedLoadJobs => 'فشل التحميل';

  @override
  String get paidSubscriptions => 'الاشتراكات';

  @override
  String get noPaidSubscriptions => 'لا توجد اشتراكات';

  @override
  String get total => 'الإجمالي';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get unknownPharmacy => 'غير معروف';

  @override
  String get expired => 'منتهي';

  @override
  String get until => 'حتى';

  @override
  String get recruiter => 'الموظف';

  @override
  String get payment => 'الدفع';

  @override
  String get name => 'الاسم';

  @override
  String get street => 'العنوان';

  @override
  String get license => 'الرخصة';

  @override
  String get licenseExpires => 'انتهاء';

  @override
  String get paidOn => 'تم الدفع';

  @override
  String get expires => 'ينتهي';

  @override
  String get method => 'الطريقة';

  @override
  String get year => 'السنة';

  @override
  String get checkoutId => 'معرّف الدفع';

  @override
  String get inactive => 'غير نشط';

  @override
  String get loadFailed => 'فشل التحميل';

  @override
  String get manageOptions => 'إدارة الخيارات';

  @override
  String get jobTitles => 'المسميات الوظيفية';

  @override
  String get noOptions => 'لا توجد خيارات حتى الآن';

  @override
  String get hidden => 'مخفي';

  @override
  String get deleteOption => 'حذف الخيار';

  @override
  String deleteOptionConfirm(Object name) {
    return 'هل تريد حذف \"$name\" نهائيًا؟';
  }

  @override
  String get fillAllLanguages => 'املأ جميع اللغات الثلاث';

  @override
  String get editJobTitle => 'تعديل المسمى الوظيفي';

  @override
  String get addJobTitle => 'إضافة مسمى وظيفي';

  @override
  String get editSkill => 'تعديل المهارة';

  @override
  String get addSkill => 'إضافة مهارة';

  @override
  String get englishRequired => 'الاسم الإنجليزي مطلوب';

  @override
  String get frenchRequired => 'الاسم الفرنسي مطلوب';

  @override
  String get arabicRequired => 'الاسم العربي مطلوب';

  @override
  String get labelInEnglish => 'التسمية بالإنجليزية';

  @override
  String get labelInFrench => 'التسمية بالفرنسية';

  @override
  String get labelInArabic => 'التسمية بالعربية';

  @override
  String get update => 'تحديث';

  @override
  String get add => 'إضافة';

  @override
  String get jobTypesTitle => 'أنواع الوظائف';

  @override
  String typesCount(Object count) {
    return '$count نوع';
  }

  @override
  String get noJobTypes => 'لا توجد أنواع وظائف بعد';

  @override
  String get addNewHint => 'اضغط + لإضافة نوع';

  @override
  String get deleteJobTypeTitle => 'حذف نوع الوظيفة';

  @override
  String deleteJobTypeConfirm(Object name) {
    return 'هل تريد حذف \"$name\" نهائيًا؟';
  }

  @override
  String get addJobType => 'إضافة نوع وظيفة';

  @override
  String get editJobType => 'تعديل نوع الوظيفة';

  @override
  String get fillLanguages => 'املأ جميع اللغات الثلاث';

  @override
  String nameInLanguage(String language) {
    return 'الاسم باللغة $language...';
  }

  @override
  String get experienceLevelsTitle => 'مستويات الخبرة';

  @override
  String levelsCount(Object count) {
    return '$count مستوى';
  }

  @override
  String get noExperienceLevels => 'لا توجد مستويات خبرة بعد';

  @override
  String get deleteExperienceLevelTitle => 'حذف مستوى الخبرة';

  @override
  String deleteExperienceLevelConfirm(Object name) {
    return 'هل تريد حذف \"$name\" نهائيًا؟';
  }

  @override
  String get addExperienceLevel => 'إضافة مستوى خبرة';

  @override
  String get editExperienceLevel => 'تعديل مستوى الخبرة';

  @override
  String labelInLanguage(Object lang) {
    return 'التسمية باللغة $lang...';
  }

  @override
  String get titleProvincesCities => 'المناطق والمدن';

  @override
  String provincesCount(int count) {
    return '$count منطقة';
  }

  @override
  String citiesCount(int count) {
    return '$count مدينة';
  }

  @override
  String get noProvinces => 'لا توجد مناطق بعد';

  @override
  String get noCities => 'لا توجد مدن بعد';

  @override
  String get addProvinceHint => 'اضغط + لإضافة منطقة';

  @override
  String addCityHint(String province) {
    return 'اضغط + لإضافة مدينة إلى $province';
  }

  @override
  String get cities => 'مدن';

  @override
  String get deleteProvinceTitle => 'حذف المنطقة';

  @override
  String deleteProvinceMessage(String name) {
    return 'هل تريد حذف \"$name\" وجميع مدنها نهائيًا؟';
  }

  @override
  String get deleteCityTitle => 'حذف المدينة';

  @override
  String deleteCityMessage(String name) {
    return 'هل تريد حذف \"$name\" نهائيًا؟';
  }

  @override
  String get edit => 'تعديل';

  @override
  String get addProvince => 'إضافة منطقة';

  @override
  String get editProvince => 'تعديل المنطقة';

  @override
  String get addCity => 'إضافة مدينة';

  @override
  String get editCity => 'تعديل المدينة';

  @override
  String get paymentConfigTitle => 'إعدادات الدفع';

  @override
  String get save => 'حفظ';

  @override
  String get saveConfiguration => 'حفظ الإعدادات';

  @override
  String get environment => 'البيئة';

  @override
  String get environmentSubtitle => 'التبديل بين وضع الاختبار والإنتاج';

  @override
  String get testMode => 'وضع الاختبار';

  @override
  String get testModeSubtitle => 'لن يتم خصم أموال حقيقية';

  @override
  String get production => 'الإنتاج';

  @override
  String get productionSubtitle => 'مدفوعات حقيقية';

  @override
  String get apiCredentials => 'بيانات API';

  @override
  String get apiCredentialsSubtitle => 'مفتاح Chargily السري وروابط API';

  @override
  String get testSecretKey => 'المفتاح السري (اختبار)';

  @override
  String get cloudFunctionUrl => 'رابط Cloud Function';

  @override
  String get webhookUrl => 'رابط Webhook';

  @override
  String get redirectUrls => 'روابط إعادة التوجيه';

  @override
  String get redirectUrlsSubtitle => 'إلى أين يتم توجيه المستخدم بعد الدفع';

  @override
  String get successUrl => 'رابط النجاح';

  @override
  String get failureUrl => 'رابط الفشل';

  @override
  String get pricing => 'التسعير';

  @override
  String get pricingSubtitle => 'الرسوم السنوية، العملة، واللغة';

  @override
  String get annualFee => 'الرسوم السنوية';

  @override
  String get currency => 'العملة';

  @override
  String get locale => 'اللغة';

  @override
  String get planCopy => 'نص الخطة';

  @override
  String get planCopySubtitle => 'النص المعروض للمستخدمين في صفحة الاشتراك';

  @override
  String get planName => 'اسم الخطة';

  @override
  String get planSubtitle => 'العنوان الفرعي';

  @override
  String get planDescription => 'الوصف';

  @override
  String get disclaimer => 'إخلاء المسؤولية';

  @override
  String get planFeatures => 'مميزات الخطة';

  @override
  String get planFeaturesSubtitle =>
      'نقاط تظهر في صفحة الاشتراك. يمكن السحب لإعادة الترتيب.';

  @override
  String get newFeature => 'ميزة جديدة';

  @override
  String get noFeatures => 'لم يتم إضافة أي ميزات بعد';

  @override
  String get annualFeeError => 'يجب أن تكون الرسوم السنوية رقمًا صحيحًا';

  @override
  String get saveSuccess => 'تم حفظ الإعدادات بنجاح';

  @override
  String saveError(String error) {
    return 'فشل في الحفظ: $error';
  }

  @override
  String get close_issue_btn => 'إغلاق المشكلة';

  @override
  String get tabs_open => 'مفتوح';

  @override
  String get tabs_closed => 'مغلق';

  @override
  String get loginHere => 'سجل الدخول هنا';

  @override
  String get welcomeMessage =>
      'قم بالوصول إلى حساب Ophicina الخاص بك بأمان باستخدام الطريقة المفضلة لديك';

  @override
  String get monthlyLimitTitle => 'تم الوصول إلى الحد الشهري';

  @override
  String monthlyLimitMessage(Object limit) {
    return 'لقد استخدمت جميع $limit من وظائف النشر لهذا الشهر. سيتم إعادة ضبط الحد في الأول من الشهر القادم. تواصل مع المدير إذا كنت بحاجة إلى المزيد.';
  }

  @override
  String get ok => 'حسناً';

  @override
  String get notif_account_verified_title => 'تم توثيق الحساب';

  @override
  String get notif_account_verified_desc =>
      'تم توثيق حساب صاحب العمل الخاص بك من قبل فريق Ophicina.';

  @override
  String get notif_account_deactivated_title => 'تم تعطيل الحساب';

  @override
  String get notif_account_deactivated_desc =>
      'تم تعطيل حساب صاحب العمل الخاص بك. يرجى الاتصال بالدعم لمزيد من المعلومات.';

  @override
  String get notif_account_pro_title => 'تمت الترقية إلى Pro';

  @override
  String get notif_account_pro_desc => 'تهانينا! تمت ترقية حسابك إلى وضع Pro.';

  @override
  String get notif_quota_updated_title => 'تم تحديث حصة نشر الوظائف';

  @override
  String notif_quota_updated_desc(int limit) {
    return 'تم تحديث حد نشر الوظائف الشهري الخاص بك إلى $limit وظيفة.';
  }

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get resetLinkSent =>
      'تم إرسال رابط إعادة التعيين. تحقق من صندوق الوارد ولا تنسَ التحقق من مجلد الرسائل غير المرغوب فيها.';

  @override
  String get noAccountFound => 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';

  @override
  String get errorPrefix => 'خطأ:';
}
