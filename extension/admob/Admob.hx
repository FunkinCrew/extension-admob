package extension.admob;

import extension.admob.AdmobBannerAlign;
import extension.admob.AdmobBannerSize;
import extension.admob.AdmobEvent;
import lime.app.Event;
#if android
import lime.system.JNI;
#end

/**
 * A class to manage AdMob advertisements on Mobile devices.
 */
#if ios
@:access(extension.admob.AdmobEvent)
@:buildXml("<include name=\"${haxelib:extension-admob}/project/admob-ios/Build.xml\" />")
@:headerInclude('admob.hpp')
#end
class Admob
{
	/**
	 * Event triggered for status updates from AdMob.
	 */
	public static var onEvent:Event<AdmobEvent->Void> = new Event<AdmobEvent->Void>();

	#if android
	/**
	 * Cache for storing created static JNI method references.
	 */
	@:noCompletion
	private static var staticMethodsCache:Map<String, Dynamic> = [];
	#end

	/**
	 * Configures `GDPR` and `CCPA` consent metadata for `Unity Ads` mediation.
	 * 
	 * @param gdprConsent The user's GDPR consent status (true for consent, false for no consent).
	 * @param ccpaConsent The user's CCPA consent status (true for consent, false for no consent).
	 */
	public static function configureConsentMetadata(gdprConsent:Bool, ccpaConsent:Bool):Void
	{
		#if android
		final configureConsentMetadataJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'configureConsentMetadata', '(ZZ)V');

