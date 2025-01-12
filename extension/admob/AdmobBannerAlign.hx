package extension.admob;

/**
 * Enum representing the different alignments for AdMob banner ads.
 * The values in this enum are based on Android's `Gravity` constants, but can be customized for Android if more flexibility is required.
 *
 * For Android, the alignment values combine `BOTTOM` or `TOP` with `CENTER_HORIZONTAL`.
 * For iOS, the alignment is represented with simpler integer values.
 *
 * Constants are taken from:
 * @see https://developer.android.com/reference/android/view/Gravity
 */
enum abstract AdmobBannerAlign(Int) from Int to Int
{
	#if android
	/**
	 * Align the banner to the bottom of the screen with horizontal centering.
	 */
	final BOTTOM = 0x00000050 | 0x00000001;

	/**
	 * Align the banner to the top of the screen with horizontal centering.
	 */
	final TOP = 0x00000030 | 0x00000001;
	#elseif ios
	/**
	 * Align the banner to the bottom of the screen.
	 */
	final BOTTOM = 0;

	/**
	 * Align the banner to the top of the screen.
	 */
	final TOP = 1;
	#end
}
