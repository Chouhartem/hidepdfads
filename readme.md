# hidepdfads

A small tool to hide a recurrent part of a PDF file such as ads on plane tickets for instance.

It is a scripted version of [this blog post](https://blog.epheme.re/tips/latex-ad-block.html).

## Files

The project comprises two main files: scr/script.sh and data/presets.json

These two files are used to generate the `pdf-adblocker` standalone file.

## Build and run

To build, simply run the `make` command in this directory.

The following commands are available:
```txt
Usage: hidepdfads <command> [<args>]

This tool uses latex to cover a specific region of a PDF file on every page.

<command> can be:
	help:	display this help message
	list:	list the different presets
	preset:	use an existing preset
		arguments: <preset> <infile> <outfile>
	manual:	set coordinates and dimension of the rectangle
		arguments: <infile> <outfile> X Y L H [color=white] [unit=cm] [format=a4paper]
```

Example:
```sh
$ hidepdfads preset AF plane-ticket.pdf plane-ticket-adfree.pdf
```

### Prerequisites

To build the PDF, you may need [jq](https://stedolan.github.io/jq/) to parse the json database.

The script relies on latex to run. You can specify your favorite latex compiler in the environment variable `LATEXCC`.

## Add presets

Presets are compiled in a json file with the following signature:
```json
{
    "name"   : "preset-name",
    "X"      : "0",
    "Y"      : "0",
    "L"      : "0",
    "H"      : "0",
    "unit"   : "mm/cm/in/pt or any LaTeX-compatible unit",
    "format" : "a4/letter",
    "color"  : "white or any LaTeX-compatible color"
},
```

This data can be filled using for instance `inkscape` to find the location and size of the area to hide.

![inkscape dimensions](https://blog.epheme.re/examples/inkscape-adblock.png)

**Instructions:** After opening your pdf file, start by selecting the ad (purple), you may have to ungroup elements (ctrl+shift+g), then set the dimensions in cm or your favourite length unit (blue) and finally note the dimensions of the ad (red).

Feel free to contribute to this (so far small) database of PDF cleaner presets 😉

## Acknowledgements 

The basecode and principles of the code are highly inspired from [dmenu-emoji](https://github.com/porras/dmenu-emoji).

## TODO

* Simplify the way to fill the database
