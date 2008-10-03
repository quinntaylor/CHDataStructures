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

//  Queue.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a> protocol
 with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a> ("First In,
 First Out") operations.
 
 A queue is commonly compared to waiting in line. When objects are added, they go to
 the back of the line, and objects are always removed from the front of the line.
 These actions are accomplished using @link #addObject: -addObject:\endlink
 and @link #removeObject -removeObject\endlink, respectively. The frontmost object
 may be examined (without removing it) using @link #nextObject -nextObject\endlink.
 
 @todo Add support for methods in NSCoding and NSMutableCopying.
 */
@protocol Queue <NSObject, NSFastEnumeration>

/**
 Initialize a newly-allocated queue with no objects.
 */
- (id) init;

/**
 Add an object to the back of the queue.
 
 @param anObject The object to add to the queue; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObject:(id)anObject;

/**
 Remove and return the object at the front of the queue.
 
 @return The frontmost object in the queue, or <code>nil</code> if the queue is empty.
 */
- (id) removeObject;

/**
 Examine the object at the front of the queue without removing it.
 
 @return The frontmost object in the queue, or <code>nil</code> if the queue is empty.
 */
- (id) nextObject;

/**
 Returns an array containing the objects in this queue, ordered from front to back.
 
 @return An array containing the objects in this queue. If the queue is empty, the
         array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently in the queue.
 
 @return The number of objects currently in the queue.
 */
- (NSUInteger) count;

/**
 Remove all objects from the queue; if it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an enumerator that accesses each object in the queue from front to back.
 
 NOTE: When you use an enumerator, you must not modify the queue during enumeration. 
 */
- (NSEnumerator*) objectEnumerator;

@end
