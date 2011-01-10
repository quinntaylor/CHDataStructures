<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>README &mdash; CHDataStructures.framework</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<style type="text/css" media="all">
		body {
			font-family: "Lucida Grande", Verdana, Geneva, Arial, sans-serif;
			font-size: 12px;
		}
		p {
			margin-left: 10px;
		}
		li {
			margin-top: 5px;
		}
		li li {
			margin-top: 0;
		}
		code {
			color: #007;
		}
	</style>
</head>
<body>
<div align="center">
<h1>CHDataStructures.framework</h1>
<h2>Version 1.4 &mdash; 09 Feb 2010</h2>
<h4><a href="http://cocoaheads.byu.edu/code/CHDataStructures">http://cocoaheads.byu.edu/code/CHDataStructures</a></h4>
<h4>&copy; 2008&ndash;2010 <a href="http://homepage.mac.com/quinntaylor/">Quinn Taylor</a> &mdash; BYU CocoaHeads<br />
&copy; 2002 <a href="http://www.phillipmorelock.com/">Phillip Morelock</a> &mdash; Los Angeles, CA</h4>
</div>

<h2>Overview</h2>
<p><strong>CHDataStructures</strong> is a library of standard data structures which can be used in (virtually) any Objective-C program. Data structures in this library adopt Objective-C protocols that define the functionality of and API for interacting with any implementation thereof, regardless of its internals.</p>
<p>This library provides Objective-C implementations of common data structures which are currently beyond the purview of Apple's extensive and flexible <a href="http://developer.apple.com/cocoa/">Cocoa frameworks</a>. Collections that are a part of Cocoa are highly optimized and amenable to many situations. However, sometimes an honest-to-goodness stack, queue, linked list, tree, etc. can greatly improve the clarity and comprehensibility of code. The currently supported abstract data types include:
	<a href="http://en.wikipedia.org/wiki/Deque">deque</a>,
	<a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a>,
	<a href="http://en.wikipedia.org/wiki/Linked_list">linked list</a>,
	<a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a>,
	<a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a>, and
	<a href="http://en.wikipedia.org/wiki/Tree_(data_structure)">tree</a>.</p>
<p>The code is written against Apple's <a href="http://developer.apple.com/mac/library/documentation/cocoa/Reference/Foundation/ObjC_classic/Intro/IntroFoundation.html">Foundation framework</a> and uses some features of <a href="http://developer.apple.com/leopard/overview/objectivec2.html">Objective-C 2.0</a> (present in OS X 10.5+ and iOS) when possible. Most of the code could be easily ported to other Objective-C environments (such as <a href="http://www.gnustep.org">GNUStep</a>) but such efforts would be better accomplished by forking this project rather than integrating with it, for several main reasons:</p>
<ol>
	<li>Supporting multiple environments increases code complexity, and consequently the effort required to test, maintain, and improve it.</li>
	<li>Libraries that have bigger and slower binaries to accommodate all possible platforms don't help the mainstream developer.</li>
	<li>Mac OS X is by far the most prevalent Objective-C environment in use, a trend which isn't likely to change soon.</li>
