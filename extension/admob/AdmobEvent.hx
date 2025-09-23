package extension.admob;

/**
 * Enum representing various AdMob event types.
 * The enum values represent different stages or outcomes of
 * initializing and interacting with AdMob ads, including banner, interstitial, rewarded, and app open ads.
 */
class AdmobEvent
{
	/**
	 * Regular expression used to match AdMob failure event messages.
	 * Captures the error code as the first group and the error description as the second group.
	 * Example matched string: "Code: 3, Description: Network error"
	 */
	@:noCompletion
	private static var FAILED_EVENT_REGEX:EReg = ~/Code: (\d+), Description: (.+)/;

	/**
	 * Regular expression used to match AdMob failurepreload event messages.
	 * Captures the preload ID as the first group, the error code as the second group, and the description as the third group.
	 * Example matched string: "Preload ID: abc123, Code: 3, Description: Network error"
	 */
	@:noCompletion
	private static var PRELOAD_EVENT_REGEX:EReg = ~/Preload ID: (.+?), Code: (\d+), Description: (.+)/;

	/**
	 * Regular expression used to match reward event string.
	 * Captures the reward type as a word and the amount as a number.
	 * Example match: "Type: coins, Amount: 100"
	 */
	@:noCompletion
	private static var REWARD_EVENT_REGEX:EReg = ~/Type: (.+?), Amount: (\d+)/;

	/**
	 * Event triggered when AdMob is initialized successfully.
	 * 
	 * Ads can be requested after this event.
	 */
	public static inline final INIT_OK:String = 'INIT_OK';

	/**
	 * Event triggered when there is an issue with the GDPR consent form.
	 * 
	 * AdMob is initialized anyway, but its usage is at your own risk.
	 */
	public static inline final CONSENT_FAIL:String = 'CONSENT_FAIL';

	/**
	 * Event triggered when the GDPR consent form is successfully completed.
	 */
	public static inline final CONSENT_SUCCESS:String = 'CONSENT_SUCCESS';

	/**
	 * Event triggered when GDPR consent is not required for the user.
	 */
	public static inline final CONSENT_NOT_REQUIRED:String = 'CONSENT_NOT_REQUIRED';

	/**
	 * Event triggered for the App Tracking Transparency (ATT) status on iOS.
	 */
	public static inline final ATT_STATUS:String = 'ATT_STATUS';

	/**
	 * Event constant indicating that the AVM (Audio Video Manager) is about to play audio.
	 */
	public static inline final AVM_WILL_PLAY_AUDIO:String = 'AVM_WILL_PLAY_AUDIO';

	/**
	 * Event constant indicating that the AVM (Audio Video Manager) has stopped playing audio.
	 */
	public static inline final AVM_DID_STOP_PLAYING_AUDIO:String = 'AVM_DID_STOP_PLAYING_AUDIO';

	/**
	 * Event triggered when a banner ad is successfully loaded.
	 */
	public static inline final BANNER_LOADED:String = 'BANNER_LOADED';

	/**
	 * Event triggered when a banner ad fails to load.
	 */
	public static inline final BANNER_FAILED_TO_LOAD:String = 'BANNER_FAILED_TO_LOAD';

	/**
	 * Event triggered when a banner ad is opened.
	 */
	public static inline final BANNER_OPENED:String = 'BANNER_OPENED';

	/**
	 * Event triggered when a banner ad is clicked.
	 */
	public static inline final BANNER_CLICKED:String = 'BANNER_CLICKED';

	/**
	 * Event triggered when a banner ad is closed.
	 */
	public static inline final BANNER_CLOSED:String = 'BANNER_CLOSED';

	/**
	 * Event dispatched when an interstitial ad has been successfully preloaded.
	 */
	public static inline final INTERSTITIAL_PRELOADER_PRELOADED:String = 'INTERSTITIAL_PRELOADER_PRELOADED';

	/**
	 * Event dispatched when the interstitial ad preloader has exhausted its available ads.
	 */
	public static inline final INTERSTITIAL_PRELOADER_EXHAUSTED:String = 'INTERSTITIAL_PRELOADER_EXHAUSTED';

