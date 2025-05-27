package org.haxe.extension;

import android.content.Context;
import android.content.SharedPreferences;
import android.provider.Settings;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowMetrics;
import android.widget.RelativeLayout;
import com.google.android.gms.ads.appopen.*;
import com.google.android.gms.ads.initialization.*;
import com.google.android.gms.ads.interstitial.*;
import com.google.android.gms.ads.rewarded.*;
import com.google.android.gms.ads.*;
import com.google.android.ump.*;
import com.unity3d.ads.metadata.MetaData;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

/**
 * @see https://developers.google.com/admob/android/quick-start?hl=en
 */
public class Admob extends Extension
{
	private static AdView adView;
	private static InterstitialAd adInterstitial;
	private static RewardedAd adRewarded;
	private static AppOpenAd adAppOpen;
	private static ConsentInformation consentInformation;
	private static HaxeObject haxeObject;

	public static void configureConsentMetadata(final boolean gdprConsent, final boolean ccpaConsent)
	{
		MetaData gdprMetaData = new MetaData(mainActivity);
		gdprMetaData.set("gdpr.consent", gdprConsent);
		gdprMetaData.commit();

		MetaData ccpaMetaData = new MetaData(mainActivity);
		ccpaMetaData.set("privacy.consent", ccpaConsent);
		ccpaMetaData.commit();
	}

	private static void initMobileAds(final boolean testingAds, final boolean childDirected, final boolean enableRDP)
	{
		RequestConfiguration.Builder configuration = new RequestConfiguration.Builder();

		if (testingAds)
		{
			List<String> testDeviceIds = new ArrayList<>();

			if (Build.FINGERPRINT.startsWith("google/sdk_gphone") || Build.FINGERPRINT.contains("generic") || Build.FINGERPRINT.contains("emulator") || Build.MODEL.contains("Emulator") || Build.MODEL.contains("Android SDK built for x86") || Build.MANUFACTURER.contains("Google") || Build.PRODUCT.contains("sdk_gphone") || Build.BRAND.startsWith("generic") || Build.DEVICE.startsWith("generic"))
				testDeviceIds.add(AdRequest.DEVICE_ID_EMULATOR);

			try
			{
				StringBuilder hexString = new StringBuilder();

				for (byte b : MessageDigest.getInstance("MD5").digest(Settings.Secure.getString(mainActivity.getContentResolver(), Settings.Secure.ANDROID_ID).getBytes()))
					hexString.append(String.format("%02x", b));

				testDeviceIds.add(hexString.toString().toUpperCase());
			}
			catch (NoSuchAlgorithmException e)
			{
				e.printStackTrace();
			}

			configuration.setTestDeviceIds(testDeviceIds);
		}

		if (childDirected)
			configuration.setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE);

		if (enableRDP)
		{
			SharedPreferences.Editor editor = mainActivity.getPreferences(Context.MODE_PRIVATE).edit();
			editor.putInt("gad_rdp", 1);
			editor.commit();
		}

		MobileAds.setRequestConfiguration(configuration.build());

