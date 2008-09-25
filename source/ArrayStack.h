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

//  ArrayStack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Stack.h"

/**
 A fairly basic Stack implementation that uses an NSMutableArray to store objects.
 */
@interface ArrayStack : NSObject <Stack>
{
    /** The actual stack. */
    NSMutableArray *theArrayStack;
    /** The "top of stack". this is the next index that an element will go into. */
    unsigned int nextIndex;
}

/**
 Create a new stack starting with an NSMutableArray of the specified capacity.
 */
- (id) initWithCapacity:(unsigned)capacity;

#pragma mark Inherited Methods
- (BOOL) push:(id)object;
- (id) pop;
- (id) peek;
- (unsigned int) count;

#pragma mark Redefined Methods
+ (ArrayStack *) stackWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end