		if (configureConsentMetadataJNI != null)
			configureConsentMetadataJNI(gdprConsent, ccpaConsent);
		#elseif ios
		configureConsentMetadataAdmob(gdprConsent, ccpaConsent);
		#end
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
		#if android
		final initJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'init', '(ZZZLorg/haxe/lime/HaxeObject;)V');

		if (initJNI != null)
			initJNI(testingAds, childDirected, enableRDP, new CallBackHandler());
		#elseif ios
		initAdmob(testingAds, childDirected, enableRDP, cpp.Callable.fromStaticFunction(onAdmobEvent));
		#end
	}

	#if ios
	@:noCompletion
	private static function onAdmobEvent(event:cpp.ConstCharStar, value:cpp.ConstCharStar):Void
	{
		if (onEvent != null)
			onEvent.dispatch(AdmobEvent.fromEvent((event : String), (value : String)));
	}
	#end

	/**
	 * Shows a banner ad.
	 * 
	 * @param id The banner ad ID.
	 * @param size The banner size.
	 * @param align The banner alignment.
	 */
	public static function showBanner(id:String, size:AdmobBannerSize, align:AdmobBannerAlign):Void
	{
		#if android
		final showBannerJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showBanner', '(Ljava/lang/String;II)V');

		if (showBannerJNI != null)
			showBannerJNI(id, size, align);
		#elseif ios
		showBannerAdmob(id, size, align);
		#end
	}

	/**
	 * Hides the currently displayed banner ad.
	 */
	public static function hideBanner():Void
	{
		#if android
		final hideBannerJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'hideBanner', '()V');

		if (hideBannerJNI != null)
			hideBannerJNI();
		#elseif ios
		hideBannerAdmob();
		#end
	}

	#if android
	/**
	 * Starts the interstitial ad preloader with the specified preload ID and buffer size.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @param adUnitId The ad unit ID to be used for loading interstitial ads.
	 * @param bufferSize The number of interstitial ads to preload.
	 */
	public static function startInterstitialPreloader(preloadID:String, adUnitId:String, bufferSize:Int):Void
	{
		final startInterstitialPreloaderJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'startInterstitialPreloader', '(Ljava/lang/String;Ljava/lang/String;I)V');

		if (startInterstitialPreloaderJNI != null)
			startInterstitialPreloaderJNI(preloadID, adUnitId, bufferSize);
	}

	/**
	 * Stops preloading for the specified interstitial ad preloader identified by `preloadID` and destroys all associated preloaded ads.
	 *
	 * @param preloadID The unique identifier for the interstitial ad preloader to be destroyed.
	 * @return `true` if the preloader was successfully destroyed, `false` otherwise.
	 */
	public static function destroyInterstitialPreloader(preloadID:String):Bool
	{
		final destroyInterstitialPreloaderJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyInterstitialPreloader', '(Ljava/lang/String;)Z');

		if (destroyInterstitialPreloaderJNI != null)
			return destroyInterstitialPreloaderJNI(preloadID);

		return false;
	}

	/**
	 * Stops preloading and destroys all preloaded interstitial ads for every preload configuration.
	 */
	public static function destroyAllInterstitialPreloaders():Void
	{
		final destroyAllInterstitialPreloadersJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyAllInterstitialPreloaders', '()V');

		if (destroyAllInterstitialPreloadersJNI != null)
			destroyAllInterstitialPreloadersJNI();
	}

	/**
	 * Returns the number of interstitial ads available for the given preload ID.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @return The number of available interstitial ads.
	 */
	public static function getNumInterstitialAdsAvailable(preloadID:String):Int
	{
		final getNumInterstitialAdsAvailableJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getNumInterstitialAdsAvailable', '(Ljava/lang/String;)I');

		if (getNumInterstitialAdsAvailableJNI != null)
			return getNumInterstitialAdsAvailableJNI(preloadID);

		return 0;
	}

	/**
	 * Checks if an interstitial ad is available for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @return `true` if an interstitial ad is available, `false` otherwise.
	 */
	public static function isInterstitialAdAvailable(preloadID:String):Bool
	{
		final isInterstitialAdAvailableJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'isInterstitialAdAvailable', '(Ljava/lang/String;)Z');

		if (isInterstitialAdAvailableJNI != null)
			return isInterstitialAdAvailableJNI(preloadID);

		return false;
	}

	/**
	 * Loads an interstitial ad from the pool for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @param immersiveModeEnabled Whether immersive mode should be enabled (default is true).
	 */
	public static function loadAdInterstitialFromPoll(preloadID:String, immersiveModeEnabled:Bool = true):Void
	{
		final loadAdInterstitialFromPollJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadAdInterstitialFromPoll', '(Ljava/lang/String;Z)V');

		if (loadAdInterstitialFromPollJNI != null)
			loadAdInterstitialFromPollJNI(preloadID, immersiveModeEnabled);
	}
	#end

	/**
	 * Loads an interstitial ad.
	 *
	 * @param id The interstitial ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadInterstitial(id:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final loadInterstitialJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadInterstitial', '(Ljava/lang/String;Z)V');

		if (loadInterstitialJNI != null)
			loadInterstitialJNI(id, immersiveModeEnabled);
		#elseif ios
		loadInterstitialAdmob(id);
		#end
	}

	/**
	 * Displays a loaded interstitial ad.
	 */
	public static function showInterstitial():Void
	{
		#if android
		final showInterstitialJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showInterstitial', '()V');

		if (showInterstitialJNI != null)
			showInterstitialJNI();
		#elseif ios
		showInterstitialAdmob();
		#end
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param id The rewarded ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadRewarded(id:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final loadRewardedJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadRewarded', '(Ljava/lang/String;Z)V');

		if (loadRewardedJNI != null)
			loadRewardedJNI(id, immersiveModeEnabled);
		#elseif ios
		loadRewardedAdmob(id);
		#end
	}

	/**
	 * Displays a loaded rewarded ad.
	 */
	public static function showRewarded():Void
	{
		#if android
		final showRewardedJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showRewarded', '()V');

		if (showRewardedJNI != null)
			showRewardedJNI();
		#elseif ios
		showRewardedAdmob();
		#end
	}

	/**
	 * Loads a 'app open' ad.
	 *
	 * @param id The 'app open' ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadAppOpen(id:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final loadAppOpenJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadAppOpen', '(Ljava/lang/String;Z)V');

		if (loadAppOpenJNI != null)
			loadAppOpenJNI(id, immersiveModeEnabled);
		#elseif ios
		loadAppOpenAdmob(id);
		#end
	}

	/**
	 * Displays a loaded 'app open' ad.
	 */
	public static function showAppOpen():Void
	{
		#if android
		final showAppOpenJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showAppOpen', '()V');

		if (showAppOpenJNI != null)
			showAppOpenJNI();
		#elseif ios
		showAppOpenAdmob();
		#end
	}

	/**
	 * Sets the volume for interstitial and rewarded ads.
	 *
	 * @param vol The volume level (0.0 - 1.0, or -1 for muted).
	 */
	public static function setVolume(vol:Float):Void
	{
		#if android
		final setVolumeJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'setVolume', '(F)V');

		if (setVolumeJNI != null)
			setVolumeJNI(vol);
		#elseif ios
		setVolumeAdmob(vol);
		#end
	}

	/**
	 * Retrieves the user's consent status for a specific IAB Transparency and Consent Framework (TCF) purpose.
	 *
	 * @param purpose The index of the purpose (0-based, as per the TCF specification).
	 * @return `1` if consent is granted, `0` if denied, `-1` if unknown or out of range.
	 */
	public static function getTCFConsentForPurpose(purpose:Int = 0):Int
	{
		#if android
		final getTCFConsentForPurposeJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getTCFConsentForPurpose', '(I)I');

		return getTCFConsentForPurposeJNI != null ? getTCFConsentForPurposeJNI(purpose) : -1;
		#elseif ios
		return getTCFConsentForPurposeAdmob(purpose);
		#end
	}

	/**
	 * Retrieves the IAB Transparency and Consent Framework (TCF) PurposeConsents string.
	 *
	 * @return A string representing the TCF PurposeConsents, or an empty string if unavailable.
	 */
	public static function getTCFPurposeConsent():String
	{
		#if android
		final getTCFPurposeConsentJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getTCFPurposeConsent', '()Ljava/lang/String;');

		return getTCFPurposeConsentJNI != null ? getTCFPurposeConsentJNI() : '';
		#elseif ios
		final cString:cpp.CastCharStar = getTCFPurposeConsentAdmob();

		if (cString != null)
		{
			final haxeString:String = new String(untyped cString);

			cpp.Stdlib.nativeFree(untyped cString);

			return haxeString;
		}

		return '';
		#end
	}

	/**
	 * Retrieves the IAB US Privacy String.
	 *
	 * @return A string representing the IAB US Privacy string, or an empty string if unavailable.
	 */
	public static function getUSPrivacy():String
	{
		#if android
		final getUSPrivacyJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getUSPrivacy', '()Ljava/lang/String;');

		return getUSPrivacyJNI != null ? getUSPrivacyJNI() : '';
		#elseif ios
		final cString:cpp.CastCharStar = getUSPrivacyAdmob();

		if (cString != null)
		{
			final haxeString:String = new String(untyped cString);

			cpp.Stdlib.nativeFree(untyped cString);

			return haxeString;
		}

		return '';
		#end
	}

	/**
	 * Checks if privacy options are required.
	 *
	 * @return `true` if required, `false` otherwise.
	 */
	public static function isPrivacyOptionsRequired():Bool
	{
		#if android
		final isPrivacyOptionsRequiredJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'isPrivacyOptionsRequired', '()Z');

		return isPrivacyOptionsRequiredJNI != null ? isPrivacyOptionsRequiredJNI() : false;
		#elseif ios
		return isPrivacyOptionsRequiredAdmob();
		#end
	}

	/**
	 * Displays the privacy options form.
	 */
	public static function showPrivacyOptionsForm():Void
	{
		#if android
		final showPrivacyOptionsFormJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showPrivacyOptionsForm', '()V');

		if (showPrivacyOptionsFormJNI != null)
			showPrivacyOptionsFormJNI();
		#elseif ios
		showPrivacyOptionsFormAdmob();
		#end
	}

	/**
	 * Displays the ad inspector.
	 */
	public static function openAdInspector():Void
	{
		#if android
		final openAdInspectorJNI:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'openAdInspector', '()V');

		if (openAdInspectorJNI != null)
			openAdInspectorJNI();
		#elseif ios
		openAdInspectorAdmob();
		#end
	}

	#if android
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
	#elseif ios
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
	#end
}

#if android
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
		if (Admob.onEvent != null)
			Admob.onEvent.dispatch(AdmobEvent.fromEvent(event, value));
	}
}
#end
