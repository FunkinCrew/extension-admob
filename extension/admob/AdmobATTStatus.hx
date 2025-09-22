package extension.admob;

#if ios
/**
 * Enum representing the different statuses for App Tracking Transparency (ATT) in iOS.
 * 
 * These statuses indicate the user's permission for tracking within apps, as per the App Tracking Transparency framework introduced in iOS 14.
 *
 * @see https://stackoverflow.com/questions/63499520/app-tracking-transparency-how-does-effect-apps-showing-ads-idfa-ios14/63522856#63522856
 */
enum abstract AdmobATTStatus(String) from String to String
{
	/**
	 * The user has not yet made a choice regarding tracking.
	 */
	final NOT_DETERMINED = 'NOT_DETERMINED';

	/**
	 * The user's tracking permission is restricted.
	 */
	final RESTRICTED = 'RESTRICTED';

	/**
	 * The user has denied permission for tracking.
	 */
	final DENIED = 'DENIED';

	/**
	 * The user has authorized tracking.
	 */
	final AUTHORIZED = 'AUTHORIZED';

	/**
	 * The status is unknown.
	 */
	final UNKNOWN = 'UNKNOWN';
}
#end
