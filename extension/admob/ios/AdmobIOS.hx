package extension.admob.ios;

#if ios
import extension.admob.AdmobBannerAlign;
import extension.admob.AdmobBannerSize;
import extension.admob.AdmobEvent;
import lime.app.Event;
import lime.media.AudioManager;
import lime.utils.Log;

/**
 * A class to manage AdMob advertisements on iOS devices.
 */
@:access(extension.admob.AdmobEvent)
@:buildXml('<include name="${haxelib:extension-admob}/project/admob-ios/Build.xml" />')
@:headerInclude('admob.hpp')
class AdmobIOS
{
	/**
	 * Event triggered for status updates from AdMob.
	 */
	public static var onEvent:Event<AdmobEvent->Void> = new Event<AdmobEvent->Void>();

	/**
	 * Configures `GDPR` and `CCPA` consent metadata for `Unity Ads` mediation.
	 * 
	 * @param gdprConsent The user's GDPR consent status (true for consent, false for no consent).
	 * @param ccpaConsent The user's CCPA consent status (true for consent, false for no consent).
	 */
	public static function configureConsentMetadata(gdprConsent:Bool, ccpaConsent:Bool):Void
	{
		configureConsentMetadataAdmob(gdprConsent, ccpaConsent);
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
		initAdmob(testingAds, childDirected, enableRDP, cpp.Callable.fromStaticFunction(onAdmobEvent));
	}

	@:noCompletion
	private static function onAdmobEvent(event:cpp.ConstCharStar, value:cpp.ConstCharStar):Void
	{
		if (onEvent != null)
			onEvent.dispatch(AdmobEvent.fromEvent((event : String), (value : String)));
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
		showBannerAdmob(id, size, align);
	}

	/**
	 * Hides the currently displayed banner ad.
	 */
	public static function hideBanner():Void
	{
		hideBannerAdmob();
	}

	/**
	 * Loads an interstitial ad.
	 *
	 * @param id The interstitial ad ID.
	 */
	public static function loadInterstitial(id:String):Void
	{
		loadInterstitialAdmob(id);
	}

