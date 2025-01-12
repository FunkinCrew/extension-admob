package extension.admob;

/**
 * Enum representing the different banner sizes supported by AdMob.
 * The values in this enum correspond to the standard banner sizes that can be used for displaying ads.
 * These sizes are compatible with the AdMob platform and may be used for various ad placements in your application.
 */
enum abstract AdmobBannerSize(Int) from Int to Int
{
	/**
	 * Anchored adaptive banner size.
	 * A replacement for SMART_BANNER, where the banner width is set to fullscreen width.
	 * This may not work well in landscape orientation.
	 */
	final ADAPTIVE = 0;

	/**
	 * Standard banner size: 320x50.
	 * Common size for banner ads on mobile devices.
	 */
	final BANNER = 1;

	/**
	 * Full banner size: 468x60.
	 * Larger than the standard banner size, providing more space for ads.
	 */
	final FULL_BANNER = 2;

	/**
	 * Large banner size: 320x100.
	 * A larger banner size, often used for more prominent ad displays.
	 */
	final LARGE_BANNER = 3;

	/**
	 * Leaderboard banner size: 728x90.
	 * A wide banner typically displayed at the top of the screen.
	 */
	final LEADERBOARD = 4;

	/**
	 * Medium rectangle banner size: 300x250.
	 * A common banner size used for both mobile and desktop.
	 */
	final MEDIUM_RECTANGLE = 5;

	/**
	 * Fluid banner size.
	 * A dynamically sized banner that matches its parent's width and adjusts its height
	 * to match the ad's content after loading completes.
	 */
	final FLUID = 6;
}
