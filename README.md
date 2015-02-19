# MiniGL

MiniGL is a minimal **2D Game** Library, available as a Ruby gem, and built on
top of the [Gosu](http://www.libgosu.org/) gem.

It provides the following features:

  * Resource management (images, sounds, ...)
  * Input manipulation (keyboard, mouse, ...)
  * UI (text, buttons, text fields, ...)
  * Basic physics and collision checking
  * Animated objects

More functionalities are coming. Feel free to contribute! You can send feedback
to victordavidsantos@gmail.com.

## Installing

MiniGL was built on top of the Gosu gem. This gem has its own dependencies for
compiling extensions. Visit
[this page](https://github.com/jlnr/gosu/wiki/Getting-Started-on-Linux) for
details.

After installing the gosu dependencies, you can just `gem install minigl`.

Please note:

  * The test package is not complete! Most of the functionality
provided by the gem is difficult to test automatically, but you can check the
examples provided with the gem.
  * The library is 100% RDoc-documented.
  * An auxiliary, tutorial-like documentation is under construction
[here](https://github.com/victords/minigl/wiki/How-To).

**Version 2.0.0**

MiniGL 2.0.0 is finally released!

It brings new features, improvements to existing features and some bug fixes.
For details on what has changed, visit
[the changelog](https://github.com/victords/minigl/wiki/Changelog-(2.0.0)).

As the semantic versioning implies, **this version is incompatible with the 1.x
series**, so you'll need to adjust your code a little if you wish to upgrade.

A new tutorial has to be built, because there have been some changes even in the
basics of the usage. So please be patient while it doesn't come out!
