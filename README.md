# CHDataStructures

## Overview

CHDataStructures is an Objective-C library of standard [data structures](https://en.wikipedia.org/wiki/Data_structure), also know as "collections", which adopt Objective-C protocols that define the functionality of and API for interacting with any implementation thereof, regardless of its internals.

Apple's extensive and flexible [Foundation](https://developer.apple.com/documentation/foundation) framework includes several well-abstracted collection classes that are highly optimized and amenable to a variety of situations. However, sometimes a more specialized data structure is better suited, and can greatly improve the clarity and comprehensibility of code. The currently supported abstract data types include:

- [deque](http://en.wikipedia.org/wiki/Deque)
- [heap](http://en.wikipedia.org/wiki/Heap_(data_structure))
- [linked list](http://en.wikipedia.org/wiki/Linked_list)
- [queue](http://en.wikipedia.org/wiki/Queue_(data_structure))
- [stack](http://en.wikipedia.org/wiki/Stack_(data_structure))
- [tree](http://en.wikipedia.org/wiki/Tree_(data_structure))

While certain implementations utilize straight C for their internals, this framework is fairly high-level, and uses composition rather than inheritance in most cases.

The project began its existence as "Cocoa Data Structures Framework", originally authored by Phillip Morelock in 2002 as an exercise in writing Objective-C code, and consisted mainly of ported Java code. In later revisions, performance has gained greater emphasis, but the primary motivation is to provide friendly, intuitive Objective-C interfaces for data structures, not to maximize speed at any cost (a common outcome when using C++ and the STL).

The algorithms should all be sound and perform well in general — you won't get `O(n)` performance when it should be `O(log n)` or `O(1)`. If your choice of data structure type and implementation are dependent on performance or memory usage, it would be wise to run the benchmarks and choose based on the time and memory complexity for specific implementations. 

## Getting the Code

All source code and resources for the framework are freely available at [https://github.com/quinntaylor/CHDataStructures](https://github.com/quinntaylor/CHDataStructures). They are organized in an [Xcode](https://developer.apple.com/xcode/) project with all relevant dependencies.

If you only need a few of the classes in the framework, you can cut down on code size by either excluding parts you don't need from the framework, or just including the source you do need in your own code. Please don't forget to include relevant copyright and license information if you choose to do so!

## Using the Library

CHDataStructures builds for most Apple OS platforms. The following directions assume that you have built the appropriate framework from source, or are using a binary distribution. (When building from source, compile the All target in the Release configuration, which produces a disk image containing the binaries.)

### Using in an Xcode project

1. Open the Xcode project for your app.
2. Add a built `CHDataStructures.framework` to your project by dragging it to the "Groups & Files" pane.
3. Expand the appropriate target and use a "Copy Files" build phase to copy the framework to the Frameworks directory in your application bundle. (The executable path in the framework binary expects this location.)
4. Add `#import <CHDataStructures/CHDataStructures.h>` where necessary in your code.

NOTE: When building or linking against this library, if you get a "Declaration does not declare anything" compiler warning, set "C Language Dialect" (`GCC_C_LANGUAGE_STANDARD`) in your target's build settings to `GNU99 [-std=gnu99]` or later.

## Documentation

Documentation is automatically indexed by Xcode when the project is open, and can be accessed in the Quick Help inspector. You can also generate full documentation yourself from the main Xcode project by building the "Documentation" target (if Doxygen is installed and its executable is in your Unix `$PATH` variable).

## Future Improvements

It would be foolish (and a lie) to claim that this framework is perfect, or even complete. There are many things that could be improved and added. The source documentation comments include `@bug`, `@todo`, and `@test` annotations for several known shortcomings, and I'm sure there are others I'm not aware of yet.

Please know that it is not my intent to leave the hard things "as an exercise to the reader." (Believe me, writing a generic, iterative, state-saving tree traversal enumerator was no walk in the park!) However, I would love to draw on the talents of others who can provide solutions which currently evade me, or which I haven't had time to implement yet. If you have ideas (or even better, a fix) for one of these items, contact me and we'll talk. Thanks!

## License Information

This framework is released under a variant of the [ISC license](http://www.isc.org/software/license), an extremely simple and permissive free software license (functionally equivalent to the [MIT license](http://opensource.org/licenses/mit-license) and two-clause [BSD license](BSD license)) approved by the [Open Source Initiative](http://opensource.org/licenses/isc-license) (OSI) and recognized as GPL-compatible by the [GNU Project](http://www.gnu.org/licenses/license-list.html#ISC). The license is included in every source file, and is reproduced in its entirety here:

> Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
> 
> The software is provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

Earlier versions of this framework were released under a [copyleft license](http://www.gnu.org/copyleft/), which are generally unfriendly towards commercial software development.

This README file is also considered a source file, and you must include it if you redistribute the framework in source form. If you change the framework, you should add your own README and include it with the source, describing your changes. If you contribute source code to the framework, you may keep your copyright or assign it to me, but you must agree to license the code under this license.

## Contributing to the Framework

All contributions (including bug reports and fixes, optimizations, new data structures, etc.) are welcomed and encouraged. In keeping with this project's goals, new features are subject to consideration prior to approval—there are no guarantees of adoption. Modifications that are deemed beneficial to the community as a whole will fit with the vision of this project and improve it. However, not all potential contributions make sense to add to the framework. For example, additions or enhancements that only apply for a specific project would be more appropriate to add as categories or subclasses in that code.

[Email me](mailto:quinntaylor@mac.com?subject=CHDataStructures.framework) if you're interested in contributing to the project, discussing improvements or additions you'd like to see, or even just letting me know that you're getting some use from it.

Major contributors are listed below, alphabetically by last name:

* [Ole Begemann](https://oleb.net)
	* Assistance with adapting framework to work on iOS; contribution of a unit test iOS app.
* [Max Horn](https://www.quendi.de/en/)
	* Ideas, example code, and impetus for conversions to C for speed.
	* Bugfixes and ideas for interface consistency.
* Phillip Morelock
	* Project inception, initial implementation, conversion of internals to straight C, maintenance.
	* Protocols and implementations for stacks, queues, linked lists, and trees.
* [Quinn Taylor](https://about.me/quinntaylor)
	* Conversion to .xcodeproj format, organization of project resources, use of modern Objective-C features.
	* Refactoring of protocols for performance, clarity, and compatibility with the Cocoa frameworks.
	* Improvements to code comments; configured auto-generated documentation using Doxygen.
	* Addition of unit tests, code coverage, and a simple benchmarking driver.
	* Bug fixes and new features, including abstract classes and more Cocoa-like exception handling.
* [Julienne Walker](http://eternallyconfuzzled.com/jsw_home.aspx)
	* Indirect contributions to binary search tree code, via code and tutorials in the public domain on her website. Many thanks!
