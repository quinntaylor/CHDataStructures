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

//  ArrayQueue.h
//  Data Structures Framework

#import <Foundation/Foundation.h>
#import "Queue.h"

/**
 A fairly basic Queue implementation that uses an NSMutableArray to store objects.
 See the protocol definition for Queue to understand the contract.
 */
@interface ArrayQueue : NSObject <Queue>
{
    NSMutableArray *queue;
    
    int backIndex; //where to place the next element
    int frontIndex; //the current front of the queue
    unsigned int qSize;  //the current size
    unsigned int arrsz;
    
    id niller; //the marker for dead spots in the queue
}

/**
 Create a new queue starting with an NSMutableArray of the specified capacity.
 */
- (id) initWithCapacity:(unsigned int)capacity;

#pragma mark Inherited Methods
- (BOOL) enqueue:(id)anObject;
- (id) dequeue;
- (unsigned int)count;
- (void) removeAllObjects;

#pragma mark Redefined Methods
+ (ArrayQueue *) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end