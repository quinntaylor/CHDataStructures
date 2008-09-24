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
/*
 *  ArrayQueue.h
 *  Data Structures Framework
/////SEE LICENSE FILE FOR LICENSE INFORMATION///////
 *
 */

//////////
//A fairly basic queue implementation that puts its data in an NSMutableArray
//See the protocol definition for Queue to understand the contract.
/////////

#import <Foundation/Foundation.h>
#import "Queue.h"

@interface ArrayQueue : NSObject <Queue>
{
    NSMutableArray *theQ;
    
    int backIndex; //where to place the next element
    int frontIndex; //the current front of the queue
    unsigned int qSize;  //the current size
    unsigned int arrsz;
    
    id niller; //the marker for dead spots in the queue
}

- init;
- initWithCapacity:(unsigned)capacity;

//returns the size of the queue currently
-(unsigned int) count;

/**
 * see protocol declaration for Queue
 */
+(ArrayQueue *)queueWithArray:(NSArray *)array
                        ofOrder:(BOOL)direction;
@end