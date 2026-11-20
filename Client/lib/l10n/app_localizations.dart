import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Ophicina'**
  String get app_title;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your opportunity is here'**
  String get tagline;

  /// No description provided for @role_job_seeker.
  ///
  /// In en, this message translates to:
  /// **'I am a Job Seeker'**
  String get role_job_seeker;

  /// No description provided for @role_recruiter.
  ///
  /// In en, this message translates to:
  /// **'I am a Recruiter'**
  String get role_recruiter;

  /// No description provided for @onboarding_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ophicina'**
  String get onboarding_title;

  /// No description provided for @onboarding_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Connecting pharmacy professionals with the right opportunities.'**
  String get onboarding_subtitle;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login to Ophicina'**
  String get login_title;

  /// No description provided for @login_subtitle_email.
  ///
  /// In en, this message translates to:
  /// **'Secure login using your email'**
  String get login_subtitle_email;

  /// No description provided for @login_subtitle_phone.
  ///
  /// In en, this message translates to:
  /// **'Secure login using your phone number'**
  String get login_subtitle_phone;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgot_password;

  /// No description provided for @sign_in_button.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in_button;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get create_account;

  /// No description provided for @welcome_to_ophicina.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ophicina'**
  String get welcome_to_ophicina;

  /// No description provided for @signup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the professional healthcare network'**
  String get signup_subtitle;

  /// No description provided for @confirm_password_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password_label;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @join_ophicina.
  ///
  /// In en, this message translates to:
  /// **'Join Ophicina'**
  String get join_ophicina;

  /// No description provided for @join_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to discover opportunities'**
  String get join_subtitle;

  /// No description provided for @signup_with_email.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Email'**
  String get signup_with_email;

  /// No description provided for @signup_with_google.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signup_with_google;

  /// No description provided for @signup_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple'**
  String get signup_with_apple;

  /// No description provided for @deletion_queue_error.
  ///
  /// In en, this message translates to:
  /// **'Your account deletion is pending. Please use a different email or phone.'**
  String get deletion_queue_error;

  /// No description provided for @email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_required;

  /// No description provided for @valid_email_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get valid_email_error;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_required;

  /// No description provided for @password_format_error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long, include 1 uppercase, 1 lowercase, and 1 number'**
  String get password_format_error;

  /// No description provided for @confirm_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirm_password_required;

  /// No description provided for @passwords_dont_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_dont_match;

  /// No description provided for @signup_successful.
  ///
  /// In en, this message translates to:
  /// **'Signup successful!'**
  String get signup_successful;

  /// No description provided for @enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enter_valid_email;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enter_password;

  /// No description provided for @enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone;

  /// No description provided for @enter_valid_algerian.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Algerian number (5, 6 or 7 followed by 8 digits)'**
  String get enter_valid_algerian;

  /// No description provided for @enter_valid_pakistani.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Pakistani number (3 followed by 9 digits)'**
  String get enter_valid_pakistani;

  /// No description provided for @otp_sent_to.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {phone}'**
  String otp_sent_to(String phone);

  /// No description provided for @otp_not_sent.
  ///
  /// In en, this message translates to:
  /// **'OTP not sent yet'**
  String get otp_not_sent;

  /// No description provided for @otp_complete.
  ///
  /// In en, this message translates to:
  /// **'Enter complete 6-digit OTP'**
  String get otp_complete;

  /// No description provided for @account_not_found.
  ///
  /// In en, this message translates to:
  /// **'Your account was not found, please register yourself first'**
  String get account_not_found;

  /// No description provided for @login_here.
  ///
  /// In en, this message translates to:
  /// **'Login Here'**
  String get login_here;

  /// No description provided for @login_subtitle_welcome.
  ///
  /// In en, this message translates to:
  /// **'Access your Ophicina account securely with your preferred method'**
  String get login_subtitle_welcome;

  /// No description provided for @login_with_email.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get login_with_email;

  /// No description provided for @login_with_google.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get login_with_google;

  /// No description provided for @login_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Login with Apple'**
  String get login_with_apple;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @hi_user.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String hi_user(String name);

  /// No description provided for @my_account.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get my_account;

  /// No description provided for @post_job.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get post_job;

  /// No description provided for @post_job_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach pharmacists by listing your vacancy'**
  String get post_job_desc;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get edit_profile;

  /// No description provided for @edit_profile_desc.
  ///
  /// In en, this message translates to:
  /// **'Edit profile & Pharmacy Detail'**
  String get edit_profile_desc;

  /// No description provided for @report_issue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get report_issue;

  /// No description provided for @report_issue_desc.
  ///
  /// In en, this message translates to:
  /// **'Report bugs & issues'**
  String get report_issue_desc;

  /// No description provided for @reported_issues.
  ///
  /// In en, this message translates to:
  /// **'Reported Issues'**
  String get reported_issues;

  /// No description provided for @reported_issues_desc.
  ///
  /// In en, this message translates to:
  /// **'View your reported issues'**
  String get reported_issues_desc;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_desc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logout_desc;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @delete_account_desc.
  ///
  /// In en, this message translates to:
  /// **'This will delete your account'**
  String get delete_account_desc;

  /// No description provided for @jobs_status_overview.
  ///
  /// In en, this message translates to:
  /// **'Job Offer Status Overview'**
  String get jobs_status_overview;

  /// No description provided for @jobs_open_count.
  ///
  /// In en, this message translates to:
  /// **'You currently have {active} of {total} jobs open and accepting new applications'**
  String jobs_open_count(int active, int total);

  /// No description provided for @manage_account.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get manage_account;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @open_jobs.
  ///
  /// In en, this message translates to:
  /// **'Open Jobs'**
  String get open_jobs;

  /// No description provided for @open_jobs_count.
  ///
  /// In en, this message translates to:
  /// **'{open} of {total} open'**
  String open_jobs_count(int open, int total);

  /// No description provided for @filled_positions.
  ///
  /// In en, this message translates to:
  /// **'Filled Positions'**
  String get filled_positions;

  /// No description provided for @filled_positions_count.
  ///
  /// In en, this message translates to:
  /// **'{filled} of {total} filled'**
  String filled_positions_count(int filled, int total);

  /// No description provided for @skill_verification_requests.
  ///
  /// In en, this message translates to:
  /// **'Skill Verifications Requests'**
  String get skill_verification_requests;

  /// No description provided for @pending_requests_count.
  ///
  /// In en, this message translates to:
  /// **'{count} pending requests'**
  String pending_requests_count(int count);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @hiring_activity.
  ///
  /// In en, this message translates to:
  /// **'Your Hiring Activity'**
  String get hiring_activity;

  /// No description provided for @review_profiles.
  ///
  /// In en, this message translates to:
  /// **'Review Profiles'**
  String get review_profiles;

  /// No description provided for @reviewed_count.
  ///
  /// In en, this message translates to:
  /// **'Reviewed: {reviewed}/{total}'**
  String reviewed_count(int reviewed, int total);

  /// No description provided for @chat_card.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_card;

  /// No description provided for @read_count.
  ///
  /// In en, this message translates to:
  /// **'Read: {read}/{total}'**
  String read_count(int read, int total);

  /// No description provided for @all_time_job_stats.
  ///
  /// In en, this message translates to:
  /// **'All Time Job Offers Statistics'**
  String get all_time_job_stats;

  /// No description provided for @no_job_offers_stats.
  ///
  /// In en, this message translates to:
  /// **'No job offers available to display statistics.'**
  String get no_job_offers_stats;

  /// No description provided for @no_stats_available.
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get no_stats_available;

  /// No description provided for @candidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get candidates;

  /// No description provided for @candidates_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Candidates'**
  String candidates_count(int count);

  /// No description provided for @upcoming_hiring_actions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Hiring Actions'**
  String get upcoming_hiring_actions;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @create_account_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account_title;

  /// No description provided for @edit_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_title;

  /// No description provided for @my_account_title.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get my_account_title;

  /// No description provided for @update_profile_picture.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Picture'**
  String get update_profile_picture;

  /// No description provided for @personal_information.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_information;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @first_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Anabella'**
  String get first_name_hint;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @last_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Angela'**
  String get last_name_hint;

  /// No description provided for @pharmacy_location_title.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy & Location'**
  String get pharmacy_location_title;

  /// No description provided for @pharmacy_name.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Name'**
  String get pharmacy_name;

  /// No description provided for @pharmacy_name_hint.
  ///
  /// In en, this message translates to:
  /// **'GreenCare Pharmacy'**
  String get pharmacy_name_hint;

  /// No description provided for @wilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get wilaya;

  /// No description provided for @select_province.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get select_province;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @select_province_first.
  ///
  /// In en, this message translates to:
  /// **'Select province first'**
  String get select_province_first;

  /// No description provided for @loading_dots.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading_dots;

  /// No description provided for @select_city.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get select_city;

  /// No description provided for @pharmacy_location_tile.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Location'**
  String get pharmacy_location_tile;

  /// No description provided for @tap_to_set_location.
  ///
  /// In en, this message translates to:
  /// **'Tap to set location on map'**
  String get tap_to_set_location;

  /// No description provided for @set_btn.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set_btn;

  /// No description provided for @change_btn.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change_btn;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @create_account_btn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account_btn;

  /// No description provided for @all_rights_reserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get all_rights_reserved;

  /// No description provided for @profile_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profile_photo_title;

  /// No description provided for @crop_photo.
  ///
  /// In en, this message translates to:
  /// **'Crop Photo'**
  String get crop_photo;

  /// No description provided for @profile_picture_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated'**
  String get profile_picture_updated;

  /// No description provided for @failed_to_update.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failed_to_update(String error);

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @remove_photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get remove_photo;

  /// No description provided for @save_btn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_btn;

  /// No description provided for @change_action.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change_action;

  /// No description provided for @recrop_action.
  ///
  /// In en, this message translates to:
  /// **'Recrop'**
  String get recrop_action;

  /// No description provided for @add_profile_photo_btn.
  ///
  /// In en, this message translates to:
  /// **'Add profile photo'**
  String get add_profile_photo_btn;

  /// No description provided for @normal_filter.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal_filter;

  /// No description provided for @verify_jobseeker_skills_title.
  ///
  /// In en, this message translates to:
  /// **'Verify Jobseeker Skills'**
  String get verify_jobseeker_skills_title;

  /// No description provided for @failed_to_load_requests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests'**
  String get failed_to_load_requests;

  /// No description provided for @no_pending_skill_requests.
  ///
  /// In en, this message translates to:
  /// **'No pending skill requests'**
  String get no_pending_skill_requests;

  /// No description provided for @anonymous_candidate.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Candidate'**
  String get anonymous_candidate;

  /// No description provided for @verify_skills_btn.
  ///
  /// In en, this message translates to:
  /// **'Verify Skills'**
  String get verify_skills_btn;

  /// No description provided for @skill_verification_completed_notif_title.
  ///
  /// In en, this message translates to:
  /// **'Skill Verification Completed'**
  String get skill_verification_completed_notif_title;

  /// No description provided for @skill_verification_completed_notif_desc.
  ///
  /// In en, this message translates to:
  /// **'Your skills have been reviewed by the recruiter.'**
  String get skill_verification_completed_notif_desc;

  /// No description provided for @skills_to_review_label.
  ///
  /// In en, this message translates to:
  /// **'Skills to Review'**
  String get skills_to_review_label;

  /// No description provided for @note_from_jobseeker_label.
  ///
  /// In en, this message translates to:
  /// **'Note from Job Seeker'**
  String get note_from_jobseeker_label;

  /// No description provided for @no_note_provided.
  ///
  /// In en, this message translates to:
  /// **'No note provided by the job seeker.'**
  String get no_note_provided;

  /// No description provided for @mark_verification_completed_btn.
  ///
  /// In en, this message translates to:
  /// **'Mark Verification as Completed'**
  String get mark_verification_completed_btn;

  /// No description provided for @all_skills_reviewed_msg.
  ///
  /// In en, this message translates to:
  /// **'All skills have already been reviewed for this job seeker.'**
  String get all_skills_reviewed_msg;

  /// No description provided for @pending_review_status.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pending_review_status;

  /// No description provided for @phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone_label;

  /// No description provided for @city_label.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city_label;

  /// No description provided for @education_label.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education_label;

  /// No description provided for @experience_label.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience_label;

  /// No description provided for @wilaya_label.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get wilaya_label;

  /// No description provided for @na_value.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na_value;

  /// No description provided for @verify_action.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify_action;

  /// No description provided for @reject_action.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject_action;

  /// No description provided for @verified_count_label.
  ///
  /// In en, this message translates to:
  /// **'{count} verified'**
  String verified_count_label(Object count);

  /// No description provided for @rejected_count_label.
  ///
  /// In en, this message translates to:
  /// **'{count} rejected'**
  String rejected_count_label(Object count);

  /// No description provided for @closed_jobs.
  ///
  /// In en, this message translates to:
  /// **'Closed Jobs'**
  String get closed_jobs;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @job_type_label.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get job_type_label;

  /// No description provided for @open_status.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open_status;

  /// No description provided for @closed_status.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed_status;

  /// No description provided for @edit_job.
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get edit_job;

  /// No description provided for @delete_job.
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get delete_job;

  /// No description provided for @close_job.
  ///
  /// In en, this message translates to:
  /// **'Close Job'**
  String get close_job;

  /// No description provided for @delete_job_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get delete_job_confirm_title;

  /// No description provided for @delete_job_confirm_msg.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this job?\n\nThis action is permanent and you will NOT be able to recover this job.'**
  String get delete_job_confirm_msg;

  /// No description provided for @close_job_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Close Job'**
  String get close_job_confirm_title;

  /// No description provided for @close_job_confirm_msg.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to close this job?\n\nOnce closed, this job will no longer be active for applicants.'**
  String get close_job_confirm_msg;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @no_job_offers_yet.
  ///
  /// In en, this message translates to:
  /// **'No job offers yet'**
  String get no_job_offers_yet;

  /// No description provided for @create_first_job_offer.
  ///
  /// In en, this message translates to:
  /// **'Create your first job offer to get started'**
  String get create_first_job_offer;

  /// No description provided for @posted_jobs.
  ///
  /// In en, this message translates to:
  /// **'Posted Jobs'**
  String get posted_jobs;

  /// No description provided for @just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get just_now;

  /// No description provided for @min_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String min_ago(int count);

  /// No description provided for @hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hours_ago(int count);

  /// No description provided for @days_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String days_ago(int count);

  /// No description provided for @weeks_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeks_ago(int count);

  /// No description provided for @months_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String months_ago(int count);

  /// No description provided for @years_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} years ago'**
  String years_ago(int count);

  /// No description provided for @per_year.
  ///
  /// In en, this message translates to:
  /// **'/ Year'**
  String get per_year;

  /// No description provided for @k_per_year.
  ///
  /// In en, this message translates to:
  /// **'K / Year'**
  String get k_per_year;

  /// No description provided for @m_per_year.
  ///
  /// In en, this message translates to:
  /// **'M / Year'**
  String get m_per_year;

  /// No description provided for @job_title_pharmacist.
  ///
  /// In en, this message translates to:
  /// **'Pharmacist'**
  String get job_title_pharmacist;

  /// No description provided for @job_title_gerant.
  ///
  /// In en, this message translates to:
  /// **'Gerant'**
  String get job_title_gerant;

  /// No description provided for @job_title_physician.
  ///
  /// In en, this message translates to:
  /// **'Physician'**
  String get job_title_physician;

  /// No description provided for @job_title_senior_salesperson.
  ///
  /// In en, this message translates to:
  /// **'Senior Salesperson'**
  String get job_title_senior_salesperson;

  /// No description provided for @job_title_sales_specialist.
  ///
  /// In en, this message translates to:
  /// **'Sales Specialist'**
  String get job_title_sales_specialist;

  /// No description provided for @job_title_intern.
  ///
  /// In en, this message translates to:
  /// **'Intern'**
  String get job_title_intern;

  /// No description provided for @job_title_labeling_specialist.
  ///
  /// In en, this message translates to:
  /// **'Labeling Specialist'**
  String get job_title_labeling_specialist;

  /// No description provided for @job_title_data_entry_specialist.
  ///
  /// In en, this message translates to:
  /// **'Data Entry Specialist'**
  String get job_title_data_entry_specialist;

  /// No description provided for @job_title_stock_management_specialist.
  ///
  /// In en, this message translates to:
  /// **'Stock Management Specialist'**
  String get job_title_stock_management_specialist;

  /// No description provided for @job_type_full_time.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get job_type_full_time;

  /// No description provided for @job_type_part_time.
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get job_type_part_time;

  /// No description provided for @job_type_replacement.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get job_type_replacement;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @search_chats.
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get search_chats;

  /// No description provided for @no_chats_yet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get no_chats_yet;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You: {message}'**
  String you(String message);

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @no_messages_yet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get no_messages_yet;

  /// No description provided for @type_a_message.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_a_message;

  /// No description provided for @please_select_job_title.
  ///
  /// In en, this message translates to:
  /// **'Please select a job title.'**
  String get please_select_job_title;

  /// No description provided for @please_select_job_type.
  ///
  /// In en, this message translates to:
  /// **'Please select a job type.'**
  String get please_select_job_type;

  /// No description provided for @please_add_skill.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one skill.'**
  String get please_add_skill;

  /// No description provided for @recruiter_profile_not_found.
  ///
  /// In en, this message translates to:
  /// **'Recruiter profile not found.'**
  String get recruiter_profile_not_found;

  /// No description provided for @account_not_active.
  ///
  /// In en, this message translates to:
  /// **'Your account is not active. Please logout and login again or contact support.'**
  String get account_not_active;

  /// No description provided for @active_listing_required.
  ///
  /// In en, this message translates to:
  /// **'An active listing period is required to post pharmacy vacancies.'**
  String get active_listing_required;

  /// No description provided for @select_skills.
  ///
  /// In en, this message translates to:
  /// **'Select Skills'**
  String get select_skills;

  /// No description provided for @no_skills_available.
  ///
  /// In en, this message translates to:
  /// **'No skills available'**
  String get no_skills_available;

  /// No description provided for @create_job_offer.
  ///
  /// In en, this message translates to:
  /// **'Create Job Offer'**
  String get create_job_offer;

  /// No description provided for @edit_job_offer.
  ///
  /// In en, this message translates to:
  /// **'Edit Job Offer'**
  String get edit_job_offer;

  /// No description provided for @job_details.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get job_details;

  /// No description provided for @job_details_desc.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to post your job offer'**
  String get job_details_desc;

  /// No description provided for @job_title.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get job_title;

  /// No description provided for @job_type.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get job_type;

  /// No description provided for @required_skills.
  ///
  /// In en, this message translates to:
  /// **'Required Skills'**
  String get required_skills;

  /// No description provided for @required_skills_desc.
  ///
  /// In en, this message translates to:
  /// **'Add skills that candidates must have'**
  String get required_skills_desc;

  /// No description provided for @add_skills.
  ///
  /// In en, this message translates to:
  /// **'Add Skills'**
  String get add_skills;

  /// No description provided for @post_job_btn.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get post_job_btn;

  /// No description provided for @update_job_btn.
  ///
  /// In en, this message translates to:
  /// **'Update Job'**
  String get update_job_btn;

  /// No description provided for @search_skills_or_positions.
  ///
  /// In en, this message translates to:
  /// **'Search skills or positions…'**
  String get search_skills_or_positions;

  /// No description provided for @no_matches_for_query.
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\"'**
  String no_matches_for_query(String query);

  /// No description provided for @skill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get skill;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clear_all;

  /// No description provided for @clear_text.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear_text;

  /// No description provided for @show_profiles_selected_count.
  ///
  /// In en, this message translates to:
  /// **'Show profiles  ·  {count} selected'**
  String show_profiles_selected_count(int count);

  /// No description provided for @show_all_profiles.
  ///
  /// In en, this message translates to:
  /// **'Show all profiles'**
  String get show_all_profiles;

  /// No description provided for @job_seeker_profiles.
  ///
  /// In en, this message translates to:
  /// **'Job Seeker Profiles'**
  String get job_seeker_profiles;

  /// No description provided for @job_seeker_location.
  ///
  /// In en, this message translates to:
  /// **'Job Seeker Location'**
  String get job_seeker_location;

  /// No description provided for @candidate_location.
  ///
  /// In en, this message translates to:
  /// **'Candidate Location'**
  String get candidate_location;

  /// No description provided for @location_not_shared.
  ///
  /// In en, this message translates to:
  /// **'Location Not Shared'**
  String get location_not_shared;

  /// No description provided for @location_not_shared_desc.
  ///
  /// In en, this message translates to:
  /// **'This job seeker has not shared\ntheir location yet.'**
  String get location_not_shared_desc;

  /// No description provided for @verified_skills.
  ///
  /// In en, this message translates to:
  /// **'Verified Skills'**
  String get verified_skills;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @contact_and_location.
  ///
  /// In en, this message translates to:
  /// **'Contact & Location'**
  String get contact_and_location;

  /// No description provided for @block_profile.
  ///
  /// In en, this message translates to:
  /// **'Block Profile'**
  String get block_profile;

  /// No description provided for @block_user_account.
  ///
  /// In en, this message translates to:
  /// **'Block User Account'**
  String get block_user_account;

  /// No description provided for @block_user_reason_desc.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason. This message will be shown to the user.'**
  String get block_user_reason_desc;

  /// No description provided for @enter_block_reason.
  ///
  /// In en, this message translates to:
  /// **'Enter block reason...'**
  String get enter_block_reason;

  /// No description provided for @reason_is_required.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reason_is_required;

  /// No description provided for @confirm_block.
  ///
  /// In en, this message translates to:
  /// **'Confirm Block'**
  String get confirm_block;

  /// No description provided for @user_account_blocked.
  ///
  /// In en, this message translates to:
  /// **'User account blocked'**
  String get user_account_blocked;

  /// No description provided for @profiles_on_map.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 profile on map} other {{count} profiles on map}}'**
  String profiles_on_map(int count);

  /// No description provided for @tap_pin_or_scroll.
  ///
  /// In en, this message translates to:
  /// **'Tap a pin or scroll below'**
  String get tap_pin_or_scroll;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @no_skills_listed.
  ///
  /// In en, this message translates to:
  /// **'No skills listed'**
  String get no_skills_listed;

  /// No description provided for @plus_more_count.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String plus_more_count(int count);

  /// No description provided for @view_profile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get view_profile;

  /// No description provided for @no_profiles_match_filters.
  ///
  /// In en, this message translates to:
  /// **'No profiles match your filters'**
  String get no_profiles_match_filters;

  /// No description provided for @filter_profiles_hint.
  ///
  /// In en, this message translates to:
  /// **'Filter profiles…'**
  String get filter_profiles_hint;

  /// No description provided for @active_filters_count.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String active_filters_count(int count);

  /// No description provided for @show_results.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get show_results;

  /// No description provided for @search_wilaya.
  ///
  /// In en, this message translates to:
  /// **'Search wilaya…'**
  String get search_wilaya;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @no_profiles_location_hint.
  ///
  /// In en, this message translates to:
  /// **'No profiles have shared their location yet'**
  String get no_profiles_location_hint;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifications_unread.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notifications_unread(int count);

  /// No description provided for @mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get mark_all_read;

  /// No description provided for @all_notifications_marked_as_read.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get all_notifications_marked_as_read;

  /// No description provided for @no_notifications_title.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get no_notifications_title;

  /// No description provided for @no_notifications_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get no_notifications_subtitle;

  /// No description provided for @notification_detail.
  ///
  /// In en, this message translates to:
  /// **'Notification Detail'**
  String get notification_detail;

  /// No description provided for @job_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Job not found or has been removed.'**
  String get job_not_found_error;

  /// No description provided for @see_skill_requests.
  ///
  /// In en, this message translates to:
  /// **'See Skill Requests'**
  String get see_skill_requests;

  /// No description provided for @view_my_applications.
  ///
  /// In en, this message translates to:
  /// **'View My Applications'**
  String get view_my_applications;

  /// No description provided for @view_job.
  ///
  /// In en, this message translates to:
  /// **'View Job'**
  String get view_job;

  /// No description provided for @type_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get type_login;

  /// No description provided for @type_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get type_logout;

  /// No description provided for @type_payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get type_payment;

  /// No description provided for @type_job_post.
  ///
  /// In en, this message translates to:
  /// **'Job Post'**
  String get type_job_post;

  /// No description provided for @type_application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get type_application;

  /// No description provided for @type_skill_verified.
  ///
  /// In en, this message translates to:
  /// **'Skill Verified'**
  String get type_skill_verified;

  /// No description provided for @type_message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get type_message;

  /// No description provided for @type_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get type_general;

  /// No description provided for @post_job_appbar_title.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get post_job_appbar_title;

  /// No description provided for @test_mode_badge.
  ///
  /// In en, this message translates to:
  /// **'TEST MODE'**
  String get test_mode_badge;

  /// No description provided for @submitting_listing_request_banner.
  ///
  /// In en, this message translates to:
  /// **'Submitting your listing request… Please wait.'**
  String get submitting_listing_request_banner;

  /// No description provided for @test_mode_banner_title.
  ///
  /// In en, this message translates to:
  /// **'Test Mode — No real money charged'**
  String get test_mode_banner_title;

  /// No description provided for @test_card_details_label.
  ///
  /// In en, this message translates to:
  /// **'Test card details (EDAHABIA):'**
  String get test_card_details_label;

  /// No description provided for @test_card_number_label.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get test_card_number_label;

  /// No description provided for @test_card_expiry_label.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get test_card_expiry_label;

  /// No description provided for @test_card_future_date_label.
  ///
  /// In en, this message translates to:
  /// **'Any future date'**
  String get test_card_future_date_label;

  /// No description provided for @test_card_otp_label.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get test_card_otp_label;

  /// No description provided for @active_plan_label.
  ///
  /// In en, this message translates to:
  /// **'Active Plan'**
  String get active_plan_label;

  /// No description provided for @no_active_plan_label.
  ///
  /// In en, this message translates to:
  /// **'No Active Plan'**
  String get no_active_plan_label;

  /// No description provided for @annual_job_listing_title.
  ///
  /// In en, this message translates to:
  /// **'Annual Job Listing — Pharmacy {year}'**
  String annual_job_listing_title(int year);

  /// No description provided for @list_vacancy_hint_subtitle.
  ///
  /// In en, this message translates to:
  /// **'List a vacancy to reach verified pharmacists'**
  String get list_vacancy_hint_subtitle;

  /// No description provided for @payment_expires_label.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get payment_expires_label;

  /// No description provided for @payment_days_left_label.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get payment_days_left_label;

  /// No description provided for @payment_days_count.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String payment_days_count(int count);

  /// No description provided for @payment_paid_label.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payment_paid_label;

  /// No description provided for @payment_method_label.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get payment_method_label;

  /// No description provided for @payment_method_edahabia.
  ///
  /// In en, this message translates to:
  /// **'EDAHABIA'**
  String get payment_method_edahabia;

  /// No description provided for @payment_method_cib.
  ///
  /// In en, this message translates to:
  /// **'CIB'**
  String get payment_method_cib;

  /// No description provided for @payment_method_unknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get payment_method_unknown;

  /// No description provided for @listing_expires_warning_banner.
  ///
  /// In en, this message translates to:
  /// **'Your job listing expires in {days} days. Relist to stay visible.'**
  String listing_expires_warning_banner(int days);

  /// No description provided for @list_pharmacy_vacancy_btn.
  ///
  /// In en, this message translates to:
  /// **'List Your Pharmacy Vacancy'**
  String get list_pharmacy_vacancy_btn;

  /// No description provided for @list_another_vacancy_btn.
  ///
  /// In en, this message translates to:
  /// **'List Another Vacancy'**
  String get list_another_vacancy_btn;

  /// No description provided for @job_posting_history_title.
  ///
  /// In en, this message translates to:
  /// **'Job Posting History'**
  String get job_posting_history_title;

  /// No description provided for @payment_test_success_toast.
  ///
  /// In en, this message translates to:
  /// **'Test payment successful. Job listing activated.'**
  String get payment_test_success_toast;

  /// No description provided for @payment_success_toast.
  ///
  /// In en, this message translates to:
  /// **'Job listing activated. Your vacancy is now visible to pharmacists.'**
  String get payment_success_toast;

  /// No description provided for @submit_listing_request_error.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your listing request. Please try again.'**
  String get submit_listing_request_error;

  /// No description provided for @payment_connection_error.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your network and try again.'**
  String get payment_connection_error;

  /// No description provided for @listing_request_failed_error.
  ///
  /// In en, this message translates to:
  /// **'Listing request failed: {message}'**
  String listing_request_failed_error(String message);

  /// No description provided for @listing_service_unreachable_error.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the listing service. Try again.'**
  String get listing_service_unreachable_error;

  /// No description provided for @payment_generic_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get payment_generic_error;

  /// No description provided for @payment_incomplete_error.
  ///
  /// In en, this message translates to:
  /// **'Payment was not completed. Please try again.'**
  String get payment_incomplete_error;

  /// No description provided for @report_issue_title.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get report_issue_title;

  /// No description provided for @edit_issue_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Issue'**
  String get edit_issue_title;

  /// No description provided for @issue_details_label.
  ///
  /// In en, this message translates to:
  /// **'Issue Details'**
  String get issue_details_label;

  /// No description provided for @issue_title_label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get issue_title_label;

  /// No description provided for @issue_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Short issue summary'**
  String get issue_title_hint;

  /// No description provided for @issue_category_label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get issue_category_label;

  /// No description provided for @issue_priority_label.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get issue_priority_label;

  /// No description provided for @issue_description_label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get issue_description_label;

  /// No description provided for @issue_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Explain the problem in detail'**
  String get issue_description_hint;

  /// No description provided for @admin_comment_label.
  ///
  /// In en, this message translates to:
  /// **'Admin Comment'**
  String get admin_comment_label;

  /// No description provided for @submit_issue_btn.
  ///
  /// In en, this message translates to:
  /// **'Submit Issue'**
  String get submit_issue_btn;

  /// No description provided for @update_issue_btn.
  ///
  /// In en, this message translates to:
  /// **'Update Issue'**
  String get update_issue_btn;

  /// No description provided for @enter_issue_title_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter issue title'**
  String get enter_issue_title_error;

  /// No description provided for @select_category_error.
  ///
  /// In en, this message translates to:
  /// **'Please select category'**
  String get select_category_error;

  /// No description provided for @describe_issue_error.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get describe_issue_error;

  /// No description provided for @reported_issues_admin_title.
  ///
  /// In en, this message translates to:
  /// **'Reported Issues'**
  String get reported_issues_admin_title;

  /// No description provided for @my_reported_issues_title.
  ///
  /// In en, this message translates to:
  /// **'My Reported Issues'**
  String get my_reported_issues_title;

  /// No description provided for @failed_load_issues_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load issues'**
  String get failed_load_issues_error;

  /// No description provided for @no_issues_reported_title.
  ///
  /// In en, this message translates to:
  /// **'No issues reported yet'**
  String get no_issues_reported_title;

  /// No description provided for @report_problem_hint.
  ///
  /// In en, this message translates to:
  /// **'If you face any problem, report it here.'**
  String get report_problem_hint;

  /// No description provided for @cat_crash.
  ///
  /// In en, this message translates to:
  /// **'Crash'**
  String get cat_crash;

  /// No description provided for @cat_ui_issue.
  ///
  /// In en, this message translates to:
  /// **'UI Issue'**
  String get cat_ui_issue;

  /// No description provided for @cat_performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get cat_performance;

  /// No description provided for @cat_payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get cat_payment;

  /// No description provided for @cat_login_auth.
  ///
  /// In en, this message translates to:
  /// **'Login / Auth'**
  String get cat_login_auth;

  /// No description provided for @cat_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cat_other;

  /// No description provided for @priority_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priority_low;

  /// No description provided for @priority_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priority_medium;

  /// No description provided for @priority_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priority_high;

  /// No description provided for @priority_critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priority_critical;

  /// No description provided for @status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get status_open;

  /// No description provided for @status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get status_in_progress;

  /// No description provided for @status_resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get status_resolved;

  /// No description provided for @status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get status_rejected;

  /// No description provided for @issue_details_title.
  ///
  /// In en, this message translates to:
  /// **'Issue Details'**
  String get issue_details_title;

  /// No description provided for @description_label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description_label;

  /// No description provided for @response_label.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response_label;

  /// No description provided for @user_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get user_not_found_error;

  /// No description provided for @reply_btn.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply_btn;

  /// No description provided for @anonymous_job_seeker.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Job Seeker'**
  String get anonymous_job_seeker;

  /// No description provided for @active_recruiter.
  ///
  /// In en, this message translates to:
  /// **'Active Recruiter'**
  String get active_recruiter;

  /// No description provided for @inactive_recruiter.
  ///
  /// In en, this message translates to:
  /// **'Inactive Recruiter'**
  String get inactive_recruiter;

  /// No description provided for @joined_label.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined_label;

  /// No description provided for @notif_job_posted_title.
  ///
  /// In en, this message translates to:
  /// **'Job Posted'**
  String get notif_job_posted_title;

  /// No description provided for @notif_job_posted_desc.
  ///
  /// In en, this message translates to:
  /// **'You posted a new job: {jobTitle}'**
  String notif_job_posted_desc(String jobTitle);

  /// No description provided for @notif_job_apply_title.
  ///
  /// In en, this message translates to:
  /// **'New Application'**
  String get notif_job_apply_title;

  /// No description provided for @notif_job_apply_desc.
  ///
  /// In en, this message translates to:
  /// **'You have a new application for {jobTitle}'**
  String notif_job_apply_desc(String jobTitle);

  /// No description provided for @notif_skill_verified_title.
  ///
  /// In en, this message translates to:
  /// **'Skill Verified'**
  String get notif_skill_verified_title;

  /// No description provided for @notif_skill_verified_desc.
  ///
  /// In en, this message translates to:
  /// **'Your skill {skillName} has been verified'**
  String notif_skill_verified_desc(String skillName);

  /// No description provided for @notif_payment_success_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get notif_payment_success_title;

  /// No description provided for @notif_payment_success_desc.
  ///
  /// In en, this message translates to:
  /// **'Your payment for {planName} was successful'**
  String notif_payment_success_desc(String planName);

  /// No description provided for @notif_login_title.
  ///
  /// In en, this message translates to:
  /// **'Login Alert'**
  String get notif_login_title;

  /// No description provided for @notif_login_desc.
  ///
  /// In en, this message translates to:
  /// **'You logged in at {time}'**
  String notif_login_desc(String time);

  /// No description provided for @notif_logout_title.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get notif_logout_title;

  /// No description provided for @notif_logout_desc.
  ///
  /// In en, this message translates to:
  /// **'You have been logged out'**
  String get notif_logout_desc;

  /// No description provided for @notif_issue_reported_title.
  ///
  /// In en, this message translates to:
  /// **'Issue Reported'**
  String get notif_issue_reported_title;

  /// No description provided for @notif_issue_reported_desc.
  ///
  /// In en, this message translates to:
  /// **'Your issue \'{title}\' has been successfully reported.'**
  String notif_issue_reported_desc(String title);

  /// No description provided for @notif_issue_resolved_title.
  ///
  /// In en, this message translates to:
  /// **'Issue Resolved'**
  String get notif_issue_resolved_title;

  /// No description provided for @notif_issue_resolved_desc.
  ///
  /// In en, this message translates to:
  /// **'Your issue \'{title}\' has been marked as resolved.'**
  String notif_issue_resolved_desc(String title);

  /// No description provided for @notif_admin_new_issue_title.
  ///
  /// In en, this message translates to:
  /// **'New Issue Reported'**
  String get notif_admin_new_issue_title;

  /// No description provided for @notif_admin_new_issue_desc.
  ///
  /// In en, this message translates to:
  /// **'A new issue \'{title}\' was reported by a user.'**
  String notif_admin_new_issue_desc(String title);

  /// No description provided for @notif_admin_issue_resolved_title.
  ///
  /// In en, this message translates to:
  /// **'Issue Resolved'**
  String get notif_admin_issue_resolved_title;

  /// No description provided for @notif_admin_issue_resolved_desc.
  ///
  /// In en, this message translates to:
  /// **'Issue \'{title}\' has been resolved.'**
  String notif_admin_issue_resolved_desc(String title);

  /// No description provided for @apply_btn.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply_btn;

  /// No description provided for @applied_btn.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied_btn;

  /// No description provided for @hire_query_btn.
  ///
  /// In en, this message translates to:
  /// **'Hire ?'**
  String get hire_query_btn;

  /// No description provided for @hire_btn.
  ///
  /// In en, this message translates to:
  /// **'Hire'**
  String get hire_btn;

  /// No description provided for @hired_btn.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get hired_btn;

  /// No description provided for @reject_btn.
  ///
  /// In en, this message translates to:
  /// **'REJECT'**
  String get reject_btn;

  /// No description provided for @job_applicants_title.
  ///
  /// In en, this message translates to:
  /// **'Job Applicants'**
  String get job_applicants_title;

  /// No description provided for @recruiter_info_title.
  ///
  /// In en, this message translates to:
  /// **'Recruiter Information'**
  String get recruiter_info_title;

  /// No description provided for @required_skills_title.
  ///
  /// In en, this message translates to:
  /// **'Required Skills'**
  String get required_skills_title;

  /// No description provided for @no_applicants_yet_label.
  ///
  /// In en, this message translates to:
  /// **'No applicants yet'**
  String get no_applicants_yet_label;

  /// No description provided for @hire_candidate_title.
  ///
  /// In en, this message translates to:
  /// **'Hire Candidate'**
  String get hire_candidate_title;

  /// No description provided for @hire_confirm_msg.
  ///
  /// In en, this message translates to:
  /// **'Once hired, this action cannot be undone.'**
  String get hire_confirm_msg;

  /// No description provided for @reject_applicant_title.
  ///
  /// In en, this message translates to:
  /// **'Reject Applicant'**
  String get reject_applicant_title;

  /// No description provided for @reject_confirm_msg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this job seeker?\n\nOnce rejected, you will NOT be able to contact this candidate for this job again.'**
  String get reject_confirm_msg;

  /// No description provided for @skill_rejected_label.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get skill_rejected_label;

  /// No description provided for @applicants_tab.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicants_tab;

  /// No description provided for @stats_tab.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats_tab;

  /// No description provided for @please_apply_first_chat.
  ///
  /// In en, this message translates to:
  /// **'Please apply first before chatting.'**
  String get please_apply_first_chat;

  /// No description provided for @show_route_btn.
  ///
  /// In en, this message translates to:
  /// **'Show Route'**
  String get show_route_btn;

  /// No description provided for @hide_route_btn.
  ///
  /// In en, this message translates to:
  /// **'Hide Route'**
  String get hide_route_btn;

  /// No description provided for @open_in_maps_btn.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get open_in_maps_btn;

  /// No description provided for @getting_route_loading.
  ///
  /// In en, this message translates to:
  /// **'Getting route…'**
  String get getting_route_loading;

  /// No description provided for @your_location_label.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get your_location_label;

  /// No description provided for @chat_btn.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_btn;

  /// No description provided for @accept_btn.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept_btn;

  /// No description provided for @job_open_label.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get job_open_label;

  /// No description provided for @job_closed_label.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get job_closed_label;

  /// No description provided for @job_views_stats_title.
  ///
  /// In en, this message translates to:
  /// **'Job Views ({count} total)'**
  String job_views_stats_title(Object count);

  /// No description provided for @job_applications_stats_title.
  ///
  /// In en, this message translates to:
  /// **'Job Applications ({count} total)'**
  String job_applications_stats_title(Object count);

  /// No description provided for @mon_short.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon_short;

  /// No description provided for @tue_short.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue_short;

  /// No description provided for @wed_short.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed_short;

  /// No description provided for @thu_short.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu_short;

  /// No description provided for @fri_short.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri_short;

  /// No description provided for @sat_short.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat_short;

  /// No description provided for @sun_short.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun_short;

  /// No description provided for @unread_messages_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No unread messages} =1 {1 unread message} other {{count} unread messages}}'**
  String unread_messages_count(int count);

  /// No description provided for @staff_pharmacist_hiring.
  ///
  /// In en, this message translates to:
  /// **'Hiring Staff Pharmacist'**
  String get staff_pharmacist_hiring;

  /// No description provided for @staff_pharmacist_vacancy.
  ///
  /// In en, this message translates to:
  /// **'Staff Pharmacist Vacancy'**
  String get staff_pharmacist_vacancy;

  /// No description provided for @staff_pharmacist_opportunity.
  ///
  /// In en, this message translates to:
  /// **'Staff Pharmacist Opportunity'**
  String get staff_pharmacist_opportunity;

  /// No description provided for @find_pharmacy_job_title.
  ///
  /// In en, this message translates to:
  /// **'Find a pharmacy job'**
  String get find_pharmacy_job_title;

  /// No description provided for @featured_jobs_title.
  ///
  /// In en, this message translates to:
  /// **'Featured jobs'**
  String get featured_jobs_title;

  /// No description provided for @interested_in_pharmacy_msg.
  ///
  /// In en, this message translates to:
  /// **'Because you are interested in pharmacy'**
  String get interested_in_pharmacy_msg;

  /// No description provided for @failed_to_load_jobs.
  ///
  /// In en, this message translates to:
  /// **'Failed to load jobs'**
  String get failed_to_load_jobs;

  /// No description provided for @no_jobs_available.
  ///
  /// In en, this message translates to:
  /// **'No jobs'**
  String get no_jobs_available;

  /// No description provided for @filter_jobs_title.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filter_jobs_title;

  /// No description provided for @search_job_titles_hint.
  ///
  /// In en, this message translates to:
  /// **'Search job titles'**
  String get search_job_titles_hint;

  /// No description provided for @search_skills_hint.
  ///
  /// In en, this message translates to:
  /// **'Search skills'**
  String get search_skills_hint;

  /// No description provided for @apply_filters_btn.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply_filters_btn;

  /// No description provided for @candidate_label.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get candidate_label;

  /// No description provided for @enter_job_keyword_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter job title or keyword'**
  String get enter_job_keyword_hint;

  /// No description provided for @job_seeker_label.
  ///
  /// In en, this message translates to:
  /// **'Job Seeker'**
  String get job_seeker_label;

  /// No description provided for @apply_now_btn.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get apply_now_btn;

  /// No description provided for @featured_job_salary.
  ///
  /// In en, this message translates to:
  /// **'{amount} / year'**
  String featured_job_salary(String amount);

  /// No description provided for @all_cities.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_cities;

  /// No description provided for @city_algiers.
  ///
  /// In en, this message translates to:
  /// **'Algiers'**
  String get city_algiers;

  /// No description provided for @city_oran.
  ///
  /// In en, this message translates to:
  /// **'Oran'**
  String get city_oran;

  /// No description provided for @city_constantine.
  ///
  /// In en, this message translates to:
  /// **'Constantine'**
  String get city_constantine;

  /// No description provided for @city_annaba.
  ///
  /// In en, this message translates to:
  /// **'Annaba'**
  String get city_annaba;

  /// No description provided for @city_blida.
  ///
  /// In en, this message translates to:
  /// **'Blida'**
  String get city_blida;

  /// No description provided for @city_tizi_ouzou.
  ///
  /// In en, this message translates to:
  /// **'Tizi Ouzou'**
  String get city_tizi_ouzou;

  /// No description provided for @city_bejaia.
  ///
  /// In en, this message translates to:
  /// **'Bejaia'**
  String get city_bejaia;

  /// No description provided for @city_setif.
  ///
  /// In en, this message translates to:
  /// **'Setif'**
  String get city_setif;

  /// No description provided for @city_batna.
  ///
  /// In en, this message translates to:
  /// **'Batna'**
  String get city_batna;

  /// No description provided for @city_skikda.
  ///
  /// In en, this message translates to:
  /// **'Skikda'**
  String get city_skikda;

  /// No description provided for @city_chlef.
  ///
  /// In en, this message translates to:
  /// **'Chlef'**
  String get city_chlef;

  /// No description provided for @city_mostaganem.
  ///
  /// In en, this message translates to:
  /// **'Mostaganem'**
  String get city_mostaganem;

  /// No description provided for @city_tlemcen.
  ///
  /// In en, this message translates to:
  /// **'Tlemcen'**
  String get city_tlemcen;

  /// No description provided for @city_biskra.
  ///
  /// In en, this message translates to:
  /// **'Biskra'**
  String get city_biskra;

  /// No description provided for @city_ouargla.
  ///
  /// In en, this message translates to:
  /// **'Ouargla'**
  String get city_ouargla;

  /// No description provided for @city_ghardaia.
  ///
  /// In en, this message translates to:
  /// **'Ghardaia'**
  String get city_ghardaia;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get nav_jobs;

  /// No description provided for @nav_messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get nav_messages;

  /// No description provided for @nav_profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get nav_profiles;

  /// No description provided for @nav_applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get nav_applications;

  /// No description provided for @nav_insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get nav_insights;

  /// No description provided for @nav_recruiters.
  ///
  /// In en, this message translates to:
  /// **'Recruiters'**
  String get nav_recruiters;

  /// No description provided for @nav_jobseekers.
  ///
  /// In en, this message translates to:
  /// **'Job Seekers'**
  String get nav_jobseekers;

  /// No description provided for @del_account_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get del_account_title;

  /// No description provided for @del_account_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get del_account_warning;

  /// No description provided for @del_account_body.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently remove:\n• Your profile\n• Login data\n• All your records\n\nThis cannot be undone.'**
  String get del_account_body;

  /// No description provided for @del_account_btn.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get del_account_btn;

  /// No description provided for @del_account_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get del_account_dialog_title;

  /// No description provided for @del_account_dialog_msg.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all data. This cannot be undone.'**
  String get del_account_dialog_msg;

  /// No description provided for @del_account_not_auth.
  ///
  /// In en, this message translates to:
  /// **'Not signed in. Please log in again.'**
  String get del_account_not_auth;

  /// No description provided for @del_account_error.
  ///
  /// In en, this message translates to:
  /// **'Please log in again and retry.'**
  String get del_account_error;

  /// No description provided for @profile_strength.
  ///
  /// In en, this message translates to:
  /// **'Profile Strength'**
  String get profile_strength;

  /// No description provided for @job_applications_nav.
  ///
  /// In en, this message translates to:
  /// **'Job Applications'**
  String get job_applications_nav;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @job_matches.
  ///
  /// In en, this message translates to:
  /// **'Job Matches'**
  String get job_matches;

  /// No description provided for @based_on_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile'**
  String get based_on_your_profile;

  /// No description provided for @skills_verified_count.
  ///
  /// In en, this message translates to:
  /// **'Skills Verified'**
  String get skills_verified_count;

  /// No description provided for @improve_visibility.
  ///
  /// In en, this message translates to:
  /// **'Improve visibility'**
  String get improve_visibility;

  /// No description provided for @profile_views_count.
  ///
  /// In en, this message translates to:
  /// **'Profile Views'**
  String get profile_views_count;

  /// No description provided for @recruiters_viewed_you.
  ///
  /// In en, this message translates to:
  /// **'Recruiters viewed you'**
  String get recruiters_viewed_you;

  /// No description provided for @profile_visibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get profile_visibility;

  /// No description provided for @visibility_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get visibility_high;

  /// No description provided for @visibility_anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get visibility_anonymous;

  /// No description provided for @privacy_mode.
  ///
  /// In en, this message translates to:
  /// **'Privacy Mode'**
  String get privacy_mode;

  /// No description provided for @skill_verification_title.
  ///
  /// In en, this message translates to:
  /// **'Skill Verification'**
  String get skill_verification_title;

  /// No description provided for @verify_your_skills.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Skills'**
  String get verify_your_skills;

  /// No description provided for @verify_skills_desc.
  ///
  /// In en, this message translates to:
  /// **'Ask a pharmacy you\'ve worked with to confirm your experience'**
  String get verify_skills_desc;

  /// No description provided for @status_verified_label.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get status_verified_label;

  /// No description provided for @status_pending_label.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending_label;

  /// No description provided for @status_rejected_label.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get status_rejected_label;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @profile_views_drawer.
  ///
  /// In en, this message translates to:
  /// **'Profile Views'**
  String get profile_views_drawer;

  /// No description provided for @profile_views_desc.
  ///
  /// In en, this message translates to:
  /// **'Recruiters who viewed you'**
  String get profile_views_desc;

  /// No description provided for @personal_pro_info.
  ///
  /// In en, this message translates to:
  /// **'Personal & professional info'**
  String get personal_pro_info;

  /// No description provided for @find_your_next_role.
  ///
  /// In en, this message translates to:
  /// **'Find your next role'**
  String get find_your_next_role;

  /// No description provided for @pharmacies_on_map.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 pharmacy on map} other {{count} pharmacies on map}}'**
  String pharmacies_on_map(num count);

  /// No description provided for @tap_pin_or_scroll_below.
  ///
  /// In en, this message translates to:
  /// **'Tap a pin or scroll below'**
  String get tap_pin_or_scroll_below;

  /// No description provided for @pharmacy_profile.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Profile'**
  String get pharmacy_profile;

  /// No description provided for @available_jobs_count.
  ///
  /// In en, this message translates to:
  /// **'Available Jobs ({count})'**
  String available_jobs_count(Object count);

  /// No description provided for @no_active_jobs_available.
  ///
  /// In en, this message translates to:
  /// **'No active jobs available right now.'**
  String get no_active_jobs_available;

  /// No description provided for @no_jobs_location_hint.
  ///
  /// In en, this message translates to:
  /// **'No jobs available at this location'**
  String get no_jobs_location_hint;

  /// No description provided for @filter_btn.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter_btn;

  /// No description provided for @clear_btn.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear_btn;

  /// No description provided for @my_applications_title.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get my_applications_title;

  /// No description provided for @failed_to_load_applications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load applications'**
  String get failed_to_load_applications;

  /// No description provided for @status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get status_accepted;

  /// No description provided for @status_viewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get status_viewed;

  /// No description provided for @status_applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get status_applied;

  /// No description provided for @chat_with_recruiter.
  ///
  /// In en, this message translates to:
  /// **'Chat with recruiter'**
  String get chat_with_recruiter;

  /// No description provided for @open_chat_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat. Please try again.'**
  String get open_chat_failed;

  /// No description provided for @no_applications_title.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get no_applications_title;

  /// No description provided for @no_applications_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply to jobs and track them here'**
  String get no_applications_subtitle;

  /// No description provided for @time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get time_just_now;

  /// No description provided for @time_min_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String time_min_ago(int count);

  /// No description provided for @time_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String time_hours_ago(int count);

  /// No description provided for @time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String time_days_ago(int count);

  /// No description provided for @time_weeks_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String time_weeks_ago(int count);

  /// No description provided for @time_months_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String time_months_ago(int count);

  /// No description provided for @time_years_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String time_years_ago(int count);

  /// No description provided for @salary_per_year.
  ///
  /// In en, this message translates to:
  /// **'{salary} / Year'**
  String salary_per_year(String salary);

  /// No description provided for @profile_analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Profile Analytics'**
  String get profile_analytics_title;

  /// No description provided for @views_trend_title.
  ///
  /// In en, this message translates to:
  /// **'Views Trend'**
  String get views_trend_title;

  /// No description provided for @last_7_days_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last_7_days_subtitle;

  /// No description provided for @total_profile_views.
  ///
  /// In en, this message translates to:
  /// **'Total Profile Views'**
  String get total_profile_views;

  /// No description provided for @this_week_views.
  ///
  /// In en, this message translates to:
  /// **'+{count} this week'**
  String this_week_views(int count);

  /// No description provided for @recruiters_label.
  ///
  /// In en, this message translates to:
  /// **'Recruiters'**
  String get recruiters_label;

  /// No description provided for @todays_views_label.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Views'**
  String get todays_views_label;

  /// No description provided for @daily_breakdown_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Breakdown'**
  String get daily_breakdown_title;

  /// No description provided for @today_label.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today_label;

  /// No description provided for @views_count_tooltip.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String views_count_tooltip(int count);

  /// No description provided for @no_trend_data.
  ///
  /// In en, this message translates to:
  /// **'No trend data yet'**
  String get no_trend_data;

  /// No description provided for @no_profile_views_title.
  ///
  /// In en, this message translates to:
  /// **'No profile views yet'**
  String get no_profile_views_title;

  /// No description provided for @no_profile_views_subtitle.
  ///
  /// In en, this message translates to:
  /// **'When recruiters view your profile,\nyour analytics will appear here.'**
  String get no_profile_views_subtitle;

  /// No description provided for @day_mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get day_mon;

  /// No description provided for @day_tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get day_tue;

  /// No description provided for @day_wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get day_wed;

  /// No description provided for @day_thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get day_thu;

  /// No description provided for @day_fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get day_fri;

  /// No description provided for @day_sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get day_sat;

  /// No description provided for @day_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get day_sun;

  /// No description provided for @select_pharmacy_title.
  ///
  /// In en, this message translates to:
  /// **'Select Pharmacy'**
  String get select_pharmacy_title;

  /// No description provided for @search_pharmacy_hint.
  ///
  /// In en, this message translates to:
  /// **'Search pharmacy by name'**
  String get search_pharmacy_hint;

  /// No description provided for @no_pharmacies_found.
  ///
  /// In en, this message translates to:
  /// **'No pharmacies found'**
  String get no_pharmacies_found;

  /// No description provided for @skill_verification_requests_title.
  ///
  /// In en, this message translates to:
  /// **'Skill Verification Requests'**
  String get skill_verification_requests_title;

  /// No description provided for @verification_request_sent_success.
  ///
  /// In en, this message translates to:
  /// **'Verification request sent successfully!'**
  String get verification_request_sent_success;

  /// No description provided for @failed_to_send_request.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request: {error}'**
  String failed_to_send_request(String error);

  /// No description provided for @add_note_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Add a Note (Optional)'**
  String get add_note_dialog_title;

  /// No description provided for @add_note_dialog_hint.
  ///
  /// In en, this message translates to:
  /// **'Add any additional information for the recruiter...'**
  String get add_note_dialog_hint;

  /// No description provided for @dialog_cancel_btn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel_btn;

  /// No description provided for @send_request_btn.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get send_request_btn;

  /// No description provided for @status_not_requested.
  ///
  /// In en, this message translates to:
  /// **'Not Requested'**
  String get status_not_requested;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_completed;

  /// No description provided for @request_skill_verification_purpose.
  ///
  /// In en, this message translates to:
  /// **'Request skill verification from this recruiter to strengthen your profile credibility and ranking.'**
  String get request_skill_verification_purpose;

  /// No description provided for @send_skill_verification_request_btn.
  ///
  /// In en, this message translates to:
  /// **'Send Skill Verification Request'**
  String get send_skill_verification_request_btn;

  /// No description provided for @verification_request_pending_desc.
  ///
  /// In en, this message translates to:
  /// **'Verification request pending. The recruiter will review your skills soon.'**
  String get verification_request_pending_desc;

  /// No description provided for @verification_completed_desc.
  ///
  /// In en, this message translates to:
  /// **'Verification completed! This recruiter has reviewed your skills.'**
  String get verification_completed_desc;

  /// No description provided for @chat_with_recruiter_btn.
  ///
  /// In en, this message translates to:
  /// **'Chat with Recruiter'**
  String get chat_with_recruiter_btn;

  /// No description provided for @failed_to_open_chat.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat: {error}'**
  String failed_to_open_chat(String error);

  /// No description provided for @no_applications_yet_title.
  ///
  /// In en, this message translates to:
  /// **'No Applications Yet'**
  String get no_applications_yet_title;

  /// No description provided for @apply_to_jobs_for_verification_desc.
  ///
  /// In en, this message translates to:
  /// **'Apply to jobs to request skill verification from recruiters'**
  String get apply_to_jobs_for_verification_desc;

  /// No description provided for @create_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get create_profile_title;

  /// No description provided for @my_profile_title.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile_title;

  /// No description provided for @personal_information_title.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_information_title;

  /// No description provided for @first_name_label.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name_label;

  /// No description provided for @last_name_label.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name_label;

  /// No description provided for @show_my_name_label.
  ///
  /// In en, this message translates to:
  /// **'Show my name to recruiters'**
  String get show_my_name_label;

  /// No description provided for @location_information_title.
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get location_information_title;

  /// No description provided for @my_location_title.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get my_location_title;

  /// No description provided for @change_location_btn.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change_location_btn;

  /// No description provided for @set_location_btn.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set_location_btn;

  /// No description provided for @current_job_title_title.
  ///
  /// In en, this message translates to:
  /// **'Current job title'**
  String get current_job_title_title;

  /// No description provided for @select_job_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Select your current job title'**
  String get select_job_title_hint;

  /// No description provided for @skills_title.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills_title;

  /// No description provided for @add_skill_btn.
  ///
  /// In en, this message translates to:
  /// **'Add Skill'**
  String get add_skill_btn;

  /// No description provided for @background_title.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background_title;

  /// No description provided for @job_experience_hint.
  ///
  /// In en, this message translates to:
  /// **'Select your job experience level'**
  String get job_experience_hint;

  /// No description provided for @save_changes_btn.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes_btn;

  /// No description provided for @select_skills_title.
  ///
  /// In en, this message translates to:
  /// **'Select Skills'**
  String get select_skills_title;

  /// No description provided for @no_experience_available.
  ///
  /// In en, this message translates to:
  /// **'No experience levels available'**
  String get no_experience_available;

  /// No description provided for @no_options_available.
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get no_options_available;

  /// No description provided for @select_province_hint.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get select_province_hint;

  /// No description provided for @loading_hint.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading_hint;

  /// No description provided for @select_city_hint.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get select_city_hint;

  /// No description provided for @fill_required_fields_error.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fill_required_fields_error;

  /// No description provided for @phone_required_error.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_required_error;

  /// No description provided for @phone_nine_digits_error.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 9 digits'**
  String get phone_nine_digits_error;

  /// No description provided for @phone_invalid_start_error.
  ///
  /// In en, this message translates to:
  /// **'Phone must start with 5, 6, or 7 (Algeria only)'**
  String get phone_invalid_start_error;

  /// No description provided for @status_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get status_verified;

  /// No description provided for @crop_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Crop Photo'**
  String get crop_photo_title;

  /// No description provided for @camera_btn.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera_btn;

  /// No description provided for @gallery_btn.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery_btn;

  /// No description provided for @remove_photo_btn.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get remove_photo_btn;

  /// No description provided for @general_save_btn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get general_save_btn;

  /// No description provided for @general_change_btn.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get general_change_btn;

  /// No description provided for @recrop_btn.
  ///
  /// In en, this message translates to:
  /// **'Recrop'**
  String get recrop_btn;

  /// No description provided for @add_profile_photo_label.
  ///
  /// In en, this message translates to:
  /// **'Add profile photo'**
  String get add_profile_photo_label;

  /// No description provided for @admin_active_jobs_title.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get admin_active_jobs_title;

  /// No description provided for @admin_active_jobs_sub.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get admin_active_jobs_sub;

  /// No description provided for @admin_skill_req_title.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get admin_skill_req_title;

  /// No description provided for @admin_skill_req_sub.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get admin_skill_req_sub;

  /// No description provided for @admin_recruiters_title.
  ///
  /// In en, this message translates to:
  /// **'Recruiters'**
  String get admin_recruiters_title;

  /// No description provided for @admin_recruiters_sub.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get admin_recruiters_sub;

  /// No description provided for @admin_seekers_title.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get admin_seekers_title;

  /// No description provided for @admin_seekers_sub.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get admin_seekers_sub;

  /// No description provided for @admin_platform_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get admin_platform_activity;

  /// No description provided for @admin_platform_activity_desc.
  ///
  /// In en, this message translates to:
  /// **'General Overview'**
  String get admin_platform_activity_desc;

  /// No description provided for @admin_open_jobs.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get admin_open_jobs;

  /// No description provided for @admin_closed_jobs.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get admin_closed_jobs;

  /// No description provided for @admin_user_activity.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admin_user_activity;

  /// No description provided for @admin_user_activity_desc.
  ///
  /// In en, this message translates to:
  /// **'Candidates vs Recruiters'**
  String get admin_user_activity_desc;

  /// No description provided for @admin_reported_issues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get admin_reported_issues;

  /// No description provided for @admin_total_earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get admin_total_earnings;

  /// No description provided for @admin_job_status_overview.
  ///
  /// In en, this message translates to:
  /// **'Job Offer Status Overview'**
  String get admin_job_status_overview;

  /// No description provided for @admin_jobs_open_count.
  ///
  /// In en, this message translates to:
  /// **'You currently have {active} of {total} jobs open'**
  String admin_jobs_open_count(int active, int total);

  /// No description provided for @admin_manage_account.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get admin_manage_account;

  /// No description provided for @admin_active_label.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get admin_active_label;

  /// No description provided for @admin_drawer_payments_title.
  ///
  /// In en, this message translates to:
  /// **'Payments from Recruiters'**
  String get admin_drawer_payments_title;

  /// No description provided for @admin_drawer_payments_sub.
  ///
  /// In en, this message translates to:
  /// **'View payments from recruiters'**
  String get admin_drawer_payments_sub;

  /// No description provided for @admin_drawer_job_options_title.
  ///
  /// In en, this message translates to:
  /// **'Add Job Title/Skill'**
  String get admin_drawer_job_options_title;

  /// No description provided for @admin_drawer_job_options_sub.
  ///
  /// In en, this message translates to:
  /// **'Add new job titles or skills to the system'**
  String get admin_drawer_job_options_sub;

  /// No description provided for @admin_drawer_job_types_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Job Types'**
  String get admin_drawer_job_types_title;

  /// No description provided for @admin_drawer_job_types_sub.
  ///
  /// In en, this message translates to:
  /// **'Manage job types available in the app'**
  String get admin_drawer_job_types_sub;

  /// No description provided for @admin_drawer_exp_levels_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Experience Levels'**
  String get admin_drawer_exp_levels_title;

  /// No description provided for @admin_drawer_exp_levels_sub.
  ///
  /// In en, this message translates to:
  /// **'Manage experience levels available in the app'**
  String get admin_drawer_exp_levels_sub;

  /// No description provided for @admin_drawer_locations_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Locations'**
  String get admin_drawer_locations_title;

  /// No description provided for @admin_drawer_locations_sub.
  ///
  /// In en, this message translates to:
  /// **'Manage locations available in the app'**
  String get admin_drawer_locations_sub;

  /// No description provided for @admin_drawer_payment_config_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Payment Configuration'**
  String get admin_drawer_payment_config_title;

  /// No description provided for @admin_drawer_payment_config_sub.
  ///
  /// In en, this message translates to:
  /// **'Manage payment parameters'**
  String get admin_drawer_payment_config_sub;

  /// No description provided for @admin_drawer_appeals_title.
  ///
  /// In en, this message translates to:
  /// **'Pending Appeals'**
  String get admin_drawer_appeals_title;

  /// No description provided for @admin_drawer_appeals_sub.
  ///
  /// In en, this message translates to:
  /// **'Review pending appeals'**
  String get admin_drawer_appeals_sub;

  /// No description provided for @admin_add_user_title.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get admin_add_user_title;

  /// No description provided for @admin_appeals_title.
  ///
  /// In en, this message translates to:
  /// **'Pending Appeals'**
  String get admin_appeals_title;

  /// No description provided for @admin_job_list_title.
  ///
  /// In en, this message translates to:
  /// **'Job Listings'**
  String get admin_job_list_title;

  /// No description provided for @admin_payments_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Management'**
  String get admin_payments_title;

  /// No description provided for @admin_promotion_title.
  ///
  /// In en, this message translates to:
  /// **'Recruiter Promotion'**
  String get admin_promotion_title;

  /// No description provided for @admin_verification_title.
  ///
  /// In en, this message translates to:
  /// **'Recruiter Verification'**
  String get admin_verification_title;

  /// No description provided for @blocked_account_title.
  ///
  /// In en, this message translates to:
  /// **'Account Blocked'**
  String get blocked_account_title;

  /// No description provided for @create_user_btn.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get create_user_btn;

  /// No description provided for @update_user_btn.
  ///
  /// In en, this message translates to:
  /// **'Update User'**
  String get update_user_btn;

  /// No description provided for @no_pending_appeals_msg.
  ///
  /// In en, this message translates to:
  /// **'No pending appeals'**
  String get no_pending_appeals_msg;

  /// No description provided for @review_btn.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review_btn;

  /// No description provided for @appeal_review_title.
  ///
  /// In en, this message translates to:
  /// **'Appeal Review'**
  String get appeal_review_title;

  /// No description provided for @user_email_label.
  ///
  /// In en, this message translates to:
  /// **'User Email'**
  String get user_email_label;

  /// No description provided for @block_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Block Reason'**
  String get block_reason_label;

  /// No description provided for @appeal_msg_label.
  ///
  /// In en, this message translates to:
  /// **'Appeal Message'**
  String get appeal_msg_label;

  /// No description provided for @admin_msg_required_label.
  ///
  /// In en, this message translates to:
  /// **'Admin message (required)'**
  String get admin_msg_required_label;

  /// No description provided for @approve_btn.
  ///
  /// In en, this message translates to:
  /// **'APPROVE'**
  String get approve_btn;

  /// No description provided for @reject_btn_caps.
  ///
  /// In en, this message translates to:
  /// **'REJECT'**
  String get reject_btn_caps;

  /// No description provided for @appeal_approved_notif_title.
  ///
  /// In en, this message translates to:
  /// **'Appeal Approved'**
  String get appeal_approved_notif_title;

  /// No description provided for @appeal_rejected_notif_title.
  ///
  /// In en, this message translates to:
  /// **'Appeal Rejected'**
  String get appeal_rejected_notif_title;

  /// No description provided for @appeal_under_review_msg.
  ///
  /// In en, this message translates to:
  /// **'Your appeal is under review'**
  String get appeal_under_review_msg;

  /// No description provided for @appeal_approved_msg.
  ///
  /// In en, this message translates to:
  /// **'Your appeal was approved'**
  String get appeal_approved_msg;

  /// No description provided for @appeal_rejected_msg.
  ///
  /// In en, this message translates to:
  /// **'Your appeal was rejected'**
  String get appeal_rejected_msg;

  /// No description provided for @no_reason_provided.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get no_reason_provided;

  /// No description provided for @explain_unblock_hint.
  ///
  /// In en, this message translates to:
  /// **'Explain why your account should be unblocked'**
  String get explain_unblock_hint;

  /// No description provided for @submit_appeal_btn.
  ///
  /// In en, this message translates to:
  /// **'Submit Appeal'**
  String get submit_appeal_btn;

  /// No description provided for @blocked_acc_msg.
  ///
  /// In en, this message translates to:
  /// **'Your account has been blocked'**
  String get blocked_acc_msg;

  /// No description provided for @recruiter_verification_card.
  ///
  /// In en, this message translates to:
  /// **'Recruiter Verification'**
  String get recruiter_verification_card;

  /// No description provided for @make_featured_card.
  ///
  /// In en, this message translates to:
  /// **'Make Recruiters Featured'**
  String get make_featured_card;

  /// No description provided for @pending_count_label.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String pending_count_label(int count);

  /// No description provided for @transactions_count_label.
  ///
  /// In en, this message translates to:
  /// **'{count} Tx'**
  String transactions_count_label(int count);

  /// No description provided for @recruiter_promotion_panel.
  ///
  /// In en, this message translates to:
  /// **'Recruiter Promotion Panel'**
  String get recruiter_promotion_panel;

  /// No description provided for @search_recruiters_label.
  ///
  /// In en, this message translates to:
  /// **'Search Recruiters'**
  String get search_recruiters_label;

  /// No description provided for @eligible_recruiters_count.
  ///
  /// In en, this message translates to:
  /// **'Eligible ({count})'**
  String eligible_recruiters_count(int count);

  /// No description provided for @no_recruiters_match_search.
  ///
  /// In en, this message translates to:
  /// **'No recruiters match your search.'**
  String get no_recruiters_match_search;

  /// No description provided for @pharmacy_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy, name or city'**
  String get pharmacy_search_hint;

  /// No description provided for @recent_payments_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Payments'**
  String get recent_payments_title;

  /// No description provided for @no_payments_found.
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get no_payments_found;

  /// No description provided for @recruiter_verification_panel.
  ///
  /// In en, this message translates to:
  /// **'Recruiter Verification Panel'**
  String get recruiter_verification_panel;

  /// No description provided for @search_pending_recruiters.
  ///
  /// In en, this message translates to:
  /// **'Search Pending'**
  String get search_pending_recruiters;

  /// No description provided for @pending_verification_count.
  ///
  /// In en, this message translates to:
  /// **'{count} to verify'**
  String pending_verification_count(int count);

  /// No description provided for @no_recruiters_for_verification.
  ///
  /// In en, this message translates to:
  /// **'No recruiters found for verification.'**
  String get no_recruiters_for_verification;

  /// No description provided for @search_jobs_hint.
  ///
  /// In en, this message translates to:
  /// **'Search jobs…'**
  String get search_jobs_hint;

  /// No description provided for @all_filter_label.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_filter_label;

  /// No description provided for @open_filter_label.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open_filter_label;

  /// No description provided for @closed_filter_label.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed_filter_label;

  /// No description provided for @total_revenue_label.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get total_revenue_label;

  /// No description provided for @total_transactions_label.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get total_transactions_label;

  /// No description provided for @pending_payments_label.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending_payments_label;

  /// No description provided for @paid_payments_label.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid_payments_label;

  /// No description provided for @amount_label.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount_label;

  /// No description provided for @plan_label.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan_label;

  /// No description provided for @status_label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status_label;

  /// No description provided for @account_blocked_title.
  ///
  /// In en, this message translates to:
  /// **'Account Blocked'**
  String get account_blocked_title;

  /// No description provided for @admin_header_title.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get admin_header_title;

  /// No description provided for @pending_verification_label.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pending_verification_label;

  /// No description provided for @personal_info_section.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personal_info_section;

  /// No description provided for @company_info_section.
  ///
  /// In en, this message translates to:
  /// **'Company Info'**
  String get company_info_section;

  /// No description provided for @registered_as_label.
  ///
  /// In en, this message translates to:
  /// **'Registered as {role}'**
  String registered_as_label(String role);

  /// No description provided for @verification_requests_card.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification_requests_card;

  /// No description provided for @featured_recruiters_card.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured_recruiters_card;

  /// No description provided for @payments_card.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments_card;

  /// No description provided for @pending_label.
  ///
  /// In en, this message translates to:
  /// **'{count} Pending'**
  String pending_label(int count);

  /// No description provided for @open_jobs_tab.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open_jobs_tab;

  /// No description provided for @closed_jobs_tab.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed_jobs_tab;

  /// No description provided for @failed_load_jobs.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get failed_load_jobs;

  /// No description provided for @view_details_btn.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get view_details_btn;

  /// No description provided for @clear_all_btn.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear_all_btn;

  /// No description provided for @search_province_hint.
  ///
  /// In en, this message translates to:
  /// **'Province...'**
  String get search_province_hint;

  /// No description provided for @search_recruiters_hint.
  ///
  /// In en, this message translates to:
  /// **'Search Recruiter...'**
  String get search_recruiters_hint;

  /// No description provided for @verified_status.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified_status;

  /// No description provided for @unverified_status.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified_status;

  /// No description provided for @view_profile_btn.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get view_profile_btn;

  /// No description provided for @paid_subscriptions_title.
  ///
  /// In en, this message translates to:
  /// **'Paid Subs'**
  String get paid_subscriptions_title;

  /// No description provided for @no_paid_subs.
  ///
  /// In en, this message translates to:
  /// **'No paid subs'**
  String get no_paid_subs;

  /// No description provided for @active_label.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active_label;

  /// No description provided for @revenue_label.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue_label;

  /// No description provided for @expired_label.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired_label;

  /// No description provided for @until_label.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String until_label(String date);

  /// No description provided for @recruiter_label.
  ///
  /// In en, this message translates to:
  /// **'Recruiter'**
  String get recruiter_label;

  /// No description provided for @street_label.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street_label;

  /// No description provided for @license_label.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license_label;

  /// No description provided for @inactive_label.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive_label;

  /// No description provided for @lic_expires_label.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get lic_expires_label;

  /// No description provided for @paid_on_label.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get paid_on_label;

  /// No description provided for @method_label.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method_label;

  /// No description provided for @year_label.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year_label;

  /// No description provided for @checkout_id_label.
  ///
  /// In en, this message translates to:
  /// **'TX ID'**
  String get checkout_id_label;

  /// No description provided for @admin_msg_label.
  ///
  /// In en, this message translates to:
  /// **'Admin Msg'**
  String get admin_msg_label;

  /// No description provided for @no_recruiters_match.
  ///
  /// In en, this message translates to:
  /// **'No recruiters match'**
  String get no_recruiters_match;

  /// No description provided for @skills_label.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills_label;

  /// No description provided for @premium_label.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium_label;

  /// No description provided for @no_to_verify.
  ///
  /// In en, this message translates to:
  /// **'No recruiters to verify'**
  String get no_to_verify;

  /// No description provided for @admin_role_desc.
  ///
  /// In en, this message translates to:
  /// **'Full platform access'**
  String get admin_role_desc;

  /// No description provided for @admin_dashboard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get admin_dashboard_subtitle;

  /// No description provided for @admin_label.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin_label;

  /// No description provided for @all_jobs_label.
  ///
  /// In en, this message translates to:
  /// **'All Jobs'**
  String get all_jobs_label;

  /// No description provided for @open_closed_jobs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Open & Closed Jobs'**
  String get open_closed_jobs_subtitle;

  /// No description provided for @search_job_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter job title or keyword'**
  String get search_job_hint;

  /// No description provided for @street_address_label.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get street_address_label;

  /// No description provided for @province_label.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province_label;

  /// No description provided for @location_label.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location_label;

  /// No description provided for @any_label.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any_label;

  /// No description provided for @job_title_label.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get job_title_label;

  /// No description provided for @only_admin_create_user_toast.
  ///
  /// In en, this message translates to:
  /// **'Only admins can create users.'**
  String get only_admin_create_user_toast;

  /// No description provided for @email_required_error.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get email_required_error;

  /// No description provided for @invalid_email_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalid_email_error;

  /// No description provided for @password_required_error.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get password_required_error;

  /// No description provided for @invalid_password_format_error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters and include 1 uppercase, 1 lowercase, and 1 number.'**
  String get invalid_password_format_error;

  /// No description provided for @confirm_password_required_error.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get confirm_password_required_error;

  /// No description provided for @passwords_do_not_match_error.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwords_do_not_match_error;

  /// No description provided for @admin_created_user_name.
  ///
  /// In en, this message translates to:
  /// **'Admin Created User'**
  String get admin_created_user_name;

  /// No description provided for @user_created_success_msg.
  ///
  /// In en, this message translates to:
  /// **'User successfully created as {role}.'**
  String user_created_success_msg(String role);

  /// No description provided for @access_denied_admin.
  ///
  /// In en, this message translates to:
  /// **'Access denied. Admin only.'**
  String get access_denied_admin;

  /// No description provided for @add_new_user_title.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get add_new_user_title;

  /// No description provided for @create_user_account_header.
  ///
  /// In en, this message translates to:
  /// **'Create User Account'**
  String get create_user_account_header;

  /// No description provided for @create_user_account_desc.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details and assign a role.\nA verification email will be sent automatically.'**
  String get create_user_account_desc;

  /// No description provided for @assign_role_label.
  ///
  /// In en, this message translates to:
  /// **'Assign Role'**
  String get assign_role_label;

  /// No description provided for @admin_role_label.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin_role_label;

  /// No description provided for @recruiters_list.
  ///
  /// In en, this message translates to:
  /// **'Recruiters'**
  String get recruiters_list;

  /// No description provided for @recruiters.
  ///
  /// In en, this message translates to:
  /// **'Recruiters'**
  String get recruiters;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by pharmacy, name or city'**
  String get searchHint;

  /// No description provided for @noRecruitersFound.
  ///
  /// In en, this message translates to:
  /// **'No recruiters found'**
  String get noRecruitersFound;

  /// No description provided for @loadingRecruiters.
  ///
  /// In en, this message translates to:
  /// **'Loading recruiters…'**
  String get loadingRecruiters;

  /// No description provided for @recruitersLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count} recruiters loaded'**
  String recruitersLoaded(Object count);

  /// No description provided for @loadMoreRecruiters.
  ///
  /// In en, this message translates to:
  /// **'Load more recruiters'**
  String get loadMoreRecruiters;

  /// No description provided for @allRecruitersLoaded.
  ///
  /// In en, this message translates to:
  /// **'All {count} recruiters loaded'**
  String allRecruitersLoaded(Object count);

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @recruiterVerificationPanel.
  ///
  /// In en, this message translates to:
  /// **'Verification Panel'**
  String get recruiterVerificationPanel;

  /// No description provided for @searchPendingRecruiters.
  ///
  /// In en, this message translates to:
  /// **'Search Recruiters'**
  String get searchPendingRecruiters;

  /// No description provided for @searchHintRecruiters.
  ///
  /// In en, this message translates to:
  /// **'Search pharmacy, name or city'**
  String get searchHintRecruiters;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;

  /// No description provided for @noRecruitersForVerification.
  ///
  /// In en, this message translates to:
  /// **'No recruiters found'**
  String get noRecruitersForVerification;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @recruiterPromotionPanel.
  ///
  /// In en, this message translates to:
  /// **'Promotion Panel'**
  String get recruiterPromotionPanel;

  /// No description provided for @searchRecruiters.
  ///
  /// In en, this message translates to:
  /// **'Search Recruiters'**
  String get searchRecruiters;

  /// No description provided for @eligibleRecruiters.
  ///
  /// In en, this message translates to:
  /// **'Eligible Recruiters'**
  String get eligibleRecruiters;

  /// No description provided for @noRecruitersMatch.
  ///
  /// In en, this message translates to:
  /// **'No recruiters found'**
  String get noRecruitersMatch;

  /// No description provided for @recruiterProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get recruiterProfile;

  /// No description provided for @pharmacyInfo.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Info'**
  String get pharmacyInfo;

  /// No description provided for @pharmacist.
  ///
  /// In en, this message translates to:
  /// **'Pharmacist'**
  String get pharmacist;

  /// No description provided for @metaInfo.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get metaInfo;

  /// No description provided for @jobStats.
  ///
  /// In en, this message translates to:
  /// **'Job Stats'**
  String get jobStats;

  /// No description provided for @pharmacyName.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacyName;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @totalJobs.
  ///
  /// In en, this message translates to:
  /// **'Total Jobs'**
  String get totalJobs;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobs;

  /// No description provided for @draftJobs.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftJobs;

  /// No description provided for @verifyRecruiter.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyRecruiter;

  /// No description provided for @unverifyRecruiter.
  ///
  /// In en, this message translates to:
  /// **'Unverify'**
  String get unverifyRecruiter;

  /// No description provided for @recruiterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get recruiterApproved;

  /// No description provided for @recruiterDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get recruiterDeactivated;

  /// No description provided for @makeRecruiterPro.
  ///
  /// In en, this message translates to:
  /// **'Make Pro'**
  String get makeRecruiterPro;

  /// No description provided for @recruiterUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Upgraded to Pro'**
  String get recruiterUpgraded;

  /// No description provided for @failedLoadJobs.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get failedLoadJobs;

  /// No description provided for @paidSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get paidSubscriptions;

  /// No description provided for @noPaidSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions'**
  String get noPaidSubscriptions;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @unknownPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownPharmacy;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @until.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get until;

  /// No description provided for @recruiter.
  ///
  /// In en, this message translates to:
  /// **'Recruiter'**
  String get recruiter;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @licenseExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get licenseExpires;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidOn;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @checkoutId.
  ///
  /// In en, this message translates to:
  /// **'Checkout ID'**
  String get checkoutId;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @manageOptions.
  ///
  /// In en, this message translates to:
  /// **'Manage Options'**
  String get manageOptions;

  /// No description provided for @jobTitles.
  ///
  /// In en, this message translates to:
  /// **'Job Titles'**
  String get jobTitles;

  /// No description provided for @noOptions.
  ///
  /// In en, this message translates to:
  /// **'No options yet'**
  String get noOptions;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// No description provided for @deleteOption.
  ///
  /// In en, this message translates to:
  /// **'Delete Option'**
  String get deleteOption;

  /// No description provided for @deleteOptionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently?'**
  String deleteOptionConfirm(Object name);

  /// No description provided for @fillAllLanguages.
  ///
  /// In en, this message translates to:
  /// **'Fill in all three languages'**
  String get fillAllLanguages;

  /// No description provided for @editJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Job Title'**
  String get editJobTitle;

  /// No description provided for @addJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Job Title'**
  String get addJobTitle;

  /// No description provided for @editSkill.
  ///
  /// In en, this message translates to:
  /// **'Edit Skill'**
  String get editSkill;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add Skill'**
  String get addSkill;

  /// No description provided for @englishRequired.
  ///
  /// In en, this message translates to:
  /// **'English name is required'**
  String get englishRequired;

  /// No description provided for @frenchRequired.
  ///
  /// In en, this message translates to:
  /// **'French name is required'**
  String get frenchRequired;

  /// No description provided for @arabicRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic name is required'**
  String get arabicRequired;

  /// No description provided for @labelInEnglish.
  ///
  /// In en, this message translates to:
  /// **'Label in English'**
  String get labelInEnglish;

  /// No description provided for @labelInFrench.
  ///
  /// In en, this message translates to:
  /// **'Label in French'**
  String get labelInFrench;

  /// No description provided for @labelInArabic.
  ///
  /// In en, this message translates to:
  /// **'Label in Arabic'**
  String get labelInArabic;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @jobTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Types'**
  String get jobTypesTitle;

  /// No description provided for @typesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} types'**
  String typesCount(Object count);

  /// No description provided for @noJobTypes.
  ///
  /// In en, this message translates to:
  /// **'No job types yet'**
  String get noJobTypes;

  /// No description provided for @addNewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add one'**
  String get addNewHint;

  /// No description provided for @deleteJobTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Job Type'**
  String get deleteJobTypeTitle;

  /// No description provided for @deleteJobTypeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently?'**
  String deleteJobTypeConfirm(Object name);

  /// No description provided for @addJobType.
  ///
  /// In en, this message translates to:
  /// **'Add Job Type'**
  String get addJobType;

  /// No description provided for @editJobType.
  ///
  /// In en, this message translates to:
  /// **'Edit Job Type'**
  String get editJobType;

  /// No description provided for @fillLanguages.
  ///
  /// In en, this message translates to:
  /// **'Fill in all three languages'**
  String get fillLanguages;

  /// No description provided for @nameInLanguage.
  ///
  /// In en, this message translates to:
  /// **'Name in {language}...'**
  String nameInLanguage(String language);

  /// No description provided for @experienceLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Experience Levels'**
  String get experienceLevelsTitle;

  /// No description provided for @levelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} levels'**
  String levelsCount(Object count);

  /// No description provided for @noExperienceLevels.
  ///
  /// In en, this message translates to:
  /// **'No experience levels yet'**
  String get noExperienceLevels;

  /// No description provided for @deleteExperienceLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Experience Level'**
  String get deleteExperienceLevelTitle;

  /// No description provided for @deleteExperienceLevelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently?'**
  String deleteExperienceLevelConfirm(Object name);

  /// No description provided for @addExperienceLevel.
  ///
  /// In en, this message translates to:
  /// **'Add Experience Level'**
  String get addExperienceLevel;

  /// No description provided for @editExperienceLevel.
  ///
  /// In en, this message translates to:
  /// **'Edit Experience Level'**
  String get editExperienceLevel;

  /// No description provided for @labelInLanguage.
  ///
  /// In en, this message translates to:
  /// **'Label in {lang}...'**
  String labelInLanguage(Object lang);

  /// No description provided for @titleProvincesCities.
  ///
  /// In en, this message translates to:
  /// **'Provinces & Cities'**
  String get titleProvincesCities;

  /// No description provided for @provincesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} provinces'**
  String provincesCount(int count);

  /// No description provided for @citiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cities'**
  String citiesCount(int count);

  /// No description provided for @noProvinces.
  ///
  /// In en, this message translates to:
  /// **'No provinces yet'**
  String get noProvinces;

  /// No description provided for @noCities.
  ///
  /// In en, this message translates to:
  /// **'No cities yet'**
  String get noCities;

  /// No description provided for @addProvinceHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a province'**
  String get addProvinceHint;

  /// No description provided for @addCityHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a city to {province}'**
  String addCityHint(String province);

  /// No description provided for @cities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get cities;

  /// No description provided for @deleteProvinceTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Province'**
  String get deleteProvinceTitle;

  /// No description provided for @deleteProvinceMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and ALL its cities permanently?'**
  String deleteProvinceMessage(String name);

  /// No description provided for @deleteCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete City'**
  String get deleteCityTitle;

  /// No description provided for @deleteCityMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently?'**
  String deleteCityMessage(String name);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @addProvince.
  ///
  /// In en, this message translates to:
  /// **'Add Province'**
  String get addProvince;

  /// No description provided for @editProvince.
  ///
  /// In en, this message translates to:
  /// **'Edit Province'**
  String get editProvince;

  /// No description provided for @addCity.
  ///
  /// In en, this message translates to:
  /// **'Add City'**
  String get addCity;

  /// No description provided for @editCity.
  ///
  /// In en, this message translates to:
  /// **'Edit City'**
  String get editCity;

  /// No description provided for @paymentConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Config'**
  String get paymentConfigTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @environmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between test and production mode'**
  String get environmentSubtitle;

  /// No description provided for @testMode.
  ///
  /// In en, this message translates to:
  /// **'Test Mode'**
  String get testMode;

  /// No description provided for @testModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No real money charged'**
  String get testModeSubtitle;

  /// No description provided for @production.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get production;

  /// No description provided for @productionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live payments'**
  String get productionSubtitle;

  /// No description provided for @apiCredentials.
  ///
  /// In en, this message translates to:
  /// **'API Credentials'**
  String get apiCredentials;

  /// No description provided for @apiCredentialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chargily secret key and endpoint URLs'**
  String get apiCredentialsSubtitle;

  /// No description provided for @testSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Test Secret Key'**
  String get testSecretKey;

  /// No description provided for @cloudFunctionUrl.
  ///
  /// In en, this message translates to:
  /// **'Cloud Function URL'**
  String get cloudFunctionUrl;

  /// No description provided for @webhookUrl.
  ///
  /// In en, this message translates to:
  /// **'Webhook URL'**
  String get webhookUrl;

  /// No description provided for @redirectUrls.
  ///
  /// In en, this message translates to:
  /// **'Redirect URLs'**
  String get redirectUrls;

  /// No description provided for @redirectUrlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where Chargily sends users after payment'**
  String get redirectUrlsSubtitle;

  /// No description provided for @successUrl.
  ///
  /// In en, this message translates to:
  /// **'Success URL'**
  String get successUrl;

  /// No description provided for @failureUrl.
  ///
  /// In en, this message translates to:
  /// **'Failure URL'**
  String get failureUrl;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @pricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Annual fee, currency and locale'**
  String get pricingSubtitle;

  /// No description provided for @annualFee.
  ///
  /// In en, this message translates to:
  /// **'Annual Fee'**
  String get annualFee;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @locale.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get locale;

  /// No description provided for @planCopy.
  ///
  /// In en, this message translates to:
  /// **'Plan Copy'**
  String get planCopy;

  /// No description provided for @planCopySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Text shown to recruiters on the subscription screen'**
  String get planCopySubtitle;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planName;

  /// No description provided for @planSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get planSubtitle;

  /// No description provided for @planDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get planDescription;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @planFeatures.
  ///
  /// In en, this message translates to:
  /// **'Plan Features'**
  String get planFeatures;

  /// No description provided for @planFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bullet points shown on the subscription screen. Drag to reorder.'**
  String get planFeaturesSubtitle;

  /// No description provided for @newFeature.
  ///
  /// In en, this message translates to:
  /// **'New Feature'**
  String get newFeature;

  /// No description provided for @noFeatures.
  ///
  /// In en, this message translates to:
  /// **'No features added yet'**
  String get noFeatures;

  /// No description provided for @annualFeeError.
  ///
  /// In en, this message translates to:
  /// **'Annual fee must be a valid number.'**
  String get annualFeeError;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment config saved successfully.'**
  String get saveSuccess;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String saveError(String error);

  /// No description provided for @close_issue_btn.
  ///
  /// In en, this message translates to:
  /// **'Close Issue'**
  String get close_issue_btn;

  /// No description provided for @tabs_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get tabs_open;

  /// No description provided for @tabs_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get tabs_closed;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Login Here'**
  String get loginHere;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Access your Ophicina account securely with your preferred method'**
  String get welcomeMessage;

  /// No description provided for @monthlyLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit Reached'**
  String get monthlyLimitTitle;

  /// No description provided for @monthlyLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used all {limit} job posts for this month. Your limit resets on the 1st of next month. Contact admin if you need more.'**
  String monthlyLimitMessage(Object limit);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @notif_account_verified_title.
  ///
  /// In en, this message translates to:
  /// **'Account Verified'**
  String get notif_account_verified_title;

  /// No description provided for @notif_account_verified_desc.
  ///
  /// In en, this message translates to:
  /// **'Your recruiter account has been verified by the Ophicina team.'**
  String get notif_account_verified_desc;

  /// No description provided for @notif_account_deactivated_title.
  ///
  /// In en, this message translates to:
  /// **'Account Deactivated'**
  String get notif_account_deactivated_title;

  /// No description provided for @notif_account_deactivated_desc.
  ///
  /// In en, this message translates to:
  /// **'Your recruiter account has been deactivated. Please contact support for more information.'**
  String get notif_account_deactivated_desc;

  /// No description provided for @notif_account_pro_title.
  ///
  /// In en, this message translates to:
  /// **'Upgraded to Pro'**
  String get notif_account_pro_title;

  /// No description provided for @notif_account_pro_desc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your account has been upgraded to Pro status.'**
  String get notif_account_pro_desc;

  /// No description provided for @notif_quota_updated_title.
  ///
  /// In en, this message translates to:
  /// **'Job Post Quota Updated'**
  String get notif_quota_updated_title;

  /// No description provided for @notif_quota_updated_desc.
  ///
  /// In en, this message translates to:
  /// **'Your monthly job post limit has been updated to {limit} posts.'**
  String notif_quota_updated_desc(int limit);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent. Check your inbox. Please don\'t forget to check spam folder.'**
  String get resetLinkSent;

  /// No description provided for @noAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with that email.'**
  String get noAccountFound;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorPrefix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
