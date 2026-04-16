#pragma once

typedef void (*AdmobCallback)(const char* event, const char* value);

/**
 * Initializes the AdMob system with configuration flags and a callback.
 * 
 * @param testingAds Enables test ads if true.
 * @param childDirected Indicates if the content is child-directed (COPPA).
 * @param enableRDP Enables Restricted Data Processing (CCPA).
 * @param callback Callback for receiving AdMob-related events.
 */
void Admob_Init(bool testingAds, bool childDirected, bool enableRDP, AdmobCallback callback);

/**
 * Displays a banner ad with the specified ad unit ID, size, and alignment.
 * 
 * @param adUnitID The ad unit ID.
 * @param size The size of the banner (implementation-specific).
 * @param align The alignment of the banner on screen (implementation-specific).
 */
void Admob_ShowBanner(const char* adUnitID, int size, int align);

/**
 * Hides the currently displayed banner ad.
 */
void Admob_HideBanner(void);

/**
 * Loads an interstitial ad with the given ad unit ID.
 * 
 * @param adUnitID The ad unit ID.
 */
void Admob_LoadInterstitial(const char* adUnitID);

/**
 * Displays a loaded interstitial ad.
 */
void Admob_ShowInterstitial(void);

/**
 * Loads a rewarded ad with the specified ad unit ID.
 * 
 * @param adUnitID The ad unit ID.
 */
void Admob_LoadRewarded(const char* adUnitID);

/**
 * Displays a loaded rewarded ad.
 */
void Admob_ShowRewarded(void);

/**
 * Loads an app open ad with the given ad unit ID.
 * 
 * @param adUnitID The ad unit ID.
 */
void Admob_LoadAppOpen(const char* adUnitID);

/**
 * Displays a loaded app open ad.
 */
void Admob_ShowAppOpen(void);

/**
 * Sets the global volume for AdMob ads.
 * 
 * @param volume A value between 0.0 (muted) and 1.0 (full volume).
 */
void Admob_SetVolume(float volume);

/**
 * Checks if privacy options are required to be shown to the user.
 * 
 * @return `true` if required, otherwise `false`.
 */
bool Admob_IsPrivacyOptionsRequired(void);

/**
 * Presents the AdMob privacy options form to the user.
 */
void Admob_ShowPrivacyOptionsForm(void);

/**
 * Opens the Ad Inspector interface for debugging and testing ads.
 */
void Admob_OpenAdInspector(void);
