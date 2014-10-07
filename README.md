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

Please note:

  * The test package is not complete! Most of the functionality
provided by the gem is difficult to test automatically, but you can check out
this [working game example](https://github.com/victords/aventura-do-saber).
  * The RDoc documentation is now available.
  * An auxiliary, tutorial-like documentation is under construction
[here](https://github.com/victords/minigl/wiki).

**Version 1.3.3**

  * Added `mass` attribute to the GameObject class and Movement module.
  * Added readers for the attributes of `Ramp`.
  * Added z-index support to all drawing functions.

**WARNING**: this version can generate incompatibility, because the `move`
method of `Movement` now requires the calling object to have a `mass` attribute.
