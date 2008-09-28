//  DataStructures.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>

#pragma mark Framework Protocols

#import "Deque.h"
#import "Heap.h"
#import "LinkedList.h"
#import "Queue.h"
#import "Stack.h"
#import "Tree.h"

#pragma mark Framework Classes

#import "AbstractQueue.h"
#import "AbstractStack.h"
#import "AbstractTree.h"
#import "ArrayHeap.h"
#import "ArrayQueue.h"
#import "ArrayStack.h"
#import "Comparable.h"
#import "DoublyLinkedList.h"
#import "LLQueue.h"
#import "LLStack.h"
#import "RedBlackTree.h"
#import "UnbalancedTree.h"

/**
 @mainpage DataStructures.framework
 
 This framework provides Objective-C implementations of several data structures, a
 piece which many people have felt is missing from Apple's Cocoa framework. Apple's
 stance is that NSArray/NSDictionary/NSSet and children should be enough, and usually
 they are sufficient (and extremely optimized!), but sometimes an honest-to-goodness
 linked list, tree, stack, queue, deque, heap, etc. is what you really want/need.
 
 This framework is an attempt to create a library of standard data structures which
 can be reliably used in Objective-C programs. It is currently distributed under the
 <a href="http://www.gnu.org/copyleft/lesser.html">GNU LGPL</a> and the source is
 available at <a href="http://www.phillipmorelock.com/examples/cocoadata/">this web
 page</a>.
 
 <!-- LGPL v.2 @ http://www.gnu.org/licenses/old-licenses/gpl-2.0.html -->
 
 The data structures in this framework are built off of Objective-C <i>protocols</i>
 (which are the predecessors of Java <i>interfaces</i>) that define the functionality
 and API for interacting with any implementation thereof, regardless of the internal
 workings.
 
 Although this framework is targeted at Mac OS X, most of the code could be easily
 ported to other environments, such as <a href="http://www.gnustep.org">GNUStep</a>.
 In the interest of cleanliness and maintainability, such efforts would probably best
 be accomplished by forking from this project's codebase, rather than integrating the
 two. (This is partially because OS X is the dominant Objective-C environment.)
  
 If you would like to contribute to the library, or if you want to be cool and let me
 know that you are getting some use out of it, please 
 <a href="mailto:me@phillipmorelock.com?subject=DataStructuresFramework">email me</a>.  
 I am very receptive to help, criticism, flames, whatever.
 
    &mdash; <a href="http://www.phillipmorelock.com/">Phillip Morelock</a>, 2002
 */
