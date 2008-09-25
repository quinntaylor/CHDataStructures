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

//  ArrayQueue.m
//  Data Structures Framework

#import "ArrayQueue.h"

@implementation ArrayQueue

- (id) init
{
    return [self initWithCapacity:10];
}

- (id) initWithCapacity:(unsigned int)capacity
{
    self = [super init];
    
    queue = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    backIndex = -1;
    frontIndex = 0;
    
    
    return self;
}

- (void) dealloc
{
    [queue release];
    [super dealloc];
}

- (void) enqueue: (id)anObject
{
	if (anObject == nil) {
		[NSException raise:NSInvalidArgumentException
					format:@"Object to be added cannot be nil."];
	}
	else {
		++backIndex;
		[queue insertObject:anObject atIndex:backIndex];
	}    
}

- (id) dequeue
{
    if ([queue count] == 0)
		return nil;

    //get it and retain it
    id theObj = [[queue objectAtIndex:frontIndex] retain];
    [queue replaceObjectAtIndex:frontIndex withObject:[NSNull null]];
    
    //now increment front -- if we have large array and we've "caught up" with
    //the back, then let's dealloc and start over.
    ++frontIndex;
    if (frontIndex > 25 && [queue count] < 0)
    {
		[self removeAllObjects];
    }
	// TODO: Fix this ridiculous hack; NSMutableArray can act as a circlar buffer
    
    return [theObj autorelease];
}

- (id) front
{
	return [queue objectAtIndex:frontIndex];
}


- (unsigned int) count
{
	return [queue count];
}

- (void) removeAllObjects
{
    if (queue != nil)
		[queue release];
    
    queue = [[NSMutableArray alloc] initWithCapacity:10];
    backIndex = -1;
    frontIndex = 0;

}

+ (ArrayQueue *) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction
{
    ArrayQueue *q = [[ArrayQueue alloc] init];
    int s = [array count];
    int i = 0;
    
    if (!array || !s)
		; //nada
    else if (direction)//so the order to dequeue will be from 0...n
    {
        while (i < s)
            [q enqueue: [array objectAtIndex: i++]];
    }
    else //order to dequeue will be n...0
    {
        while (s > i)
            [q enqueue: [array objectAtIndex: --s]];
    }

    return [q autorelease];
}


@end
