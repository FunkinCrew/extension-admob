package;

import sys.FileSystem;
import haxe.io.Path;
import util.ANSIUtil;
import util.FileUtil;
import util.ProcessUtil;

using StringTools;

@:nullSafety
class Main
{
	@:noCompletion
	private static final BUNDLES_DIR:String = 'project/admob-ios/bundles';

	@:noCompletion
	private static final FRAMEWORKS_DIR:String = 'project/admob-ios/frameworks';

	@:noCompletion
	private static final TEMP_DIR:String = '.temp_sdks';

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
		FileUtil.deletePath(BUNDLES_DIR);
		FileUtil.createDirectory(BUNDLES_DIR);

		FileUtil.deletePath(FRAMEWORKS_DIR);
		FileUtil.createDirectory(FRAMEWORKS_DIR);

		FileUtil.deletePath(TEMP_DIR);

		FileUtil.createDirectory(TEMP_DIR);

		var urls:Array<String> = [];

		// Google Mobile Services (GMS) and User Messaging Platform (UMP)
		urls.push('https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip');

		// Unity Ads SDK and Mediation Adapter
		urls.push('https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.16.6/UnityAds.zip');
		urls.push('https://dl.google.com/googleadmobadssdk/mediation/ios/unity/UnityAdapter-4.16.6.1.zip');

		// Pangle Ads SDK and Mediation Adapter
		urls.push('https://lf16-pangle.ibytedtos.com/obj/union-pangle/b84740e56ae03200c75e8f975378818d.zip');
		urls.push('https://dl.google.com/googleadmobadssdk/mediation/ios/pangle/PangleAdapter-7.9.0.6.0.zip');

		for (url in urls)
		{
			final filename:String = Path.withoutDirectory(url);

			if (ProcessUtil.commandExists('curl'))
			{
				Sys.println(ANSIUtil.apply('Downloading "$filename" from "$url"...', [Blue]));

				final result:Int = ProcessUtil.runCommand('curl', ['-s', '-L', '-o', Path.join([TEMP_DIR, filename]), url]);

				if (result != 0)
				{
					Sys.println(ANSIUtil.apply('Failed to download "$filename".', [Red]));

					FileUtil.deletePath(TEMP_DIR);

					Sys.exit(result);
				}
				else
					Sys.println(ANSIUtil.apply('Successfully downloaded "$filename".', [Green]));
			}
			else
			{
				Sys.println(ANSIUtil.apply('Command not found "curl".', [Red]));

				FileUtil.deletePath(TEMP_DIR);

				Sys.exit(1);
			}

			if (ProcessUtil.commandExists('unzip'))
			{
				Sys.println(ANSIUtil.apply('Unzipping "$filename" to "$TEMP_DIR"...', [Blue]));

				final result:Int = ProcessUtil.runCommand('unzip', ['-q', Path.join([TEMP_DIR, filename]), '-d', TEMP_DIR]);

				if (result != 0)
				{
					Sys.println(ANSIUtil.apply('Failed to unzip "$filename".', [Red]));

					FileUtil.deletePath(TEMP_DIR);

					Sys.exit(result);
				}
				else
				{
					Sys.println(ANSIUtil.apply('Successfully unzipped "$filename".', [Green]));

					FileUtil.deletePath(Path.join([TEMP_DIR, filename]));

					Sys.println(ANSIUtil.apply('Removed "$filename" archive.', [Yellow]));
				}
			}
			else
			{
				Sys.println(ANSIUtil.apply('Command not found "unzip".', [Red]));

				FileUtil.deletePath(TEMP_DIR);

				Sys.exit(1);
			}
		}

		{
			function searchDirs(path:String, extension:String, matched:String->Void):Void
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

			for (dependency in sys.FileSystem.readDirectory(TEMP_DIR))
			{
				final path:String = Path.join([TEMP_DIR, dependency]);

				if (sys.FileSystem.isDirectory(path) && Path.extension(path) == 'xcframework')
					findFrameworks(path);
				else if (sys.FileSystem.isDirectory(path))
					searchDirs(path, 'xcframework', findFrameworks);
				else if (!sys.FileSystem.isDirectory(path))
					FileUtil.deletePath(path);
			}

			for (dependency in sys.FileSystem.readDirectory(TEMP_DIR))
			{
				final path:String = Path.join([TEMP_DIR, dependency]);

				if (sys.FileSystem.isDirectory(path) && Path.extension(path) == 'bundle')
					copyBundle(path);
				else if (sys.FileSystem.isDirectory(path))
					searchDirs(path, 'bundle', copyBundle);
				else if (!sys.FileSystem.isDirectory(path))
					FileUtil.deletePath(path);
			}
		}

		Sys.println(ANSIUtil.apply('Cleaning up...', [Yellow]));

		FileUtil.deletePath(TEMP_DIR);
	}

	@:noCompletion
	private static function findFrameworks(filePath:String):Void
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
					final destPath:String = Path.join([destDir, frameworkName]);

					Sys.println(ANSIUtil.apply('Copying "$frameworkName" to "$destDir"...', [Blue]));

					FileUtil.copyDirectory(frameworkDir, destPath);

					Sys.println(ANSIUtil.apply('Successfully copied "$frameworkName" to "$destDir".', [Green]));
				}
				else
					Sys.println(ANSIUtil.apply('No ".framework" file found in "$archDir".', [Blue]));
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
		Sys.println(ANSIUtil.apply('Copying "${Path.withoutDirectory(filePath)}" to "$BUNDLES_DIR"...', [Blue]));

		FileUtil.copyDirectory(filePath, Path.join([BUNDLES_DIR, Path.withoutDirectory(filePath)]));

		Sys.println(ANSIUtil.apply('Successfully copied "${Path.withoutDirectory(filePath)}" to "$BUNDLES_DIR".', [Green]));
	}
}
