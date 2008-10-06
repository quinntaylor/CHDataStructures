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

//  Heap.h
//  DataStructuresFramework

//  Copyright (c) 2002 Gordon Worley redbird@rbisland.cx
//  Minor contributions by Phillip Morelock for purposes of library integration.
//  Many thanks to Gordon for the very first outside contribution to the library!

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol,
 suitable for use with many variations of the heap structure.
 
 Since objects in a Heap are inserted according to their sorted order, all objects
 must respond to the <code>compare:</code> selector, which accepts another object
 and returns NSOrderedAscending, NSOrderedSame, or NSOrderedDescending as the
 receiver is less than, equal to, or greater than the argument, respectively. (See
 NSComparisonResult in NSObjCRuntime.h for details.) 
 
 @todo Add support for methods in NSCoding, NSMutableCopying, and NSFastEnumeration.
 */
@protocol Heap <NSObject>

/**
 Initialize a newly-allocated heap with no objects.
 */
- (id) init;

/**
 Insert a given object into the heap.

 @param anObject The object to add to the heap; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObject:(id)anObject;

/**
 Remove and return the first element in the heap. Rearranges the remaining elements.
 
 @return The first element in the heap, or <code>nil</code> if the heap is empty.
 */
- (id) removeRoot;

/**
 Remove and return the last element in the heap.
 
 @return The last element in the heap, or <code>nil</code> if the heap is empty.
 */
- (id) removeLast;

/**
 Returns the number of objects currently in the heap.
 
 @return The number of objects currently in the heap.
 */
- (NSUInteger) count;

// NOTE: For a future release:

//- (id) initWithSortOrder:(NSComparisonResult)sortOrder; // for min/max heaps
//- (void) addObjectsFromHeap:(id<Heap>)otherHeap;

@end
