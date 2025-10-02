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
	public static function configureUnity(gdprConsent:Bool, ccpaConsent:Bool):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'configureUnity', '(ZZ)V');

		if (jni != null)
			jni(gdprConsent, ccpaConsent);
		#elseif ios
		configureUnityAdmob(gdprConsent, ccpaConsent);
		#end
	}

	/**
	 * Configures `GDPR` and `PA` (similar to CCPA) consent metadata for `Pangle` mediation.
	 * 
	 * @param gdprConsent The user's GDPR consent status (true for consent, false for no consent).
	 * @param paConsent The user's PA consent status (true for consent, false for no consent).
	 */
	public static function configurePangle(gdprConsent:Bool, paConsent:Bool):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'configurePangle', '(ZZ)V');

		if (jni != null)
			jni(gdprConsent, paConsent);
		#elseif ios
		configurePangleAdmob(gdprConsent, paConsent);
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'init', '(ZZZLorg/haxe/lime/HaxeObject;)V');

		if (jni != null)
			jni(testingAds, childDirected, enableRDP, new CallBackHandler());
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
	 * @param adUnitID The ad unit ID.
	 * @param size The banner size.
	 * @param align The banner alignment.
	 */
	public static function showBanner(adUnitID:String, size:AdmobBannerSize, align:AdmobBannerAlign):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showBanner', '(Ljava/lang/String;II)V');

		if (jni != null)
			jni(adUnitID, size, align);
		#elseif ios
		showBannerAdmob(adUnitID, size, align);
		#end
	}

	/**
	 * Hides the currently displayed banner ad.
	 */
	public static function hideBanner():Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'hideBanner', '()V');

		if (jni != null)
			jni();
		#elseif ios
		hideBannerAdmob();
		#end
	}

	/**
	 * Starts the interstitial ad preloader with the specified preload ID and buffer size.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @param adUnitID The ad unit ID to be used for loading interstitial ads.
	 * @param bufferSize The number of interstitial ads to preload.
	 */
	public static function startInterstitialPreloader(preloadID:String, adUnitID:String, bufferSize:Int):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'startInterstitialPreloader', '(Ljava/lang/String;Ljava/lang/String;I)V');

		if (jni != null)
			jni(preloadID, adUnitID, bufferSize);
		#end
	}

	/**
	 * Stops preloading for the specified interstitial ad preloader identified by `preloadID` and destroys all associated preloaded ads.
	 *
	 * @param preloadID The unique identifier for the interstitial ad preloader to be destroyed.
	 * @return `true` if the preloader was successfully destroyed, `false` otherwise.
	 */
	public static function destroyInterstitialPreloader(preloadID:String):Bool
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyInterstitialPreloader', '(Ljava/lang/String;)Z');

		return jni != null ? jni(preloadID) : false;
		#else
		return false;
		#end
	}

	/**
	 * Stops preloading and destroys all preloaded interstitial ads for every preload configuration.
	 */
	public static function destroyAllInterstitialPreloaders():Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyAllInterstitialPreloaders', '()V');

		if (jni != null)
			jni();
		#end
	}

	/**
	 * Returns the number of interstitial ads available for the given preload ID.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @return The number of available interstitial ads.
	 */
	public static function getNumInterstitialAdsAvailable(preloadID:String):Int
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getNumInterstitialAdsAvailable', '(Ljava/lang/String;)I');

		return jni != null ? jni(preloadID) : 0;
		#else
		return 0;
		#end
	}

	/**
	 * Checks if an interstitial ad is available for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @return `true` if an interstitial ad is available, `false` otherwise.
	 */
	public static function isInterstitialAdAvailable(preloadID:String):Bool
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'isInterstitialAdAvailable', '(Ljava/lang/String;)Z');

		return jni != null ? jni(preloadID) : false;
		#else
		return false;
		#end
	}

	/**
	 * Loads an interstitial ad from the preloader for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the interstitial ad preloader.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadInterstitialFromPreloader(preloadID:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadInterstitialFromPreloader', '(Ljava/lang/String;Z)V');

		if (jni != null)
			jni(preloadID, immersiveModeEnabled);
		#end
	}

	/**
	 * Loads an interstitial ad.
	 *
	 * @param adUnitID The ad unit ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadInterstitial(adUnitID:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadInterstitial', '(Ljava/lang/String;Z)V');

		if (jni != null)
			jni(adUnitID, immersiveModeEnabled);
		#elseif ios
		loadInterstitialAdmob(adUnitID);
		#end
	}

	/**
	 * Displays a loaded interstitial ad.
	 */
	public static function showInterstitial():Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showInterstitial', '()V');

		if (jni != null)
			jni();
		#elseif ios
		showInterstitialAdmob();
		#end
	}

	/**
	 * Starts the rewarded ad preloader with the specified preload ID and buffer size.
	 * 
	 * @param preloadID The identifier for the rewarded ad preloader.
	 * @param adUnitID The ad unit ID to be used for loading rewarded ads.
	 * @param bufferSize The number of rewarded ads to preload.
	 */
	public static function startRewardedPreloader(preloadID:String, adUnitID:String, bufferSize:Int):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'startRewardedPreloader', '(Ljava/lang/String;Ljava/lang/String;I)V');

		if (jni != null)
			jni(preloadID, adUnitID, bufferSize);
		#end
	}

	/**
	 * Stops preloading for the specified rewarded ad preloader identified by `preloadID`
	 * and destroys all associated preloaded ads.
	 *
	 * @param preloadID The unique identifier for the rewarded ad preloader to be destroyed.
	 * @return `true` if the preloader was successfully destroyed, `false` otherwise.
	 */
	public static function destroyRewardedPreloader(preloadID:String):Bool
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyRewardedPreloader', '(Ljava/lang/String;)Z');

		return jni != null ? jni(preloadID) : false;
		#else
		return false;
		#end
	}

	/**
	 * Stops preloading and destroys all preloaded rewarded ads for every preload configuration.
	 */
	public static function destroyAllRewardedPreloaders():Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyAllRewardedPreloaders', '()V');

		if (jni != null)
			jni();
		#end
	}

	/**
	 * Returns the number of rewarded ads available for the given preload ID.
	 * 
	 * @param preloadID The identifier for the rewarded ad preloader.
	 * @return The number of available rewarded ads.
	 */
	public static function getNumRewardedAdsAvailable(preloadID:String):Int
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getNumRewardedAdsAvailable', '(Ljava/lang/String;)I');

		return jni != null ? jni(preloadID) : 0;
		#else
		return 0;
		#end
	}

	/**
	 * Checks if a rewarded ad is available for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the rewarded ad preloader.
	 * @return `true` if a rewarded ad is available, `false` otherwise.
	 */
	public static function isRewardedAdAvailable(preloadID:String):Bool
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'isRewardedAdAvailable', '(Ljava/lang/String;)Z');

		return jni != null ? jni(preloadID) : false;
		#else
		return false;
		#end
	}

	/**
	 * Loads a rewarded ad from the preloader for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the rewarded ad preloader.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadRewardedFromPreloader(preloadID:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadRewardedFromPreloader', '(Ljava/lang/String;Z)V');

		if (jni != null)
			jni(preloadID, immersiveModeEnabled);
		#end
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param adUnitID The ad unit ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadRewarded(adUnitID:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadRewarded', '(Ljava/lang/String;Z)V');

		if (jni != null)
			jni(adUnitID, immersiveModeEnabled);
		#elseif ios
		loadRewardedAdmob(adUnitID);
		#end
	}

	/**
	 * Displays a loaded rewarded ad.
	 */
	public static function showRewarded():Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showRewarded', '()V');

		if (jni != null)
			jni();
		#elseif ios
		showRewardedAdmob();
		#end
	}

	/**
	 * Starts the app open ad preloader with the specified preload ID and buffer size.
	 * 
	 * @param preloadID The identifier for the app open ad preloader.
	 * @param adUnitID The ad unit ID to be used for loading app open ads.
	 * @param bufferSize The number of app open ads to preload.
	 */
	public static function startAppOpenPreloader(preloadID:String, adUnitID:String, bufferSize:Int):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'startAppOpenPreloader', '(Ljava/lang/String;Ljava/lang/String;I)V');

		if (jni != null)
			jni(preloadID, adUnitID, bufferSize);
		#end
	}

	/**
	 * Stops preloading for the specified app open ad preloader identified by `preloadID`
	 * and destroys all associated preloaded ads.
	 *
	 * @param preloadID The unique identifier for the app open ad preloader to be destroyed.
	 * @return `true` if the preloader was successfully destroyed, `false` otherwise.
	 */
	public static function destroyAppOpenPreloader(preloadID:String):Bool
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyAppOpenPreloader', '(Ljava/lang/String;)Z');

		return jni != null ? jni(preloadID) : false;
		#else
		return false;
		#end
	}

	/**
	 * Stops preloading and destroys all preloaded app open ads for every preload configuration.
	 */
	public static function destroyAllAppOpenPreloaders():Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'destroyAllAppOpenPreloaders', '()V');

		if (jni != null)
			jni();
		#end
	}

	/**
	 * Returns the number of app open ads available for the given preload ID.
	 * 
	 * @param preloadID The identifier for the app open ad preloader.
	 * @return The number of available app open ads.
	 */
	public static function getNumAppOpenAdsAvailable(preloadID:String):Int
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getNumAppOpenAdsAvailable', '(Ljava/lang/String;)I');

		return jni != null ? jni(preloadID) : 0;
		#else
		return 0;
		#end
	}

	/**
	 * Checks if an app open ad is available for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the app open ad preloader.
	 * @return `true` if an app open ad is available, `false` otherwise.
	 */
	public static function isAppOpenAdAvailable(preloadID:String):Bool
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'isAppOpenAdAvailable', '(Ljava/lang/String;)Z');

		return jni != null ? jni(preloadID) : false;
		#else
		return false;
		#end
	}

	/**
	 * Loads an app open ad from the preloader for the specified preload ID.
	 * 
	 * @param preloadID The identifier for the app open ad preloader.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadAppOpenFromPreloader(preloadID:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadAppOpenFromPreloader', '(Ljava/lang/String;Z)V');

		if (jni != null)
			jni(preloadID, immersiveModeEnabled);
		#end
	}

	/**
	 * Loads a app open ad.
	 *
	 * @param adUnitID The ad unit ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadAppOpen(adUnitID:String, immersiveModeEnabled:Bool = true):Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'loadAppOpen', '(Ljava/lang/String;Z)V');

		if (jni != null)
			jni(adUnitID, immersiveModeEnabled);
		#elseif ios
		loadAppOpenAdmob(adUnitID);
		#end
	}

	/**
	 * Displays a loaded 'app open' ad.
	 */
	public static function showAppOpen():Void
	{
		#if android
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showAppOpen', '()V');

		if (jni != null)
			jni();
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'setVolume', '(F)V');

		if (jni != null)
			jni(vol);
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getTCFConsentForPurpose', '(I)I');

		return jni != null ? jni(purpose) : -1;
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getTCFPurposeConsent', '()Ljava/lang/String;');

		return jni != null ? jni() : '';
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'getUSPrivacy', '()Ljava/lang/String;');

		return jni != null ? jni() : '';
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'isPrivacyOptionsRequired', '()Z');

		return jni != null ? jni() : false;
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'showPrivacyOptionsForm', '()V');

		if (jni != null)
			jni();
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
		final jni:Null<Dynamic> = createJNIStaticMethod('org/haxe/extension/Admob', 'openAdInspector', '()V');

		if (jni != null)
			jni();
		#elseif ios
		openAdInspectorAdmob();
		#end
	}

	#if android
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
	@:native('Admob_ConfigureUnity')
	@:noCompletion
	extern private static function configureUnityAdmob(gdprConsent:Bool, ccpaConsent:Bool):Void;

	@:native('Admob_ConfigurePangle')
	@:noCompletion
	extern private static function configurePangleAdmob(gdprConsent:Bool, paConsent:Bool):Void;

	@:native('Admob_Init')
	@:noCompletion
	extern private static function initAdmob(testingAds:Bool, childDirected:Bool, enableRDP:Bool,
		callback:cpp.Callable<(event:cpp.ConstCharStar, value:cpp.ConstCharStar) -> Void>):Void;

	@:native('Admob_ShowBanner')
	@:noCompletion
	extern private static function showBannerAdmob(adUnitID:cpp.ConstCharStar, size:Int, align:Int):Void;

	@:native('Admob_HideBanner')
	@:noCompletion
	extern private static function hideBannerAdmob():Void;

	@:native('Admob_LoadInterstitial')
	@:noCompletion
	extern private static function loadInterstitialAdmob(adUnitID:cpp.ConstCharStar):Void;

	@:native('Admob_ShowInterstitial')
	@:noCompletion
	extern private static function showInterstitialAdmob():Void;

	@:native('Admob_LoadRewarded')
	@:noCompletion
	extern private static function loadRewardedAdmob(adUnitID:cpp.ConstCharStar):Void;

	@:native('Admob_ShowRewarded')
	@:noCompletion
	extern private static function showRewardedAdmob():Void;

	@:native('Admob_LoadAppOpen')
	@:noCompletion
	extern private static function loadAppOpenAdmob(adUnitID:cpp.ConstCharStar):Void;

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