	/**
	 * Event dispatched when the interstitial ad preloader fails to preload an ad.
	 */
	public static inline final INTERSTITIAL_PRELOADER_FAILED_TO_PRELOAD:String = 'INTERSTITIAL_PRELOADER_FAILED_TO_PRELOAD';

	/**
	 * Event triggered when an interstitial ad is successfully loaded.
	 */
	public static inline final INTERSTITIAL_LOADED:String = 'INTERSTITIAL_LOADED';

	/**
	 * Event triggered when an interstitial ad fails to load.
	 */
	public static inline final INTERSTITIAL_FAILED_TO_LOAD:String = 'INTERSTITIAL_FAILED_TO_LOAD';

	/**
	 * Event triggered when an interstitial ad fails to show.
	 */
	public static inline final INTERSTITIAL_FAILED_TO_SHOW:String = 'INTERSTITIAL_FAILED_TO_SHOW';

	/**
	 * Event triggered when an interstitial ad is shown.
	 */
	public static inline final INTERSTITIAL_SHOWED:String = 'INTERSTITIAL_SHOWED';

	/**
	 * Event triggered when an interstitial ad is clicked.
	 */
	public static inline final INTERSTITIAL_CLICKED:String = 'INTERSTITIAL_CLICKED';

	/**
	 * Event triggered when an interstitial ad is dismissed.
	 */
	public static inline final INTERSTITIAL_DISMISSED:String = 'INTERSTITIAL_DISMISSED';

	/**
	 * Event dispatched when a rewarded ad has been successfully preloaded.
	 */
	public static inline final REWARDED_PRELOADER_PRELOADED:String = "REWARDED_PRELOADER_PRELOADED";

	/**
	 * Event dispatched when the rewarded ad preloader has exhausted its available ads.
	 */
	public static inline final REWARDED_PRELOADER_EXHAUSTED:String = "REWARDED_PRELOADER_EXHAUSTED";

	/**
	 * Event dispatched when the rewarded ad preloader fails to preload an ad.
	 */
	public static inline final REWARDED_PRELOADER_FAILED_TO_PRELOAD:String = "REWARDED_PRELOADER_FAILED_TO_PRELOAD";

	/**
	 * Event triggered when a rewarded ad is successfully loaded.
	 */
	public static inline final REWARDED_LOADED:String = 'REWARDED_LOADED';

	/**
	 * Event triggered when a rewarded ad fails to load.
	 */
	public static inline final REWARDED_FAILED_TO_LOAD:String = 'REWARDED_FAILED_TO_LOAD';

	/**
	 * Event triggered when a rewarded ad fails to show.
	 */
	public static inline final REWARDED_FAILED_TO_SHOW:String = 'REWARDED_FAILED_TO_SHOW';

	/**
	 * Event triggered when a rewarded ad is shown.
	 */
	public static inline final REWARDED_SHOWED:String = 'REWARDED_SHOWED';

	/**
	 * Event triggered when a reward is earned from a rewarded ad.
	 */
	public static inline final REWARDED_EARNED:String = 'REWARDED_EARNED';

	/**
	 * Event triggered when a rewarded ad is clicked.
	 */
	public static inline final REWARDED_CLICKED:String = 'REWARDED_CLICKED';

	/**
	 * Event triggered when a rewarded ad is dismissed.
	 */
	public static inline final REWARDED_DISMISSED:String = 'REWARDED_DISMISSED';

	/**
	 * Event dispatched when an app open ad has been successfully preloaded.
	 */
	public static inline final APP_OPEN_PRELOADER_PRELOADED:String = "APP_OPEN_PRELOADER_PRELOADED";

	/**
	 * Event dispatched when the app open ad preloader has exhausted its available ads.
	 */
	public static inline final APP_OPEN_PRELOADER_EXHAUSTED:String = "APP_OPEN_PRELOADER_EXHAUSTED";

