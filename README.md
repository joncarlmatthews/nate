# nate v0.1

proof is a little command line utility for finding audio file Bit Rates

Written by: [Jon Matthews](https://github.com/joncarlmatthews)

Date: 08/03/2014

## Installation

1. Download
2. cd into `build` directory
3. `$ chmod +x nate`
4. Add nate to your $PATH if you wish
5. Done!

## Usage

````usage: nate [directory/to/search]````

````$ ./nate ~/Music/````

Example output:

	/Users/<username>/Music/file.mp3 Bit Rate: 320kbps
	/Users/<username>/Music/file2.mp3 Bit Rate: 127kbps
	/Users/<username>/Music/iTunes/file3.mp3 Bit Rate: 127kbps
	...

It's a good idea to dump the output into a text file:

	$ ./nate ~/Music/ > bitrates.txt
	
## TODO
Support files as well as directories

### Note
Currently only supports .wav and .mp3
