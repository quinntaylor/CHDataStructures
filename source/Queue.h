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
//
//  Queue.h
//  DataStructuresFramework
//
/////SEE LICENSE FILE FOR LICENSE INFORMATION///////

//////////////
//a VERY basic queue interface
/////////////

#import <Foundation/Foundation.h>


@protocol Queue <NSObject>

//if you try to enqueue nil, it will return false
//retains your object
- (BOOL) enqueue:(id)pushedObj;

//returns nil if the queue is empty.
//autoreleases your object
- (id) dequeue;

//simple BOOL for whether the queue is empty or not.
//count == 0 usually, or for linked lists it's a nil test. 
- (BOOL) isEmpty;

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
