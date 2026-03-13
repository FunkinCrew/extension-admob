package;

import sys.FileSystem;
import haxe.io.Path;
import util.ANSIUtil;
import util.FileUtil;
import util.ProcessUtil;

using StringTools;

class FrameworkSDK
{
	public var downloadLink:String = '';
	public var needExtractDir:Bool = false;
	public var directoriesToRemove:Array<String> = [];

	public function new():Void {}
}

@:nullSafety
class Run
{
	@:noCompletion
	private static final BUNDLES_DIR:String = 'project/admob-ios/bundles';

	@:noCompletion
	private static final FRAMEWORKS_DIR:String = 'project/admob-ios/frameworks';

	@:noCompletion
	private static final TEMP_DIR:String = '.temp_sdks';

	@:noCompletion
	private static function buildFrameworks():Array<FrameworkSDK>
	{
		final sdks:Array<FrameworkSDK> = [];

		// Google Mobile Services (GMS) and User Messaging Platform (UMP)
		final gms:FrameworkSDK = new FrameworkSDK();
		gms.downloadLink = 'https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip';
		sdks.push(gms);

		// Unity Ads SDK
		final unityAds:FrameworkSDK = new FrameworkSDK();
		unityAds.downloadLink = 'https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.16.6/UnityAds.zip';
		unityAds.needExtractDir = true;
		sdks.push(unityAds);

		// Unity Mediation Adapter
		final unityAdapter:FrameworkSDK = new FrameworkSDK();
		unityAdapter.downloadLink = 'https://dl.google.com/googleadmobadssdk/mediation/ios/unity/UnityAdapter-4.16.6.1.zip';
		sdks.push(unityAdapter);

		// Pangle Ads SDK
		final pangleAds:FrameworkSDK = new FrameworkSDK();
		pangleAds.downloadLink = 'https://lf16-pangle.ibytedtos.com/obj/union-pangle/b84740e56ae03200c75e8f975378818d.zip';
		sdks.push(pangleAds);

		// Pangle Mediation Adapter
		final pangleAdapter:FrameworkSDK = new FrameworkSDK();
		pangleAdapter.downloadLink = 'https://dl.google.com/googleadmobadssdk/mediation/ios/pangle/PangleAdapter-7.9.0.6.0.zip';
		sdks.push(pangleAdapter);

		// Vungle Ads SDK
		final vungleAds:FrameworkSDK = new FrameworkSDK();
		vungleAds.downloadLink = 'https://vungle2-cdn-prod.s3.us-east-1.amazonaws.com/sdks/ios/7.7.x/VungleAds-7.7.1.zip';
		vungleAds.needExtractDir = true;
		vungleAds.directoriesToRemove = ['dynamic'];
		sdks.push(vungleAds);

		// Liftoff Monetize Adapter
		final liftoffAdapter:FrameworkSDK = new FrameworkSDK();
		liftoffAdapter.downloadLink = 'https://dl.google.com/googleadmobadssdk/mediation/ios/liftoffmonetize/LiftoffMonetizeAdapter-7.7.1.0.zip';
		sdks.push(liftoffAdapter);

		return sdks;
	}

	public static function main():Void
	{
		final path:String = Sys.getCwd();
		final args:Array<String> = Sys.args();
		final last:Null<String> = args.pop();
		final command:Null<String> = args.shift();

		if (command != null)
		{
			switch (command)
			{
				case 'setup':
					setupFrameworks();
				default:
					Sys.println(ANSIUtil.apply('Unknown command "$command".', [Red]));
					Sys.exit(1);
			}
		}
		else
		{
			Sys.println(ANSIUtil.apply('No command to run.', [Red]));
			Sys.exit(1);
		}
	}

	@:noCompletion
	private static function setupFrameworks():Void
	{
		if (!ProcessUtil.commandExists('curl') || !ProcessUtil.commandExists('unzip'))
		{
			Sys.println(ANSIUtil.apply('Missing required tools: curl, unzip', [Red]));
			Sys.exit(1);
		}

		FileUtil.deletePath(BUNDLES_DIR);
		FileUtil.createDirectory(BUNDLES_DIR);

		FileUtil.deletePath(FRAMEWORKS_DIR);
		FileUtil.createDirectory(FRAMEWORKS_DIR);

		FileUtil.deletePath(TEMP_DIR);

		FileUtil.createDirectory(TEMP_DIR);

		for (framework in buildFrameworks())
		{
			setupFramework(framework);
		}

		searchAndCopy(TEMP_DIR, 'xcframework', copyFrameworks);
		searchAndCopy(TEMP_DIR, 'bundle', copyBundle);

		Sys.println(ANSIUtil.apply('Removing temporary files...', [Yellow]));

		FileUtil.deletePath(TEMP_DIR);
	}

