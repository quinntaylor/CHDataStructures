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

//retains your object
//if you try to enqueue nil, it will return false
- (BOOL) enqueue:(id)pushedObj;

//returns and autoreleases your object
//returns nil if the queue is empty.
- (id) dequeue;

/**
 Returns the number of objects currently in the queue.
 */
- (unsigned int)count;

//releases the queue and starts a new one.
- (void) removeAllObjects;

/**
 * Returns an autoreleased queue with the contents of your 
 * array in the specified order.
 * YES means that objects will dequeue in the order indexed (0...n)
 * whereas NO means that objects will dequeue (n...0).
 * Your array will not be changed, released, etc.  The queue will retain,
 * not copy, your references.  If you retain this queue, your array will
 * be safe to release.
 */
+ (id <Queue>)queueWithArray:(NSArray *)array
                        ofOrder:(BOOL)direction;

@end
