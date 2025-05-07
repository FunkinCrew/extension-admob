#include "admob.hpp"

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CommonCrypto/CommonDigest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <UnityAds/UnityAds.h>
#import <UnityAdapter/UnityAdapter.h>

static AdmobCallback admobCallback = nullptr;
static GADBannerView *bannerView = nil;
static int currentAlign = 0;

static void dispatchCallback(const char *event, const char *value)
{
	if (admobCallback)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			admobCallback(event, value);
		});
	}
}

static void alignBanner(GADBannerView *bannerView, int align)
{
	if (!bannerView)
		return;

	CGRect screenBounds = UIScreen.mainScreen.bounds;

	CGFloat bannerWidth = bannerView.bounds.size.width;
	CGFloat bannerHeight = bannerView.bounds.size.height;

	switch (align)
	{
	case 0:
		bannerView.center = CGPointMake(bannerWidth / 2, bannerHeight / 2);
		break;
	case 1:
		bannerView.center = CGPointMake(screenBounds.size.width / 2, bannerHeight / 2);
		break;
	case 2:
		bannerView.center = CGPointMake(screenBounds.size.width - bannerWidth / 2, bannerHeight / 2);
		break;
	case 3:
		bannerView.center = CGPointMake(bannerWidth / 2, screenBounds.size.height - bannerHeight / 2);
		break;
	case 4:
		bannerView.center = CGPointMake(screenBounds.size.width / 2, screenBounds.size.height - bannerHeight / 2);
		break;
	case 5:
		bannerView.center = CGPointMake(screenBounds.size.width - bannerWidth / 2, screenBounds.size.height - bannerHeight / 2);
		break;
	case 6:
		bannerView.center = CGPointMake(screenBounds.size.width / 2, screenBounds.size.height / 2);
		break;
	}
}

@interface BannerHelper : NSObject
+ (void)handleOrientationChange;
@end

@implementation BannerHelper
+ (void)handleOrientationChange
{
	if (bannerView)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
  			alignBanner(bannerView, currentAlign);
		});
	}
}
@end

@interface BannerViewDelegate : NSObject <GADBannerViewDelegate>
@end

@implementation BannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
	dispatchCallback("BANNER_LOADED", "");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
	if (admobCallback)
	{
		char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

		dispatch_async(dispatch_get_main_queue(), ^{
			admobCallback("BANNER_FAILED_TO_LOAD", value);

			free(value);
		});
	}
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView
{
	dispatchCallback("BANNER_CLICKED", "");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
	dispatchCallback("BANNER_OPENED", "");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView
{
	dispatchCallback("BANNER_CLOSED", "");
}

@end

@interface InterstitialDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *_ad;

- (void)loadWithAdUnitID:(const char *)adUnitID;
- (void)show;

@end

@implementation InterstitialDelegate

- (void)loadWithAdUnitID:(const char *)adUnitID
{
	self._ad = nil;

	[GADInterstitialAd loadWithAdUnitID:[NSString stringWithUTF8String:adUnitID] request:[GADRequest request] completionHandler:^(GADInterstitialAd *ad, NSError *error)
	{
		if (error)
		{
			if (admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("INTERSTITIAL_FAILED_TO_LOAD", value);

					free(value);
				});
			}
		}
		else
		{
			self._ad = ad;

			self._ad.fullScreenContentDelegate = self;

			dispatchCallback("INTERSTITIAL_LOADED", "");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController]];

		dispatchCallback("INTERSTITIAL_SHOWED", "");
	}
	else
		dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", "Interstitial ad not ready.");
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("INTERSTITIAL_CLICKED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("INTERSTITIAL_DISMISSED", "");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
	{
		char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

		dispatch_async(dispatch_get_main_queue(), ^{
			admobCallback("INTERSTITIAL_FAILED_TO_SHOW", value);

			free(value);
		});
	}
}

@end

@interface RewardedDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADRewardedAd *_ad;

- (void)loadWithAdUnitID:(const char *)adUnitID;
- (void)show;

@end

@implementation RewardedDelegate

