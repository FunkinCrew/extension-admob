package extension.admob;

/**
 * Enum representing the different alignments for AdMob banner ads.
 */
enum abstract AdmobBannerAlign(Int) from Int to Int
{
	/**
	 * Represents the alignment constant for positioning an AdMob banner at the top-left corner of the screen.
	 */
	final TOP_LEFT = 0;

	/**
	 * Represents the alignment constant for positioning an AdMob banner at the top-center of the screen.
	 */
	final TOP_CENTER = 1;

	/**
	 * Represents the alignment constant for positioning an AdMob banner at the top-right corner.
	 */
	final TOP_RIGHT = 2;

	/**
	 * Represents the alignment constant for positioning an AdMob banner at the bottom left of the screen.
	 */
	final BOTTOM_LEFT = 3;

	/**
	 * Represents the alignment constant for positioning an AdMob banner at the bottom-center of the screen.
	 */
	final BOTTOM_CENTER = 4;

	/**
	 * Represents the alignment constant for positioning an AdMob banner at the bottom-right corner of the screen.
	 */
	final BOTTOM_RIGHT = 5;
}
