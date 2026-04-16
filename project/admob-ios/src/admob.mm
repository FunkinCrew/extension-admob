#include "admob.hpp"

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CommonCrypto/CommonDigest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <UnityAds/UnityAds.h>
#import <UnityAdapter/UnityAdapter.h>
#import <PAGAdSDK/PAGSdk.h>
#import <PangleAdapter/PangleAdapter.h>
#import <VungleAdsSDK/VungleAdsSDK.h>

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
		char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

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

@property(nonatomic, weak) UIViewController *_presentingViewController;
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
				char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

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
	UIViewController *vc = [UIApplication.sharedApplication.keyWindow rootViewController];

	if (self._ad != nil && [self._ad canPresentFromRootViewController:vc error:nil])
	{
		self._presentingViewController = vc;

		[self._ad presentFromRootViewController:vc];
	}
	else
		dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", "Interstitial ad not ready.");
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("INTERSTITIAL_CLICKED", "");
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("INTERSTITIAL_SHOWED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (admobCallback)
			admobCallback("INTERSTITIAL_DISMISSED", "");

		if (@available(iOS 11.0, *))
		{
			if (self._presentingViewController)
				[self._presentingViewController setNeedsUpdateOfHomeIndicatorAutoHidden];
		}
	});
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
	{
		char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

		dispatch_async(dispatch_get_main_queue(), ^{
			admobCallback("INTERSTITIAL_FAILED_TO_SHOW", value);

			free(value);
		});
	}
}

@end

@interface RewardedDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, weak) UIViewController *_presentingViewController;
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
				char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

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
	UIViewController *vc = [UIApplication.sharedApplication.keyWindow rootViewController];

	if (self._ad != nil && [self._ad canPresentFromRootViewController:vc error:nil])
	{
		self._presentingViewController = vc;

		[self._ad presentFromRootViewController:vc userDidEarnRewardHandler:^{
			if (admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"Type: %@, Amount: %d", self._ad.adReward.type, self._ad.adReward.amount.intValue] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("REWARDED_EARNED", value);

					free(value);
				});
			}
		}];
	}
	else
		dispatchCallback("REWARDED_FAILED_TO_SHOW", "Rewarded ad not ready.");
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("REWARDED_CLICKED", "");
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("REWARDED_SHOWED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (admobCallback)
			admobCallback("REWARDED_DISMISSED", "");

		if (@available(iOS 11.0, *))
		{
			if (self._presentingViewController)
				[self._presentingViewController setNeedsUpdateOfHomeIndicatorAutoHidden];
		}
	});
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
	{
		char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

		dispatch_async(dispatch_get_main_queue(), ^{
			admobCallback("REWARDED_FAILED_TO_SHOW", value);

			free(value);
		});
	}
}

@end

@interface AppOpenAdDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, weak) UIViewController *_presentingViewController;
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
				char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

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
	UIViewController *vc = [UIApplication.sharedApplication.keyWindow rootViewController];

	if (self._ad != nil && [self._ad canPresentFromRootViewController:vc error:nil])
	{
		self._presentingViewController = vc;

		[self._ad presentFromRootViewController:vc];
	}
	else
		dispatchCallback("APP_OPEN_FAILED_TO_SHOW", "App Open ad not ready.");
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("APP_OPEN_CLICKED", "");
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("APP_OPEN_SHOWED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (admobCallback)
			admobCallback("APP_OPEN_DISMISSED", "");

		if (@available(iOS 11.0, *))
		{
			if (self._presentingViewController)
				[self._presentingViewController setNeedsUpdateOfHomeIndicatorAutoHidden];
		}
	});
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
	{
		char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

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

static bool getGDPRConsent()
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSString *tcString = [prefs stringForKey:@"IABTCF_TCString"];
    NSString *purposeConsents = [prefs stringForKey:@"IABTCF_PurposeConsents"];

    // TCF exists + Purpose 1 consent required
    return tcString.length > 0 && (purposeConsents.length > 0 && [purposeConsents characterAtIndex:0] == '1');
}

static bool getCCPAConsent()
{
    NSString *usPrivacy = [NSUserDefaults.standardUserDefaults stringForKey:@"IABUSPrivacy_String"];

    // No signal = no opt-out
    if (usPrivacy.length < 3)
        return true;

    // 'Y' = opted out of sale
    return [usPrivacy characterAtIndex:2] != 'Y';
}

static bool getPAConsent()
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSString *tcString = [prefs stringForKey:@"IABTCF_TCString"];
    NSString *usPrivacy = [prefs stringForKey:@"IABUSPrivacy_String"];

    // GDPR takes priority if TCF exists
    if (tcString.length > 0)
        return getGDPRConsent();

    // Otherwise CCPA if available
    if (usPrivacy.length > 0)
        return getCCPAConsent();

    // Default allow (no signal)
    return true;
}

static void configureUnity(bool gdprConsent, bool ccpaConsent)
{
	UADSMetaData *gdprMetaData = [[UADSMetaData alloc] init];
	[gdprMetaData set:@"gdpr.consent" value:gdprConsent ? @YES : @NO];
	[gdprMetaData commit];

	UADSMetaData *ccpaMetaData = [[UADSMetaData alloc] init];
	[ccpaMetaData set:@"privacy.consent" value:ccpaConsent ? @YES : @NO];
	[ccpaMetaData commit];
}

static void configurePangle(bool paConsent)
{
    [GADMediationAdapterPangle setPAConsent:paConsent ? PAGPAConsentTypeConsent : PAGPAConsentTypeNoConsent];
}

static void configureVungle(bool ccpaConsent)
{
	[VunglePrivacySettings setCCPAStatus:ccpaConsent ? @YES : @NO];
}