- (void)loadWithAdUnitID:(const char *)adUnitID
{
	self._ad = nil;

	[GADRewardedAd loadWithAdUnitID:[NSString stringWithUTF8String:adUnitID] request:[GADRequest request] completionHandler:^(GADRewardedAd *ad, NSError *error)
	{
		if (error)
		{
			if (admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("REWARDED_FAILED_TO_LOAD", value);

					free(value);
				});
			}
		}
		else
		{
			self._ad = ad;

			self._ad.fullScreenContentDelegate = self;

			dispatchCallback("REWARDED_LOADED", "");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] userDidEarnRewardHandler:^{
			if (admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"%@:%d", self._ad.adReward.type, self._ad.adReward.amount.intValue] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("REWARDED_EARNED", value);

					free(value);
				});
			}
		}];

		dispatchCallback("REWARDED_SHOWED", "");
	}
	else
		dispatchCallback("REWARDED_FAILED_TO_SHOW", "Rewarded ad not ready.");
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("REWARDED_CLICKED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("REWARDED_DISMISSED", "");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
	{
		char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

		dispatch_async(dispatch_get_main_queue(), ^{
			admobCallback("REWARDED_FAILED_TO_SHOW", value);

			free(value);
		});
	}
}

@end

@interface AppOpenAdDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADAppOpenAd *_ad;

- (void)loadWithAdUnitID:(const char *)adUnitID;
- (void)show;

@end

@implementation AppOpenAdDelegate

- (void)loadWithAdUnitID:(const char *)adUnitID
{
	self._ad = nil;

	[GADAppOpenAd loadWithAdUnitID:[NSString stringWithUTF8String:adUnitID] request:[GADRequest request] completionHandler:^(GADAppOpenAd *ad, NSError *error)
	{
		if (error)
		{
			if (admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("APP_OPEN_FAILED_TO_LOAD", value);

					free(value);
				});
			}
		}
		else
		{
			self._ad = ad;
			self._ad.fullScreenContentDelegate = self;

			dispatchCallback("APP_OPEN_LOADED", "");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController]];

		dispatchCallback("APP_OPEN_SHOWED", "");
	}
	else
		dispatchCallback("APP_OPEN_FAILED_TO_SHOW", "App Open ad not ready.");
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("APP_OPEN_CLICKED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("APP_OPEN_DISMISSED", "");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
	{
		char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

		dispatch_async(dispatch_get_main_queue(), ^{
			admobCallback("APP_OPEN_FAILED_TO_SHOW", value);

			free(value);
		});
	}
}

@end

static BannerViewDelegate *bannerDelegate = nil;
static InterstitialDelegate *interstitialDelegate = nil;
static RewardedDelegate *rewardedDelegate = nil;
static AppOpenAdDelegate *appOpenDelegate = nil;

void Admob_ConfigureConsentMetadata(bool gdprConsent, bool ccpaConsent)
{
	UADSMetaData *gdprMetaData = [[UADSMetaData alloc] init];
	[gdprMetaData set:@"gdpr.consent" value:gdprConsent ? @YES : @NO];
	[gdprMetaData commit];

	UADSMetaData *ccpaMetaData = [[UADSMetaData alloc] init];
	[ccpaMetaData set:@"privacy.consent" value:ccpaConsent ? @YES : @NO];
	[ccpaMetaData commit];
}

