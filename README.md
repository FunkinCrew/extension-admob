# extension-admob

![](https://img.shields.io/github/repo-size/HaxeExtension/extension-admob) ![](https://badgen.net/github/open-issues/HaxeExtension/extension-admob) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[Lime](https://lime.openfl.org) extension for integrating [Google AdMob](https://extension.admob.google.com/home) on iOS and Android.

### Installation

To install **extension-admob**, follow these steps:

1. **Haxelib Installation**
	```bash
	haxelib install extension-admob
	```

2. **Haxelib Git Installation (for latest updates)**
	```bash
	haxelib git extension-admob https://github.com/HaxeExtension/extension-admob.git
	```

3. **Project Configuration** (Add the following code to your **project.xml** file)
	```xml
	<section if="cpp">
		<haxelib name="extension-admob" if="mobile" />
	</section>
	```

### Setup

To configure **extension-admob** for your project, follow these steps:

1. **iOS Frameworks Installation**  
	To set up the required frameworks for iOS compilation execute the following command:
	```bash
	haxelib run extension-admob setup
	```

2. **Add AdMob App IDs**  
	Include your AdMob app IDs in your **project.xml**. Ensure you specify the correct IDs for both Android and iOS platforms.
	```xml
	<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123457" if="android" />
	<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123458" if="ios" />
	```

3. **GDPR Consent Management**  
	Beginning January 16, 2024, Google requires publishers serving ads in the EEA and UK to use a certified consent management platform (CMP). This extension integrates Google's UMP SDK to display a consent dialog during the first app launch. Ads may not function if user does not provide consent.

3. **Initializing Admob extension**  
	If GDPR consent dialog and/or iOS 14+ tracking authorization dialog are required, they are shown automatically upon Admob initialization.
	```haxe
	import extension.admob.*;
	...
	Admob.onEvent.add(function(event:String, message:String):Void
	{
		if (event == AdmobEvent.INIT_OK)
			// You can load/show your ads here
	});
	Admob.init();
	```

4. **Checking GDPR Consent Requirements**  
	After consenting (or not) to show ads, user must have an option to change his choice.
	To give this choice an access to GDPR consent dialog should be provided somewhere in the app.
	You can determine if the GDPR consent dialog is required (ie user is from EEA or UK):
	```haxe
	if (Admob.isPrivacyOptionsRequired())
		trace("GDPR consent dialog is required.");
	```

5. **Reopen Privacy Options Dialog**  
	If needed, allow users to manage their GDPR consent options again:
	```haxe
	Admob.showPrivacyOptionsForm();
	```

6. **Load and Show Ads**  
	Add the following snippets to display ads in your app:

	- **Banner Ad**
	```haxe
	Admob.showBanner("ca-app-pub-XXXX/XXXXXXXXXX");
	```

	- **Interstitial Ad**
	```haxe
	Admob.onEvent.add(function(event:String, message:String):Void
	{
		if (event == AdmobEvent.INTERSTITIAL_LOADED)
			Admob.showInterstitial();
	});
	Admob.loadInterstitial("ca-app-pub-XXXX/XXXXXXXXXX");
	```

	- **Rewarded Ad**
	```haxe
	Admob.onEvent.add(function(event:String, message:String):Void
	{
		if (event == AdmobEvent.REWARDED_LOADED)
			Admob.showRewarded();
	});
	Admob.loadRewarded("ca-app-pub-XXXX/XXXXXXXXXX");
	```

	- **App Open Ad**
	```haxe
	Admob.onEvent.add(function(event:String, message:String):Void
	{
		if (event == AdmobEvent.APP_OPEN_LOADED)
			Admob.showAppOpen();
	});
	Admob.loadAppOpen("ca-app-pub-XXXX/XXXXXXXXXX");
	```

### Disclaimer

[Google](http://unibrander.com/united-states/140279US/google.html) is a registered trademark of Google Inc.

[AdMob](http://unibrander.com/united-states/479956US/extension.admob.html) is a registrered trademark of Google Inc.

### License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright (c) 2025 Haxe/Lime/NME/OpenFL contributors
