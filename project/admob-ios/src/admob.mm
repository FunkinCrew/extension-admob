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
static char currentMessage[128] = "";

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
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

	dispatchCallback("BANNER_FAILED_TO_LOAD", currentMessage);
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
			[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

			dispatchCallback("INTERSTITIAL_FAILED_TO_LOAD", currentMessage);
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
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

	dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", currentMessage);
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
			[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

			dispatchCallback("REWARDED_FAILED_TO_LOAD", currentMessage);
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
			[[NSString stringWithFormat:@"%@:%d", self._ad.adReward.type, self._ad.adReward.amount.intValue] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

			dispatchCallback("REWARDED_EARNED", currentMessage);
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
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

	dispatchCallback("REWARDED_FAILED_TO_SHOW", currentMessage);
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
			[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

			dispatchCallback("APP_OPEN_FAILED_TO_LOAD", currentMessage);
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
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

	dispatchCallback("APP_OPEN_FAILED_TO_SHOW", currentMessage);
}

@end

static BannerViewDelegate *bannerDelegate = nil;
static InterstitialDelegate *interstitialDelegate = nil;
static RewardedDelegate *rewardedDelegate = nil;
static AppOpenAdDelegate *appOpenDelegate = nil;

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

		[[NSString stringWithFormat:@"%zd.%zd.%zd", GADMobileAds.sharedInstance.versionNumber.majorVersion, GADMobileAds.sharedInstance.versionNumber.minorVersion, GADMobileAds.sharedInstance.versionNumber.patchVersion] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];


 		UADSMetaData *gdprMetaData = [[UADSMetaData alloc] init];
 		[gdprMetaData set:@"gdpr.consent" value:hasAdmobConsentForPurpose(0) == 1 ? @YES : @NO];
 		[gdprMetaData commit];
 
 		NSString *iabUSPrivacyString = [[NSUserDefaults standardUserDefaults] stringForKey:@"IABUSPrivacy_String"];
 
 		UADSMetaData *ccpaMetaData = [[UADSMetaData alloc] init];
 		[ccpaMetaData set:@"privacy.consent" value:@(!(iabUSPrivacyString && [iabUSPrivacyString hasPrefix:@"1Y"]))];
 		[ccpaMetaData commit];

		if (@available(iOS 14.0, *))
		{
			int purpose = hasAdmobConsentForPurpose(0);

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
							dispatchCallback("INIT_OK", currentMessage);
						}];
					});
				}];
			}
			else
			{
				[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
				{
					dispatchCallback("INIT_OK", currentMessage);
				}];
			}
		}
		else
		{
			[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
			{
				dispatchCallback("INIT_OK", currentMessage);
			}];
		}
	});
}

void initAdmob(bool testingAds, bool childDirected, bool enableRDP, AdmobCallback callback)
{
	admobCallback = callback;

	UMPRequestParameters *params = [[UMPRequestParameters alloc] init];

	params.tagForUnderAgeOfConsent = childDirected;

	[UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:params completionHandler:^(NSError *_Nullable error)
	{
		if (error)
		{
			[[NSString stringWithFormat:@"Consent Info Error: %@ (Code: %zd)", error.localizedDescription, error.code] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

			dispatchCallback("CONSENT_FAIL", currentMessage);

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
						[[NSString stringWithFormat:@"Consent Form Load Error: %@ (Code: %zd)", loadError.localizedDescription, loadError.code] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

						dispatchCallback("CONSENT_FAIL", currentMessage);

						initMobileAds(testingAds, childDirected, enableRDP);
					}
					else
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							[form presentFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable error)
							{
								if (loadError)
								{
									[[NSString stringWithFormat:@"Consent Form Load Error: %@ (Code: %zd)", loadError.localizedDescription, loadError.code] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

									dispatchCallback("CONSENT_FAIL", currentMessage);
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

void showAdmobBanner(const char *id, int size, int align)
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

		alignBanner(bannerView, align);

		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
		{
			[BannerHelper handleOrientationChange];
		}];

		[bannerView loadRequest:[GADRequest request]];
	});
}

void hideAdmobBanner()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (bannerView != nil)
		{
			[bannerView removeFromSuperview];
			bannerView = nil;
		}
	});
}

void loadAdmobInterstitial(const char *id)
{
	if (!interstitialDelegate)
		interstitialDelegate = [[InterstitialDelegate alloc] init];

	[interstitialDelegate loadWithAdUnitID:id];
}

void showAdmobInterstitial()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (interstitialDelegate)
			[interstitialDelegate show];
		else
			dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", "You need to load interstitial ad first!");
	});
}

void loadAdmobRewarded(const char *id)
{
	if (!rewardedDelegate)
		rewardedDelegate = [[RewardedDelegate alloc] init];

	[rewardedDelegate loadWithAdUnitID:id];
}

void showAdmobRewarded()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (rewardedDelegate)
			[rewardedDelegate show];
		else
			dispatchCallback("REWARDED_FAILED_TO_SHOW", "You need to load rewarded ad first!");
	});
}

void loadAdmobAppOpen(const char *id)
{
	if (!appOpenDelegate)
		appOpenDelegate = [[AppOpenAdDelegate alloc] init];

	[appOpenDelegate loadWithAdUnitID:id];
}

void showAdmobAppOpen()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (appOpenDelegate)
			[appOpenDelegate show];
		else
			dispatchCallback("APP_OPEN_FAILED_TO_SHOW", "You need to load App Open Ad first!");
	});
}

void setAdmobVolume(float vol)
{
	if (vol > 0)
	{
		GADMobileAds.sharedInstance.applicationVolume = vol;
		GADMobileAds.sharedInstance.applicationMuted = false;
	}
	else
		GADMobileAds.sharedInstance.applicationMuted = true;
}

int hasAdmobConsentForPurpose(int purpose)
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents == nil || purposeConsents.length == 0)
		return -1;

	if (purpose >= purposeConsents.length)
		return -1;

	return [[purposeConsents substringWithRange:NSMakeRange(purpose, 1)] integerValue];
}

const char *getAdmobConsent()
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents.length > 0)
	{
		[purposeConsents getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

		return currentMessage;
	}

	return "";
}

bool isAdmobPrivacyOptionsRequired()
{
	return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == UMPPrivacyOptionsRequirementStatusRequired;
}

void showAdmobPrivacyOptionsForm()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[UMPConsentForm presentPrivacyOptionsFormFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable formError)
		{
			if (formError)
			{
				[[NSString stringWithFormat:@"Consent Form Error: %@ (Code: %zd)", formError.localizedDescription, formError.code] getCString:currentMessage maxLength:sizeof(currentMessage) encoding:NSUTF8StringEncoding];

				dispatchCallback("CONSENT_FAIL", currentMessage);
			}
		}];
	});
}