static void initMobileAds(bool testingAds, bool childDirected, bool enableRDP)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (testingAds)
		{
			GADMediationAdapterUnity.testMode = @YES;

			NSString *UDIDString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
			const char *cStr = [UDIDString UTF8String];
			unsigned char digest[16];
			CC_MD5(cStr, strlen(cStr), digest);

			NSMutableString *deviceId = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

			for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
				[deviceId appendFormat:@"%02x", digest[i]];

			GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ deviceId ];
		}

		if (childDirected)
			GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = @YES;

		if (enableRDP)
			[NSUserDefaults.standardUserDefaults setBool:YES forKey:@"gad_rdp"];

		if (@available(iOS 14.0, *))
		{
			int purpose = Admob_GetTCFConsentForPurpose(0);

			if (purpose == 1 || purpose == -1)
			{
				[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status)
				{
					switch (status)
					{
					case ATTrackingManagerAuthorizationStatusNotDetermined:
						dispatchCallback("ATT_STATUS", "NOT_DETERMINED");
						break;
					case ATTrackingManagerAuthorizationStatusRestricted:
						dispatchCallback("ATT_STATUS", "RESTRICTED");
						break;
					case ATTrackingManagerAuthorizationStatusDenied:
						dispatchCallback("ATT_STATUS", "DENIED");
						break;
					case ATTrackingManagerAuthorizationStatusAuthorized:
						dispatchCallback("ATT_STATUS", "AUTHORIZED");
						break;
					}

					dispatch_async(dispatch_get_main_queue(), ^{
						[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
						{
							if (admobCallback)
							{
								char *value = strdup([[NSString stringWithFormat:@"%zd.%zd.%zd", GADMobileAds.sharedInstance.versionNumber.majorVersion, GADMobileAds.sharedInstance.versionNumber.minorVersion, GADMobileAds.sharedInstance.versionNumber.patchVersion] UTF8String]);

								dispatch_async(dispatch_get_main_queue(), ^{
									admobCallback("INIT_OK", value);

									free(value);
								});
							}
						}];
					});
				}];
			}
			else
			{
				[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
				{
					if (admobCallback)
					{
						char *value = strdup([[NSString stringWithFormat:@"%zd.%zd.%zd", GADMobileAds.sharedInstance.versionNumber.majorVersion, GADMobileAds.sharedInstance.versionNumber.minorVersion, GADMobileAds.sharedInstance.versionNumber.patchVersion] UTF8String]);

						dispatch_async(dispatch_get_main_queue(), ^{
							admobCallback("INIT_OK", value);

							free(value);
						});
					}
				}];
			}
		}
		else
		{
			[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
			{
				if (admobCallback)
				{
					char *value = strdup([[NSString stringWithFormat:@"%zd.%zd.%zd", GADMobileAds.sharedInstance.versionNumber.majorVersion, GADMobileAds.sharedInstance.versionNumber.minorVersion, GADMobileAds.sharedInstance.versionNumber.patchVersion] UTF8String]);

					dispatch_async(dispatch_get_main_queue(), ^{
						admobCallback("INIT_OK", value);

						free(value);
					});
				}
			}];
		}
	});
}

void Admob_Init(bool testingAds, bool childDirected, bool enableRDP, AdmobCallback callback)
{
	admobCallback = callback;

	UMPRequestParameters *params = [[UMPRequestParameters alloc] init];

	params.tagForUnderAgeOfConsent = childDirected;

	[UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:params completionHandler:^(NSError *_Nullable error)
	{
		if (error)
		{
			if (admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("CONSENT_FAIL", value);

					free(value);
				});
			}

			initMobileAds(testingAds, childDirected, enableRDP);
		}
		else
		{
			if (UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable && UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatusRequired)
			{
				[UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *_Nullable form, NSError *_Nullable loadError)
				{
					if (loadError)
					{
						if (admobCallback)
						{
							char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", loadError.code, loadError.localizedDescription] UTF8String]);

							dispatch_async(dispatch_get_main_queue(), ^{
								admobCallback("CONSENT_FAIL", value);

								free(value);
							});
						}

						initMobileAds(testingAds, childDirected, enableRDP);
					}
					else
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							[form presentFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable error)
							{
								if (loadError)
								{
									if (admobCallback)
									{
										char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", loadError.code, loadError.localizedDescription] UTF8String]);

										dispatch_async(dispatch_get_main_queue(), ^{
											admobCallback("CONSENT_FAIL", value);

											free(value);
										});
									}
								}
								else
									dispatchCallback("CONSENT_SUCCESS", "Consent form dismissed successfully.");

								initMobileAds(testingAds, childDirected, enableRDP);
							}];
						});
					}
				}];
			}
			else
			{
				dispatchCallback("CONSENT_NOT_REQUIRED", "Consent form not required or available.");

				initMobileAds(testingAds, childDirected, enableRDP);
			}
		}
	}];
}

