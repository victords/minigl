# MiniGL

MiniGL is a minimal **2D Game** Library, available as a Ruby gem, and built on
top of the [Gosu](http://www.libgosu.org/) gem.

It provides the following features:

  * Resource management (images, sound effects, songs, tilesets, fonts)
  * Input manipulation (keyboard, mouse, joystick)
  * UI (text, buttons, text fields, drop-down lists, progress bars)
  * Basic physics and collision checking
  * Animated objects
  * Particle systems

More functionalities are coming. Feel free to contribute! You can send feedback
to victordavidsantos@gmail.com.

## Made with MiniGL

Below are some games built with MiniGL, all available for free download and also open source.
* [Super Bombinhas](https://github.com/victords/super-bombinhas)
* [ConnecMan](https://github.com/victords/connecman)
* [SokoAdventure](https://github.com/victords/sokoadventure)
* [Spheres](https://github.com/victords/spheres)
* [Willy the droid](https://github.com/gavr-games/willy_the_droid)

Download Super Bombinhas, ConnecMan, SokoAdventure and Spheres in my [itch.io page](https://victords.itch.io).

If you create a project using MiniGL, feel free to open a PR to include it in this list.

## Installing

MiniGL was built on top of the Gosu gem. This gem has its own dependencies for
compiling extensions. Visit
[this page](https://github.com/jlnr/gosu/wiki/Getting-Started-on-Linux) for
details.

After installing the Gosu dependencies, you can just `gem install minigl`.

## Documentation

  * The library is 100% RDoc-documented [here](https://www.rubydoc.info/gems/minigl).
  * The [wiki](https://github.com/victords/minigl/wiki) is a work in progress with tutorials and examples.
  * Test package and examples aren't complete!

## Version 2.5.3

  * Fixed small collision bug in `Movement#move`.

## Contributing

Contributions are very welcome. Feel free to fork and send pull requests.
Also, you can support my work by purchasing any of my games on [itch.io](https://victords.itch.io) or [Super Bombinhas on Steam](https://store.steampowered.com/app/1553840).