	@:noCompletion
	private static function setupFramework(framework:FrameworkSDK):Void
	{
		final filename:String = Path.withoutDirectory(framework.downloadLink);
		final extractDirectory:String = framework.needExtractDir ? Path.join([TEMP_DIR, Path.withoutExtension(filename)]) : TEMP_DIR;

		Sys.println(ANSIUtil.apply('Downloading $filename...', [Blue]));

		final downloadResult:Int = ProcessUtil.runCommand('curl', ['-s', '-L', '-o', Path.join([TEMP_DIR, filename]), framework.downloadLink]);

		if (downloadResult != 0)
		{
			Sys.println(ANSIUtil.apply('Download failed: $filename', [Red]));
			FileUtil.deletePath(TEMP_DIR);
			Sys.exit(downloadResult);
		}

		Sys.println(ANSIUtil.apply('Extracting $filename...', [Yellow]));

		if (!FileSystem.exists(extractDirectory))
			FileUtil.createDirectory(extractDirectory);

		final unzipResult:Int = ProcessUtil.runCommand('unzip', ['-q', Path.join([TEMP_DIR, filename]), '-d', extractDirectory]);

		if (unzipResult != 0)
		{
			Sys.println(ANSIUtil.apply('Extraction failed: $filename', [Red]));
			FileUtil.deletePath(TEMP_DIR);
			Sys.exit(unzipResult);
		}

		if (framework.directoriesToRemove != null)
		{
			for (directory in framework.directoriesToRemove)
			{
				final path:String = Path.join([extractDirectory, directory]);

				if (FileSystem.isDirectory(path))
					FileUtil.deletePath(path);
			}
		}

		Sys.println(ANSIUtil.apply('Installed $filename', [Green]));
	}

	@:noCompletion
	private static function searchAndCopy(dir:String, extension:String, copyTo:String->Void):Void
	{
		for (name in sys.FileSystem.readDirectory(dir))
		{
			final path:String = Path.join([dir, name]);

			if (sys.FileSystem.isDirectory(path))
			{
				if (Path.extension(path) == extension)
					copyTo(path);
				else
					searchDirs(path, extension, copyTo);
			}
		}
	}

	@:noCompletion
	private static function searchDirs(path:String, extension:String, matched:String->Void):Void
	{
		for (file in sys.FileSystem.readDirectory(path))
		{
			final filePath:String = Path.join([path, file]);

			if (sys.FileSystem.isDirectory(filePath))
			{
				if (Path.extension(filePath) == extension)
				{
					matched(filePath);
				}
				else
				{
					searchDirs(filePath, extension, matched);
				}
			}
		}
	}

	@:noCompletion
	private static function copyFrameworks(filePath:String):Void
	{
		for (archDir in sys.FileSystem.readDirectory(filePath))
		{
			final archPath:String = Path.join([filePath, archDir]);

			if (sys.FileSystem.isDirectory(archPath) && archDir.indexOf('ios-') == 0)
			{
				final frameworkDir:Null<String> = findFrameworkDirectory(archPath);

				if (frameworkDir != null)
				{
					final archName:String = extractArchName(archDir);
					final destDir:String = Path.join([FRAMEWORKS_DIR, archName]);
					final frameworkName:String = Path.withoutDirectory(frameworkDir);

					FileUtil.copyDirectory(frameworkDir, Path.join([destDir, frameworkName]));

					Sys.println(ANSIUtil.apply('Framework $frameworkName -> $archName', [Cyan]));
				}
			}
		}
	}

	@:noCompletion
	private static function findFrameworkDirectory(directory:String):Null<String>
	{
		for (file in sys.FileSystem.readDirectory(directory))
		{
			final path:String = Path.join([directory, file]);

			if (sys.FileSystem.isDirectory(path) && Path.extension(file) == 'framework')
				return path;
		}

		return null;
	}

	@:noCompletion
	private static function extractArchName(dirName:String):String
	{
		final regex:EReg = ~/^ios-(.+)/;

		if (regex.match(dirName))
			return regex.matched(1);

		return dirName;
	}

	@:noCompletion
	private static function copyBundle(filePath:String):Void
	{
		if (!isBundleInFramework(filePath))
		{
			final bundleName:String = Path.withoutDirectory(filePath);

			FileUtil.copyDirectory(filePath, Path.join([BUNDLES_DIR, bundleName]));

			Sys.println(ANSIUtil.apply('Bundle $bundleName -> bundles', [Magenta]));
		}
	}

	@:noCompletion
	private static function isBundleInFramework(filePath:String):Bool
	{
		var current:String = filePath;

		while (current.length > 0)
		{
			if (Path.extension(current) == 'framework')
				return true;

			current = Path.directory(current);
		}

		return false;
	}
}
