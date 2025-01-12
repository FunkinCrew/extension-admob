package extension.admob;

/**
 * Enum representing various AdMob event types.
 * The enum values represent different stages or outcomes of
 * initializing and interacting with AdMob ads, including banner, interstitial, rewarded, and app open ads.
 */
enum abstract AdmobEvent(String) from String to String
{
	/**
	 * Event triggered when AdMob is initialized successfully.
	 * Ads can be requested after this event.
	 */
	final INIT_OK = "INIT_OK";

	/**
	 * Event triggered when there is an issue with the GDPR consent form.
	 * AdMob is initialized anyway, but its usage is at your own risk.
	 */
	final CONSENT_FAIL = "CONSENT_FAIL";

	/**
	 * Event triggered when the GDPR consent form is successfully completed.
	 */
	final CONSENT_SUCCESS = "CONSENT_SUCCESS";

	/**
	 * Event triggered when GDPR consent is not required for the user.
	 */
	final CONSENT_NOT_REQUIRED = "CONSENT_NOT_REQUIRED";

	#if ios
	/**
	 * Event triggered for the App Tracking Transparency (ATT) status on iOS.
	 */
	final ATT_STATUS = "ATT_STATUS";
	#end

	/**
	 * Event triggered when a banner ad is successfully loaded.
	 */
	final BANNER_LOADED = "BANNER_LOADED";

	/**
	 * Event triggered when a banner ad fails to load.
	 */
	final BANNER_FAILED_TO_LOAD = "BANNER_FAILED_TO_LOAD";

	/**
	 * Event triggered when a banner ad is opened.
	 */
	final BANNER_OPENED = "BANNER_OPENED";

	/**
	 * Event triggered when a banner ad is clicked.
	 */
	final BANNER_CLICKED = "BANNER_CLICKED";

	/**
	 * Event triggered when a banner ad is closed.
	 */
	final BANNER_CLOSED = "BANNER_CLOSED";

	/**
	 * Event triggered when an interstitial ad is successfully loaded.
	 */
	final INTERSTITIAL_LOADED = "INTERSTITIAL_LOADED";

	/**
	 * Event triggered when an interstitial ad fails to load.
	 */
	final INTERSTITIAL_FAILED_TO_LOAD = "INTERSTITIAL_FAILED_TO_LOAD";

	/**
	 * Event triggered when an interstitial ad fails to show.
	 */
	final INTERSTITIAL_FAILED_TO_SHOW = "INTERSTITIAL_FAILED_TO_SHOW";

	/**
	 * Event triggered when an interstitial ad is shown.
	 */
	final INTERSTITIAL_SHOWED = "INTERSTITIAL_SHOWED";

	/**
	 * Event triggered when an interstitial ad is clicked.
	 */
	final INTERSTITIAL_CLICKED = "INTERSTITIAL_CLICKED";

	/**
	 * Event triggered when an interstitial ad is dismissed.
	 */
	final INTERSTITIAL_DISMISSED = "INTERSTITIAL_DISMISSED";

	/**
	 * Event triggered when a rewarded ad is successfully loaded.
	 */
	final REWARDED_LOADED = "REWARDED_LOADED";

	/**
	 * Event triggered when a rewarded ad fails to load.
	 */
	final REWARDED_FAILED_TO_LOAD = "REWARDED_FAILED_TO_LOAD";

	/**
	 * Event triggered when a rewarded ad fails to show.
	 */
	final REWARDED_FAILED_TO_SHOW = "REWARDED_FAILED_TO_SHOW";

	/**
	 * Event triggered when a rewarded ad is shown.
	 */
	final REWARDED_SHOWED = "REWARDED_SHOWED";

	/**
	 * Event triggered when a reward is earned from a rewarded ad.
	 */
	final REWARDED_EARNED = "REWARDED_EARNED";

	/**
	 * Event triggered when a rewarded ad is clicked.
	 */
	final REWARDED_CLICKED = "REWARDED_CLICKED";

	/**
	 * Event triggered when a rewarded ad is dismissed.
	 */
	final REWARDED_DISMISSED = "REWARDED_DISMISSED";

	/**
	 * Event triggered when an app open ad is successfully loaded.
	 */
	final APP_OPEN_LOADED = "APP_OPEN_LOADED";

	/**
	 * Event triggered when an app open ad fails to load.
	 */
	final APP_OPEN_FAILED_TO_LOAD = "APP_OPEN_FAILED_TO_LOAD";

	/**
	 * Event triggered when an app open ad fails to show.
	 */
	final APP_OPEN_FAILED_TO_SHOW = "APP_OPEN_FAILED_TO_SHOW";

	/**
	 * Event triggered when an app open ad is shown.
	 */
	final APP_OPEN_SHOWED = "APP_OPEN_SHOWED";

	/**
	 * Event triggered when an app open ad is clicked.
	 */
	final APP_OPEN_CLICKED = "APP_OPEN_CLICKED";

	/**
	 * Event triggered when an app open ad is dismissed.
	 */
	final APP_OPEN_DISMISSED = "APP_OPEN_DISMISSED";

	/**
	 * Event triggered for any general failure.
	 */
	final FAIL = "FAIL";
}
