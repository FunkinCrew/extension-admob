package extension.admob;

/**
 * Enum representing the different alignments for AdMob banner ads.
 */
enum abstract AdmobBannerAlign(Int) from Int to Int
{
	/**
	 * Anchor the banner to the top-left of the screen.
	 */
	final TOP_LEFT = 0;

	/**
	 * Anchor the banner to the top-center of the screen.
	 */
	final TOP_CENTER = 1;

	/**
	 * Anchor the banner to the top-right of the screen.
	 */
	final TOP_RIGHT = 2;

	/**
	 * Anchor the banner to the center-left of the screen.
	 */
	final CENTER_LEFT = 3;

	/**
	 * Anchor the banner to the center of the screen.
	 */
	final CENTER = 4;

	/**
	 * Anchor the banner to the center-right of the screen.
	 */
	final CENTER_RIGHT = 5;

	/**
	 * Anchor the banner to the bottom-left of the screen.
	 */
	final BOTTOM_LEFT = 6;

	/**
	 * Anchor the banner to the bottom-center of the screen.
	 */
	final BOTTOM_CENTER = 7;

	/**
	 * Anchor the banner to the bottom-right of the screen.
	 */
	final BOTTOM_RIGHT = 8;
}
