class AppConstant {
  AppConstant._();

  static const String APP_NAME = 'Faris';
  static const String MAP_API_KEY = '';
  static const double APP_VERSION = 1.4;
  static const bool APP_UPDATED = true;

  // Host URLs
  static const String HOST = "https://apps.farisbusinessgroup.com";
  static const String BASE_URL = "$HOST";
  static const String BASE_IMAGE_URL = "$BASE_URL/storage";
  static const String HOST_IMAGE_ARTICLE = "/uploads/articles/";

  // App Settings
  static const String APP_SETTINGS_URI = "/api/v1/settings";
  static const String APP_PLAYSTORE_PACKAGE = "com.powersofttechnology.faris";
  static const String SHORT_LINK_URI = "https://cleanuri.com/api/v1/shorten";

  static const String INIT_MOOV_OTP = "$BASE_URL/api/initMoovOtp";
  static const String CHECK_PAYMENT_MOOV = "/api/v1/checkpaymentmoov";
  // Authentication
  static const String LOGIN_URI = "/api/v1/auth/login";
  static const String REGISTER_URI = "/api/v1/auth/register";
  static const String LOGOUT_URI = "/api/v1/auth/logout";
  static const String FORGET_PASSWORD_URI = "/api/v1/auth/forget-password";
  static const String RESET_PASSWORD_URI = "/api/v1/auth/reset-password";
  static const String VERIFY_EMAIL_URI = "/api/v1/auth/verify-email";
  static const String CHECK_EMAIL_URI = "/api/v1/auth/check-email";
  static const String VERIFY_TOKEN_URI = "/api/v1/auth/verify-token";

  // User
  static const String USER_INFO_URI = "/api/v1/users/info";
  static const String TOKEN_URI = "/api/v1/users/cm-firebase-token";
  static const String UPDATE_PROFILE_URI = "/api/v1/users/update-profile";
  static const String UPDATE_PASSWORD_URI = "/api/v1/users/update-password";
  static const String NOTIFICATION_URI = "/api/v1/notifications";
  static const String SEARCH_USER_URI = "/api/v1/users/search";
  static const String USER_REQUEST_LIST = "/api/v1/users/requetes";

  // FARIS Nana
  static const String SOUSCRIPTION_FARIS_NANA_URI = "$BASE_URL/api/v1/souscription/client/depot";
  static const String SOUSCRIPTION_FARIS_DEPOT_URI = "$BASE_URL/api/v1/souscription/client/depot";
  static const String INFO_SOUSCRIPTION_FARIS_NANA_URI = "$BASE_URL/api/v1/souscription/article/client/info/";
  static const String INFO_SOUSCRIPTION_FARIS_DEPOT_URI = "$BASE_URL/api/v1/souscription/depotarticle/client/info/";
  static const String LISTE_SOUSCRIPTION_FARIS_NANA_URI = "$BASE_URL/api/v1/liste/article/user";
  static const String LISTE_SOUSCRIPTION_FARIS_DEPOT_URI = "$BASE_URL/api/v1/depotliste/article/user";
  static const String UPDATE_PAIEMENT_FARIS_NANA_URI = "$BASE_URL/api/v1/userpaiement/update/";
  static const String ENREGISTREMENT_DEMANDE_FARIS_NANA_URI = "$BASE_URL/api/v1/demande/article/client";
  static const String ENREGISTREMENT_DEPOT_FARIS_DEPOT_URI = "$BASE_URL/api/v1/depot/article/client";

  static const String ENREGISTREMENT_FARIS_RIDER_URI = "$BASE_URL/api/v1/rider/article/client";
  static const String LISTE_FARIS_RIDER_URI = "$BASE_URL/api/v1/article/liste/rider/client/";
  static const String SUPPRIMER_RIDER_URI = "$BASE_URL/api/v1/rider/desactiver/proposition/etat/";
  static const String UPDATE_STATUT_RIDER_URI = "$BASE_URL/api/update_statut_rider/";


