package;

import haxe.io.Path;

import util.ANSIUtil;
import util.FileUtil;
import util.ProcessUtil;

@:nullSafety
class Main
{
	@:noCompletion
	private static final URLS:Array<String> = [
		'https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip',
		'https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.16.5/UnityAds.zip',
		'https://dl.google.com/googleadmobadssdk/mediation/ios/unity/UnityAdapter-4.16.5.0.zip'
	];

	@:noCompletion
	private static final OUTPUT_DIR:String = 'project/admob-ios/frameworks';

	@:noCompletion
	private static final TEMP_DIR:String = '.temp_sdk';

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
		FileUtil.deletePath(OUTPUT_DIR);
		FileUtil.createDirectory(OUTPUT_DIR);

		FileUtil.deletePath(TEMP_DIR);
		FileUtil.createDirectory(TEMP_DIR);

		for (url in URLS)
		{
			final filename:String = Path.withoutDirectory(url);

			if (ProcessUtil.commandExists('curl'))
			{
				Sys.println(ANSIUtil.apply('Downloading "$filename" from "$url"...', [Blue]));

				final result:Int = ProcessUtil.runCommand('curl', ['-s', '-L', '-o', filename, url]);

				if (result != 0)
				{
					Sys.println(ANSIUtil.apply('Failed to download "$filename".', [Red]));

					FileUtil.deletePath(filename);
					FileUtil.deletePath(TEMP_DIR);

					Sys.exit(result);
				}
				else
					Sys.println(ANSIUtil.apply('Successfully downloaded "$filename".', [Green]));
			}
			else
			{
				Sys.println(ANSIUtil.apply('Command not found "curl".', [Red]));

				FileUtil.deletePath(filename);
				FileUtil.deletePath(TEMP_DIR);

				Sys.exit(1);
			}

			if (ProcessUtil.commandExists('unzip'))
			{
				Sys.println(ANSIUtil.apply('Unzipping "$filename" to "$TEMP_DIR"...', [Blue]));

				final result:Int = ProcessUtil.runCommand('unzip', ['-q', filename, '-d', TEMP_DIR]);

				if (result != 0)
				{
					Sys.println(ANSIUtil.apply('Failed to unzip "$filename".', [Red]));

					FileUtil.deletePath(filename);
					FileUtil.deletePath(TEMP_DIR);

					Sys.exit(result);
				}
				else
				{
					Sys.println(ANSIUtil.apply('Successfully unzipped "$filename".', [Green]));

					FileUtil.deletePath(filename);

					Sys.println(ANSIUtil.apply('Removed "$filename" archive.', [Yellow]));
				}
			}
			else
			{
				Sys.println(ANSIUtil.apply('Command not found "unzip".', [Red]));

				FileUtil.deletePath(filename);
				FileUtil.deletePath(TEMP_DIR);

				Sys.exit(1);
			}
		}

		for (dependency in sys.FileSystem.readDirectory(TEMP_DIR))
		{
			final path:String = Path.join([TEMP_DIR, dependency]);

			if (sys.FileSystem.isDirectory(path) && Path.extension(path) == 'xcframework')
				findFrameworks(path);
			else if (sys.FileSystem.isDirectory(path))
			{
				for (file in sys.FileSystem.readDirectory(path))
				{
					final filePath:String = Path.join([path, file]);

					if (sys.FileSystem.isDirectory(filePath) && Path.extension(filePath) == 'xcframework')
						findFrameworks(filePath);
				}
			}
		}

		Sys.println(ANSIUtil.apply('Cleaning up...', [Yellow]));

		FileUtil.deletePath(TEMP_DIR);

		Sys.println(ANSIUtil.apply('Frameworks have been organized in "$OUTPUT_DIR"!', [Green]));
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

					final destDir:String = Path.join([OUTPUT_DIR, archName]);
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
}
