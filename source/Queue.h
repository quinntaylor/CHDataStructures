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
 A basic queue interface
 */
@protocol Queue <NSObject>

/**
 Add an object to the end of the queue. Returns NO if the object is <code>nil</code>.
 */
- (BOOL) enqueue:(id)anObject;

/**
 Remove and return the object at the front of the queue, or <code>nil</code> if the
 queue is empty.
 */
- (id) dequeue;

/**
 Returns the number of objects currently in the queue.
 */
- (unsigned int)count;

/**
 Remove all objects from the queue. If it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an autoreleased queue with the contents of the array in the same order.
 For direction, YES means that objects will dequeue in the order indexed (0...n),
 whereas NO means that objects will dequeue (n...0).
 */
+ (id <Queue>) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