void Admob_ShowBanner(const char *id, int size, int align)
{
	if (bannerView != nil)
	{
		dispatchCallback("BANNER_FAILED_TO_LOAD", "Hide previous banner first!");
		return;
	}

	currentAlign = align;

	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;

		GADAdSize adSize;

		switch (size)
		{
		case 1:
			adSize = GADAdSizeBanner;
			break;
		case 2:
			adSize = GADAdSizeFullBanner;
			break;
		case 3:
			adSize = GADAdSizeLargeBanner;
			break;
		case 4:
			adSize = GADAdSizeLeaderboard;
			break;
		case 5:
			adSize = GADAdSizeMediumRectangle;
			break;
		case 6:
			adSize = GADAdSizeFluid;
		default:
			CGRect frame = rootVC.view.frame;

			if (@available(iOS 11.0, *))
				frame = UIEdgeInsetsInsetRect(frame, rootVC.view.safeAreaInsets);

			adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.size.width);
			
			break;
		}

		bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
		bannerView.adUnitID = [NSString stringWithUTF8String:id];
		bannerView.rootViewController = rootVC;
		bannerView.backgroundColor = UIColor.clearColor;

		if (bannerDelegate == nil)
			bannerDelegate = [[BannerViewDelegate alloc] init];

		bannerView.delegate = bannerDelegate;

		[rootVC.view addSubview:bannerView];

		{
			alignBanner(bannerView, align);

			[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
			{
				[BannerHelper handleOrientationChange];
			}];
		}

		[bannerView loadRequest:[GADRequest request]];
	});
}

void Admob_HideBanner()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (bannerView != nil)
		{
			[bannerView removeFromSuperview];
			bannerView = nil;
		}
	});
}

void Admob_LoadInterstitial(const char *id)
{
	if (!interstitialDelegate)
		interstitialDelegate = [[InterstitialDelegate alloc] init];

	[interstitialDelegate loadWithAdUnitID:id];
}

void Admob_ShowInterstitial()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (interstitialDelegate)
			[interstitialDelegate show];
		else
			dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", "You need to load interstitial ad first!");
	});
}

void Admob_LoadRewarded(const char *id)
{
	if (!rewardedDelegate)
		rewardedDelegate = [[RewardedDelegate alloc] init];

	[rewardedDelegate loadWithAdUnitID:id];
}

void Admob_ShowRewarded()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (rewardedDelegate)
			[rewardedDelegate show];
		else
			dispatchCallback("REWARDED_FAILED_TO_SHOW", "You need to load rewarded ad first!");
	});
}

void Admob_LoadAppOpen(const char *id)
{
	if (!appOpenDelegate)
		appOpenDelegate = [[AppOpenAdDelegate alloc] init];

	[appOpenDelegate loadWithAdUnitID:id];
}

void Admob_ShowAppOpen()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (appOpenDelegate)
			[appOpenDelegate show];
		else
			dispatchCallback("APP_OPEN_FAILED_TO_SHOW", "You need to load App Open Ad first!");
	});
}

void Admob_SetVolume(float vol)
{
	if (vol > 0)
	{
		GADMobileAds.sharedInstance.applicationVolume = vol;
		GADMobileAds.sharedInstance.applicationMuted = false;
	}
	else
		GADMobileAds.sharedInstance.applicationMuted = true;
}

int Admob_GetTCFConsentForPurpose(int purpose)
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents == nil || purposeConsents.length == 0)
		return -1;

	if (purpose >= purposeConsents.length)
		return -1;

	return [[purposeConsents substringWithRange:NSMakeRange(purpose, 1)] integerValue];
}

char* Admob_GetTCFPurposeConsent(void)
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents.length > 0)
		return strdup([purposeConsents UTF8String]);

	return nullptr;
}

char* Admob_GetIABUSPrivacy(void)
{
	NSString *usPrivacyString = [NSUserDefaults.standardUserDefaults stringForKey:@"IABUSPrivacy_String"];

	if (usPrivacyString.length > 0)
		return strdup([usPrivacyString UTF8String]);

	return nullptr;
}

bool Admob_IsPrivacyOptionsRequired()
{
	return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == UMPPrivacyOptionsRequirementStatusRequired;
}

void Admob_ShowPrivacyOptionsForm()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[UMPConsentForm presentPrivacyOptionsFormFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable formError)
		{
			if (formError && admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"Error Code: %zd, Description: %@", formError.code, formError.localizedDescription] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("CONSENT_FAIL", value);

					free(value);
				});
			}
		}];
	});
}