</ol>
<p>While certain implementations utilize straight C for their internals, this framework is fairly high-level, and uses composition rather than inheritance in most cases. The framework began its existence as an exercise in writing Objective-C code and consisted mainly of ported Java code. In later revisions, performance has gained greater emphasis, but the primary motivation is to provide friendly, intuitive Objective-C interfaces for data structures, not to maximize speed at any cost (a common outcome when using C++ and the STL). The algorithms should all be sound (i.e., you won't get O(n) performance when it should be O(log n) or O(1), etc.) and perform quite well in general. If your choice of data structure type and implementation are dependent on performance or memory usage, it would be wise to run the benchmarks from Xcode and choose based on the time and memory complexity for specific implementations.</p>
  
<h2>Getting the Code</h2>
<p>All source code and resources for the framework are freely available at <a href="http://cocoaheads.byu.edu/code/CHDataStructures/">this link</a>. They are organized in an Xcode 3 project with all relevant dependencies.</p>
<p>If you only need a few of the classes in the framework, you can cut down on code size by either excluding parts you don't need from the framework, or just including the source you do need in your own code. Please don't forget to include relevant copyright and license information if you choose to do so!</p>
<p>The original page for the framework when it was maintained by Phillip Morelock (back when its name was "Cocoa Data Structures Framework") is <a href="http://www.phillipmorelock.com/examples/cocoadata/"> here.</a></p>

<h2>Using the Library</h2>
<p>CHDataStructures builds for both OS X (as a framework) and iOS (as a static library, since third-party frameworks are not permitted). The following directions assume that you have either built the appropriate library form (framework or static library) from source, or are using a binary distribution. (When building from source, compile the All target in the Release configuration, which produces a disk image containing the binaries.)</p>
<p>NOTE: When using this library, if you get a "Declaration does not declare anything" compiler warning, set the "C Language Dialect" (<code>GCC_C_LANGUAGE_STANDARD</code>) setting in your target's build settings to <code>GNU99 [-std=gnu99]</code>.</p>

<h3>Using the framework in a Mac application</h3>
<ol>
  <li>Open the Xcode project for your Mac application.</li>
  <li>Add <code>CHDataStructures.framework</code> to your project by dragging it to the "Groups &amp; Files" pane.</li>
  <li>Expand the appropriate target and use a "Copy Files" build phase to copy the framework to the <code>Contents/Frameworks/</code> directory in your application bundle. (The executable path in the framework binary expects this location.)</li>
  <li>Add <code>#import &lt;CHDataStructures/CHDataStructures.h&gt;</code> where necessary in your code.</li>
</ol>
<p>For details or clarification about frameworks, consult the <a href="http://developer.apple.com/documentation/MacOSX/Conceptual/BPFrameworks/">Framework Programming Guide</a>.</p>

<h3>Using the static library in an iOS app</h3>
<ol>
  <li>Open the Xcode project for your iOS app.</li>
  <li>Add <code>libCHDataStructures.a</code> and the library header files to your project by dragging them to the "Groups &amp; Files" pane. (You can organize the headers in their own physical directory and sidebar group to prevent clutter.)</li>
  <li>Expand the appropriate target and drag <code>libCHDataStructures.a</code> into the "Link Binary With Libraries" build phase.</li>
  <li>Add <code>#import "CHDataStructures.h"</code> where necessary in your code.</li>
</ol>
<p>If you have any issues with this approach, you can opt to drag <code>CHDataStructures-iOS.xcodeproj</code> into the "Groups &amp; Files" pane and use the <code>libCHDataStructures.a</code> product from that project. In this case, you must also include <code>PATH_TO_CHDATASTRUCTURES/source</code> in Header Search Paths (<code>HEADER_SEARCH_PATHS</code>) for your target.</p>

<h2>Documentation</h2>
<p>Documentation is auto-generated after each Subversion commit, and is <a href="http://dysart.cs.byu.edu/CHDataStructures/">available online</a>. You can also generate it yourself from the main Xcode project by building the "Documentation" target (if <a href="http://doxygen.org">Doxygen</a> is installed and its executable is in your Unix <code>$PATH</code> variable).</p>

<h2>Future Improvements</h2>
<p>Let's just say it: no software is perfect. It would be foolish (and a lie) to claim that this framework is flawless, or even complete. There are several things that could be improved, and admitting you have a problem is the first step.... Accordingly, the online documentation includes lists of <a href="http://dysart.cs.byu.edu/CHDataStructures/bug.html">known bugs</a> and <a href="http://dysart.cs.byu.edu/CHDataStructures/todo.html">wish list items</a> that are documented in the code.</p>

<p>Please know that it is not my intent to leave the hard things "as an exercise to the reader." (Believe me, writing a generic, iterative, state-saving tree traversal enumerator was no walk in the park!) However, I would love to draw on the talents of others who can provide solutions which currently evade me, or which I haven't had time to implement yet. If you have ideas (or even better, a fix) for one of these items, <a href="mailto:quinntaylor@mac.com?subject=CHDataStructures.framework">email me</a> and we'll talk. Thanks!</p>

<h2>License Information</h2>
<p>This framework is released under a variant of the <a href="http://www.isc.org/software/license">ISC license</a>, an extremely simple and permissive free software license (functionally equivalent to the <a href="http://opensource.org/licenses/mit-license">MIT license</a> and two-clause <a href="http://opensource.org/licenses/bsd-license">BSD license</a>) approved by the <a href="http://opensource.org/licenses/isc-license">Open Source Initiative (OSI)</a> and recognized as GPL-compatible by the <a href="http://www.gnu.org/licenses/license-list.html#ISC">GNU Project</a>. The license is included in every source file, and is reproduced in its entirety here:</p>
<blockquote><em>Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.<br/>
<br/>
The software is provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.</em></blockquote>
<p>Earlier versions of this framework were released under a <a href="http://www.gnu.org/copyleft/">copyleft license</a>, which are generally unfriendly towards commercial software development.</p>
<p>This README file is also considered a source file, and you must include it if you redistribute the framework in source form. If you change the framework, you should add your own README and include it with the source, describing your changes. If you contribute source code to the framework, you may keep your copyright or assign it to me, but you must agree to license the code under this license.</p>

<h2>Contributing to the Framework</h2>
<p>All contributions (including bug reports and fixes, optimizations, new data structures, etc.) are welcomed and encouraged. In keeping with this project's goals, new features are subject to consideration prior to approval&mdash;there are no guarantees of adoption. Modifications that are deemed beneficial to the community as a whole will fit with the vision of this project and improve it. However, not all potential contributions make sense to add to the framework. For example, additions or enhancements that only apply for a specific project would be more appropriate to add as categories or subclasses in that code.</p>
<p><a href="mailto:quinntaylor@mac.com?subject=CHDataStructures.framework"> Email me</a> if you're interested in contributing to the project, discussing improvements or additions you'd like to see, or even just letting me know that you're getting some use from it.</p>

<p>Major contributors are listed below, alphabetically by last name:</p>
<ul>
  <li><strong>Ole Begemann</strong> (<a href="mailto:ole@oleb.net">Email</a>, <a href="http://oleb.net">Website</a>)
    <ul>
      <li>Assistance with adapting framework to work on iOS; contribution of a unit test iOS app.</li>
    </ul>
  </li>
  <li><strong>Max Horn</strong> (<a href="mailto:max@quendi.de">Email</a>, <a href="http://www.quendi.de/">Website</a>)
    <ul>
      <li>Ideas, example code, and impetus for conversions to C for speed.</li>
      <li>Bugfixes and ideas for interface consistency.</li>
    </ul>
  </li>
  <li><strong>Phillip Morelock</strong> (<a href="mailto:me@phillipmorelock.com">Email</a>, <a href="http://www.phillipmorelock.com/">Website</a>)
    <ul>
      <li>Project inception, initial implementation, conversion of internals to straight C, maintenance.</li>
      <li>Protocols and implementations for stacks, queues, linked lists, and trees.</li>
    </ul>
  </li>
  <li><strong>Quinn Taylor</strong> (<a href="mailto:quinntaylor@mac.com">Email</a>, <a href="http://homepage.mac.com/quinntaylor/">Website</a>)
    <ul>
      <li>Conversion to <code>.xcodeproj</code> format, organization of project resources, use of Objective-C 2.0 features.</li>
	  <li>Refactoring of protocols for performance, clarity, and compatibility with the Cocoa frameworks.</li>
	  <li>Improvements to code comments; configured auto-generated documentation using <a href="http://doxygen.org">Doxygen</a>.</li>
	  <li>Addition of <a href="http://www.sente.ch/software/ocunit/">OCUnit</a> unit tests, code coverage, and a simple benchmarking driver.</li>
	  <li>Bugfixes and new features, including abstract classes and more Cocoa-like exception handling.</li>
    </ul>
  </li>
  <li><strong>Julienne Walker</strong> (<a href="mailto:happyfrosty@hotmail.com">Email</a>, <a href="http://eternallyconfuzzled.com/">Website</a>)
    <ul>
      <li>Indirect contributions to binary search tree code, via code and tutorials in the public domain on her website. Many thanks!</li>
    </ul>
  </li>
</ul>

</body>
</html>
