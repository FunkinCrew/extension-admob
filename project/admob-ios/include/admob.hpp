#pragma once

typedef void (*AdmobCallback)(const char* event, const char* value);

/**
 * Configures `GDPR` and `CCPA` consent metadata for `Unity Ads` mediation.
 * 
 * @param gdprConsent The user's GDPR consent status (true for consent, false for no consent).
 * @param ccpaConsent The user's CCPA consent status (true for consent, false for no consent).
 */
void Admob_ConfigureConsentMetadata(bool gdprConsent, bool ccpaConsent);

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
 * @param adUnitId The AdMob banner ad unit ID.
 * @param size The size of the banner (implementation-specific).
 * @param align The alignment of the banner on screen (implementation-specific).
 */
void Admob_ShowBanner(const char* adUnitId, int size, int align);

/**
 * Hides the currently displayed banner ad.
 */
void Admob_HideBanner(void);

/**
 * Loads an interstitial ad with the given ad unit ID.
 * 
 * @param adUnitId The AdMob interstitial ad unit ID.
 */
void Admob_LoadInterstitial(const char* adUnitId);

/**
 * Displays a loaded interstitial ad.
 */
void Admob_ShowInterstitial(void);

/**
 * Loads a rewarded ad with the specified ad unit ID.
 * 
 * @param adUnitId The AdMob rewarded ad unit ID.
 */
void Admob_LoadRewarded(const char* adUnitId);

/**
 * Displays a loaded rewarded ad.
 */
void Admob_ShowRewarded(void);

/**
 * Loads an app open ad with the given ad unit ID.
 * 
 * @param adUnitId The AdMob app open ad unit ID.
 */
void Admob_LoadAppOpen(const char* adUnitId);

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
 * Retrieves the user's consent status for a specific IAB TCF purpose.
 *
 * @param purpose The index of the purpose (0-based, as per TCF spec).
 * @return `1` if consent is granted, `0` if denied, `-1` if unknown or out of range.
 */
int Admob_GetTCFConsentForPurpose(int purpose);

/**
 * Retrieves the raw IAB TCF PurposeConsents string.
 *
 * @return A dynamically allocated string representing the TCF PurposeConsents (or an empty string if unavailable).
 */
char* Admob_GetTCFPurposeConsent(void);

/**
 * Retrieves the IAB US Privacy String (CCPA compliance).
 *
 * @return A dynamically allocated string representing the IAB US Privacy string (or an empty string if unavailable).
 */
char* Admob_GetIABUSPrivacy(void);

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
