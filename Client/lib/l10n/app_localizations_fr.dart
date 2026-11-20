// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get app_title => 'Ophicina';

  @override
  String get tagline => 'Votre opportunité est ici';

  @override
  String get role_job_seeker => 'Candidat';

  @override
  String get role_recruiter => 'Recruteur';

  @override
  String get onboarding_title => 'Bienvenue sur Ophicina';

  @override
  String get onboarding_subtitle =>
      'Connecter les professionnels de la pharmacie aux bonnes opportunités.';

  @override
  String get login_title => 'Connexion à Ophicina';

  @override
  String get login_subtitle_email => 'Connexion sécurisée par e-mail';

  @override
  String get login_subtitle_phone =>
      'Connexion sécurisée par numéro de téléphone';

  @override
  String get email_label => 'Email';

  @override
  String get password_label => 'Mot de passe';

  @override
  String get forgot_password => 'Mot de passe oublié ?';

  @override
  String get sign_in_button => 'Se connecter';

  @override
  String get create_account => 'Créer un compte';

  @override
  String get welcome_to_ophicina => 'Bienvenue sur Ophicina';

  @override
  String get signup_subtitle =>
      'Rejoignez le réseau des professionnels de santé';

  @override
  String get confirm_password_label => 'Confirmer le mot de passe';

  @override
  String get already_have_account => 'Vous avez déjà un compte ?';

  @override
  String get join_ophicina => 'Rejoindre Ophicina';

  @override
  String get join_subtitle => 'Créez un compte pour découvrir les opportunités';

  @override
  String get signup_with_email => 'S\'inscrire par e-mail';

  @override
  String get signup_with_google => 'S\'inscrire avec Google';

  @override
  String get signup_with_apple => 'S\'inscrire avec Apple';

  @override
  String get deletion_queue_error =>
      'Votre demande de suppression est en cours. Veuillez utiliser un autre identifiant.';

  @override
  String get email_required => 'L\'e-mail est requis';

  @override
  String get valid_email_error => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get password_required => 'Le mot de passe est requis';

  @override
  String get password_format_error =>
      'Le mot de passe doit contenir au moins 6 caractères, une majuscule, une minuscule et un chiffre';

  @override
  String get confirm_password_required =>
      'Veuillez confirmer votre mot de passe';

  @override
  String get passwords_dont_match => 'Les mots de passe ne correspondent pas';

  @override
  String get signup_successful => 'Inscription réussie !';

  @override
  String get enter_valid_email => 'Veuillez saisir un e-mail valide';

  @override
  String get enter_password => 'Veuillez saisir le mot de passe';

  @override
  String get enter_phone => 'Entrez le numéro de téléphone';

  @override
  String get enter_valid_algerian =>
      'Entrez un numéro algérien valide (5, 6 ou 7 suivi de 8 chiffres)';

  @override
  String get enter_valid_pakistani =>
      'Entrez un numéro pakistanais valide (3 suivi de 9 chiffres)';

  @override
  String otp_sent_to(String phone) {
    return 'OTP envoyé à $phone';
  }

  @override
  String get otp_not_sent => 'OTP non encore envoyé';

  @override
  String get otp_complete => 'Entrez le code OTP complet à 6 chiffres';

  @override
  String get account_not_found =>
      'Votre compte n\'a pas été trouvé, veuillez vous inscrire d\'abord';

  @override
  String get login_here => 'Connectez-vous ici';

  @override
  String get login_subtitle_welcome =>
      'Accédez à votre compte Ophicina en toute sécurité avec votre méthode préférée';

  @override
  String get login_with_email => 'Se connecter avec e-mail';

  @override
  String get login_with_google => 'Se connecter avec Google';

  @override
  String get login_with_apple => 'Se connecter avec Apple';

  @override
  String get sign_in => 'Connexion';

  @override
  String get sign_up => 'Inscription';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String hi_user(String name) {
    return 'Salut, $name';
  }

  @override
  String get my_account => 'Mon compte';

  @override
  String get post_job => 'Publier une offre';

  @override
  String get post_job_desc =>
      'Atteignez les pharmaciens en listant vos postes vacants';

  @override
  String get edit_profile => 'Modifier le profil';

  @override
  String get edit_profile_desc =>
      'Modifier le profil et les détails de la pharmacie';

  @override
  String get report_issue => 'Signaler un problème';

  @override
  String get report_issue_desc => 'Signaler des bugs et des problèmes';

  @override
  String get reported_issues => 'Problèmes signalés';

  @override
  String get reported_issues_desc => 'Voir vos problèmes signalés';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logout_desc => 'Se déconnecter de votre compte';

  @override
  String get delete_account => 'Supprimer le compte';

  @override
  String get delete_account_desc => 'Ceci supprimera votre compte';

  @override
  String get jobs_status_overview => 'Aperçu du statut des offres d\'emploi';

  @override
  String jobs_open_count(int active, int total) {
    return 'Vous avez actuellement $active sur $total postes ouverts';
  }

  @override
  String get manage_account => 'Gérer le compte';

  @override
  String get active => 'Actif';

  @override
  String get open_jobs => 'Offres ouvertes';

  @override
  String open_jobs_count(int open, int total) {
    return '$open sur $total ouvert';
  }

  @override
  String get filled_positions => 'Postes pourvus';

  @override
  String filled_positions_count(int filled, int total) {
    return '$filled sur $total pourvus';
  }

  @override
  String get skill_verification_requests =>
      'Demandes de vérification des compétences';

  @override
  String pending_requests_count(int count) {
    return '$count demandes en attente';
  }

  @override
  String get view => 'Voir';

  @override
  String get hiring_activity => 'Votre activité de recrutement';

  @override
  String get review_profiles => 'Examiner les profils';

  @override
  String reviewed_count(int reviewed, int total) {
    return 'Examiné : $reviewed/$total';
  }

  @override
  String get chat_card => 'Chat';

  @override
  String read_count(int read, int total) {
    return 'Lu : $read/$total';
  }

  @override
  String get all_time_job_stats =>
      'Statistiques des offres d\'emploi de tous les temps';

  @override
  String get no_job_offers_stats =>
      'Aucune offre d\'emploi disponible pour afficher les statistiques.';

  @override
  String get no_stats_available => 'Aucune statistique disponible';

  @override
  String get candidates => 'Candidats';

  @override
  String candidates_count(int count) {
    return '$count Candidats';
  }

  @override
  String get upcoming_hiring_actions => 'Actions de recrutement à venir';

  @override
  String get see_all => 'Voir tout';

  @override
  String get create_account_title => 'Créer un compte';

  @override
  String get edit_profile_title => 'Modifier le Profil';

  @override
  String get my_account_title => 'Mon compte';

  @override
  String get update_profile_picture => 'Mettre à jour la photo de profil';

  @override
  String get personal_information => 'Informations personnelles';

  @override
  String get first_name => 'Prénom';

  @override
  String get first_name_hint => 'Anabella';

  @override
  String get last_name => 'Nom';

  @override
  String get last_name_hint => 'Angela';

  @override
  String get pharmacy_location_title => 'Pharmacie et emplacement';

  @override
  String get pharmacy_name => 'Nom de la pharmacie';

  @override
  String get pharmacy_name_hint => 'Pharmacie GreenCare';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get select_province => 'Sélectionner la province';

  @override
  String get city => 'Ville';

  @override
  String get select_province_first => 'Sélectionnez la province en premier';

  @override
  String get loading_dots => 'Chargement...';

  @override
  String get select_city => 'Sélectionner la ville';

  @override
  String get pharmacy_location_tile => 'Emplacement de la pharmacie';

  @override
  String get tap_to_set_location => 'Appuyez pour définir sur la carte';

  @override
  String get set_btn => 'Définir';

  @override
  String get change_btn => 'Modifier';

  @override
  String get save_changes => 'Enregistrer les modifications';

  @override
  String get create_account_btn => 'Créer un compte';

  @override
  String get all_rights_reserved => 'Tous droits réservés';

  @override
  String get profile_photo_title => 'Photo de profil';

  @override
  String get crop_photo => 'Recadrer la photo';

  @override
  String get profile_picture_updated => 'Photo de profil mise à jour';

  @override
  String failed_to_update(String error) {
    return 'Échec : $error';
  }

  @override
  String get camera => 'Appareil photo';

  @override
  String get gallery => 'Galerie';

  @override
  String get remove_photo => 'Supprimer la photo';

  @override
  String get save_btn => 'Enregistrer';

  @override
  String get change_action => 'Changer';

  @override
  String get recrop_action => 'Recadrer';

  @override
  String get add_profile_photo_btn => 'Ajouter une photo de profil';

  @override
  String get normal_filter => 'Normal';

  @override
  String get verify_jobseeker_skills_title =>
      'Vérifier les compétences du chercheur d\'emploi';

  @override
  String get failed_to_load_requests => 'Échec du chargement des demandes';

  @override
  String get no_pending_skill_requests =>
      'Aucune demande de compétence en attente';

  @override
  String get anonymous_candidate => 'Candidat anonyme';

  @override
  String get verify_skills_btn => 'Vérifier les compétences';

  @override
  String get skill_verification_completed_notif_title =>
      'Vérification des compétences terminée';

  @override
  String get skill_verification_completed_notif_desc =>
      'Vos compétences ont été examinées par le recruteur.';

  @override
  String get skills_to_review_label => 'Compétences à examiner';

  @override
  String get note_from_jobseeker_label => 'Note du chercheur d\'emploi';

  @override
  String get no_note_provided =>
      'Aucune note fournie par le chercheur d\'emploi.';

  @override
  String get mark_verification_completed_btn =>
      'Marquer la vérification comme terminée';

  @override
  String get all_skills_reviewed_msg =>
      'Toutes les compétences ont déjà été examinées pour ce chercheur d\'emploi.';

  @override
  String get pending_review_status => 'Examen en attente';

  @override
  String get phone_label => 'Téléphone';

  @override
  String get city_label => 'Ville';

  @override
  String get education_label => 'Éducation';

  @override
  String get experience_label => 'Expérience';

  @override
  String get wilaya_label => 'Wilaya';

  @override
  String get na_value => 'N/A';

  @override
  String get verify_action => 'Vérifier';

  @override
  String get reject_action => 'Rejeter';

  @override
  String verified_count_label(Object count) {
    return '$count vérifié';
  }

  @override
  String rejected_count_label(Object count) {
    return '$count rejeté';
  }

  @override
  String get closed_jobs => 'Offres fermées';

  @override
  String get view_details => 'Voir les détails';

  @override
  String get job_type_label => 'Type d\'emploi';

  @override
  String get open_status => 'Ouverte';

  @override
  String get closed_status => 'Fermée';

  @override
  String get edit_job => 'Modifier l\'offre';

  @override
  String get delete_job => 'Supprimer l\'offre';

  @override
  String get close_job => 'Fermer l\'offre';

  @override
  String get delete_job_confirm_title => 'Supprimer l\'offre';

  @override
  String get delete_job_confirm_msg =>
      'Voulez-vous vraiment supprimer cette offre ?\n\nCette action est permanente et vous ne pourrez PAS récupérer cette offre.';

  @override
  String get close_job_confirm_title => 'Fermer l\'offre';

  @override
  String get close_job_confirm_msg =>
      'Voulez-vous vraiment fermer cette offre ?\n\nUne fois fermée, cette offre ne sera plus active pour les candidats.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get no_job_offers_yet => 'Pas encore d\'offres d\'emploi';

  @override
  String get create_first_job_offer =>
      'Créez votre première offre d\'emploi pour commencer';

  @override
  String get posted_jobs => 'Offres publiées';

  @override
  String get just_now => 'À l\'instant';

  @override
  String min_ago(int count) {
    return 'Il y a $count min';
  }

  @override
  String hours_ago(int count) {
    return 'Il y a $count h';
  }

  @override
  String days_ago(int count) {
    return 'Il y a $count j';
  }

  @override
  String weeks_ago(int count) {
    return 'Il y a $count sem';
  }

  @override
  String months_ago(int count) {
    return 'Il y a $count mois';
  }

  @override
  String years_ago(int count) {
    return 'Il y a $count ans';
  }

  @override
  String get per_year => '/ An';

  @override
  String get k_per_year => 'K / An';

  @override
  String get m_per_year => 'M / An';

  @override
  String get job_title_pharmacist => 'Pharmacien';

  @override
  String get job_title_gerant => 'Gérant';

  @override
  String get job_title_physician => 'Médecin';

  @override
  String get job_title_senior_salesperson => 'Vendeur Senior';

  @override
  String get job_title_sales_specialist => 'Spécialiste des Ventes';

  @override
  String get job_title_intern => 'Stagiaire';

  @override
  String get job_title_labeling_specialist => 'Spécialiste de l\'étiquetage';

  @override
  String get job_title_data_entry_specialist => 'Saisie de données';

  @override
  String get job_title_stock_management_specialist => 'Gestion de stock';

  @override
  String get job_type_full_time => 'Temps plein';

  @override
  String get job_type_part_time => 'Temps partiel';

  @override
  String get job_type_replacement => 'Remplacement';

  @override
  String get chats => 'Discussions';

  @override
  String get search_chats => 'Rechercher des discussions';

  @override
  String get no_chats_yet => 'Pas encore de discussions';

  @override
  String you(String message) {
    return 'Vous : $message';
  }

  @override
  String get typing => 'En train d\'écrire...';

  @override
  String get no_messages_yet => 'Pas encore de messages';

  @override
  String get type_a_message => 'Tapez un message...';

  @override
  String get please_select_job_title =>
      'Veuillez sélectionner un titre de poste.';

  @override
  String get please_select_job_type =>
      'Veuillez sélectionner un type d\'emploi.';

  @override
  String get please_add_skill => 'Veuillez ajouter au moins une compétence.';

  @override
  String get recruiter_profile_not_found => 'Profil du recruteur introuvable.';

  @override
  String get account_not_active =>
      'Votre compte n\'est pas actif. Veuillez vous déconnecter et vous reconnecter ou contacter le support.';

  @override
  String get active_listing_required =>
      'Une période d\'inscription active est requise pour publier des offres d\'emploi en pharmacie.';

  @override
  String get select_skills => 'Sélectionner des compétences';

  @override
  String get no_skills_available => 'Aucune compétence disponible';

  @override
  String get create_job_offer => 'Créer une offre d\'emploi';

  @override
  String get edit_job_offer => 'Modifier l\'offre d\'emploi';

  @override
  String get job_details => 'Détails de l\'emploi';

  @override
  String get job_details_desc =>
      'Remplissez les détails pour publier votre offre d\'emploi';

  @override
  String get job_title => 'Titre du poste';

  @override
  String get job_type => 'Type d\'emploi';

  @override
  String get required_skills => 'Compétences requises';

  @override
  String get required_skills_desc =>
      'Ajoutez les compétences que les candidats doivent avoir';

  @override
  String get add_skills => 'Ajouter des compétences';

  @override
  String get post_job_btn => 'Publier l\'offre';

  @override
  String get update_job_btn => 'Mettre à jour l\'offre';

  @override
  String get search_skills_or_positions =>
      'Chercher des compétences ou des postes…';

  @override
  String no_matches_for_query(String query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get skill => 'Compétence';

  @override
  String get position => 'Poste';

  @override
  String get clear_all => 'Tout effacer';

  @override
  String get clear_text => 'Effacer';

  @override
  String show_profiles_selected_count(int count) {
    return 'Afficher les profils  ·  $count sélectionné(s)';
  }

  @override
  String get show_all_profiles => 'Afficher tous les profils';

  @override
  String get job_seeker_profiles => 'Profils de candidats';

  @override
  String get job_seeker_location => 'Localisation du candidat';

  @override
  String get candidate_location => 'Localisation du candidat';

  @override
  String get location_not_shared => 'Localisation non partagée';

  @override
  String get location_not_shared_desc =>
      'Ce candidat n\'a pas encore\npartagé sa localisation.';

  @override
  String get verified_skills => 'Compétences vérifiées';

  @override
  String get unverified => 'Non vérifié';

  @override
  String get skills => 'Compétences';

  @override
  String get contact_and_location => 'Contact & Localisation';

  @override
  String get block_profile => 'Bloquer le profil';

  @override
  String get block_user_account => 'Bloquer le compte utilisateur';

  @override
  String get block_user_reason_desc =>
      'Veuillez indiquer une raison. Ce message sera affiché à l\'utilisateur.';

  @override
  String get enter_block_reason => 'Entrer la raison du blocage...';

  @override
  String get reason_is_required => 'Une raison est requise';

  @override
  String get confirm_block => 'Confirmer le blocage';

  @override
  String get user_account_blocked => 'Compte utilisateur bloqué';

  @override
  String profiles_on_map(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profils sur la carte',
      one: '1 profil sur la carte',
    );
    return '$_temp0';
  }

  @override
  String get tap_pin_or_scroll =>
      'Appuyez sur une épingle ou défilez vers le bas';

  @override
  String get profile => 'Profil';

  @override
  String get no_skills_listed => 'Aucune compétence listée';

  @override
  String plus_more_count(int count) {
    return '+$count de plus';
  }

  @override
  String get view_profile => 'Voir le profil';

  @override
  String get no_profiles_match_filters =>
      'Aucun profil ne correspond à vos filtres';

  @override
  String get filter_profiles_hint => 'Filtrer les profils…';

  @override
  String active_filters_count(int count) {
    return '$count actif';
  }

  @override
  String get show_results => 'Afficher les résultats';

  @override
  String get search_wilaya => 'Rechercher une wilaya…';

  @override
  String get address => 'Adresse';

  @override
  String get district => 'District';

  @override
  String get experience => 'Expérience';

  @override
  String get education => 'Éducation';

  @override
  String get chat => 'Discuter';

  @override
  String get no_profiles_location_hint =>
      'Aucun profil n\'a encore partagé sa position';

  @override
  String get notifications => 'Notifications';

  @override
  String notifications_unread(int count) {
    return '$count non lues';
  }

  @override
  String get mark_all_read => 'Tout marquer comme lu';

  @override
  String get all_notifications_marked_as_read =>
      'Toutes les notifications sont marquées comme lues';

  @override
  String get no_notifications_title => 'Pas encore de notifications';

  @override
  String get no_notifications_subtitle => 'Vous êtes à jour !';

  @override
  String get notification_detail => 'Détail de la notification';

  @override
  String get job_not_found_error => 'Offre d\'emploi introuvable ou supprimée.';

  @override
  String get see_skill_requests => 'Voir les demandes de compétences';

  @override
  String get view_my_applications => 'Voir mes candidatures';

  @override
  String get view_job => 'Voir l\'offre';

  @override
  String get type_login => 'Connexion';

  @override
  String get type_logout => 'Déconnexion';

  @override
  String get type_payment => 'Paiement';

  @override
  String get type_job_post => 'Offre d\'emploi';

  @override
  String get type_application => 'Candidature';

  @override
  String get type_skill_verified => 'Compétence vérifiée';

  @override
  String get type_message => 'Message';

  @override
  String get type_general => 'Général';

  @override
  String get post_job_appbar_title => 'Publier une offre';

  @override
  String get test_mode_badge => 'MODE TEST';

  @override
  String get submitting_listing_request_banner =>
      'Envoi de votre demande d\'inscription… Veuillez patienter.';

  @override
  String get test_mode_banner_title => 'Mode Test — Pas d\'argent réel débité';

  @override
  String get test_card_details_label =>
      'Détails de la carte de test (EDAHABIA) :';

  @override
  String get test_card_number_label => 'Numéro de carte';

  @override
  String get test_card_expiry_label => 'Expiration';

  @override
  String get test_card_future_date_label => 'Toute date future';

  @override
  String get test_card_otp_label => 'OTP';

  @override
  String get active_plan_label => 'Plan actif';

  @override
  String get no_active_plan_label => 'Aucun plan actif';

  @override
  String annual_job_listing_title(int year) {
    return 'Annonce annuelle de pharmacie — Pharmacie $year';
  }

  @override
  String get list_vacancy_hint_subtitle =>
      'Publiez une offre pour atteindre des pharmaciens vérifiés';

  @override
  String get payment_expires_label => 'Expire le';

  @override
  String get payment_days_left_label => 'Jours restants';

  @override
  String payment_days_count(int count) {
    return '$count jours';
  }

  @override
  String get payment_paid_label => 'Payé';

  @override
  String get payment_method_label => 'Méthode';

  @override
  String get payment_method_edahabia => 'EDAHABIA';

  @override
  String get payment_method_cib => 'CIB';

  @override
  String get payment_method_unknown => '—';

  @override
  String listing_expires_warning_banner(int days) {
    return 'Votre annonce expire dans $days jours. Republiez pour rester visible.';
  }

  @override
  String get list_pharmacy_vacancy_btn => 'Publiez votre offre de pharmacie';

  @override
  String get list_another_vacancy_btn => 'Publiez une autre offre';

  @override
  String get job_posting_history_title => 'Historique des annonces';

  @override
  String get payment_test_success_toast =>
      'Paiement test réussi. Annonce activée.';

  @override
  String get payment_success_toast =>
      'Annonce activée. Votre offre est désormais visible par les pharmaciens.';

  @override
  String get submit_listing_request_error =>
      'Impossible d\'envoyer votre demande. Veuillez réessayer.';

  @override
  String get payment_connection_error =>
      'Erreur de connexion. Vérifiez votre réseau et réessayez.';

  @override
  String listing_request_failed_error(String message) {
    return 'Échec de la demande d\'inscription : $message';
  }

  @override
  String get listing_service_unreachable_error =>
      'Impossible de joindre le service d\'inscription. Réessayez.';

  @override
  String get payment_generic_error =>
      'Quelque chose s\'est mal passé. Veuillez réessayer.';

  @override
  String get payment_incomplete_error =>
      'Le paiement n\'a pas été effectué. Veuillez réessayer.';

  @override
  String get report_issue_title => 'Signaler un problème';

  @override
  String get edit_issue_title => 'Modifier le problème';

  @override
  String get issue_details_label => 'Détails du problème';

  @override
  String get issue_title_label => 'Titre';

  @override
  String get issue_title_hint => 'Bref résumé du problème';

  @override
  String get issue_category_label => 'Catégorie';

  @override
  String get issue_priority_label => 'Priorité';

  @override
  String get issue_description_label => 'Description';

  @override
  String get issue_description_hint => 'Expliquez le problème en détail';

  @override
  String get admin_comment_label => 'Commentaire de l\'administrateur';

  @override
  String get submit_issue_btn => 'Envoyer le problème';

  @override
  String get update_issue_btn => 'Mettre à jour le problème';

  @override
  String get enter_issue_title_error => 'Veuillez saisir le titre du problème';

  @override
  String get select_category_error => 'Veuillez sélectionner une catégorie';

  @override
  String get describe_issue_error => 'Veuillez décrire le problème';

  @override
  String get reported_issues_admin_title => 'Problèmes signalés';

  @override
  String get my_reported_issues_title => 'Mes problèmes signalés';

  @override
  String get failed_load_issues_error => 'Échec du chargement des problèmes';

  @override
  String get no_issues_reported_title =>
      'Aucun problème signalé pour le moment';

  @override
  String get report_problem_hint =>
      'Si vous rencontrez un problème, signalez-le ici.';

  @override
  String get cat_crash => 'Crash';

  @override
  String get cat_ui_issue => 'Problème d\'interface';

  @override
  String get cat_performance => 'Performance';

  @override
  String get cat_payment => 'Paiement';

  @override
  String get cat_login_auth => 'Connexion / Auth';

  @override
  String get cat_other => 'Autre';

  @override
  String get priority_low => 'Basse';

  @override
  String get priority_medium => 'Moyenne';

  @override
  String get priority_high => 'Haute';

  @override
  String get priority_critical => 'Critique';

  @override
  String get status_open => 'Ouvert';

  @override
  String get status_in_progress => 'En cours';

  @override
  String get status_resolved => 'Résolu';

  @override
  String get status_rejected => 'Rejeté';

  @override
  String get issue_details_title => 'Détails du problème';

  @override
  String get description_label => 'Description';

  @override
  String get response_label => 'Réponse';

  @override
  String get user_not_found_error => 'Utilisateur non trouvé';

  @override
  String get reply_btn => 'Répondre';

  @override
  String get anonymous_job_seeker => 'Chercheur d\'emploi anonyme';

  @override
  String get active_recruiter => 'Recruteur actif';

  @override
  String get inactive_recruiter => 'Recruteur inactif';

  @override
  String get joined_label => 'Membre depuis';

  @override
  String get notif_job_posted_title => 'Offre publiée';

  @override
  String notif_job_posted_desc(String jobTitle) {
    return 'Vous avez publié une nouvelle offre: $jobTitle';
  }

  @override
  String get notif_job_apply_title => 'Nouvelle candidature';

  @override
  String notif_job_apply_desc(String jobTitle) {
    return 'Vous avez une nouvelle candidature pour $jobTitle';
  }

  @override
  String get notif_skill_verified_title => 'Compétence vérifiée';

  @override
  String notif_skill_verified_desc(String skillName) {
    return 'Votre compétence $skillName a été vérifiée';
  }

  @override
  String get notif_payment_success_title => 'Paiement réussi';

  @override
  String notif_payment_success_desc(String planName) {
    return 'Votre paiement pour $planName a été effectué avec succès';
  }

  @override
  String get notif_login_title => 'Alerte de connexion';

  @override
  String notif_login_desc(String time) {
    return 'Vous vous êtes connecté à $time';
  }

  @override
  String get notif_logout_title => 'Déconnexion';

  @override
  String get notif_logout_desc => 'Vous avez été déconnecté';

  @override
  String get notif_issue_reported_title => 'Problème signalé';

  @override
  String notif_issue_reported_desc(String title) {
    return 'Votre problème \'$title\' a été signalé avec succès.';
  }

  @override
  String get notif_issue_resolved_title => 'Problème résolu';

  @override
  String notif_issue_resolved_desc(String title) {
    return 'Votre problème \'$title\' a été marqué comme résolu.';
  }

  @override
  String get notif_admin_new_issue_title => 'Nouveau problème signalé';

  @override
  String notif_admin_new_issue_desc(String title) {
    return 'Un nouveau problème \'$title\' a été signalé par un utilisateur.';
  }

  @override
  String get notif_admin_issue_resolved_title => 'Problème résolu';

  @override
  String notif_admin_issue_resolved_desc(String title) {
    return 'Le problème \'$title\' a été résolu.';
  }

  @override
  String get apply_btn => 'Postuler';

  @override
  String get applied_btn => 'Déjà postulé';

  @override
  String get hire_query_btn => 'Embaucher ?';

  @override
  String get hire_btn => 'Embaucher';

  @override
  String get hired_btn => 'Embauché';

  @override
  String get reject_btn => 'REJETÉ';

  @override
  String get job_applicants_title => 'Candidats à l\'offre';

  @override
  String get recruiter_info_title => 'Informations sur le recruteur';

  @override
  String get required_skills_title => 'Compétences requises';

  @override
  String get no_applicants_yet_label => 'Aucun candidat pour le moment';

  @override
  String get hire_candidate_title => 'Embaucher le candidat';

  @override
  String get hire_confirm_msg =>
      'Une fois embauché, cette action ne peut pas être annulée.';

  @override
  String get reject_applicant_title => 'Rejeter le candidat';

  @override
  String get reject_confirm_msg =>
      'Êtes-vous sûr de vouloir rejeter ce candidat ?\n\nUne fois rejeté, vous ne pourrez plus contacter ce candidat pour cette offre.';

  @override
  String get skill_rejected_label => 'Rejeté';

  @override
  String get applicants_tab => 'Candidats';

  @override
  String get stats_tab => 'Stats';

  @override
  String get please_apply_first_chat =>
      'Veuillez d\'abord postuler avant de discuter.';

  @override
  String get show_route_btn => 'Afficher l\'itinéraire';

  @override
  String get hide_route_btn => 'Masquer l\'itinéraire';

  @override
  String get open_in_maps_btn => 'Ouvrir dans Maps';

  @override
  String get getting_route_loading => 'Calcul de l\'itinéraire…';

  @override
  String get your_location_label => 'Votre position';

  @override
  String get chat_btn => 'Discussion';

  @override
  String get accept_btn => 'Accepter';

  @override
  String get job_open_label => 'Ouvert';

  @override
  String get job_closed_label => 'Fermé';

  @override
  String job_views_stats_title(Object count) {
    return 'Vues de l\'offre ($count au total)';
  }

  @override
  String job_applications_stats_title(Object count) {
    return 'Candidatures ($count au total)';
  }

  @override
  String get mon_short => 'Lun';

  @override
  String get tue_short => 'Mar';

  @override
  String get wed_short => 'Mer';

  @override
  String get thu_short => 'Jeu';

  @override
  String get fri_short => 'Ven';

  @override
  String get sat_short => 'Sam';

  @override
  String get sun_short => 'Dim';

  @override
  String unread_messages_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages non lus',
      one: '1 message non lu',
      zero: 'Aucun message non lu',
    );
    return '$_temp0';
  }

  @override
  String get staff_pharmacist_hiring => 'Recrutement de pharmacien';

  @override
  String get staff_pharmacist_vacancy => 'Poste de pharmacien vacant';

  @override
  String get staff_pharmacist_opportunity => 'Opportunité pour pharmacien';

  @override
  String get find_pharmacy_job_title => 'Emplois pharmacie';

  @override
  String get featured_jobs_title => 'Emplois vedettes';

  @override
  String get interested_in_pharmacy_msg =>
      'Parce que vous vous intéressez à la pharmacie';

  @override
  String get failed_to_load_jobs => 'Échec du chargement des emplois';

  @override
  String get no_jobs_available => 'Aucune offre';

  @override
  String get filter_jobs_title => 'Filtres';

  @override
  String get search_job_titles_hint => 'Rechercher des titres d\'emploi';

  @override
  String get search_skills_hint => 'Rechercher des compétences';

  @override
  String get apply_filters_btn => 'Appliquer';

  @override
  String get candidate_label => 'Candidat';

  @override
  String get enter_job_keyword_hint => 'Entrez le titre du poste ou mot-clé';

  @override
  String get job_seeker_label => 'Chercheur d\'emploi';

  @override
  String get apply_now_btn => 'Postuler maintenant';

  @override
  String featured_job_salary(String amount) {
    return '$amount / an';
  }

  @override
  String get all_cities => 'Tout';

  @override
  String get city_algiers => 'Alger';

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
  String get city_bejaia => 'Béjaïa';

  @override
  String get city_setif => 'Sétif';

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
  String get city_ghardaia => 'Ghardaïa';

  @override
  String get nav_home => 'Accueil';

  @override
  String get nav_jobs => 'Emplois';

  @override
  String get nav_messages => 'Messages';

  @override
  String get nav_profiles => 'Profils';

  @override
  String get nav_applications => 'Candidatures';

  @override
  String get nav_insights => 'Analyses';

  @override
  String get nav_recruiters => 'Recruteurs';

  @override
  String get nav_jobseekers => 'Candidats';

  @override
  String get del_account_title => 'Supprimer le compte';

  @override
  String get del_account_warning => 'Attention';

  @override
  String get del_account_body =>
      'La suppression supprimera définitivement :\n• Votre profil\n• Vos données de connexion\n• Tous vos enregistrements\n\nCette action est irréversible.';

  @override
  String get del_account_btn => 'Supprimer mon compte';

  @override
  String get del_account_dialog_title => 'Supprimer le compte';

  @override
  String get del_account_dialog_msg =>
      'Ceci supprimera définitivement votre compte et toutes vos données. Cette action est irréversible.';

  @override
  String get del_account_not_auth => 'Non connecté. Veuillez vous reconnecter.';

  @override
  String get del_account_error => 'Reconnectez-vous et réessayez.';

  @override
  String get profile_strength => 'Force du profil';

  @override
  String get job_applications_nav => 'Candidatures';

  @override
  String get matches => 'Matchs';

  @override
  String get job_matches => 'Matchs d\'emplois';

  @override
  String get based_on_your_profile => 'Selon votre profil';

  @override
  String get skills_verified_count => 'Skills vérifiés';

  @override
  String get improve_visibility => 'Améliorer visibilité';

  @override
  String get profile_views_count => 'Vues du profil';

  @override
  String get recruiters_viewed_you => 'Vues recruteurs';

  @override
  String get profile_visibility => 'Visibilité profil';

  @override
  String get visibility_high => 'Haute';

  @override
  String get visibility_anonymous => 'Anonyme';

  @override
  String get privacy_mode => 'Mode privé';

  @override
  String get skill_verification_title => 'Vérification skills';

  @override
  String get verify_your_skills => 'Vérifier skills';

  @override
  String get verify_skills_desc => 'Confirmer via pharmacie';

  @override
  String get status_verified_label => 'Vérifié';

  @override
  String get status_pending_label => 'En attente';

  @override
  String get status_rejected_label => 'Rejeté';

  @override
  String get my_profile => 'Mon Profil';

  @override
  String get profile_views_drawer => 'Vues du profil';

  @override
  String get profile_views_desc => 'Recruteurs qui vous ont vu';

  @override
  String get personal_pro_info => 'Infos personnelles et pro';

  @override
  String get find_your_next_role => 'Trouvez votre prochain rôle';

  @override
  String pharmacies_on_map(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pharmacies sur la carte',
      one: '1 pharmacie sur la carte',
    );
    return '$_temp0';
  }

  @override
  String get tap_pin_or_scroll_below =>
      'Appuyez sur une épingle ou faites défiler';

  @override
  String get pharmacy_profile => 'Profil de la pharmacie';

  @override
  String available_jobs_count(Object count) {
    return 'Emplois disponibles ($count)';
  }

  @override
  String get no_active_jobs_available => 'Aucun emploi actif pour le moment.';

  @override
  String get no_jobs_location_hint => 'Aucun emploi disponible à cet endroit';

  @override
  String get filter_btn => 'Filtrer';

  @override
  String get clear_btn => 'Effacer';

  @override
  String get my_applications_title => 'Mes Candidatures';

  @override
  String get failed_to_load_applications =>
      'Échec du chargement des candidatures';

  @override
  String get status_accepted => 'Acceptée';

  @override
  String get status_viewed => 'Vue';

  @override
  String get status_applied => 'Postulée';

  @override
  String get chat_with_recruiter => 'Discuter avec le recruteur';

  @override
  String get open_chat_failed =>
      'Échec de l\'ouverture du chat. Veuillez réessayer.';

  @override
  String get no_applications_title => 'Aucune candidature';

  @override
  String get no_applications_subtitle =>
      'Postulez à des offres et suivez-les ici';

  @override
  String get time_just_now => 'À l\'instant';

  @override
  String time_min_ago(int count) {
    return 'il y a ${count}m';
  }

  @override
  String time_hours_ago(int count) {
    return 'il y a ${count}h';
  }

  @override
  String time_days_ago(int count) {
    return 'il y a ${count}j';
  }

  @override
  String time_weeks_ago(int count) {
    return 'il y a ${count}sem';
  }

  @override
  String time_months_ago(int count) {
    return 'il y a ${count}mois';
  }

  @override
  String time_years_ago(int count) {
    return 'il y a ${count}a';
  }

  @override
  String salary_per_year(String salary) {
    return '$salary / An';
  }

  @override
  String get profile_analytics_title => 'Analyses du Profil';

  @override
  String get views_trend_title => 'Tendance des Vues';

  @override
  String get last_7_days_subtitle => '7 derniers jours';

  @override
  String get total_profile_views => 'Vues Totales du Profil';

  @override
  String this_week_views(int count) {
    return '+$count cette semaine';
  }

  @override
  String get recruiters_label => 'Recruteurs';

  @override
  String get todays_views_label => 'Vues d\'Aujourd\'hui';

  @override
  String get daily_breakdown_title => 'Détail Quotidien';

  @override
  String get today_label => 'Aujourd\'hui';

  @override
  String views_count_tooltip(int count) {
    return '$count vues';
  }

  @override
  String get no_trend_data => 'Aucune donnée de tendance';

  @override
  String get no_profile_views_title => 'Aucune vue du profil';

  @override
  String get no_profile_views_subtitle =>
      'Quand les recruteurs consulteront votre profil,\nles analyses apparaîtront ici.';

  @override
  String get day_mon => 'Lun';

  @override
  String get day_tue => 'Mar';

  @override
  String get day_wed => 'Mer';

  @override
  String get day_thu => 'Jeu';

  @override
  String get day_fri => 'Ven';

  @override
  String get day_sat => 'Sam';

  @override
  String get day_sun => 'Dim';

  @override
  String get select_pharmacy_title => 'Sélectionner une Pharmacie';

  @override
  String get search_pharmacy_hint => 'Rechercher une pharmacie';

  @override
  String get no_pharmacies_found => 'Aucune pharmacie trouvée';

  @override
  String get skill_verification_requests_title => 'Demandes de Vérification';

  @override
  String get verification_request_sent_success =>
      'Demande de vérification envoyée avec succès !';

  @override
  String failed_to_send_request(String error) {
    return 'Échec de l\'envoi de la demande : $error';
  }

  @override
  String get add_note_dialog_title => 'Ajouter une Note (Optionnel)';

  @override
  String get add_note_dialog_hint =>
      'Ajouter toute information supplémentaire pour le recruteur...';

  @override
  String get dialog_cancel_btn => 'Annuler';

  @override
  String get send_request_btn => 'Envoyer la Demande';

  @override
  String get status_not_requested => 'Non Demandé';

  @override
  String get status_pending => 'En Attente';

  @override
  String get status_completed => 'Terminé';

  @override
  String get request_skill_verification_purpose =>
      'Demandez une vérification de compétences à ce recruteur pour renforcer la crédibilité de votre profil.';

  @override
  String get send_skill_verification_request_btn =>
      'Envoyer la Demande de Vérification';

  @override
  String get verification_request_pending_desc =>
      'Demande de vérification en attente. Le recruteur examinera vos compétences bientôt.';

  @override
  String get verification_completed_desc =>
      'Vérification terminée ! Ce recruteur a examiné vos compétences.';

  @override
  String get chat_with_recruiter_btn => 'Discuter avec le Recruteur';

  @override
  String failed_to_open_chat(String error) {
    return 'Impossible d\'ouvrir le chat : $error';
  }

  @override
  String get no_applications_yet_title => 'Aucune Candidature';

  @override
  String get apply_to_jobs_for_verification_desc =>
      'Postulez à des offres pour demander une vérification de compétences';

  @override
  String get create_profile_title => 'Créer le Profil';

  @override
  String get my_profile_title => 'Mon Profil';

  @override
  String get personal_information_title => 'Informations Personnelles';

  @override
  String get first_name_label => 'Prénom';

  @override
  String get last_name_label => 'Nom';

  @override
  String get show_my_name_label => 'Afficher mon nom aux recruteurs';

  @override
  String get location_information_title => 'Informations de Localisation';

  @override
  String get my_location_title => 'Ma Position';

  @override
  String get change_location_btn => 'Changer';

  @override
  String get set_location_btn => 'Définir';

  @override
  String get current_job_title_title => 'Titre du poste actuel';

  @override
  String get select_job_title_hint => 'Sélectionnez votre titre actuel';

  @override
  String get skills_title => 'Compétences';

  @override
  String get add_skill_btn => 'Ajouter Compétence';

  @override
  String get background_title => 'Parcours';

  @override
  String get job_experience_hint => 'Sélectionnez votre niveau d\'expérience';

  @override
  String get save_changes_btn => 'Enregistrer les modifications';

  @override
  String get select_skills_title => 'Sélectionnez des Compétences';

  @override
  String get no_experience_available => 'Aucun niveau d\'expérience disponible';

  @override
  String get no_options_available => 'Aucune option disponible';

  @override
  String get select_province_hint => 'Sélectionner la Province';

  @override
  String get loading_hint => 'Chargement...';

  @override
  String get select_city_hint => 'Sélectionner la Ville';

  @override
  String get fill_required_fields_error =>
      'Veuillez remplir tous les champs obligatoires';

  @override
  String get phone_required_error => 'Le numéro de téléphone est requis';

  @override
  String get phone_nine_digits_error => 'Le numéro doit comporter 9 chiffres';

  @override
  String get phone_invalid_start_error =>
      'Doit commencer par 5, 6, ou 7 (Algérie)';

  @override
  String get status_verified => 'Vérifié';

  @override
  String get crop_photo_title => 'Recadrer la photo';

  @override
  String get camera_btn => 'Caméra';

  @override
  String get gallery_btn => 'Galerie';

  @override
  String get remove_photo_btn => 'Supprimer la photo';

  @override
  String get general_save_btn => 'Enregistrer';

  @override
  String get general_change_btn => 'Changer';

  @override
  String get recrop_btn => 'Recadrer';

  @override
  String get add_profile_photo_label => 'Ajouter une photo de profil';

  @override
  String get admin_active_jobs_title => 'Emplois';

  @override
  String get admin_active_jobs_sub => 'Actifs';

  @override
  String get admin_skill_req_title => 'Compétences';

  @override
  String get admin_skill_req_sub => 'En attente';

  @override
  String get admin_recruiters_title => 'Recruteurs';

  @override
  String get admin_recruiters_sub => 'Inscrits';

  @override
  String get admin_seekers_title => 'Candidats';

  @override
  String get admin_seekers_sub => 'Actifs';

  @override
  String get admin_platform_activity => 'Activité';

  @override
  String get admin_platform_activity_desc => 'Aperçu Global';

  @override
  String get admin_open_jobs => 'Ouverts';

  @override
  String get admin_closed_jobs => 'Fermés';

  @override
  String get admin_user_activity => 'Utilisateurs';

  @override
  String get admin_user_activity_desc => 'Candidats vs Recruteurs';

  @override
  String get admin_reported_issues => 'Signalements';

  @override
  String get admin_total_earnings => 'Revenus';

  @override
  String get admin_job_status_overview =>
      'Aperçu du statut des offres d\'emploi';

  @override
  String admin_jobs_open_count(int active, int total) {
    return 'Vous avez actuellement $active sur $total emplois ouverts';
  }

  @override
  String get admin_manage_account => 'Gérer le compte';

  @override
  String get admin_active_label => 'Actif';

  @override
  String get admin_drawer_payments_title => 'Paiements des recruteurs';

  @override
  String get admin_drawer_payments_sub => 'Voir les paiements des recruteurs';

  @override
  String get admin_drawer_job_options_title => 'Ajouter Titre/Compétence';

  @override
  String get admin_drawer_job_options_sub =>
      'Ajouter de nouveaux titres ou compétences au système';

  @override
  String get admin_drawer_job_types_title => 'Gérer les types d\'emploi';

  @override
  String get admin_drawer_job_types_sub =>
      'Gérer les types d\'emploi disponibles';

  @override
  String get admin_drawer_exp_levels_title => 'Gérer les niveaux d\'expérience';

  @override
  String get admin_drawer_exp_levels_sub =>
      'Gérer les niveaux d\'expérience disponibles';

  @override
  String get admin_drawer_locations_title => 'Gérer les lieux';

  @override
  String get admin_drawer_locations_sub => 'Gérer les lieux disponibles';

  @override
  String get admin_drawer_payment_config_title =>
      'Gérer la configuration de paiement';

  @override
  String get admin_drawer_payment_config_sub =>
      'Gérer les paramètres de paiement';

  @override
  String get admin_drawer_appeals_title => 'Appels en attente';

  @override
  String get admin_drawer_appeals_sub => 'Examiner les appels en attente';

  @override
  String get admin_add_user_title => 'Ajouter un utilisateur';

  @override
  String get admin_appeals_title => 'Appels en attente';

  @override
  String get admin_job_list_title => 'Offres d\'emploi';

  @override
  String get admin_payments_title => 'Gestion des paiements';

  @override
  String get admin_promotion_title => 'Promotion des recruteurs';

  @override
  String get admin_verification_title => 'Vérification des recruteurs';

  @override
  String get blocked_account_title => 'Compte bloqué';

  @override
  String get create_user_btn => 'Créer l\'utilisateur';

  @override
  String get update_user_btn => 'Mettre à jour';

  @override
  String get no_pending_appeals_msg => 'Aucun appel';

  @override
  String get review_btn => 'Examiner';

  @override
  String get appeal_review_title => 'Révision d\'appel';

  @override
  String get user_email_label => 'E-mail de l\'utilisateur';

  @override
  String get block_reason_label => 'Raison du blocage';

  @override
  String get appeal_msg_label => 'Message d\'appel';

  @override
  String get admin_msg_required_label => 'Message admin (requis)';

  @override
  String get approve_btn => 'APPROUVER';

  @override
  String get reject_btn_caps => 'REJETER';

  @override
  String get appeal_approved_notif_title => 'Appel approuvé';

  @override
  String get appeal_rejected_notif_title => 'Appel rejeté';

  @override
  String get appeal_under_review_msg => 'Votre appel est en cours d\'examen';

  @override
  String get appeal_approved_msg => 'Votre appel a été approuvé';

  @override
  String get appeal_rejected_msg => 'Votre appel a été rejeté';

  @override
  String get no_reason_provided => 'Aucune raison fournie';

  @override
  String get explain_unblock_hint =>
      'Expliquez pourquoi votre compte doit être débloqué';

  @override
  String get submit_appeal_btn => 'Soumettre l\'appel';

  @override
  String get blocked_acc_msg => 'Votre compte a été bloqué';

  @override
  String get recruiter_verification_card => 'Vérification recruteur';

  @override
  String get make_featured_card => 'Promouvoir des recruteurs';

  @override
  String pending_count_label(int count) {
    return '$count en attente';
  }

  @override
  String transactions_count_label(int count) {
    return '$count Tx';
  }

  @override
  String get recruiter_promotion_panel => 'Panneau de promotion';

  @override
  String get search_recruiters_label => 'Rechercher recruteurs';

  @override
  String eligible_recruiters_count(int count) {
    return 'Éligibles ($count)';
  }

  @override
  String get no_recruiters_match_search => 'Aucun recruteur ne correspond.';

  @override
  String get pharmacy_search_hint => 'Pharmacie, nom ou ville';

  @override
  String get recent_payments_title => 'Paiements récents';

  @override
  String get no_payments_found => 'Aucun paiement';

  @override
  String get recruiter_verification_panel => 'Panneau de vérification';

  @override
  String get search_pending_recruiters => 'Rechercher en attente';

  @override
  String pending_verification_count(int count) {
    return '$count à vérifier';
  }

  @override
  String get no_recruiters_for_verification => 'Aucun recruteur à vérifier.';

  @override
  String get search_jobs_hint => 'Rechercher des offres…';

  @override
  String get all_filter_label => 'Tous';

  @override
  String get open_filter_label => 'Ouverts';

  @override
  String get closed_filter_label => 'Fermés';

  @override
  String get total_revenue_label => 'Revenu total';

  @override
  String get total_transactions_label => 'Total transactions';

  @override
  String get pending_payments_label => 'En attente';

  @override
  String get paid_payments_label => 'Payé';

  @override
  String get amount_label => 'Montant';

  @override
  String get plan_label => 'Plan';

  @override
  String get status_label => 'Statut';

  @override
  String get account_blocked_title => 'Compte bloqué';

  @override
  String get admin_header_title => 'Panneau admin';

  @override
  String get pending_verification_label => 'Vérification en attente';

  @override
  String get personal_info_section => 'Infos personnelles';

  @override
  String get company_info_section => 'Infos entreprise';

  @override
  String registered_as_label(String role) {
    return 'Inscrit en tant que $role';
  }

  @override
  String get verification_requests_card => 'Vérification';

  @override
  String get featured_recruiters_card => 'En vedette';

  @override
  String get payments_card => 'Paiements';

  @override
  String pending_label(int count) {
    return '$count en attente';
  }

  @override
  String get open_jobs_tab => 'Ouvert';

  @override
  String get closed_jobs_tab => 'Fermé';

  @override
  String get failed_load_jobs => 'Échec chargement';

  @override
  String get view_details_btn => 'Détails';

  @override
  String get clear_all_btn => 'Effacer';

  @override
  String get search_province_hint => 'Province...';

  @override
  String get search_recruiters_hint => 'Rechercher...';

  @override
  String get verified_status => 'Vérifié';

  @override
  String get unverified_status => 'Non vérifié';

  @override
  String get view_profile_btn => 'Profil';

  @override
  String get paid_subscriptions_title => 'Abonnements';

  @override
  String get no_paid_subs => 'Aucun abonnement';

  @override
  String get active_label => 'Actif';

  @override
  String get revenue_label => 'Revenu';

  @override
  String get expired_label => 'Expiré';

  @override
  String until_label(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String get recruiter_label => 'Recruteur';

  @override
  String get street_label => 'Rue';

  @override
  String get license_label => 'Licence';

  @override
  String get inactive_label => 'Inactif';

  @override
  String get lic_expires_label => 'Expire';

  @override
  String get paid_on_label => 'Payé le';

  @override
  String get method_label => 'Méthode';

  @override
  String get year_label => 'Année';

  @override
  String get checkout_id_label => 'ID TX';

  @override
  String get admin_msg_label => 'Msg Admin';

  @override
  String get no_recruiters_match => 'Aucun recruteur';

  @override
  String get skills_label => 'Compétences';

  @override
  String get premium_label => 'Premium';

  @override
  String get no_to_verify => 'Rien à vérifier';

  @override
  String get admin_role_desc => 'Accès complet à la plateforme';

  @override
  String get admin_dashboard_subtitle => 'Tableau de bord admin';

  @override
  String get admin_label => 'Admin';

  @override
  String get all_jobs_label => 'Tous les jobs';

  @override
  String get open_closed_jobs_subtitle => 'Jobs ouverts et fermés';

  @override
  String get search_job_hint => 'Entrez le titre du poste ou un mot-clé';

  @override
  String get street_address_label => 'Adresse';

  @override
  String get province_label => 'Province';

  @override
  String get location_label => 'Emplacement';

  @override
  String get any_label => 'N\'importe quel';

  @override
  String get job_title_label => 'Titre du poste';

  @override
  String get only_admin_create_user_toast =>
      'Seuls les administrateurs peuvent créer des utilisateurs.';

  @override
  String get email_required_error => 'L\'e-mail est requis.';

  @override
  String get invalid_email_error =>
      'Veuillez entrer une adresse e-mail valide.';

  @override
  String get password_required_error => 'Le mot de passe est requis.';

  @override
  String get invalid_password_format_error =>
      'Le mot de passe doit comporter au moins 6 caractères et inclure 1 majuscule, 1 minuscule et 1 chiffre.';

  @override
  String get confirm_password_required_error =>
      'Veuillez confirmer le mot de passe.';

  @override
  String get passwords_do_not_match_error =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get admin_created_user_name => 'Utilisateur créé par l\'admin';

  @override
  String user_created_success_msg(String role) {
    return 'Utilisateur créé avec succès en tant que $role.';
  }

  @override
  String get access_denied_admin => 'Accès refusé. Administrateur uniquement.';

  @override
  String get add_new_user_title => 'Ajouter un nouvel utilisateur';

  @override
  String get create_user_account_header => 'Créer un compte utilisateur';

  @override
  String get create_user_account_desc =>
      'Remplissez les détails et attribuez un rôle.\nUn e-mail de vérification sera envoyé automatiquement.';

  @override
  String get assign_role_label => 'Attribuer un rôle';

  @override
  String get admin_role_label => 'Admin';

  @override
  String get recruiters_list => 'المسمى الوظيفي';

  @override
  String get recruiters => 'Recruteurs';

  @override
  String get searchHint => 'Rechercher par pharmacie, nom ou ville';

  @override
  String get noRecruitersFound => 'Aucun recruteur trouvé';

  @override
  String get loadingRecruiters => 'Chargement des recruteurs…';

  @override
  String recruitersLoaded(Object count) {
    return '$count recruteurs chargés';
  }

  @override
  String get loadMoreRecruiters => 'Charger plus de recruteurs';

  @override
  String allRecruitersLoaded(Object count) {
    return 'Tous les $count recruteurs sont chargés';
  }

  @override
  String get verified => 'Vérifié';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get recruiterVerificationPanel => 'Panneau de vérification';

  @override
  String get searchPendingRecruiters => 'Rechercher recruteurs';

  @override
  String get searchHintRecruiters => 'Pharmacie, nom ou ville';

  @override
  String get pendingVerification => 'En attente';

  @override
  String get noRecruitersForVerification => 'Aucun recruteur trouvé';

  @override
  String get premium => 'Premium';

  @override
  String get recruiterPromotionPanel => 'Panneau promo';

  @override
  String get searchRecruiters => 'Rechercher recruteurs';

  @override
  String get eligibleRecruiters => 'Recruteurs éligibles';

  @override
  String get noRecruitersMatch => 'Aucun recruteur trouvé';

  @override
  String get recruiterProfile => 'Profil';

  @override
  String get pharmacyInfo => 'Pharmacie';

  @override
  String get pharmacist => 'Pharmacien';

  @override
  String get metaInfo => 'Détails';

  @override
  String get jobStats => 'Stat. emplois';

  @override
  String get pharmacyName => 'Pharmacie';

  @override
  String get province => 'Province';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get userId => 'ID utilisateur';

  @override
  String get createdAt => 'Créé';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get totalJobs => 'Total';

  @override
  String get activeJobs => 'Actifs';

  @override
  String get draftJobs => 'Brouillons';

  @override
  String get verifyRecruiter => 'Vérifier';

  @override
  String get unverifyRecruiter => 'Annuler';

  @override
  String get recruiterApproved => 'Approuvé';

  @override
  String get recruiterDeactivated => 'Désactivé';

  @override
  String get makeRecruiterPro => 'Passer Pro';

  @override
  String get recruiterUpgraded => 'Passé en Pro';

  @override
  String get failedLoadJobs => 'Erreur chargement';

  @override
  String get paidSubscriptions => 'Abonnements';

  @override
  String get noPaidSubscriptions => 'Aucun abonnement';

  @override
  String get total => 'Total';

  @override
  String get revenue => 'Revenu';

  @override
  String get unknownPharmacy => 'Inconnu';

  @override
  String get expired => 'Expiré';

  @override
  String get until => 'Jusqu’à';

  @override
  String get recruiter => 'Recruteur';

  @override
  String get payment => 'Paiement';

  @override
  String get name => 'Nom';

  @override
  String get street => 'Adresse';

  @override
  String get license => 'Licence';

  @override
  String get licenseExpires => 'Expire';

  @override
  String get paidOn => 'Payé';

  @override
  String get expires => 'Expire';

  @override
  String get method => 'Méthode';

  @override
  String get year => 'Année';

  @override
  String get checkoutId => 'ID paiement';

  @override
  String get inactive => 'Inactif';

  @override
  String get loadFailed => 'Erreur chargement';

  @override
  String get manageOptions => 'Gérer les options';

  @override
  String get jobTitles => 'Postes';

  @override
  String get noOptions => 'Aucune option pour le moment';

  @override
  String get hidden => 'Masqué';

  @override
  String get deleteOption => 'Supprimer l\'option';

  @override
  String deleteOptionConfirm(Object name) {
    return 'Supprimer \"$name\" définitivement ?';
  }

  @override
  String get fillAllLanguages => 'Remplissez les trois langues';

  @override
  String get editJobTitle => 'Modifier le poste';

  @override
  String get addJobTitle => 'Ajouter un poste';

  @override
  String get editSkill => 'Modifier la compétence';

  @override
  String get addSkill => 'Ajouter une compétence';

  @override
  String get englishRequired => 'Le nom anglais est requis';

  @override
  String get frenchRequired => 'Le nom français est requis';

  @override
  String get arabicRequired => 'Le nom arabe est requis';

  @override
  String get labelInEnglish => 'Libellé en anglais';

  @override
  String get labelInFrench => 'Libellé en français';

  @override
  String get labelInArabic => 'Libellé en arabe';

  @override
  String get update => 'Mettre à jour';

  @override
  String get add => 'Ajouter';

  @override
  String get jobTypesTitle => 'Types de poste';

  @override
  String typesCount(Object count) {
    return '$count types';
  }

  @override
  String get noJobTypes => 'Aucun type de poste';

  @override
  String get addNewHint => 'Appuyez sur + pour en ajouter';

  @override
  String get deleteJobTypeTitle => 'Supprimer le type de poste';

  @override
  String deleteJobTypeConfirm(Object name) {
    return 'Supprimer \"$name\" définitivement ?';
  }

  @override
  String get addJobType => 'Ajouter un type de poste';

  @override
  String get editJobType => 'Modifier le type de poste';

  @override
  String get fillLanguages => 'Remplissez les trois langues';

  @override
  String nameInLanguage(String language) {
    return 'Nom en $language...';
  }

  @override
  String get experienceLevelsTitle => 'Niveaux d\'expérience';

  @override
  String levelsCount(Object count) {
    return '$count niveaux';
  }

  @override
  String get noExperienceLevels => 'Aucun niveau d\'expérience';

  @override
  String get deleteExperienceLevelTitle => 'Supprimer le niveau d\'expérience';

  @override
  String deleteExperienceLevelConfirm(Object name) {
    return 'Supprimer \"$name\" définitivement ?';
  }

  @override
  String get addExperienceLevel => 'Ajouter un niveau d\'expérience';

  @override
  String get editExperienceLevel => 'Modifier le niveau d\'expérience';

  @override
  String labelInLanguage(Object lang) {
    return 'Libellé en $lang...';
  }

  @override
  String get titleProvincesCities => 'Provinces et Villes';

  @override
  String provincesCount(int count) {
    return '$count provinces';
  }

  @override
  String citiesCount(int count) {
    return '$count villes';
  }

  @override
  String get noProvinces => 'Aucune province pour le moment';

  @override
  String get noCities => 'Aucune ville pour le moment';

  @override
  String get addProvinceHint => 'Appuyez sur + pour ajouter une province';

  @override
  String addCityHint(String province) {
    return 'Appuyez sur + pour ajouter une ville à $province';
  }

  @override
  String get cities => 'Villes';

  @override
  String get deleteProvinceTitle => 'Supprimer la province';

  @override
  String deleteProvinceMessage(String name) {
    return 'Supprimer \"$name\" et TOUTES ses villes définitivement ?';
  }

  @override
  String get deleteCityTitle => 'Supprimer la ville';

  @override
  String deleteCityMessage(String name) {
    return 'Supprimer \"$name\" définitivement ?';
  }

  @override
  String get edit => 'Modifier';

  @override
  String get addProvince => 'Ajouter une province';

  @override
  String get editProvince => 'Modifier la province';

  @override
  String get addCity => 'Ajouter une ville';

  @override
  String get editCity => 'Modifier la ville';

  @override
  String get paymentConfigTitle => 'Configuration de paiement';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveConfiguration => 'Enregistrer la configuration';

  @override
  String get environment => 'Environnement';

  @override
  String get environmentSubtitle => 'Basculer entre mode test et production';

  @override
  String get testMode => 'Mode test';

  @override
  String get testModeSubtitle => 'Aucun argent réel facturé';

  @override
  String get production => 'Production';

  @override
  String get productionSubtitle => 'Paiements réels';

  @override
  String get apiCredentials => 'Identifiants API';

  @override
  String get apiCredentialsSubtitle => 'Clé secrète Chargily et URLs';

  @override
  String get testSecretKey => 'Clé secrète (test)';

  @override
  String get cloudFunctionUrl => 'URL Cloud Function';

  @override
  String get webhookUrl => 'URL Webhook';

  @override
  String get redirectUrls => 'URLs de redirection';

  @override
  String get redirectUrlsSubtitle =>
      'Où l’utilisateur est redirigé après paiement';

  @override
  String get successUrl => 'URL de succès';

  @override
  String get failureUrl => 'URL d’échec';

  @override
  String get pricing => 'Tarification';

  @override
  String get pricingSubtitle => 'Frais annuels, devise et langue';

  @override
  String get annualFee => 'Frais annuels';

  @override
  String get currency => 'Devise';

  @override
  String get locale => 'Langue';

  @override
  String get planCopy => 'Contenu du plan';

  @override
  String get planCopySubtitle => 'Texte affiché aux recruteurs';

  @override
  String get planName => 'Nom du plan';

  @override
  String get planSubtitle => 'Sous-titre';

  @override
  String get planDescription => 'Description';

  @override
  String get disclaimer => 'Avertissement';

  @override
  String get planFeatures => 'Fonctionnalités du plan';

  @override
  String get planFeaturesSubtitle =>
      'Points affichés. Glisser pour réorganiser.';

  @override
  String get newFeature => 'Nouvelle fonctionnalité';

  @override
  String get noFeatures => 'Aucune fonctionnalité ajoutée';

  @override
  String get annualFeeError => 'Le montant annuel doit être un nombre valide.';

  @override
  String get saveSuccess => 'Configuration enregistrée avec succès.';

  @override
  String saveError(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get close_issue_btn => 'Clôturer le problème';

  @override
  String get tabs_open => 'Ouverts';

  @override
  String get tabs_closed => 'Fermés';

  @override
  String get loginHere => 'Connexion';

  @override
  String get welcomeMessage =>
      'Accédez à votre compte Ophicina en toute sécurité avec votre méthode préférée';

  @override
  String get monthlyLimitTitle => 'Limite mensuelle atteinte';

  @override
  String monthlyLimitMessage(Object limit) {
    return 'Vous avez utilisé toutes vos $limit offres d\'emploi pour ce mois. Votre limite sera réinitialisée le 1er du mois prochain. Contactez l\'administrateur si vous avez besoin de plus.';
  }

  @override
  String get ok => 'OK';

  @override
  String get notif_account_verified_title => 'Compte vérifié';

  @override
  String get notif_account_verified_desc =>
      'Votre compte recruteur a été vérifié par l\'équipe Ophicina.';

  @override
  String get notif_account_deactivated_title => 'Compte désactivé';

  @override
  String get notif_account_deactivated_desc =>
      'Votre compte recruteur a été désactivé. Veuillez contacter le support pour plus d\'informations.';

  @override
  String get notif_account_pro_title => 'Passage en mode Pro';

  @override
  String get notif_account_pro_desc =>
      'Félicitations ! Votre compte a été mis à jour avec le statut Pro.';

  @override
  String get notif_quota_updated_title => 'Quota de publications mis à jour';

  @override
  String notif_quota_updated_desc(int limit) {
    return 'Votre limite mensuelle de publications a été mise à jour à $limit offres.';
  }

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get emailLabel => 'Email';

  @override
  String get resetPasswordButton => 'Réinitialiser le mot de passe';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get emailRequired => 'L\'email est requis';

  @override
  String get resetLinkSent =>
      'Lien de réinitialisation envoyé. Vérifiez votre boîte de réception et n\'oubliez pas le dossier spam.';

  @override
  String get noAccountFound => 'Aucun compte trouvé avec cet email.';

  @override
  String get errorPrefix => 'Erreur :';
}
