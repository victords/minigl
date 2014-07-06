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
  * The [documentation](https://github.com/victords/minigl/wiki) is under
construction.

**Version 1.2.5**

  * Added support for "invisible" buttons (for associating actions with clicks
in screen areas).
  * Exposed `Button`'s `click` method and `TextField`'s `focus` and `unfocus`
methods.