	/**
	 * Displays a loaded interstitial ad.
	 */
	public static function showInterstitial():Void
	{
		showInterstitialAdmob();
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param id The rewarded ad ID.
	 */
	public static function loadRewarded(id:String):Void
	{
		loadRewardedAdmob(id);
	}

	/**
	 * Displays a loaded rewarded ad.
	 */
	public static function showRewarded():Void
	{
		showRewardedAdmob();
	}

	/**
	 * Loads a 'app open' ad.
	 *
	 * @param id The 'app open' ad ID.
	 */
	public static function loadAppOpen(id:String):Void
	{
		loadAppOpenAdmob(id);
	}

	/**
	 * Displays a loaded 'app open' ad.
	 */
	public static function showAppOpen():Void
	{
		showAppOpenAdmob();
	}

	/**
	 * Sets the volume for interstitial and rewarded ads.
	 *
	 * @param vol The volume level (0.0 - 1.0, or -1 for muted).
	 */
	public static function setVolume(vol:Float):Void
	{
		setVolumeAdmob(vol);
	}

	/**
	 * Retrieves the user's consent status for a specific IAB Transparency and Consent Framework (TCF) purpose.
	 *
	 * @param purpose The index of the purpose (0-based, as per the TCF specification).
	 * @return `1` if consent is granted, `0` if denied, `-1` if unknown or out of range.
	 */
	public static function getTCFConsentForPurpose(purpose:Int = 0):Int
	{
		return getTCFConsentForPurposeAdmob(purpose);
	}

	/**
	 * Retrieves the IAB Transparency and Consent Framework (TCF) PurposeConsents string.
	 *
	 * @return A string representing the TCF PurposeConsents, or an empty string if unavailable.
	 */
	public static function getTCFPurposeConsent():String
	{
		final cString:cpp.CastCharStar = getTCFPurposeConsentAdmob();

		if (cString != null)
		{
			final haxeString:String = new String(untyped cString);

			cpp.Stdlib.nativeFree(untyped cString);

			return haxeString;
		}

		return '';
	}

	/**
	 * Retrieves the IAB US Privacy String.
	 *
	 * @return A string representing the IAB US Privacy string, or an empty string if unavailable.
	 */
	public static function getUSPrivacy():String
	{
		final cString:cpp.CastCharStar = getUSPrivacyAdmob();

		if (cString != null)
		{
			final haxeString:String = new String(untyped cString);

			cpp.Stdlib.nativeFree(untyped cString);

			return haxeString;
		}

		return '';
	}

	/**
	 * Checks if privacy options are required.
	 *
	 * @return `true` if required, `false` otherwise.
	 */
	public static function isPrivacyOptionsRequired():Bool
	{
		return isPrivacyOptionsRequiredAdmob();
	}

	/**
	 * Displays the privacy options form.
	 */
	public static function showPrivacyOptionsForm():Void
	{
		showPrivacyOptionsFormAdmob();
	}

	/**
	 * Displays the ad inspector.
	 */
	public static function openAdInspector():Void
	{
		openAdInspectorAdmob();
	}

	@:native('Admob_ConfigureConsentMetadata')
	@:noCompletion
	extern private static function configureConsentMetadataAdmob(gdprConsent:Bool, ccpaConsent:Bool):Void;

	@:native('Admob_Init')
	@:noCompletion
	extern private static function initAdmob(testingAds:Bool, childDirected:Bool, enableRDP:Bool,
		callback:cpp.Callable<(event:cpp.ConstCharStar, value:cpp.ConstCharStar) -> Void>):Void;

	@:native('Admob_ShowBanner')
	@:noCompletion
	extern private static function showBannerAdmob(adUnitId:cpp.ConstCharStar, size:Int, align:Int):Void;

	@:native('Admob_HideBanner')
	@:noCompletion
	extern private static function hideBannerAdmob():Void;

	@:native('Admob_LoadInterstitial')
	@:noCompletion
	extern private static function loadInterstitialAdmob(adUnitId:cpp.ConstCharStar):Void;

	@:native('Admob_ShowInterstitial')
	@:noCompletion
	extern private static function showInterstitialAdmob():Void;

	@:native('Admob_LoadRewarded')
	@:noCompletion
	extern private static function loadRewardedAdmob(adUnitId:cpp.ConstCharStar):Void;

	@:native('Admob_ShowRewarded')
	@:noCompletion
	extern private static function showRewardedAdmob():Void;

	@:native('Admob_LoadAppOpen')
	@:noCompletion
	extern private static function loadAppOpenAdmob(adUnitId:cpp.ConstCharStar):Void;

	@:native('Admob_ShowAppOpen')
	@:noCompletion
	extern private static function showAppOpenAdmob():Void;

	@:native('Admob_SetVolume')
	@:noCompletion
	extern private static function setVolumeAdmob(volume:Single):Void;

	@:native('Admob_GetTCFConsentForPurpose')
	@:noCompletion
	extern private static function getTCFConsentForPurposeAdmob(purpose:Int):Int;

	@:native('Admob_GetTCFPurposeConsent')
	@:noCompletion
	extern private static function getTCFPurposeConsentAdmob():cpp.CastCharStar;

	@:native('Admob_GetUSPrivacy')
	@:noCompletion
	extern private static function getUSPrivacyAdmob():cpp.CastCharStar;

	@:native('Admob_IsPrivacyOptionsRequired')
	@:noCompletion
	extern private static function isPrivacyOptionsRequiredAdmob():Bool;

	@:native('Admob_ShowPrivacyOptionsForm')
	@:noCompletion
	extern private static function showPrivacyOptionsFormAdmob():Void;

	@:native('Admob_OpenAdInspector')
	@:noCompletion
	extern private static function openAdInspectorAdmob():Void;
}
#end