	/**
	 * Event dispatched when the app open ad preloader fails to preload an ad.
	 */
	public static inline final APP_OPEN_PRELOADER_FAILED_TO_PRELOAD:String = "APP_OPEN_PRELOADER_FAILED_TO_PRELOAD";

	/**
	 * Event triggered when an app open ad is successfully loaded.
	 */
	public static inline final APP_OPEN_LOADED:String = 'APP_OPEN_LOADED';

	/**
	 * Event triggered when an app open ad fails to load.
	 */
	public static inline final APP_OPEN_FAILED_TO_LOAD:String = 'APP_OPEN_FAILED_TO_LOAD';

	/**
	 * Event triggered when an app open ad fails to show.
	 */
	public static inline final APP_OPEN_FAILED_TO_SHOW:String = 'APP_OPEN_FAILED_TO_SHOW';

	/**
	 * Event triggered when an app open ad is shown.
	 */
	public static inline final APP_OPEN_SHOWED:String = 'APP_OPEN_SHOWED';

	/**
	 * Event triggered when an app open ad is clicked.
	 */
	public static inline final APP_OPEN_CLICKED:String = 'APP_OPEN_CLICKED';

	/**
	 * Event triggered when an app open ad is dismissed.
	 */
	public static inline final APP_OPEN_DISMISSED:String = 'APP_OPEN_DISMISSED';

	/**
	 * Event triggered when the Ad Inspector is closed.
	 */
	public static inline final AD_INSPECTOR_CLOSED:String = 'AD_INSPECTOR_CLOSED';

	/**
	 * The name of the AdMob event.
	 */
	public var name:String;

	/**
	 * The error code associated with the event, if any.
	 */
	public var errorCode:Null<Int>;

	/**
	 * The error description associated with the event, if any.
	 */
	public var errorDescription:Null<String>;

	/**
	 * Identifier for the preloaded ad, if any.
	 */
	public var preloadID:Null<String>;

	/**
	 * The reward type associated with the event, if any.
	 */
	public var rewardType:Null<String>;

	/**
	 * The reward amount associated with the event, if any.
	 */
	public var rewardAmount:Null<Int>;

	/**
	 * The value associated with the event.
	 */
	public var value:Null<String>;

	@:noCompletion
	private function new(name:String, value:String):Void
	{
		this.name = name;

		if (FAILED_EVENT_REGEX.match(value))
		{
			this.errorCode = Std.parseInt(FAILED_EVENT_REGEX.matched(1));
			this.errorDescription = FAILED_EVENT_REGEX.matched(2);
		}
		else if (PRELOAD_EVENT_REGEX.match(value))
		{
			this.preloadID = FAILED_EVENT_REGEX.matched(1);
			this.errorCode = Std.parseInt(FAILED_EVENT_REGEX.matched(2));
			this.errorDescription = FAILED_EVENT_REGEX.matched(3);
		}
		else if (REWARD_EVENT_REGEX.match(value))
		{
			this.rewardType = REWARD_EVENT_REGEX.matched(1);
			this.rewardAmount = Std.parseInt(REWARD_EVENT_REGEX.matched(2));
		}
		else if (value.length > 0)
			this.value = value;
	}

	/**
	 * Returns a string representation of the `AdmobEvent`, including any associated data.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = ['AdmobEvent<$name>'];

		if (preloadID != null)
			parts.push('preloadID=$preloadID');

		if (errorCode != null || errorDescription != null)
			parts.push('error(code=$errorCode, description=$errorDescription)');

		if (rewardType != null || rewardAmount != null)
			parts.push('reward(type=$rewardType, amount=$rewardAmount)');

		if (value != null)
			parts.push('value=$value');

		return parts.join(', ');
	}

	/**
	 * Creates a new `AdmobEvent` instance from the given event name and value.
	 * 
	 * @param name The name of the event.
	 * @param value The value associated with the event.
	 * @return A new `AdmobEvent` object initialized with the specified name and value.
	 */
	public static function fromEvent(name:String, value:String):AdmobEvent
	{
		return new AdmobEvent(name, value);
	}
}
