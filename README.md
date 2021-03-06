# nate v0.1

nate is a command line utility for finding audio file Bit Rates. It will recursively look through a given directory and output a bit rate value for each audio file found. It's primary purpose is to discover audio files below a certain quality.

Written by: [Jon Matthews](https://github.com/joncarlmatthews)

Date: 08/03/2014

## Installation

1. Download
2. cd into `build` directory
3. `$ chmod +x nate`
4. Add nate to your $PATH if you wish
5. Done!

## Usage

````usage: nate directory_or_file_path [quality (only find audio files below this KBPS value)]````

### Single file

```
$ nate myfile.mp3
Bit Rate: 320kbps
```

### Multi file

```
$ nate ~/Music/
/Users/<username>/Music/file.mp3 Bit Rate: 320kbps
/Users/<username>/Music/file2.mp3 Bit Rate: 127kbps
/Users/<username>/Music/iTunes/file3.mp3 Bit Rate: 127kbps
```

### Quality threshold

```
$ nate ~/Music/ 320
/Users/<username>/Music/file2.mp3 Bit Rate: 127kbps
/Users/<username>/Music/iTunes/file3.mp3 Bit Rate: 127kbps
...
```

It's a good idea to dump the output into a text file:

	$ nate ~/Music/ > bitrates.txt

### Audio file support

Supports .mp3, .wav, .wma, .mid and .m4a files
