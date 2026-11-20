// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Ophicina';

  @override
  String get tagline => 'Your opportunity is here';

  @override
  String get role_job_seeker => 'I am a Job Seeker';

  @override
  String get role_recruiter => 'I am a Recruiter';

  @override
  String get onboarding_title => 'Welcome to Ophicina';

  @override
  String get onboarding_subtitle =>
      'Connecting pharmacy professionals with the right opportunities.';

  @override
  String get login_title => 'Login to Ophicina';

  @override
  String get login_subtitle_email => 'Secure login using your email';

  @override
  String get login_subtitle_phone => 'Secure login using your phone number';

  @override
  String get email_label => 'Email';

  @override
  String get password_label => 'Password';

  @override
  String get forgot_password => 'Forgot your password?';

  @override
  String get sign_in_button => 'Sign In';

  @override
  String get create_account => 'Create new account';

  @override
  String get welcome_to_ophicina => 'Welcome to Ophicina';

  @override
  String get signup_subtitle => 'Join the professional healthcare network';

  @override
  String get confirm_password_label => 'Confirm Password';

  @override
  String get already_have_account => 'Already have an account?';

  @override
  String get join_ophicina => 'Join Ophicina';

  @override
  String get join_subtitle => 'Create an account to discover opportunities';

  @override
  String get signup_with_email => 'Sign up with Email';

  @override
  String get signup_with_google => 'Sign up with Google';

  @override
  String get signup_with_apple => 'Sign up with Apple';

  @override
  String get deletion_queue_error =>
      'Your account deletion is pending. Please use a different email or phone.';

  @override
  String get email_required => 'Email is required';

  @override
  String get valid_email_error => 'Please enter a valid email address';

  @override
  String get password_required => 'Password is required';

  @override
  String get password_format_error =>
      'Password must be at least 6 characters long, include 1 uppercase, 1 lowercase, and 1 number';

  @override
  String get confirm_password_required => 'Please confirm your password';

  @override
  String get passwords_dont_match => 'Passwords do not match';

  @override
  String get signup_successful => 'Signup successful!';

  @override
  String get enter_valid_email => 'Please enter a valid email';

  @override
  String get enter_password => 'Please enter password';

  @override
  String get enter_phone => 'Enter phone number';

  @override
  String get enter_valid_algerian =>
      'Enter a valid Algerian number (5, 6 or 7 followed by 8 digits)';

  @override
  String get enter_valid_pakistani =>
      'Enter a valid Pakistani number (3 followed by 9 digits)';

  @override
  String otp_sent_to(String phone) {
    return 'OTP sent to $phone';
  }

  @override
  String get otp_not_sent => 'OTP not sent yet';

  @override
  String get otp_complete => 'Enter complete 6-digit OTP';

  @override
  String get account_not_found =>
      'Your account was not found, please register yourself first';

  @override
  String get login_here => 'Login Here';

  @override
  String get login_subtitle_welcome =>
      'Access your Ophicina account securely with your preferred method';

  @override
  String get login_with_email => 'Login with Email';

  @override
  String get login_with_google => 'Login with Google';

  @override
  String get login_with_apple => 'Login with Apple';

  @override
  String get sign_in => 'Sign In';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get arabic => 'Arabic';

  @override
  String hi_user(String name) {
    return 'Hi, $name';
  }

  @override
  String get my_account => 'My Account';

  @override
  String get post_job => 'Post a Job';

  @override
  String get post_job_desc => 'Reach pharmacists by listing your vacancy';

  @override
  String get edit_profile => 'Edit profile';

  @override
  String get edit_profile_desc => 'Edit profile & Pharmacy Detail';

  @override
  String get report_issue => 'Report an Issue';

  @override
  String get report_issue_desc => 'Report bugs & issues';

  @override
  String get reported_issues => 'Reported Issues';

  @override
  String get reported_issues_desc => 'View your reported issues';

  @override
  String get logout => 'Logout';

  @override
  String get logout_desc => 'Sign out of your account';

  @override
  String get delete_account => 'Delete Account';

  @override
  String get delete_account_desc => 'This will delete your account';

  @override
  String get jobs_status_overview => 'Job Offer Status Overview';

  @override
  String jobs_open_count(int active, int total) {
    return 'You currently have $active of $total jobs open and accepting new applications';
  }

  @override
  String get manage_account => 'Manage Account';

  @override
  String get active => 'Active';

  @override
  String get open_jobs => 'Open Jobs';

  @override
  String open_jobs_count(int open, int total) {
    return '$open of $total open';
  }

  @override
  String get filled_positions => 'Filled Positions';

  @override
  String filled_positions_count(int filled, int total) {
    return '$filled of $total filled';
  }

  @override
  String get skill_verification_requests => 'Skill Verifications Requests';

  @override
  String pending_requests_count(int count) {
    return '$count pending requests';
  }

  @override
  String get view => 'View';

  @override
  String get hiring_activity => 'Your Hiring Activity';

  @override
  String get review_profiles => 'Review Profiles';

  @override
  String reviewed_count(int reviewed, int total) {
    return 'Reviewed: $reviewed/$total';
  }

  @override
  String get chat_card => 'Chat';

  @override
  String read_count(int read, int total) {
    return 'Read: $read/$total';
  }

  @override
  String get all_time_job_stats => 'All Time Job Offers Statistics';

  @override
  String get no_job_offers_stats =>
      'No job offers available to display statistics.';

  @override
  String get no_stats_available => 'No statistics available';

  @override
  String get candidates => 'Candidates';

  @override
  String candidates_count(int count) {
    return '$count Candidates';
  }

  @override
  String get upcoming_hiring_actions => 'Upcoming Hiring Actions';

  @override
  String get see_all => 'See all';

  @override
  String get create_account_title => 'Create Account';

  @override
  String get edit_profile_title => 'Edit Profile';

  @override
  String get my_account_title => 'My Account';

  @override
  String get update_profile_picture => 'Update Profile Picture';

  @override
  String get personal_information => 'Personal Information';

  @override
  String get first_name => 'First Name';

  @override
  String get first_name_hint => 'Anabella';

  @override
  String get last_name => 'Last Name';

  @override
  String get last_name_hint => 'Angela';

  @override
  String get pharmacy_location_title => 'Pharmacy & Location';

  @override
  String get pharmacy_name => 'Pharmacy Name';

  @override
  String get pharmacy_name_hint => 'GreenCare Pharmacy';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get select_province => 'Select Province';

  @override
  String get city => 'City';

  @override
  String get select_province_first => 'Select province first';

  @override
  String get loading_dots => 'Loading...';

  @override
  String get select_city => 'Select City';

  @override
  String get pharmacy_location_tile => 'Pharmacy Location';

  @override
  String get tap_to_set_location => 'Tap to set location on map';

  @override
  String get set_btn => 'Set';

  @override
  String get change_btn => 'Change';

  @override
  String get save_changes => 'Save Changes';

  @override
  String get create_account_btn => 'Create Account';

  @override
  String get all_rights_reserved => 'All rights reserved';

  @override
  String get profile_photo_title => 'Profile photo';

  @override
  String get crop_photo => 'Crop Photo';

  @override
  String get profile_picture_updated => 'Profile picture updated';

  @override
  String failed_to_update(String error) {
    return 'Failed: $error';
  }

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get remove_photo => 'Remove photo';

  @override
  String get save_btn => 'Save';

  @override
  String get change_action => 'Change';

  @override
  String get recrop_action => 'Recrop';

  @override
  String get add_profile_photo_btn => 'Add profile photo';

  @override
  String get normal_filter => 'Normal';

  @override
  String get verify_jobseeker_skills_title => 'Verify Jobseeker Skills';

  @override
  String get failed_to_load_requests => 'Failed to load requests';

  @override
  String get no_pending_skill_requests => 'No pending skill requests';

  @override
  String get anonymous_candidate => 'Anonymous Candidate';

  @override
  String get verify_skills_btn => 'Verify Skills';

  @override
  String get skill_verification_completed_notif_title =>
      'Skill Verification Completed';

  @override
  String get skill_verification_completed_notif_desc =>
      'Your skills have been reviewed by the recruiter.';

  @override
  String get skills_to_review_label => 'Skills to Review';

  @override
  String get note_from_jobseeker_label => 'Note from Job Seeker';

  @override
  String get no_note_provided => 'No note provided by the job seeker.';

  @override
  String get mark_verification_completed_btn =>
      'Mark Verification as Completed';

  @override
  String get all_skills_reviewed_msg =>
      'All skills have already been reviewed for this job seeker.';

  @override
  String get pending_review_status => 'Pending Review';

  @override
  String get phone_label => 'Phone';

  @override
  String get city_label => 'City';

  @override
  String get education_label => 'Education';

  @override
  String get experience_label => 'Experience';

  @override
  String get wilaya_label => 'Wilaya';

  @override
  String get na_value => 'N/A';

  @override
  String get verify_action => 'Verify';

  @override
  String get reject_action => 'Reject';

  @override
  String verified_count_label(Object count) {
    return '$count verified';
  }

  @override
  String rejected_count_label(Object count) {
    return '$count rejected';
  }

  @override
  String get closed_jobs => 'Closed Jobs';

  @override
  String get view_details => 'View Details';

  @override
  String get job_type_label => 'Job Type';

  @override
  String get open_status => 'Open';

  @override
  String get closed_status => 'Closed';

  @override
  String get edit_job => 'Edit Job';

  @override
  String get delete_job => 'Delete Job';

  @override
  String get close_job => 'Close Job';

  @override
  String get delete_job_confirm_title => 'Delete Job';

  @override
  String get delete_job_confirm_msg =>
      'Do you really want to delete this job?\n\nThis action is permanent and you will NOT be able to recover this job.';

  @override
  String get close_job_confirm_title => 'Close Job';

  @override
  String get close_job_confirm_msg =>
      'Do you really want to close this job?\n\nOnce closed, this job will no longer be active for applicants.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get no_job_offers_yet => 'No job offers yet';

  @override
  String get create_first_job_offer =>
      'Create your first job offer to get started';

  @override
  String get posted_jobs => 'Posted Jobs';

  @override
  String get just_now => 'Just now';

  @override
  String min_ago(int count) {
    return '$count min ago';
  }

  @override
  String hours_ago(int count) {
    return '$count hours ago';
  }

  @override
  String days_ago(int count) {
    return '$count days ago';
  }

  @override
  String weeks_ago(int count) {
    return '$count weeks ago';
  }

  @override
  String months_ago(int count) {
    return '$count months ago';
  }

  @override
  String years_ago(int count) {
    return '$count years ago';
  }

  @override
  String get per_year => '/ Year';

  @override
  String get k_per_year => 'K / Year';

  @override
  String get m_per_year => 'M / Year';

  @override
  String get job_title_pharmacist => 'Pharmacist';

  @override
  String get job_title_gerant => 'Gerant';

  @override
  String get job_title_physician => 'Physician';

  @override
  String get job_title_senior_salesperson => 'Senior Salesperson';

  @override
  String get job_title_sales_specialist => 'Sales Specialist';

  @override
  String get job_title_intern => 'Intern';

  @override
  String get job_title_labeling_specialist => 'Labeling Specialist';

  @override
  String get job_title_data_entry_specialist => 'Data Entry Specialist';

  @override
  String get job_title_stock_management_specialist =>
      'Stock Management Specialist';

  @override
  String get job_type_full_time => 'Full Time';

  @override
  String get job_type_part_time => 'Part Time';

  @override
  String get job_type_replacement => 'Replacement';

  @override
  String get chats => 'Chats';

  @override
  String get search_chats => 'Search chats';

  @override
  String get no_chats_yet => 'No chats yet';

  @override
  String you(String message) {
    return 'You: $message';
  }

  @override
  String get typing => 'Typing...';

  @override
  String get no_messages_yet => 'No messages yet';

  @override
  String get type_a_message => 'Type a message...';

  @override
  String get please_select_job_title => 'Please select a job title.';

  @override
  String get please_select_job_type => 'Please select a job type.';

  @override
  String get please_add_skill => 'Please add at least one skill.';

  @override
  String get recruiter_profile_not_found => 'Recruiter profile not found.';

  @override
  String get account_not_active =>
      'Your account is not active. Please logout and login again or contact support.';

  @override
  String get active_listing_required =>
      'An active listing period is required to post pharmacy vacancies.';

  @override
  String get select_skills => 'Select Skills';

  @override
  String get no_skills_available => 'No skills available';

  @override
  String get create_job_offer => 'Create Job Offer';

  @override
  String get edit_job_offer => 'Edit Job Offer';

  @override
  String get job_details => 'Job Details';

  @override
  String get job_details_desc => 'Fill in the details to post your job offer';

  @override
  String get job_title => 'Job Title';

  @override
  String get job_type => 'Job Type';

  @override
  String get required_skills => 'Required Skills';

  @override
  String get required_skills_desc => 'Add skills that candidates must have';

  @override
  String get add_skills => 'Add Skills';

  @override
  String get post_job_btn => 'Post Job';

  @override
  String get update_job_btn => 'Update Job';

  @override
  String get search_skills_or_positions => 'Search skills or positions…';

  @override
  String no_matches_for_query(String query) {
    return 'No matches for \"$query\"';
  }

  @override
  String get skill => 'Skill';

  @override
  String get position => 'Position';

  @override
  String get clear_all => 'Clear all';

  @override
  String get clear_text => 'Clear';

  @override
  String show_profiles_selected_count(int count) {
    return 'Show profiles  ·  $count selected';
  }

  @override
  String get show_all_profiles => 'Show all profiles';

  @override
  String get job_seeker_profiles => 'Job Seeker Profiles';

  @override
  String get job_seeker_location => 'Job Seeker Location';

  @override
  String get candidate_location => 'Candidate Location';

  @override
  String get location_not_shared => 'Location Not Shared';

  @override
  String get location_not_shared_desc =>
      'This job seeker has not shared\ntheir location yet.';

  @override
  String get verified_skills => 'Verified Skills';

  @override
  String get unverified => 'Unverified';

  @override
  String get skills => 'Skills';

  @override
  String get contact_and_location => 'Contact & Location';

  @override
  String get block_profile => 'Block Profile';

  @override
  String get block_user_account => 'Block User Account';

  @override
  String get block_user_reason_desc =>
      'Please provide a reason. This message will be shown to the user.';

  @override
  String get enter_block_reason => 'Enter block reason...';

  @override
  String get reason_is_required => 'Reason is required';

  @override
  String get confirm_block => 'Confirm Block';

  @override
  String get user_account_blocked => 'User account blocked';

  @override
  String profiles_on_map(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profiles on map',
      one: '1 profile on map',
    );
    return '$_temp0';
  }

  @override
  String get tap_pin_or_scroll => 'Tap a pin or scroll below';

  @override
  String get profile => 'Profile';

  @override
  String get no_skills_listed => 'No skills listed';

  @override
  String plus_more_count(int count) {
    return '+$count more';
  }

  @override
  String get view_profile => 'View Profile';

  @override
  String get no_profiles_match_filters => 'No profiles match your filters';

  @override
  String get filter_profiles_hint => 'Filter profiles…';

  @override
  String active_filters_count(int count) {
    return '$count active';
  }

  @override
  String get show_results => 'Show results';

  @override
  String get search_wilaya => 'Search wilaya…';

  @override
  String get address => 'Address';

  @override
  String get district => 'District';

  @override
  String get experience => 'Experience';

  @override
  String get education => 'Education';

  @override
  String get chat => 'Chat';

  @override
  String get no_profiles_location_hint =>
      'No profiles have shared their location yet';

  @override
  String get notifications => 'Notifications';

  @override
  String notifications_unread(int count) {
    return '$count unread';
  }

  @override
  String get mark_all_read => 'Mark all read';

  @override
  String get all_notifications_marked_as_read =>
      'All notifications marked as read';

  @override
  String get no_notifications_title => 'No notifications yet';

  @override
  String get no_notifications_subtitle => 'You\'re all caught up!';

  @override
  String get notification_detail => 'Notification Detail';

  @override
  String get job_not_found_error => 'Job not found or has been removed.';

  @override
  String get see_skill_requests => 'See Skill Requests';

  @override
  String get view_my_applications => 'View My Applications';

  @override
  String get view_job => 'View Job';

  @override
  String get type_login => 'Login';

  @override
  String get type_logout => 'Logout';

  @override
  String get type_payment => 'Payment';

  @override
  String get type_job_post => 'Job Post';

  @override
  String get type_application => 'Application';

  @override
  String get type_skill_verified => 'Skill Verified';

  @override
  String get type_message => 'Message';

  @override
  String get type_general => 'General';

  @override
  String get post_job_appbar_title => 'Post a Job';

  @override
  String get test_mode_badge => 'TEST MODE';

  @override
  String get submitting_listing_request_banner =>
      'Submitting your listing request… Please wait.';

  @override
  String get test_mode_banner_title => 'Test Mode — No real money charged';

  @override
  String get test_card_details_label => 'Test card details (EDAHABIA):';

  @override
  String get test_card_number_label => 'Card number';

  @override
  String get test_card_expiry_label => 'Expiry';

  @override
  String get test_card_future_date_label => 'Any future date';

  @override
  String get test_card_otp_label => 'OTP';

  @override
  String get active_plan_label => 'Active Plan';

  @override
  String get no_active_plan_label => 'No Active Plan';

  @override
  String annual_job_listing_title(int year) {
    return 'Annual Job Listing — Pharmacy $year';
  }

  @override
  String get list_vacancy_hint_subtitle =>
      'List a vacancy to reach verified pharmacists';

  @override
  String get payment_expires_label => 'Expires';

  @override
  String get payment_days_left_label => 'Days left';

  @override
  String payment_days_count(int count) {
    return '$count days';
  }

  @override
  String get payment_paid_label => 'Paid';

  @override
  String get payment_method_label => 'Method';

  @override
  String get payment_method_edahabia => 'EDAHABIA';

  @override
  String get payment_method_cib => 'CIB';

  @override
  String get payment_method_unknown => '—';

  @override
  String listing_expires_warning_banner(int days) {
    return 'Your job listing expires in $days days. Relist to stay visible.';
  }

  @override
  String get list_pharmacy_vacancy_btn => 'List Your Pharmacy Vacancy';

  @override
  String get list_another_vacancy_btn => 'List Another Vacancy';

  @override
  String get job_posting_history_title => 'Job Posting History';

  @override
  String get payment_test_success_toast =>
      'Test payment successful. Job listing activated.';

  @override
  String get payment_success_toast =>
      'Job listing activated. Your vacancy is now visible to pharmacists.';

  @override
  String get submit_listing_request_error =>
      'Could not submit your listing request. Please try again.';

  @override
  String get payment_connection_error =>
      'Connection error. Check your network and try again.';

  @override
  String listing_request_failed_error(String message) {
    return 'Listing request failed: $message';
  }

  @override
  String get listing_service_unreachable_error =>
      'Could not reach the listing service. Try again.';

  @override
  String get payment_generic_error => 'Something went wrong. Please try again.';

  @override
  String get payment_incomplete_error =>
      'Payment was not completed. Please try again.';

  @override
  String get report_issue_title => 'Report Issue';

  @override
  String get edit_issue_title => 'Edit Issue';

  @override
  String get issue_details_label => 'Issue Details';

  @override
  String get issue_title_label => 'Title';

  @override
  String get issue_title_hint => 'Short issue summary';

  @override
  String get issue_category_label => 'Category';

  @override
  String get issue_priority_label => 'Priority';

  @override
  String get issue_description_label => 'Description';

  @override
  String get issue_description_hint => 'Explain the problem in detail';

  @override
  String get admin_comment_label => 'Admin Comment';

  @override
  String get submit_issue_btn => 'Submit Issue';

  @override
  String get update_issue_btn => 'Update Issue';

  @override
  String get enter_issue_title_error => 'Please enter issue title';

  @override
  String get select_category_error => 'Please select category';

  @override
  String get describe_issue_error => 'Please describe the issue';

  @override
  String get reported_issues_admin_title => 'Reported Issues';

  @override
  String get my_reported_issues_title => 'My Reported Issues';

  @override
  String get failed_load_issues_error => 'Failed to load issues';

  @override
  String get no_issues_reported_title => 'No issues reported yet';

  @override
  String get report_problem_hint => 'If you face any problem, report it here.';

  @override
  String get cat_crash => 'Crash';

  @override
  String get cat_ui_issue => 'UI Issue';

  @override
  String get cat_performance => 'Performance';

  @override
  String get cat_payment => 'Payment';

  @override
  String get cat_login_auth => 'Login / Auth';

  @override
  String get cat_other => 'Other';

  @override
  String get priority_low => 'Low';

  @override
  String get priority_medium => 'Medium';

  @override
  String get priority_high => 'High';

  @override
  String get priority_critical => 'Critical';

  @override
  String get status_open => 'Open';

  @override
  String get status_in_progress => 'In Progress';

  @override
  String get status_resolved => 'Resolved';

  @override
  String get status_rejected => 'Rejected';

  @override
  String get issue_details_title => 'Issue Details';

  @override
  String get description_label => 'Description';

  @override
  String get response_label => 'Response';

  @override
  String get user_not_found_error => 'User not found';

  @override
  String get reply_btn => 'Reply';

  @override
  String get anonymous_job_seeker => 'Anonymous Job Seeker';

  @override
  String get active_recruiter => 'Active Recruiter';

  @override
  String get inactive_recruiter => 'Inactive Recruiter';

  @override
  String get joined_label => 'Joined';

  @override
  String get notif_job_posted_title => 'Job Posted';

  @override
  String notif_job_posted_desc(String jobTitle) {
    return 'You posted a new job: $jobTitle';
  }

  @override
  String get notif_job_apply_title => 'New Application';

  @override
  String notif_job_apply_desc(String jobTitle) {
    return 'You have a new application for $jobTitle';
  }

  @override
  String get notif_skill_verified_title => 'Skill Verified';

  @override
  String notif_skill_verified_desc(String skillName) {
    return 'Your skill $skillName has been verified';
  }

  @override
  String get notif_payment_success_title => 'Payment Successful';

  @override
  String notif_payment_success_desc(String planName) {
    return 'Your payment for $planName was successful';
  }

  @override
  String get notif_login_title => 'Login Alert';

  @override
  String notif_login_desc(String time) {
    return 'You logged in at $time';
  }

  @override
  String get notif_logout_title => 'Logout';

  @override
  String get notif_logout_desc => 'You have been logged out';

  @override
  String get notif_issue_reported_title => 'Issue Reported';

  @override
  String notif_issue_reported_desc(String title) {
    return 'Your issue \'$title\' has been successfully reported.';
  }

  @override
  String get notif_issue_resolved_title => 'Issue Resolved';

  @override
  String notif_issue_resolved_desc(String title) {
    return 'Your issue \'$title\' has been marked as resolved.';
  }

  @override
  String get notif_admin_new_issue_title => 'New Issue Reported';

  @override
  String notif_admin_new_issue_desc(String title) {
    return 'A new issue \'$title\' was reported by a user.';
  }

  @override
  String get notif_admin_issue_resolved_title => 'Issue Resolved';

  @override
  String notif_admin_issue_resolved_desc(String title) {
    return 'Issue \'$title\' has been resolved.';
  }

  @override
  String get apply_btn => 'Apply';

  @override
  String get applied_btn => 'Applied';

  @override
  String get hire_query_btn => 'Hire ?';

  @override
  String get hire_btn => 'Hire';

  @override
  String get hired_btn => 'Hired';

  @override
  String get reject_btn => 'REJECT';

  @override
  String get job_applicants_title => 'Job Applicants';

  @override
  String get recruiter_info_title => 'Recruiter Information';

  @override
  String get required_skills_title => 'Required Skills';

  @override
  String get no_applicants_yet_label => 'No applicants yet';

  @override
  String get hire_candidate_title => 'Hire Candidate';

  @override
  String get hire_confirm_msg => 'Once hired, this action cannot be undone.';

  @override
  String get reject_applicant_title => 'Reject Applicant';

  @override
  String get reject_confirm_msg =>
      'Are you sure you want to reject this job seeker?\n\nOnce rejected, you will NOT be able to contact this candidate for this job again.';

  @override
  String get skill_rejected_label => 'Rejected';

  @override
  String get applicants_tab => 'Applicants';

  @override
  String get stats_tab => 'Stats';

  @override
  String get please_apply_first_chat => 'Please apply first before chatting.';

  @override
  String get show_route_btn => 'Show Route';

  @override
  String get hide_route_btn => 'Hide Route';

  @override
  String get open_in_maps_btn => 'Open in Maps';

  @override
  String get getting_route_loading => 'Getting route…';

  @override
  String get your_location_label => 'Your Location';

  @override
  String get chat_btn => 'Chat';

  @override
  String get accept_btn => 'Accept';

  @override
  String get job_open_label => 'Open';

  @override
  String get job_closed_label => 'Closed';

  @override
  String job_views_stats_title(Object count) {
    return 'Job Views ($count total)';
  }

  @override
  String job_applications_stats_title(Object count) {
    return 'Job Applications ($count total)';
  }

  @override
  String get mon_short => 'Mon';

  @override
  String get tue_short => 'Tue';

  @override
  String get wed_short => 'Wed';

  @override
  String get thu_short => 'Thu';

  @override
  String get fri_short => 'Fri';

  @override
  String get sat_short => 'Sat';

  @override
  String get sun_short => 'Sun';

  @override
  String unread_messages_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
      zero: 'No unread messages',
    );
    return '$_temp0';
  }

  @override
  String get staff_pharmacist_hiring => 'Hiring Staff Pharmacist';

  @override
  String get staff_pharmacist_vacancy => 'Staff Pharmacist Vacancy';

  @override
  String get staff_pharmacist_opportunity => 'Staff Pharmacist Opportunity';

  @override
  String get find_pharmacy_job_title => 'Find a pharmacy job';

  @override
  String get featured_jobs_title => 'Featured jobs';

  @override
  String get interested_in_pharmacy_msg =>
      'Because you are interested in pharmacy';

  @override
  String get failed_to_load_jobs => 'Failed to load jobs';

  @override
  String get no_jobs_available => 'No jobs';

  @override
  String get filter_jobs_title => 'Filters';

  @override
  String get search_job_titles_hint => 'Search job titles';

  @override
  String get search_skills_hint => 'Search skills';

  @override
  String get apply_filters_btn => 'Apply';

  @override
  String get candidate_label => 'Candidate';

  @override
  String get enter_job_keyword_hint => 'Enter job title or keyword';

  @override
  String get job_seeker_label => 'Job Seeker';

  @override
  String get apply_now_btn => 'Apply Now';

  @override
  String featured_job_salary(String amount) {
    return '$amount / year';
  }

  @override
  String get all_cities => 'All';

  @override
  String get city_algiers => 'Algiers';

  @override
  String get city_oran => 'Oran';

  @override
  String get city_constantine => 'Constantine';

  @override
  String get city_annaba => 'Annaba';

  @override
  String get city_blida => 'Blida';

  @override
  String get city_tizi_ouzou => 'Tizi Ouzou';

  @override
  String get city_bejaia => 'Bejaia';

  @override
  String get city_setif => 'Setif';

  @override
  String get city_batna => 'Batna';

  @override
  String get city_skikda => 'Skikda';

  @override
  String get city_chlef => 'Chlef';

  @override
  String get city_mostaganem => 'Mostaganem';

  @override
  String get city_tlemcen => 'Tlemcen';

  @override
  String get city_biskra => 'Biskra';

  @override
  String get city_ouargla => 'Ouargla';

  @override
  String get city_ghardaia => 'Ghardaia';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_jobs => 'Jobs';

  @override
  String get nav_messages => 'Messages';

  @override
  String get nav_profiles => 'Profiles';

  @override
  String get nav_applications => 'Applications';

  @override
  String get nav_insights => 'Insights';

  @override
  String get nav_recruiters => 'Recruiters';

  @override
  String get nav_jobseekers => 'Job Seekers';

  @override
  String get del_account_title => 'Delete Account';

  @override
  String get del_account_warning => 'Warning';

  @override
  String get del_account_body =>
      'Deleting your account will permanently remove:\n• Your profile\n• Login data\n• All your records\n\nThis cannot be undone.';

  @override
  String get del_account_btn => 'Delete My Account';

  @override
  String get del_account_dialog_title => 'Delete Account';

  @override
  String get del_account_dialog_msg =>
      'This will permanently delete your account and all data. This cannot be undone.';

  @override
  String get del_account_not_auth => 'Not signed in. Please log in again.';

  @override
  String get del_account_error => 'Please log in again and retry.';

  @override
  String get profile_strength => 'Profile Strength';

  @override
  String get job_applications_nav => 'Job Applications';

  @override
  String get matches => 'Matches';

  @override
  String get job_matches => 'Job Matches';

  @override
  String get based_on_your_profile => 'Based on your profile';

  @override
  String get skills_verified_count => 'Skills Verified';

  @override
  String get improve_visibility => 'Improve visibility';

  @override
  String get profile_views_count => 'Profile Views';

  @override
  String get recruiters_viewed_you => 'Recruiters viewed you';

  @override
  String get profile_visibility => 'Profile Visibility';

  @override
  String get visibility_high => 'High';

  @override
  String get visibility_anonymous => 'Anonymous';

  @override
  String get privacy_mode => 'Privacy Mode';

  @override
  String get skill_verification_title => 'Skill Verification';

  @override
  String get verify_your_skills => 'Verify Your Skills';

  @override
  String get verify_skills_desc =>
      'Ask a pharmacy you\'ve worked with to confirm your experience';

  @override
  String get status_verified_label => 'Verified';

  @override
  String get status_pending_label => 'Pending';

  @override
  String get status_rejected_label => 'Rejected';

  @override
  String get my_profile => 'My Profile';

  @override
  String get profile_views_drawer => 'Profile Views';

  @override
  String get profile_views_desc => 'Recruiters who viewed you';

  @override
  String get personal_pro_info => 'Personal & professional info';

  @override
  String get find_your_next_role => 'Find your next role';

  @override
  String pharmacies_on_map(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pharmacies on map',
      one: '1 pharmacy on map',
    );
    return '$_temp0';
  }

  @override
  String get tap_pin_or_scroll_below => 'Tap a pin or scroll below';

  @override
  String get pharmacy_profile => 'Pharmacy Profile';

  @override
  String available_jobs_count(Object count) {
    return 'Available Jobs ($count)';
  }

  @override
  String get no_active_jobs_available => 'No active jobs available right now.';

  @override
  String get no_jobs_location_hint => 'No jobs available at this location';

  @override
  String get filter_btn => 'Filter';

  @override
  String get clear_btn => 'Clear';

  @override
  String get my_applications_title => 'My Applications';

  @override
  String get failed_to_load_applications => 'Failed to load applications';

  @override
  String get status_accepted => 'Accepted';

  @override
  String get status_viewed => 'Viewed';

  @override
  String get status_applied => 'Applied';

  @override
  String get chat_with_recruiter => 'Chat with recruiter';

  @override
  String get open_chat_failed => 'Failed to open chat. Please try again.';

  @override
  String get no_applications_title => 'No applications yet';

  @override
  String get no_applications_subtitle => 'Apply to jobs and track them here';

  @override
  String get time_just_now => 'Just now';

  @override
  String time_min_ago(int count) {
    return '${count}m ago';
  }

  @override
  String time_hours_ago(int count) {
    return '${count}h ago';
  }

  @override
  String time_days_ago(int count) {
    return '${count}d ago';
  }

  @override
  String time_weeks_ago(int count) {
    return '${count}w ago';
  }

  @override
  String time_months_ago(int count) {
    return '${count}mo ago';
  }

  @override
  String time_years_ago(int count) {
    return '${count}y ago';
  }

  @override
  String salary_per_year(String salary) {
    return '$salary / Year';
  }

  @override
  String get profile_analytics_title => 'Profile Analytics';

  @override
  String get views_trend_title => 'Views Trend';

  @override
  String get last_7_days_subtitle => 'Last 7 days';

  @override
  String get total_profile_views => 'Total Profile Views';

  @override
  String this_week_views(int count) {
    return '+$count this week';
  }

  @override
  String get recruiters_label => 'Recruiters';

  @override
  String get todays_views_label => 'Today\'s Views';

  @override
  String get daily_breakdown_title => 'Daily Breakdown';

  @override
  String get today_label => 'Today';

  @override
  String views_count_tooltip(int count) {
    return '$count views';
  }

  @override
  String get no_trend_data => 'No trend data yet';

  @override
  String get no_profile_views_title => 'No profile views yet';

  @override
  String get no_profile_views_subtitle =>
      'When recruiters view your profile,\nyour analytics will appear here.';

  @override
  String get day_mon => 'Mon';

  @override
  String get day_tue => 'Tue';

  @override
  String get day_wed => 'Wed';

  @override
  String get day_thu => 'Thu';

  @override
  String get day_fri => 'Fri';

  @override
  String get day_sat => 'Sat';

  @override
  String get day_sun => 'Sun';

  @override
  String get select_pharmacy_title => 'Select Pharmacy';

  @override
  String get search_pharmacy_hint => 'Search pharmacy by name';

  @override
  String get no_pharmacies_found => 'No pharmacies found';

  @override
  String get skill_verification_requests_title => 'Skill Verification Requests';

  @override
  String get verification_request_sent_success =>
      'Verification request sent successfully!';

  @override
  String failed_to_send_request(String error) {
    return 'Failed to send request: $error';
  }

  @override
  String get add_note_dialog_title => 'Add a Note (Optional)';

  @override
  String get add_note_dialog_hint =>
      'Add any additional information for the recruiter...';

  @override
  String get dialog_cancel_btn => 'Cancel';

  @override
  String get send_request_btn => 'Send Request';

  @override
  String get status_not_requested => 'Not Requested';

  @override
  String get status_pending => 'Pending';

  @override
  String get status_completed => 'Completed';

  @override
  String get request_skill_verification_purpose =>
      'Request skill verification from this recruiter to strengthen your profile credibility and ranking.';

  @override
  String get send_skill_verification_request_btn =>
      'Send Skill Verification Request';

  @override
  String get verification_request_pending_desc =>
      'Verification request pending. The recruiter will review your skills soon.';

  @override
  String get verification_completed_desc =>
      'Verification completed! This recruiter has reviewed your skills.';

  @override
  String get chat_with_recruiter_btn => 'Chat with Recruiter';

  @override
  String failed_to_open_chat(String error) {
    return 'Failed to open chat: $error';
  }

  @override
  String get no_applications_yet_title => 'No Applications Yet';

  @override
  String get apply_to_jobs_for_verification_desc =>
      'Apply to jobs to request skill verification from recruiters';

  @override
  String get create_profile_title => 'Create Profile';

  @override
  String get my_profile_title => 'My Profile';

  @override
  String get personal_information_title => 'Personal Information';

  @override
  String get first_name_label => 'First Name';

  @override
  String get last_name_label => 'Last Name';

  @override
  String get show_my_name_label => 'Show my name to recruiters';

  @override
  String get location_information_title => 'Location Information';

  @override
  String get my_location_title => 'My Location';

  @override
  String get change_location_btn => 'Change';

  @override
  String get set_location_btn => 'Set';

  @override
  String get current_job_title_title => 'Current job title';

  @override
  String get select_job_title_hint => 'Select your current job title';

  @override
  String get skills_title => 'Skills';

  @override
  String get add_skill_btn => 'Add Skill';

  @override
  String get background_title => 'Background';

  @override
  String get job_experience_hint => 'Select your job experience level';

  @override
  String get save_changes_btn => 'Save Changes';

  @override
  String get select_skills_title => 'Select Skills';

  @override
  String get no_experience_available => 'No experience levels available';

  @override
  String get no_options_available => 'No options available';

  @override
  String get select_province_hint => 'Select Province';

  @override
  String get loading_hint => 'Loading...';

  @override
  String get select_city_hint => 'Select City';

  @override
  String get fill_required_fields_error => 'Please fill all required fields';

  @override
  String get phone_required_error => 'Phone number is required';

  @override
  String get phone_nine_digits_error => 'Phone number must be 9 digits';

  @override
  String get phone_invalid_start_error =>
      'Phone must start with 5, 6, or 7 (Algeria only)';

  @override
  String get status_verified => 'Verified';

  @override
  String get crop_photo_title => 'Crop Photo';

  @override
  String get camera_btn => 'Camera';

  @override
  String get gallery_btn => 'Gallery';

  @override
  String get remove_photo_btn => 'Remove photo';

  @override
  String get general_save_btn => 'Save';

  @override
  String get general_change_btn => 'Change';

  @override
  String get recrop_btn => 'Recrop';

  @override
  String get add_profile_photo_label => 'Add profile photo';

  @override
  String get admin_active_jobs_title => 'Jobs';

  @override
  String get admin_active_jobs_sub => 'Active';

  @override
  String get admin_skill_req_title => 'Skills';

  @override
  String get admin_skill_req_sub => 'Pending';

  @override
  String get admin_recruiters_title => 'Recruiters';

  @override
  String get admin_recruiters_sub => 'Registered';

  @override
  String get admin_seekers_title => 'Candidates';

  @override
  String get admin_seekers_sub => 'Active';

  @override
  String get admin_platform_activity => 'Activity';

  @override
  String get admin_platform_activity_desc => 'General Overview';

  @override
  String get admin_open_jobs => 'Open';

  @override
  String get admin_closed_jobs => 'Closed';

  @override
  String get admin_user_activity => 'Users';

  @override
  String get admin_user_activity_desc => 'Candidates vs Recruiters';

  @override
  String get admin_reported_issues => 'Issues';

  @override
  String get admin_total_earnings => 'Earnings';

  @override
  String get admin_job_status_overview => 'Job Offer Status Overview';

  @override
  String admin_jobs_open_count(int active, int total) {
    return 'You currently have $active of $total jobs open';
  }

  @override
  String get admin_manage_account => 'Manage Account';

  @override
  String get admin_active_label => 'Active';

  @override
  String get admin_drawer_payments_title => 'Payments from Recruiters';

  @override
  String get admin_drawer_payments_sub => 'View payments from recruiters';

  @override
  String get admin_drawer_job_options_title => 'Add Job Title/Skill';

  @override
  String get admin_drawer_job_options_sub =>
      'Add new job titles or skills to the system';

  @override
  String get admin_drawer_job_types_title => 'Manage Job Types';

  @override
  String get admin_drawer_job_types_sub =>
      'Manage job types available in the app';

  @override
  String get admin_drawer_exp_levels_title => 'Manage Experience Levels';

  @override
  String get admin_drawer_exp_levels_sub =>
      'Manage experience levels available in the app';

  @override
  String get admin_drawer_locations_title => 'Manage Locations';

  @override
  String get admin_drawer_locations_sub =>
      'Manage locations available in the app';

  @override
  String get admin_drawer_payment_config_title =>
      'Manage Payment Configuration';

  @override
  String get admin_drawer_payment_config_sub => 'Manage payment parameters';

  @override
  String get admin_drawer_appeals_title => 'Pending Appeals';

  @override
  String get admin_drawer_appeals_sub => 'Review pending appeals';

  @override
  String get admin_add_user_title => 'Add New User';

  @override
  String get admin_appeals_title => 'Pending Appeals';

  @override
  String get admin_job_list_title => 'Job Listings';

  @override
  String get admin_payments_title => 'Payment Management';

  @override
  String get admin_promotion_title => 'Recruiter Promotion';

  @override
  String get admin_verification_title => 'Recruiter Verification';

  @override
  String get blocked_account_title => 'Account Blocked';

  @override
  String get create_user_btn => 'Create User';

  @override
  String get update_user_btn => 'Update User';

  @override
  String get no_pending_appeals_msg => 'No pending appeals';

  @override
  String get review_btn => 'Review';

  @override
  String get appeal_review_title => 'Appeal Review';

  @override
  String get user_email_label => 'User Email';

  @override
  String get block_reason_label => 'Block Reason';

  @override
  String get appeal_msg_label => 'Appeal Message';

  @override
  String get admin_msg_required_label => 'Admin message (required)';

  @override
  String get approve_btn => 'APPROVE';

  @override
  String get reject_btn_caps => 'REJECT';

  @override
  String get appeal_approved_notif_title => 'Appeal Approved';

  @override
  String get appeal_rejected_notif_title => 'Appeal Rejected';

  @override
  String get appeal_under_review_msg => 'Your appeal is under review';

  @override
  String get appeal_approved_msg => 'Your appeal was approved';

  @override
  String get appeal_rejected_msg => 'Your appeal was rejected';

  @override
  String get no_reason_provided => 'No reason provided';

  @override
  String get explain_unblock_hint =>
      'Explain why your account should be unblocked';

  @override
  String get submit_appeal_btn => 'Submit Appeal';

  @override
  String get blocked_acc_msg => 'Your account has been blocked';

  @override
  String get recruiter_verification_card => 'Recruiter Verification';

  @override
  String get make_featured_card => 'Make Recruiters Featured';

  @override
  String pending_count_label(int count) {
    return '$count pending';
  }

  @override
  String transactions_count_label(int count) {
    return '$count Tx';
  }

  @override
  String get recruiter_promotion_panel => 'Recruiter Promotion Panel';

  @override
  String get search_recruiters_label => 'Search Recruiters';

  @override
  String eligible_recruiters_count(int count) {
    return 'Eligible ($count)';
  }

  @override
  String get no_recruiters_match_search => 'No recruiters match your search.';

  @override
  String get pharmacy_search_hint => 'Pharmacy, name or city';

  @override
  String get recent_payments_title => 'Recent Payments';

  @override
  String get no_payments_found => 'No payments found';

  @override
  String get recruiter_verification_panel => 'Recruiter Verification Panel';

  @override
  String get search_pending_recruiters => 'Search Pending';

  @override
  String pending_verification_count(int count) {
    return '$count to verify';
  }

  @override
  String get no_recruiters_for_verification =>
      'No recruiters found for verification.';

  @override
  String get search_jobs_hint => 'Search jobs…';

  @override
  String get all_filter_label => 'All';

  @override
  String get open_filter_label => 'Open';

  @override
  String get closed_filter_label => 'Closed';

  @override
  String get total_revenue_label => 'Total Revenue';

  @override
  String get total_transactions_label => 'Total Transactions';

  @override
  String get pending_payments_label => 'Pending';

  @override
  String get paid_payments_label => 'Paid';

  @override
  String get amount_label => 'Amount';

  @override
  String get plan_label => 'Plan';

  @override
  String get status_label => 'Status';

  @override
  String get account_blocked_title => 'Account Blocked';

  @override
  String get admin_header_title => 'Admin Panel';

  @override
  String get pending_verification_label => 'Pending Verification';

  @override
  String get personal_info_section => 'Personal Info';

  @override
  String get company_info_section => 'Company Info';

  @override
  String registered_as_label(String role) {
    return 'Registered as $role';
  }

  @override
  String get verification_requests_card => 'Verification';

  @override
  String get featured_recruiters_card => 'Featured';

  @override
  String get payments_card => 'Payments';

  @override
  String pending_label(int count) {
    return '$count Pending';
  }

  @override
  String get open_jobs_tab => 'Open';

  @override
  String get closed_jobs_tab => 'Closed';

  @override
  String get failed_load_jobs => 'Load failed';

  @override
  String get view_details_btn => 'Details';

  @override
  String get clear_all_btn => 'Clear';

  @override
  String get search_province_hint => 'Province...';

  @override
  String get search_recruiters_hint => 'Search Recruiter...';

  @override
  String get verified_status => 'Verified';

  @override
  String get unverified_status => 'Unverified';

  @override
  String get view_profile_btn => 'Profile';

  @override
  String get paid_subscriptions_title => 'Paid Subs';

  @override
  String get no_paid_subs => 'No paid subs';

  @override
  String get active_label => 'Active';

  @override
  String get revenue_label => 'Revenue';

  @override
  String get expired_label => 'Expired';

  @override
  String until_label(String date) {
    return 'Until $date';
  }

  @override
  String get recruiter_label => 'Recruiter';

  @override
  String get street_label => 'Street';

  @override
  String get license_label => 'License';

  @override
  String get inactive_label => 'Inactive';

  @override
  String get lic_expires_label => 'Expires';

  @override
  String get paid_on_label => 'Paid on';

  @override
  String get method_label => 'Method';

  @override
  String get year_label => 'Year';

  @override
  String get checkout_id_label => 'TX ID';

  @override
  String get admin_msg_label => 'Admin Msg';

  @override
  String get no_recruiters_match => 'No recruiters match';

  @override
  String get skills_label => 'Skills';

  @override
  String get premium_label => 'Premium';

  @override
  String get no_to_verify => 'No recruiters to verify';

  @override
  String get admin_role_desc => 'Full platform access';

  @override
  String get admin_dashboard_subtitle => 'Admin Dashboard';

  @override
  String get admin_label => 'Admin';

  @override
  String get all_jobs_label => 'All Jobs';

  @override
  String get open_closed_jobs_subtitle => 'Open & Closed Jobs';

  @override
  String get search_job_hint => 'Enter job title or keyword';

  @override
  String get street_address_label => 'Street Address';

  @override
  String get province_label => 'Province';

  @override
  String get location_label => 'Location';

  @override
  String get any_label => 'Any';

  @override
  String get job_title_label => 'Job Title';

  @override
  String get only_admin_create_user_toast => 'Only admins can create users.';

  @override
  String get email_required_error => 'Email is required.';

  @override
  String get invalid_email_error => 'Please enter a valid email address.';

  @override
  String get password_required_error => 'Password is required.';

  @override
  String get invalid_password_format_error =>
      'Password must be at least 6 characters and include 1 uppercase, 1 lowercase, and 1 number.';

  @override
  String get confirm_password_required_error => 'Please confirm your password.';

  @override
  String get passwords_do_not_match_error => 'Passwords do not match.';

  @override
  String get admin_created_user_name => 'Admin Created User';

  @override
  String user_created_success_msg(String role) {
    return 'User successfully created as $role.';
  }

  @override
  String get access_denied_admin => 'Access denied. Admin only.';

  @override
  String get add_new_user_title => 'Add New User';

  @override
  String get create_user_account_header => 'Create User Account';

  @override
  String get create_user_account_desc =>
      'Fill in the details and assign a role.\nA verification email will be sent automatically.';

  @override
  String get assign_role_label => 'Assign Role';

  @override
  String get admin_role_label => 'Admin';

  @override
  String get recruiters_list => 'Recruiters';

  @override
  String get recruiters => 'Recruiters';

  @override
  String get searchHint => 'Search by pharmacy, name or city';

  @override
  String get noRecruitersFound => 'No recruiters found';

  @override
  String get loadingRecruiters => 'Loading recruiters…';

  @override
  String recruitersLoaded(Object count) {
    return '$count recruiters loaded';
  }

  @override
  String get loadMoreRecruiters => 'Load more recruiters';

  @override
  String allRecruitersLoaded(Object count) {
    return 'All $count recruiters loaded';
  }

  @override
  String get verified => 'Verified';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get recruiterVerificationPanel => 'Verification Panel';

  @override
  String get searchPendingRecruiters => 'Search Recruiters';

  @override
  String get searchHintRecruiters => 'Search pharmacy, name or city';

  @override
  String get pendingVerification => 'Pending Verification';

  @override
  String get noRecruitersForVerification => 'No recruiters found';

  @override
  String get premium => 'Premium';

  @override
  String get recruiterPromotionPanel => 'Promotion Panel';

  @override
  String get searchRecruiters => 'Search Recruiters';

  @override
  String get eligibleRecruiters => 'Eligible Recruiters';

  @override
  String get noRecruitersMatch => 'No recruiters found';

  @override
  String get recruiterProfile => 'Profile';

  @override
  String get pharmacyInfo => 'Pharmacy Info';

  @override
  String get pharmacist => 'Pharmacist';

  @override
  String get metaInfo => 'Details';

  @override
  String get jobStats => 'Job Stats';

  @override
  String get pharmacyName => 'Pharmacy';

  @override
  String get province => 'Province';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get userId => 'User ID';

  @override
  String get createdAt => 'Created';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get totalJobs => 'Total Jobs';

  @override
  String get activeJobs => 'Active Jobs';

  @override
  String get draftJobs => 'Drafts';

  @override
  String get verifyRecruiter => 'Verify';

  @override
  String get unverifyRecruiter => 'Unverify';

  @override
  String get recruiterApproved => 'Approved';

  @override
  String get recruiterDeactivated => 'Deactivated';

  @override
  String get makeRecruiterPro => 'Make Pro';

  @override
  String get recruiterUpgraded => 'Upgraded to Pro';

  @override
  String get failedLoadJobs => 'Load failed';

  @override
  String get paidSubscriptions => 'Subscriptions';

  @override
  String get noPaidSubscriptions => 'No subscriptions';

  @override
  String get total => 'Total';

  @override
  String get revenue => 'Revenue';

  @override
  String get unknownPharmacy => 'Unknown';

  @override
  String get expired => 'Expired';

  @override
  String get until => 'Until';

  @override
  String get recruiter => 'Recruiter';

  @override
  String get payment => 'Payment';

  @override
  String get name => 'Name';

  @override
  String get street => 'Street';

  @override
  String get license => 'License';

  @override
  String get licenseExpires => 'Expires';

  @override
  String get paidOn => 'Paid';

  @override
  String get expires => 'Expires';

  @override
  String get method => 'Method';

  @override
  String get year => 'Year';

  @override
  String get checkoutId => 'Checkout ID';

  @override
  String get inactive => 'Inactive';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get manageOptions => 'Manage Options';

  @override
  String get jobTitles => 'Job Titles';

  @override
  String get noOptions => 'No options yet';

  @override
  String get hidden => 'Hidden';

  @override
  String get deleteOption => 'Delete Option';

  @override
  String deleteOptionConfirm(Object name) {
    return 'Delete \"$name\" permanently?';
  }

  @override
  String get fillAllLanguages => 'Fill in all three languages';

  @override
  String get editJobTitle => 'Edit Job Title';

  @override
  String get addJobTitle => 'Add Job Title';

  @override
  String get editSkill => 'Edit Skill';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get englishRequired => 'English name is required';

  @override
  String get frenchRequired => 'French name is required';

  @override
  String get arabicRequired => 'Arabic name is required';

  @override
  String get labelInEnglish => 'Label in English';

  @override
  String get labelInFrench => 'Label in French';

  @override
  String get labelInArabic => 'Label in Arabic';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get jobTypesTitle => 'Job Types';

  @override
  String typesCount(Object count) {
    return '$count types';
  }

  @override
  String get noJobTypes => 'No job types yet';

  @override
  String get addNewHint => 'Tap + to add one';

  @override
  String get deleteJobTypeTitle => 'Delete Job Type';

  @override
  String deleteJobTypeConfirm(Object name) {
    return 'Delete \"$name\" permanently?';
  }

  @override
  String get addJobType => 'Add Job Type';

  @override
  String get editJobType => 'Edit Job Type';

  @override
  String get fillLanguages => 'Fill in all three languages';

  @override
  String nameInLanguage(String language) {
    return 'Name in $language...';
  }

  @override
  String get experienceLevelsTitle => 'Experience Levels';

  @override
  String levelsCount(Object count) {
    return '$count levels';
  }

  @override
  String get noExperienceLevels => 'No experience levels yet';

  @override
  String get deleteExperienceLevelTitle => 'Delete Experience Level';

  @override
  String deleteExperienceLevelConfirm(Object name) {
    return 'Delete \"$name\" permanently?';
  }

  @override
  String get addExperienceLevel => 'Add Experience Level';

  @override
  String get editExperienceLevel => 'Edit Experience Level';

  @override
  String labelInLanguage(Object lang) {
    return 'Label in $lang...';
  }

  @override
  String get titleProvincesCities => 'Provinces & Cities';

  @override
  String provincesCount(int count) {
    return '$count provinces';
  }

  @override
  String citiesCount(int count) {
    return '$count cities';
  }

  @override
  String get noProvinces => 'No provinces yet';

  @override
  String get noCities => 'No cities yet';

  @override
  String get addProvinceHint => 'Tap + to add a province';

  @override
  String addCityHint(String province) {
    return 'Tap + to add a city to $province';
  }

  @override
  String get cities => 'Cities';

  @override
  String get deleteProvinceTitle => 'Delete Province';

  @override
  String deleteProvinceMessage(String name) {
    return 'Delete \"$name\" and ALL its cities permanently?';
  }

  @override
  String get deleteCityTitle => 'Delete City';

  @override
  String deleteCityMessage(String name) {
    return 'Delete \"$name\" permanently?';
  }

  @override
  String get edit => 'Edit';

  @override
  String get addProvince => 'Add Province';

  @override
  String get editProvince => 'Edit Province';

  @override
  String get addCity => 'Add City';

  @override
  String get editCity => 'Edit City';

  @override
  String get paymentConfigTitle => 'Payment Config';

  @override
  String get save => 'Save';

  @override
  String get saveConfiguration => 'Save Configuration';

  @override
  String get environment => 'Environment';

  @override
  String get environmentSubtitle => 'Switch between test and production mode';

  @override
  String get testMode => 'Test Mode';

  @override
  String get testModeSubtitle => 'No real money charged';

  @override
  String get production => 'Production';

  @override
  String get productionSubtitle => 'Live payments';

  @override
  String get apiCredentials => 'API Credentials';

  @override
  String get apiCredentialsSubtitle => 'Chargily secret key and endpoint URLs';

  @override
  String get testSecretKey => 'Test Secret Key';

  @override
  String get cloudFunctionUrl => 'Cloud Function URL';

  @override
  String get webhookUrl => 'Webhook URL';

  @override
  String get redirectUrls => 'Redirect URLs';

  @override
  String get redirectUrlsSubtitle => 'Where Chargily sends users after payment';

  @override
  String get successUrl => 'Success URL';

  @override
  String get failureUrl => 'Failure URL';

  @override
  String get pricing => 'Pricing';

  @override
  String get pricingSubtitle => 'Annual fee, currency and locale';

  @override
  String get annualFee => 'Annual Fee';

  @override
  String get currency => 'Currency';

  @override
  String get locale => 'Locale';

  @override
  String get planCopy => 'Plan Copy';

  @override
  String get planCopySubtitle =>
      'Text shown to recruiters on the subscription screen';

  @override
  String get planName => 'Plan Name';

  @override
  String get planSubtitle => 'Subtitle';

  @override
  String get planDescription => 'Description';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get planFeatures => 'Plan Features';

  @override
  String get planFeaturesSubtitle =>
      'Bullet points shown on the subscription screen. Drag to reorder.';

  @override
  String get newFeature => 'New Feature';

  @override
  String get noFeatures => 'No features added yet';

  @override
  String get annualFeeError => 'Annual fee must be a valid number.';

  @override
  String get saveSuccess => 'Payment config saved successfully.';

  @override
  String saveError(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get close_issue_btn => 'Close Issue';

  @override
  String get tabs_open => 'Open';

  @override
  String get tabs_closed => 'Closed';

  @override
  String get loginHere => 'Login Here';

  @override
  String get welcomeMessage =>
      'Access your Ophicina account securely with your preferred method';

  @override
  String get monthlyLimitTitle => 'Monthly Limit Reached';

  @override
  String monthlyLimitMessage(Object limit) {
    return 'You have used all $limit job posts for this month. Your limit resets on the 1st of next month. Contact admin if you need more.';
  }

  @override
  String get ok => 'OK';

  @override
  String get notif_account_verified_title => 'Account Verified';

  @override
  String get notif_account_verified_desc =>
      'Your recruiter account has been verified by the Ophicina team.';

  @override
  String get notif_account_deactivated_title => 'Account Deactivated';

  @override
  String get notif_account_deactivated_desc =>
      'Your recruiter account has been deactivated. Please contact support for more information.';

  @override
  String get notif_account_pro_title => 'Upgraded to Pro';

  @override
  String get notif_account_pro_desc =>
      'Congratulations! Your account has been upgraded to Pro status.';

  @override
  String get notif_quota_updated_title => 'Job Post Quota Updated';

  @override
  String notif_quota_updated_desc(int limit) {
    return 'Your monthly job post limit has been updated to $limit posts.';
  }

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get emailLabel => 'Email';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get resetLinkSent =>
      'Reset link sent. Check your inbox. Please don\'t forget to check spam folder.';

  @override
  String get noAccountFound => 'No account found with that email.';

  @override
  String get errorPrefix => 'Error:';
}
