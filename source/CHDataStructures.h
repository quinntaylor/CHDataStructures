/*
 CHDataStructures.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <Foundation/Foundation.h>

// Protocols
#import "CHDeque.h"
#import "CHHeap.h"
#import "CHLinkedList.h"
#import "CHQueue.h"
#import "CHStack.h"
#import "CHTree.h"

// Classes
#import "CHAnderssonTree.h"
#import "CHAVLTree.h"
#import "CHDoublyLinkedList.h"
#import "CHListDeque.h"
#import "CHListQueue.h"
#import "CHListStack.h"
#import "CHMutableArrayDeque.h"
#import "CHMutableArrayHeap.h"
#import "CHMutableArrayQueue.h"
#import "CHMutableArrayStack.h"
#import "CHRedBlackTree.h"
#import "CHSinglyLinkedList.h"
#import "CHTreap.h"
#import "CHUnbalancedTree.h"

// Utilities
#import "Util.h"


/**
 @file CHDataStructures.h
 
 An umbrella header which imports the important header files from the framework.
 */

/**
 @mainpage Overview
 
 <strong>CHDataStructures.framework</strong> is an attempt to create a library
 of standard data structures which can be used in any Objective-C program, for
 educational purposes or as a foundation for other data structures to build on.
 Data structures in this framework adopt Objective-C protocols that define the
 functionality of and API for interacting with any implementation thereof,
 regardless of its internals.
 
 This framework provides Objective-C implementations of common data structures
 which are currently beyond the purview of Apple's extensive and flexible
 <a href="http://developer.apple.com/cocoa/">Cocoa frameworks</a>. Collections
 that are a part of Cocoa are highly optimized and amenable to many situations.
 However, sometimes an honest-to-goodness stack, queue, linked list, tree, etc.
 can greatly improve the clarity and comprehensibility of code.
 
 The currently supported abstract data type protocols include:
 - CHDeque
 - CHHeap
 - CHLinkedList
 - CHQueue
 - CHStack
 - CHTree
 
 The code is written for <a href="http://www.apple.com/macosx/">Mac OS X</a>
 and does use some features of Objective-C 2.0 (part of 10.5 "Leopard"), but
 most of the code could be easily ported to other Objective-C environments,
 such as <a href="http://www.gnustep.org">GNUStep</a>. However, such efforts
 would be better accomplished by forking this project rather than integrating
 with it, for several main reasons:
 
 <ol>
 <li>Supporting multiple environments increases code complexity, and
 consequently the effort required to test, maintain, and improve it.</li>
 <li>Libraries that have bigger and slower binaries to accommodate all possible
 platforms don't help the mainstream developer.</li>
 <li>Mac OS X is by far the most prevalent Objective-C environment in use, a
 trend which isn't likely to change soon.</li>
 </ol>
 
 While certain implementations utilize straight C for their internals, this
 framework is fairly high-level, and uses composition rather than inheritance
 in most cases. The framework was originally written as an exercise in writing
 Objective-C code and consisted mainly of ported Java code. In later revisions,
 performance has gained greater emphasis, but the primary motivation is to
 provide friendly, intuitive Objective-C interfaces for data structures, not to
 maximize speed at any cost, which sometimes happens with C++ and the STL. The
 algorithms should all be sound (i.e., you won't get O(n) performance where it
 should be O(log n) or O(1), etc.) and perform quite well in general. If your
 choice of data structure type and implementation are dependent on performance
 or memory usage, it would be wise to run the benchmarks from Xcode and choose
 based on the time and memory complexity for specific implementations.
 
 Binaries and source code for the framework is available
 <a href="http://cocoaheads.byu.edu/code/CHDataStructures/">here</a>. It is
 organized in an Xcode project with all relevant dependencies, but could also
 be built by hand if you're masochistic or just like a challenge.
 
 This framework (library) is free software and is licensed to you under the
 <b>GNU Lesser General Public License (LGPL)</b>, which may be found at
 <a href="http://www.gnu.org/copyleft/lesser.html">gnu.org</a> or verbatim in
 the included <a href="LICENSE.html">LICENSE.html</a>. You may redistribute
 and/or modify this framework under the terms of version 3 of the License, or
 (at your option) any later version thereof. This basically means that anyone
 can use this framework for any purpose, but there are important restrictions,
 so please read and understand the license before using or modifying the code.
 (The LGPL is commonly interpreted incorrectly, so please be careful.)
 
 If you would like to contribute to the library or let me know that you use it,
 please <a href="mailto:quinntaylor@mac.com?subject=CHDataStructures.framework">
 email me</a>. I am very receptive to help, criticism, flames, whatever.
 
   &mdash; <a href="http://homepage.mac.com/quinntaylor/">Quinn Taylor</a>, 2008
 */
