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

/**
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a> protocol
 with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a> operations.
 */
@protocol Queue <NSObject>

/**
 Add an object to the back of the queue.
 
 @param anObject The object to add to the queue; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) enqueue:(id)anObject;

/**
 Remove and return the object at the front of the queue.
 
 @return The frontmost object in the queue, or <code>nil</code> if the queue is empty.
 */
- (id) dequeue;

/**
 Examine the object at the front of the queue without removing it.
 
 @return The frontmost object in the queue, or <code>nil</code> if the queue is empty.
 */
- (id) front;

/**
 Returns the number of objects currently in the queue.
 
 @return The number of objects currently in the queue.
 */
- (unsigned int) count;

/**
 Remove all objects from the queue; if it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an autoreleased Queue with the contents of the array in the specified order.
 
 @param array An array of objects to add to the queue.
 @param direction The order in which to enqueue objects from the array. YES means the 
        natural index order (0...n), NO means reverse index order (n...0).
 */
+ (id <Queue>) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
