package;

import haxe.io.Path;
import util.ANSIUtil;
import util.FileUtil;
import util.ProcessUtil;

@:nullSafety
class Main
{
	@:noCompletion
	private static final ADMOB_URLS:Array<String> = [
		'https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip',
		'https://dl.google.com/googleadmobadssdk/mediation/ios/unity/UnityAdapter-4.16.5.0.zip',
		'https://dl.google.com/googleadmobadssdk/mediation/ios/pangle/PangleAdapter-7.8.0.5.0.zip'
	];

	@:noCompletion
	private static final UNITY_URL:String = 'https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.16.5/UnityAds.zip';

	@:noCompletion
	private static final PANGLE_URL:String = 'https://lf16-pangle.ibytedtos.com/obj/union-pangle/630e33e3a473272bc2a8272339bed350.zip';

	@:noCompletion
	private static final PANGLE_DIR:String = 'oversea_union_platform_iOS_7.8.0.5';

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
				case 'rebuild':
					rebuildLib();
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

		for (url in ADMOB_URLS.concat([UNITY_URL, PANGLE_URL]))
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

					if (filename == Path.withoutDirectory(PANGLE_URL))
						FileUtil.deletePath(Path.join([TEMP_DIR, PANGLE_DIR, 'InternationalDemo']));

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
	private static function rebuildLib():Void
	{
		final lastCwd:String = Sys.getCwd();

		Sys.setCwd(Path.join([lastCwd, 'setup']));

		final result:Int = ProcessUtil.runCommand('haxe', ['build.hxml']);

		if (result != 0)
		{
			Sys.println(ANSIUtil.apply('Failed to rebuild.', [Red]));
			Sys.exit(result);
		}
		else
			Sys.println(ANSIUtil.apply('Successfully rebuilt "extension-admob" runner.', [Green]));
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
