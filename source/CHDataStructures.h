//  CHDataStructures.h
//  CHDataStructures.framework

/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

/**
 @file CHDataStructures.h
 
 An umbrella header which imports the important header files from the framework.
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
 @mainpage Overview
 
 This framework provides Objective-C interfaces and implementations of several data
 structures, a piece which many people have felt is a glaring omission from Apple's
 <a href="http://developer.apple.com/cocoa/">Cocoa frameworks</a>. Apple's stance is
 that the very flexible and optimized NSArray / NSDictionary / NSSet and children are
 enough, and usually they are sufficient, but sometimes an honest-to-goodness stack,
 queue, deque, linked list, tree, heap, etc. is what you really need or want.
 
 This project is an attempt to create a library of standard data structures which can
 be reliably used in any Objective-C program. It is currently distributed under the
 <a href="http://www.gnu.org/copyleft/lesser.html">GNU LGPL</a> and the source is
 available at <a href="http://www.phillipmorelock.com/examples/cocoadata/">this web
 page</a>. Data structures in this framework conform to Objective-C <i>protocols</i>
 (the predecessor of Java <i>interfaces</i>) that define the functionality and API
 for interacting with any implementation thereof, regardless of its internals.
 
 <!-- LGPL v.2 @ http://www.gnu.org/licenses/old-licenses/gpl-2.0.html -->
 
 The data structure protocols include:
 - CHDeque
 - CHHeap
 - CHLinkedList
 - CHQueue
 - CHStack
 - CHTree
 
 Although we specifically target <a href="http://www.apple.com/macosx/">Mac OS X</a>,
 most of the code could be easily ported to other Objective-C environments, such as
 <a href="http://www.gnustep.org">GNUStep</a>. However, in the interest of code
 cleanliness and maintainability, such efforts would probably best be accomplished by
 forking this project's codebase, rather than integrating the two. (This is partially
 because OS X is by far the most prevalent Objective-C environment currently in use.)
  
 If you would like to contribute to the library or let me know that you use it, please 
 <a href="mailto:me@phillipmorelock.com?subject=DataStructuresFramework">email me</a>.  
 I am very receptive to help, criticism, flames, whatever.
 
         &mdash; <a href="http://www.phillipmorelock.com/">Phillip Morelock</a>, 2002
 */