  static const String LISTE_DEMANDE_FARIS_NANA_URI = "$BASE_URL/api/v1/article/liste/demande/client/";
  static const String LISTE_DEPOT_FARIS_NANA_URI = "$BASE_URL/api/v1/article/liste/depot/client/";
  static const String LISTE_INFO_SOUSCRIPTION_ACHAT_URI = "$BASE_URL/api/v1/detail/souscription/article/info/client/";
  static const String LISTE_PAIEMENT_URI ="$BASE_URL/api/v1/liste/paiement/user/article";
  static const String SUPPRIMER_SOUSCRIPTION_URI ="$BASE_URL/api/v1/desactiver/souscription/etat/";
  static const String SUPPRIMER_DEMANDE_URI ="$BASE_URL/api/v1/demande/desactiver/proposition/etat/";
  static const String SUPPRIMER_DEPOT_URI ="$BASE_URL/api/v1/depot/desactiver/proposition/etat/";

  // FARIS Tontine
  static const String TONTINE_LIST_URI = "/api/v1/tontines";
  static const String TONTINE_CREATE_URI = "/api/v1/tontines";
  static const String TONTINE_LAST_URI = "/api/v1/tontines/last";
  static const String TONTINE_RUNNING_URI = "/api/v1/tontines/running";
  static const String TONTINE_PENDING_URI = "/api/v1/tontines/pending";
  static const String TONTINE_FINISH_URI = "/api/v1/tontines/finish";
  static const String TONTINE_UPDATE_STATUS_URI = "/api/v1/tontines/";
  static const String TONTINE_MEMBRE_URI = "/api/v1/tontines/";
  static const String TONTINE_COTISATION_LIST_URI = "/api/v1/tontines/";
  static const String TONTINE_COTISER_URI = "/api/v1/tontines/cotiser";
    static const String TONTINE_COTISER_DIRECTEMENT_VIA_OM_URI =
      "/api/v1/tontines/cotiser_directement_via_om";
  static const String TONTINE_RETIRER_URI = "/api/v1/tontines/retirer";
  static const String TONTINE_PERIODICITE_LIST_URI = "/api/v1/tontines/";
  static const String TONTINE_PERIODICITE_TO_PAID_LIST_URI = "/api/v1/periodicites/";
  static const String TONTINE_STATS_LIST_URI = "/api/v1/tontines/";
  static const String TONTINE_SEARCH_URI = "/api/v1/tontines/search";

  static const String TONTINE_SOFT_DELETE_URI  = "/api/v1/tontines/soft-delete";


  // FARIS Pay
  static const String FARISPAY_CREATE_URI = "/api/v1/farispays";
  static const String FARISPAY_LIST_URI = "/api/v1/farispays";
  static const String FARISPAY_PENDING_URI = "/api/v1/farispays";
  static const String FARISPAY_RUNNING_URI = "/api/v1/farispays";
  static const String FARISPAY_RECEIPT_URI = "/api/v1/farispays";
  static const String FARISPAY_NOT_RECEIPT_URI = "/api/v1/farispays";
  static const String FARISPAY_LAST_URI = "/api/v1/farispays/last";
  static const String FARISPAY_DETAILS_URI = "/api/v1/farispays/";
  static const String FARISPAY_CONFIRM_URI = "/api/v1/farispays/";
  static const String FARISPAY_DETELTE_URI = "/api/v1/farispays/";

  // Buy Airtime
  static const String MOBILE_CREDIT_PLANS_LIST_URI =
      "/api/v1/airtime/mobile-credit-plans";
  static const String INTERNET_PLANS_LIST_URI =
      "/api/v1/airtime/internet-plans";
  static const String BUY_AIRTIME_URI = "/api/v1/airtime/buy";
  static const String BUY_AIRTIME_HISTORY_LIST_URI = "/api/v1/airtime/history";

  // Shared Keys
  static const String THEME = "theme";
  static const String TOKEN = "user_token";
  static const String USER_USERNAME = "user_username";
  static const String USER_PASSWORD = "user_password";
  static const String USER_ADDRESS = "user_address";
  static const String USER_TELEPHONE = "user_telephone";
  static const String NOTIFICATION = "notification";
  static const String INTRO = "intro";
  static const String NOTIFICATION_COUNT = "notification_count";
  static const String TOPIC = "single"; //"general";
}
