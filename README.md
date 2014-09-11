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

**Version 1.3.2**

  * Created documentation for the abstract class `Component`.
  * Granted read and write access to the `params` attribute for all components.
  * Fixed issue with `ToggleButton` instantiation with no width and height set.
  * Added `checked` parameter to the constructor of `ToggleButton`.

**WARNING**: this version can generate incompatibility, because of the parameter
order in the constructor for `ToggleButton`.