		MobileAds.initialize(mainContext, new OnInitializationCompleteListener()
		{
			@Override
			public void onInitializationComplete(InitializationStatus initializationStatus)
			{
				if (haxeObject != null) 
					haxeObject.call("onEvent", new Object[]{ "INIT_OK", MobileAds.getVersion().toString() });
			}
		});
	}

	public static void init(final boolean testingAds, final boolean childDirected, final boolean enableRDP, HaxeObject callback)
	{
		haxeObject = callback;

		ConsentRequestParameters.Builder params = new ConsentRequestParameters.Builder();

		params.setTagForUnderAgeOfConsent(childDirected);

		consentInformation = UserMessagingPlatform.getConsentInformation(mainContext);

		consentInformation.requestConsentInfoUpdate(mainActivity, params.build(), new ConsentInformation.OnConsentInfoUpdateSuccessListener()
		{
			public void onConsentInfoUpdateSuccess()
			{
				if (consentInformation.isConsentFormAvailable() && consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.REQUIRED)
				{
					UserMessagingPlatform.loadConsentForm(mainActivity, new UserMessagingPlatform.OnConsentFormLoadSuccessListener()
					{
						@Override
						public void onConsentFormLoadSuccess(ConsentForm consentForm)
						{
							mainActivity.runOnUiThread(new Runnable()
							{
								public void run()
								{
									consentForm.show(mainActivity, new ConsentForm.OnConsentFormDismissedListener()
									{
										@Override
										public void onConsentFormDismissed(FormError formError)
										{
											if (formError == null && haxeObject != null)
												haxeObject.call("onEvent", new Object[]{ "CONSENT_SUCCESS", "Consent form dismissed successfully." });
											else if (haxeObject != null)
												haxeObject.call("onEvent", new Object[]{ "CONSENT_FAIL", String.format("Code: %d, Description: %s", formError.getErrorCode(), formError.getMessage()) });

											initMobileAds(testingAds, childDirected, enableRDP);
										}
									});
								}
							});
						}
					}, new UserMessagingPlatform.OnConsentFormLoadFailureListener()
					{
						@Override
						public void onConsentFormLoadFailure(FormError loadError)
						{
							if (haxeObject != null)
								haxeObject.call("onEvent", new Object[]{ "CONSENT_FAIL", String.format("Code: %d, Description: %s", loadError.getErrorCode(), loadError.getMessage()) });

							initMobileAds(testingAds, childDirected, enableRDP);
						}
					});
				}
				else
				{
					if (haxeObject != null)
						haxeObject.call("onEvent", new Object[]{ "CONSENT_NOT_REQUIRED", "Consent form not required or available." });

					initMobileAds(testingAds, childDirected, enableRDP);
				}
			}
		}, new ConsentInformation.OnConsentInfoUpdateFailureListener()
		{
			public void onConsentInfoUpdateFailure(FormError requestError)
			{
				if (haxeObject != null)
					haxeObject.call("onEvent", new Object[]{ "CONSENT_FAIL", String.format("Code: %d, Description: %s", requestError.getErrorCode(), requestError.getMessage()) });

				initMobileAds(testingAds, childDirected, enableRDP);
			}
		});
	}

	public static void showBanner(final String id, final int size, final int align)
	{
		if (adView != null)
		{
			if (haxeObject != null)
				haxeObject.call("onEvent", new Object[] { "BANNER_FAILED_TO_LOAD", "Hide previous banner first!" });

			return;
		}

		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				adView = new AdView(mainActivity);

				adView.setAdUnitId(id);

				switch (size)
				{
					case 1:
						adView.setAdSize(AdSize.BANNER);
						break;
					case 2:
						adView.setAdSize(AdSize.FULL_BANNER);
						break;
					case 3:
						adView.setAdSize(AdSize.LARGE_BANNER);
						break;
					case 4:
						adView.setAdSize(AdSize.LEADERBOARD);
						break;
					case 5:
						adView.setAdSize(AdSize.MEDIUM_RECTANGLE);
						break;
					case 6:
						adView.setAdSize(AdSize.FLUID);
						break;
					default:
						DisplayMetrics displayMetrics = mainContext.getResources().getDisplayMetrics();

						int adWidthPixels = displayMetrics.widthPixels;

						if (Build.VERSION.SDK_INT >= 30)
							adWidthPixels = mainActivity.getWindowManager().getCurrentWindowMetrics().getBounds().width();

						adView.setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(mainContext, (int) (adWidthPixels / displayMetrics.density)));
						break;
				}

				adView.setAdListener(new AdListener()
				{
					@Override
					public void onAdLoaded()
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "BANNER_LOADED", "" });
					}

					@Override
					public void onAdFailedToLoad(LoadAdError adError)
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "BANNER_FAILED_TO_LOAD", String.format("Code: %d, Description: %s", adError.getCode(), adError.getMessage()) });
					}

					@Override
					public void onAdOpened()
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "BANNER_OPENED", "" });
					}

					@Override
					public void onAdClicked()
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "BANNER_CLICKED", "" });
					}

					@Override
					public void onAdClosed()
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "BANNER_CLOSED", "" });
					}
				});

				RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);

				switch (align)
				{
					case 0:
						params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
						params.addRule(RelativeLayout.ALIGN_PARENT_START);
						break;
					case 1:
						params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
						params.addRule(RelativeLayout.CENTER_HORIZONTAL);
						break;
					case 2:
						params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
						params.addRule(RelativeLayout.ALIGN_PARENT_END);
						break;
					case 3:
						params.addRule(RelativeLayout.ALIGN_PARENT_START);
						params.addRule(RelativeLayout.CENTER_VERTICAL);
						break;
					case 4:
						params.addRule(RelativeLayout.CENTER_HORIZONTAL);
						params.addRule(RelativeLayout.CENTER_VERTICAL);
						break;
					case 5:
						params.addRule(RelativeLayout.ALIGN_PARENT_END);
						params.addRule(RelativeLayout.CENTER_VERTICAL);
						break;
					case 6:
						params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
						params.addRule(RelativeLayout.ALIGN_PARENT_START);
						break;
					case 7:
						params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
						params.addRule(RelativeLayout.CENTER_HORIZONTAL);
						break;
					case 8:
						params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
						params.addRule(RelativeLayout.ALIGN_PARENT_END);
						break;
				}

				((RelativeLayout) mainView).addView(adView, params);

				adView.loadAd(new AdRequest.Builder().build());
			}
		});
	}

	public static void hideBanner()
	{
		if (adView != null)
		{
			mainActivity.runOnUiThread(new Runnable()
			{
				public void run()
				{
					if (adView.getParent() != null)
						((ViewGroup) adView.getParent()).removeView(adView);

					adView.destroy();
					adView = null;
				}
			});
		}
	}

	public static void loadInterstitial(final String id, final boolean immersiveModeEnabled)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				InterstitialAd.load(mainContext, id, new AdRequest.Builder().build(), new InterstitialAdLoadCallback()
				{
					@Override
					public void onAdLoaded(InterstitialAd interstitialAd)
					{
						adInterstitial = interstitialAd;
						adInterstitial.setImmersiveMode(immersiveModeEnabled);
						adInterstitial.setFullScreenContentCallback(new FullScreenContentCallback()
						{
							@Override
							public void onAdClicked()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "INTERSTITIAL_CLICKED", "" });
							}
							
							@Override
							public void onAdDismissedFullScreenContent()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "INTERSTITIAL_DISMISSED", "" });
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError)
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "INTERSTITIAL_FAILED_TO_SHOW", String.format("Code: %d, Description: %s", adError.getCode(), adError.getMessage()) });
							}

							@Override
							public void onAdShowedFullScreenContent()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "INTERSTITIAL_SHOWED", "" });

								adInterstitial = null;
							}
						});

						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "INTERSTITIAL_LOADED", "" });
					}

					@Override
					public void onAdFailedToLoad(LoadAdError loadAdError)
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "INTERSTITIAL_FAILED_TO_LOAD", String.format("Code: %d, Description: %s", loadAdError.getCode(), loadAdError.getMessage()) });

						adInterstitial = null;
					}
				});
			}
		});
	}

	public static void showInterstitial()
	{
		if (adInterstitial != null)
		{
			mainActivity.runOnUiThread(new Runnable()
			{
				public void run()
				{
					adInterstitial.show(mainActivity);
				}
			});
		}
		else
		{
			if (haxeObject != null)
				haxeObject.call("onEvent", new Object[] { "INTERSTITIAL_FAILED_TO_SHOW", "You need to load interstitial ad first!" });
		}
	}

	public static void loadRewarded(final String id, final boolean immersiveModeEnabled)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				RewardedAd.load(mainContext, id, new AdRequest.Builder().build(), new RewardedAdLoadCallback()
				{
					@Override
					public void onAdLoaded(RewardedAd rewardedAd)
					{
						adRewarded = rewardedAd;
						adRewarded.setImmersiveMode(immersiveModeEnabled);
						adRewarded.setFullScreenContentCallback(new FullScreenContentCallback()
						{
							@Override
							public void onAdClicked()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "REWARDED_CLICKED", "" });
							}
							
							@Override
							public void onAdDismissedFullScreenContent()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "REWARDED_DISMISSED", "" });
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError)
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "REWARDED_FAILED_TO_SHOW", String.format("Code: %d, Description: %s", adError.getCode(), adError.getMessage()) });
							}

							@Override
							public void onAdShowedFullScreenContent()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "REWARDED_SHOWED", "" });

								adRewarded = null;
							}
						});

						haxeObject.call("onEvent", new Object[] { "REWARDED_LOADED", "" });
					}

					@Override
					public void onAdFailedToLoad(LoadAdError loadAdError)
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "REWARDED_FAILED_TO_LOAD", String.format("Code: %d, Description: %s", loadAdError.getCode(), loadAdError.getMessage()) });

						adRewarded = null;
					}
				});
			}
		});
	}

	public static void showRewarded()
	{
		if (adRewarded != null)
		{
			mainActivity.runOnUiThread(new Runnable()
			{
				public void run()
				{
					adRewarded.show(mainActivity, new OnUserEarnedRewardListener()
					{
						@Override
						public void onUserEarnedReward(RewardItem rewardItem)
						{
							if (haxeObject != null)
								haxeObject.call("onEvent", new Object[] { "REWARDED_EARNED", String.format("Type: %s, Amount: %d", rewardItem.getType(), rewardItem.getAmount())});
						}
					});
				}
			});
		}
		else if (haxeObject != null)
			haxeObject.call("onEvent", new Object[] { "REWARDED_FAILED_TO_SHOW", "You need to load rewarded ad first!" });
	}

	public static void loadAppOpen(final String id, final boolean immersiveModeEnabled)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			@Override
			public void run()
			{
				AppOpenAd.load(mainContext, id, new AdRequest.Builder().build(), new AppOpenAd.AppOpenAdLoadCallback()
				{
					@Override
					public void onAdLoaded(AppOpenAd ad)
					{
						adAppOpen = ad;
						adAppOpen.setImmersiveMode(immersiveModeEnabled);
						adAppOpen.setFullScreenContentCallback(new FullScreenContentCallback()
						{
							@Override
							public void onAdClicked()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[] { "APP_OPEN_CLICKED", "" });
							}
							
							@Override
							public void onAdDismissedFullScreenContent()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[]{ "APP_OPEN_DISMISSED", "" });
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError)
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[]{ "APP_OPEN_FAILED_TO_SHOW", String.format("Code: %d, Description: %s", adError.getCode(), adError.getMessage()) });
							}

							@Override
							public void onAdShowedFullScreenContent()
							{
								if (haxeObject != null)
									haxeObject.call("onEvent", new Object[]{"APP_OPEN_SHOWED", ""});

								adAppOpen = null;
							}
						});

						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[]{ "APP_OPEN_LOADED", "" });
					}

					@Override
					public void onAdFailedToLoad(LoadAdError loadAdError)
					{
						if (haxeObject != null)
							haxeObject.call("onEvent", new Object[]{ "APP_OPEN_FAILED_TO_LOAD", String.format("Code: %d, Description: %s", loadAdError.getCode(), loadAdError.getMessage()) });

						adAppOpen = null;
					}
				});
			}
		});
	}

	public static void showAppOpen()
	{
		if (adAppOpen != null)
			mainActivity.runOnUiThread(() -> adAppOpen.show(mainActivity));
		else if (haxeObject != null)
			haxeObject.call("onEvent", new Object[]{ "APP_OPEN_FAILED_TO_SHOW", "You need to load App Open Ad first!" });
	}

	public static void setVolume(final float vol)
	{
		if (vol > 0)
		{
			MobileAds.setAppMuted(false);
			MobileAds.setAppVolume(vol);
		}
		else
			MobileAds.setAppMuted(true);
	}

	public static int getTCFConsentForPurpose(int purpose)
	{
		String purposeConsents = getTCFPurposeConsent();

		if (purposeConsents.length() > purpose)
			return Character.getNumericValue(purposeConsents.charAt(purpose));

		return -1;
	}

	public static String getTCFPurposeConsent()
	{
		return mainContext.getSharedPreferences(packageName + "_preferences", Context.MODE_PRIVATE).getString("IABTCF_PurposeConsents", "");
	}

	public static String getUSPrivacy()
	{
		return mainContext.getSharedPreferences(packageName + "_preferences", Context.MODE_PRIVATE).getString("IABUSPrivacy_String", "");
	}

	public static boolean isPrivacyOptionsRequired()
	{
		return consentInformation != null && consentInformation.getPrivacyOptionsRequirementStatus() == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED;
	}

	public static void showPrivacyOptionsForm()
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				UserMessagingPlatform.showPrivacyOptionsForm(mainActivity, new ConsentForm.OnConsentFormDismissedListener()
				{
					@Override
					public void onConsentFormDismissed(FormError formError)
					{
						if (formError != null && haxeObject != null)
							haxeObject.call("onEvent", new Object[] { "CONSENT_FAIL", String.format("Code: %d, Description: %s", formError.getErrorCode(), formError.getMessage()) });
					}
				});
			}
		});
	}

	@Override
	public void onPause()
	{
		if (adView != null)
			adView.pause();

		super.onPause();
	}

	@Override
	public void onResume()
	{
		super.onResume();

		if (adView != null)
			adView.resume();
	}

	@Override
	public void onDestroy()
	{
		if (adView != null)
			adView.destroy();

		super.onDestroy();
	}
}