static void initAdmob()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		bool gdprConsent = getGDPRConsent();
		bool ccpaConsent = getCCPAConsent();
		bool paConsent = getPAConsent();

		configureUnity(gdprConsent, ccpaConsent);
		configurePangle(paConsent);
		configureVungle(ccpaConsent);

		[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
		{
			GADMobileAds.sharedInstance.audioVideoManager.audioSessionIsApplicationManaged = YES;

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
}

static void initMobileAds(bool testingAds, bool childDirected, bool enableRDP)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (testingAds)
		{
			const char *cStr = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] UTF8String];
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
			if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined)
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

					initAdmob();
				}];
			}
			else
			{
				initAdmob();
			}
		}
		else
		{
			initAdmob();
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
				char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

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
							char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", loadError.code, loadError.localizedDescription] UTF8String]);

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
										char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", loadError.code, loadError.localizedDescription] UTF8String]);

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

void Admob_ShowBanner(const char *adUnitID, int size, int align)
{
	if (bannerView != nil)
	{
		dispatchCallback("BANNER_FAILED_TO_LOAD", "Hide previous banner first!");
		return;
	}

	currentAlign = align;

	dispatch_async(dispatch_get_main_queue(), ^{
		UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;

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
			CGRect frame = keyWindow.rootViewController.view.frame;

			if (@available(iOS 11.0, *))
				frame = UIEdgeInsetsInsetRect(frame, keyWindow.rootViewController.view.safeAreaInsets);

			adSize = GADLargeAnchoredAdaptiveBannerAdSizeWithWidth(frame.size.width);

			break;
		}

		bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
		bannerView.adUnitID = [NSString stringWithUTF8String:adUnitID];
		bannerView.translatesAutoresizingMaskIntoConstraints = NO;
		bannerView.rootViewController = keyWindow.rootViewController;
		bannerView.backgroundColor = UIColor.clearColor;

		if (bannerDelegate == nil)
			bannerDelegate = [[BannerViewDelegate alloc] init];

		bannerView.delegate = bannerDelegate;

		[bannerView loadRequest:[GADRequest request]];

		[keyWindow.rootViewController.view addSubview:bannerView];

		switch (align)
		{
		case 0:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.topAnchor constraintEqualToAnchor:keyWindow.topAnchor],
				[bannerView.leadingAnchor constraintEqualToAnchor:keyWindow.leadingAnchor]
			]];
			break;
		case 1:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.topAnchor constraintEqualToAnchor:keyWindow.topAnchor],
				[bannerView.centerXAnchor constraintEqualToAnchor:keyWindow.centerXAnchor]
			]];
			break;
		case 2:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.topAnchor constraintEqualToAnchor:keyWindow.topAnchor],
				[bannerView.trailingAnchor constraintEqualToAnchor:keyWindow.trailingAnchor]
			]];
			break;
		case 3:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.centerYAnchor constraintEqualToAnchor:keyWindow.centerYAnchor],
				[bannerView.leadingAnchor constraintEqualToAnchor:keyWindow.leadingAnchor]
			]];
			break;
		case 4:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.centerXAnchor constraintEqualToAnchor:keyWindow.centerXAnchor],
				[bannerView.centerYAnchor constraintEqualToAnchor:keyWindow.centerYAnchor]
			]];
			break;
		case 5:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.centerYAnchor constraintEqualToAnchor:keyWindow.centerYAnchor],
				[bannerView.trailingAnchor constraintEqualToAnchor:keyWindow.trailingAnchor]
			]];
			break;
		case 6:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.bottomAnchor constraintEqualToAnchor:keyWindow.bottomAnchor],
				[bannerView.leadingAnchor constraintEqualToAnchor:keyWindow.leadingAnchor]
			]];
			break;
		case 7:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.bottomAnchor constraintEqualToAnchor:keyWindow.bottomAnchor],
				[bannerView.centerXAnchor constraintEqualToAnchor:keyWindow.centerXAnchor]
			]];
			break;
		case 8:
			[NSLayoutConstraint activateConstraints:@[
				[bannerView.bottomAnchor constraintEqualToAnchor:keyWindow.bottomAnchor],
				[bannerView.trailingAnchor constraintEqualToAnchor:keyWindow.trailingAnchor]
			]];
			break;
		}
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

void Admob_LoadInterstitial(const char *adUnitID)
{
	if (!interstitialDelegate)
		interstitialDelegate = [[InterstitialDelegate alloc] init];

	[interstitialDelegate loadWithAdUnitID:adUnitID];
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

void Admob_LoadRewarded(const char *adUnitID)
{
	if (!rewardedDelegate)
		rewardedDelegate = [[RewardedDelegate alloc] init];

	[rewardedDelegate loadWithAdUnitID:adUnitID];
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

void Admob_LoadAppOpen(const char *adUnitID)
{
	if (!appOpenDelegate)
		appOpenDelegate = [[AppOpenAdDelegate alloc] init];

	[appOpenDelegate loadWithAdUnitID:adUnitID];
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
				char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", formError.code, formError.localizedDescription] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("CONSENT_FAIL", value);

					free(value);
				});
			}
		}];
	});
}

void Admob_OpenAdInspector()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[GADMobileAds sharedInstance] presentAdInspectorFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *error)
		{
			if (error && admobCallback)
			{
				char *value = strdup([[NSString stringWithFormat:@"Code: %zd, Description: %@", error.code, error.localizedDescription] UTF8String]);

				dispatch_async(dispatch_get_main_queue(), ^{
					admobCallback("AD_INSPECTOR_CLOSED", value);

					free(value);
				});
			}
			else if (admobCallback)
				dispatchCallback("AD_INSPECTOR_CLOSED", "");
		}];
	});
}
