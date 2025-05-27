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
	public static inline final INIT_OK = 'INIT_OK';

	/**
	 * Event triggered when there is an issue with the GDPR consent form.
	 * 
	 * AdMob is initialized anyway, but its usage is at your own risk.
	 */
	public static inline final CONSENT_FAIL = 'CONSENT_FAIL';

	/**
	 * Event triggered when the GDPR consent form is successfully completed.
	 */
	public static inline final CONSENT_SUCCESS = 'CONSENT_SUCCESS';

	/**
	 * Event triggered when GDPR consent is not required for the user.
	 */
	public static inline final CONSENT_NOT_REQUIRED = 'CONSENT_NOT_REQUIRED';

	#if ios
	/**
	 * Event triggered for the App Tracking Transparency (ATT) status on iOS.
	 */
	public static inline final ATT_STATUS = 'ATT_STATUS';

	/**
	 * Event constant indicating that the AVM (Audio Video Manager) is about to play audio.
	 */
	public static inline final AVM_WILL_PLAY_AUDIO = 'AVM_WILL_PLAY_AUDIO';

	/**
	 * Event constant indicating that the AVM (Audio Video Manager) has stopped playing audio.
	 */
	public static inline final AVM_DID_STOP_PLAYING_AUDIO = 'AVM_DID_STOP_PLAYING_AUDIO';
	#end

	/**
	 * Event triggered when a banner ad is successfully loaded.
	 */
	public static inline final BANNER_LOADED = 'BANNER_LOADED';

	/**
	 * Event triggered when a banner ad fails to load.
	 */
	public static inline final BANNER_FAILED_TO_LOAD = 'BANNER_FAILED_TO_LOAD';

	/**
	 * Event triggered when a banner ad is opened.
	 */
	public static inline final BANNER_OPENED = 'BANNER_OPENED';

	/**
	 * Event triggered when a banner ad is clicked.
	 */
	public static inline final BANNER_CLICKED = 'BANNER_CLICKED';

	/**
	 * Event triggered when a banner ad is closed.
	 */
	public static inline final BANNER_CLOSED = 'BANNER_CLOSED';

	/**
	 * Event triggered when an interstitial ad is successfully loaded.
	 */
	public static inline final INTERSTITIAL_LOADED = 'INTERSTITIAL_LOADED';

	/**
	 * Event triggered when an interstitial ad fails to load.
	 */
	public static inline final INTERSTITIAL_FAILED_TO_LOAD = 'INTERSTITIAL_FAILED_TO_LOAD';

	/**
	 * Event triggered when an interstitial ad fails to show.
	 */
	public static inline final INTERSTITIAL_FAILED_TO_SHOW = 'INTERSTITIAL_FAILED_TO_SHOW';

	/**
	 * Event triggered when an interstitial ad is shown.
	 */
	public static inline final INTERSTITIAL_SHOWED = 'INTERSTITIAL_SHOWED';

	/**
	 * Event triggered when an interstitial ad is clicked.
	 */
	public static inline final INTERSTITIAL_CLICKED = 'INTERSTITIAL_CLICKED';

	/**
	 * Event triggered when an interstitial ad is dismissed.
	 */
	public static inline final INTERSTITIAL_DISMISSED = 'INTERSTITIAL_DISMISSED';

	/**
	 * Event triggered when a rewarded ad is successfully loaded.
	 */
	public static inline final REWARDED_LOADED = 'REWARDED_LOADED';

	/**
	 * Event triggered when a rewarded ad fails to load.
	 */
	public static inline final REWARDED_FAILED_TO_LOAD = 'REWARDED_FAILED_TO_LOAD';

	/**
	 * Event triggered when a rewarded ad fails to show.
	 */
	public static inline final REWARDED_FAILED_TO_SHOW = 'REWARDED_FAILED_TO_SHOW';

	/**
	 * Event triggered when a rewarded ad is shown.
	 */
	public static inline final REWARDED_SHOWED = 'REWARDED_SHOWED';

	/**
	 * Event triggered when a reward is earned from a rewarded ad.
	 */
	public static inline final REWARDED_EARNED = 'REWARDED_EARNED';

	/**
	 * Event triggered when a rewarded ad is clicked.
	 */
	public static inline final REWARDED_CLICKED = 'REWARDED_CLICKED';

	/**
	 * Event triggered when a rewarded ad is dismissed.
	 */
	public static inline final REWARDED_DISMISSED = 'REWARDED_DISMISSED';

	/**
	 * Event triggered when an app open ad is successfully loaded.
	 */
	public static inline final APP_OPEN_LOADED = 'APP_OPEN_LOADED';

	/**
	 * Event triggered when an app open ad fails to load.
	 */
	public static inline final APP_OPEN_FAILED_TO_LOAD = 'APP_OPEN_FAILED_TO_LOAD';

	/**
	 * Event triggered when an app open ad fails to show.
	 */
	public static inline final APP_OPEN_FAILED_TO_SHOW = 'APP_OPEN_FAILED_TO_SHOW';

	/**
	 * Event triggered when an app open ad is shown.
	 */
	public static inline final APP_OPEN_SHOWED = 'APP_OPEN_SHOWED';

	/**
	 * Event triggered when an app open ad is clicked.
	 */
	public static inline final APP_OPEN_CLICKED = 'APP_OPEN_CLICKED';

	/**
	 * Event triggered when an app open ad is dismissed.
	 */
	public static inline final APP_OPEN_DISMISSED = 'APP_OPEN_DISMISSED';

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
		else if (REWARD_EVENT_REGEX.match(value))
		{
			this.rewardType = REWARD_EVENT_REGEX.matched(1);
			this.rewardAmount = Std.parseInt(REWARD_EVENT_REGEX.matched(2));
		}
		else if (value.length > 0)
			this.value = value;
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
