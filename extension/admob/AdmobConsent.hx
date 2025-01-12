package extension.admob;

/**
 * Enum representing the different levels of consent for AdMob ads based on GDPR policies.
 * The values in this enum reflect the consent status provided by the user
 * for showing personalized or non-personalized ads according to the GDPR and the IAB Europe Transparency & Consent Framework.
 *
 * @see https://support.google.com/admob/answer/9760862#consent-policies
 * @see https://iabeurope.eu/iab-europe-transparency-consent-framework-policies/#A_Purposes
 */
enum abstract AdmobConsent(String) from String to String
{
	/**
	 * Full consent has been granted by the user.
	 * AdMob should have no issues showing personalized or non-personalized ads.
	 */
	final FULL = "11111111111";

	/**
	 * No consent has been granted by the user.
	 * Ads will not be shown.
	 */
	final ZERO = "00000000000";

	/**
	 * Consent for personalized ads has been granted.
	 * This value is less likely to occur as the user must manually select all checkboxes.
	 */
	final PERSONALIZED = "11110010110";

	/**
	 * Consent to show non-personalized ads has been granted.
	 * This value is more likely, but the user must manually select the right checkboxes.
	 */
	final NON_PERSONALIZED = "11000010110";
}
