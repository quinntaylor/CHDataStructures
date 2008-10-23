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
#import "CHUnbalancedTree.h"

// Utilities
#import "Util.h"


/**
 @file CHDataStructures.h
 
 An umbrella header which imports the important header files from the framework.
 */

/**
 @mainpage Overview
 
 This framework provides Objective-C protocols for and implementations of common
 data structures which are currently beyond the purview of Apple's extensive and
 flexible <a href="http://developer.apple.com/cocoa/">Cocoa frameworks</a>. The
 collections which are a part of Cocoa (NSArray, NSDictionary, NSSet, etc.) ar
 highly optimized and amenable to many situations. Even so, sometimes the use of
 an honest-to-goodness stack, queue, linked list, tree, etc. can greatly improve
 the clarity and comprehensibility of code.
 
 This framework is an attempt to create a library of standard data structures
 which can be reliably used in any Objective-C program. Data structures in this
 framework adopt Objective-C protocols which define the functionality of and API
 for interacting with any implementation thereof, regardless of its internals.
 
 The data structure protocols include:
 - CHDeque
 - CHHeap
 - CHLinkedList
 - CHQueue
 - CHStack
 - CHTree
 
 We specifically target <a href="http://www.apple.com/macosx/">Mac OS X</a>, but
 most of the code could be easily ported to other Objective-C environments, such
 as <a href="http://www.gnustep.org">GNUStep</a>. However, such efforts would be
 better accomplished by forking this project rather than integrating with it,
 for two primary reasons:
 
 <ol>
 <li>Accommodating multiple environments dramatically increases code complexity,
     and consequently the effort required to test, maintain, and improve it.
 <li>Mac OS X is by far the most prevalent Objective-C environment in use, and a
     needlessly bloated framework binary is a disservice to any developer.
 </ol>
 
 This framework is free software: you can redistribute it and/or modify it under
 the terms of the <a href="http://www.gnu.org/copyleft/lesser.html">GNU Lesser
 General Public License</a>, either version 3 of the License, or (at your option)
 any later version thereof. The source code for the framework is available at
 <a href="http://www.phillipmorelock.com/examples/cocoadata/">this web page</a>.
  
 If you would like to contribute to the library or let me know that you use it,
 please <a href="mailto:me@phillipmorelock.com?subject=DataStructuresFramework">
 email me</a>. I am very receptive to help, criticism, flames, whatever.
 
         &mdash; <a href="http://www.phillipmorelock.com/">Phillip Morelock</a>, 2002
 */
