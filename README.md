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

After installing the Gosu dependencies, you can just `gem install minigl`.

## Documentation

  * The library is 100% RDoc-documented [here](http://www.rubydoc.info/gems/minigl).
  * The [wiki](https://github.com/victords/minigl/wiki) is a work in progress with tutorials and examples.
  * Test package and examples aren't complete!

## Version 2.1.2

  * Fixed `GameObject#draw` when rotated and scaled.
