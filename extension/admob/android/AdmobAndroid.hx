package extension.admob.android;

#if android
import extension.admob.AdmobBannerAlign;
import extension.admob.AdmobBannerSize;
import extension.admob.AdmobEvent;
import lime.app.Event;
import lime.system.JNI;

/**
 * A class to manage AdMob advertisements on Android devices.
 */
class AdmobAndroid
{
	/**
	 * Event triggered for status updates from AdMob.
	 */
	public static var onEvent:Event<AdmobEvent->Void> = new Event<AdmobEvent->Void>();

	/**
	 * Cache for storing created static JNI method references.
	 */
	@:noCompletion
	private static var staticMethodsCache:Map<String, Dynamic> = [];

	/**
	 * Configures `GDPR` and `CCPA` consent metadata for `Unity Ads` mediation.
	 * 
	 * @param gdprConsent The user's GDPR consent status (true for consent, false for no consent).
	 * @param ccpaConsent The user's CCPA consent status (true for consent, false for no consent).
	 */
	public static function configureConsentMetadata(gdprConsent:Bool, ccpaConsent:Bool):Void
	{
		final configureConsentMetadataJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'configureConsentMetadata', '(ZZ)V');

		if (configureConsentMetadataJNI != null)
			configureConsentMetadataJNI(gdprConsent, ccpaConsent);
	}

	/**
	 * Initializes the AdMob extension.
	 *
	 * @param testingAds Whether to use testing ads.
	 * @param childDirected Whether the ads should comply with child-directed policies.
	 * @param enableRDP Whether to enable restricted data processing (RDP).
	 */
	public static function init(testingAds:Bool = false, childDirected:Bool = false, enableRDP:Bool = false):Void
	{
		final initJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'init', '(ZZZLorg/haxe/lime/HaxeObject;)V');

		if (initJNI != null)
			initJNI(testingAds, childDirected, enableRDP, new CallBackHandler());
	}

	/**
	 * Shows a banner ad.
	 *
	 * @param id The banner ad ID.
	 * @param size The banner size.
	 * @param align The banner alignment.
	 */
	public static function showBanner(id:String, size:AdmobBannerSize, align:AdmobBannerAlign):Void
	{
		final showBannerJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showBanner', '(Ljava/lang/String;II)V');

		if (showBannerJNI != null)
			showBannerJNI(id, size, align);
	}

	/**
	 * Hides the currently displayed banner ad.
	 */
	public static function hideBanner():Void
	{
		final hideBannerJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'hideBanner', '()V');

		if (hideBannerJNI != null)
			hideBannerJNI();
	}

	/**
	 * Loads an interstitial ad.
	 *
	 * @param id The interstitial ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadInterstitial(id:String, immersiveModeEnabled:Bool = true):Void
	{
		final loadInterstitialJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadInterstitial', '(Ljava/lang/String;Z)V');

		if (loadInterstitialJNI != null)
			loadInterstitialJNI(id, immersiveModeEnabled);
	}

	/**
	 * Displays a loaded interstitial ad.
	 */
	public static function showInterstitial():Void
	{
		final showInterstitialJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showInterstitial', '()V');

		if (showInterstitialJNI != null)
			showInterstitialJNI();
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param id The rewarded ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadRewarded(id:String, immersiveModeEnabled:Bool = true):Void
	{
		final loadRewardedJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadRewarded', '(Ljava/lang/String;Z)V');

		if (loadRewardedJNI != null)
			loadRewardedJNI(id, immersiveModeEnabled);
	}

	/**
	 * Displays a loaded rewarded ad.
	 */
	public static function showRewarded():Void
	{
		final showRewardedJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showRewarded', '()V');

		if (showRewardedJNI != null)
			showRewardedJNI();
	}

	/**
	 * Loads a 'app open' ad.
	 *
	 * @param id The 'app open' ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadAppOpen(id:String, immersiveModeEnabled:Bool = true):Void
	{
		final loadAppOpenJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadAppOpen', '(Ljava/lang/String;Z)V');

		if (loadAppOpenJNI != null)
			loadAppOpenJNI(id, immersiveModeEnabled);
	}

	/**
	 * Displays a loaded 'app open' ad.
	 */
	public static function showAppOpen():Void
	{
		final showAppOpenJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showAppOpen', '()V');

		if (showAppOpenJNI != null)
			showAppOpenJNI();
	}

	/**
	 * Sets the volume for interstitial and rewarded ads.
	 *
	 * @param vol The volume level (0.0 - 1.0, or -1 for muted).
	 */
	public static function setVolume(vol:Float):Void
	{
		final setVolumeJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'setVolume', '(F)V');

		if (setVolumeJNI != null)
			setVolumeJNI(vol);
	}

	/**
	 * Retrieves the user's consent status for a specific IAB Transparency and Consent Framework (TCF) purpose.
	 *
	 * @param purpose The index of the purpose (0-based, as per the TCF specification).
	 * @return `1` if consent is granted, `0` if denied, `-1` if unknown or out of range.
	 */
	public static function getTCFConsentForPurpose(purpose:Int = 0):Int
	{
		final getTCFConsentForPurposeJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getTCFConsentForPurpose', '(I)I');

		return getTCFConsentForPurposeJNI != null ? getTCFConsentForPurposeJNI(purpose) : -1;
	}

	/**
	 * Retrieves the IAB Transparency and Consent Framework (TCF) PurposeConsents string.
	 *
	 * @return A string representing the TCF PurposeConsents, or an empty string if unavailable.
	 */
	public static function getTCFPurposeConsent():String
	{
		final getTCFPurposeConsentJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getTCFPurposeConsent', '()Ljava/lang/String;');

		return getTCFPurposeConsentJNI != null ? getTCFPurposeConsentJNI() : '';
	}

	/**
	 * Retrieves the IAB US Privacy String.
	 *
	 * @return A string representing the IAB US Privacy string, or an empty string if unavailable.
	 */
	public static function getUSPrivacy():String
	{
		final getUSPrivacyJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getUSPrivacy', '()Ljava/lang/String;');

		return getUSPrivacyJNI != null ? getUSPrivacyJNI() : '';
	}

	/**
	 * Checks if privacy options are required.
	 *
	 * @return `true` if required, `false` otherwise.
	 */
	public static function isPrivacyOptionsRequired():Bool
	{
		final isPrivacyOptionsRequiredJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'isPrivacyOptionsRequired', '()Z');

		return isPrivacyOptionsRequiredJNI != null ? isPrivacyOptionsRequiredJNI() : false;
	}

	/**
	 * Displays the privacy options form.
	 */
	public static function showPrivacyOptionsForm():Void
	{
		final showPrivacyOptionsFormJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showPrivacyOptionsForm', '()V');

		if (showPrivacyOptionsFormJNI != null)
			showPrivacyOptionsFormJNI();
	}

	/**
	 * Displays the ad inspector.
	 */
	public static function openAdInspector():Void
	{
		final openAdInspectorJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'openAdInspector', '()V');

		if (openAdInspectorJNI != null)
			openAdInspectorJNI();
	}

	/**
	 * Retrieves or creates a cached static method reference.
	 * @param className The name of the Java class containing the method.
	 * @param methodName The name of the method to call.
	 * @param signature The JNI method signature string (e.g., "()V", "(Ljava/lang/String;)V").
	 * @param cache Whether to cache the result (default true).
	 * @return A dynamic reference to the static method, or null if it couldn't be created.
	 */
	@:noCompletion
	private static function createJNIStaticMethod(className:String, methodName:String, signature:String, cache:Bool = true):Null<Dynamic>
	{
		@:privateAccess
		className = JNI.transformClassName(className);

		final key:String = '$className::$methodName::$signature';

		if (cache && !staticMethodsCache.exists(key))
			staticMethodsCache.set(key, JNI.createStaticMethod(className, methodName, signature));
		else if (!cache)
			return JNI.createStaticMethod(className, methodName, signature);

		return staticMethodsCache.get(key);
	}
}

/**
 * Internal callback handler for AdMob events.
 */
@:access(extension.admob.AdmobEvent)
@:noCompletion
private class CallBackHandler #if (lime >= "8.0.0") implements lime.system.JNI.JNISafety #end
{
	public function new():Void {}

	@:keep
	#if (lime >= "8.0.0")
	@:runOnMainThread
	#end
	public function onEvent(event:String, value:String):Void
	{
		if (AdmobAndroid.onEvent != null)
			AdmobAndroid.onEvent.dispatch(AdmobEvent.fromEvent(event, value));
	}
}
#end
