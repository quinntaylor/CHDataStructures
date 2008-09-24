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

/////SEE LICENSE FILE FOR LICENSE INFORMATION///////

#import "ArrayQueue.h"

@implementation ArrayQueue

- init
{
    return [self initWithCapacity:10];
}

-initWithCapacity:(unsigned)capacity
{
    self = [super init];
    
    theQ = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    backIndex = -1;
    frontIndex = 0;
    qSize = 0;
    
    niller = [[NSString stringWithFormat:@"nothing"] retain];
    
    return self;
}

-(void) dealloc
{
    [theQ release];
    [niller release];
    [super dealloc];
}

-(BOOL) enqueue: (id)enqueuedObj
{
    if ( enqueuedObj == nil )
	return NO;
    
    ++backIndex;
    [theQ insertObject:enqueuedObj atIndex:backIndex];
    ++qSize;
    return YES;
}

- dequeue
{
    id theObj;

    if ( qSize < 1 )
	return nil;
    
    //decrement the size of the Q
    --qSize;

    //get it and retain it
    theObj = [[theQ objectAtIndex:frontIndex] retain];
    [theQ replaceObjectAtIndex:frontIndex withObject:niller];
    
    //now increment front -- if we have large array and we've "caught up" with
    //the back, then let's dealloc and start over.
    ++frontIndex;
    if (frontIndex > 25 && qSize < 0)
    {
	[self removeAllObjects];
    }
    
    return [theObj autorelease];
}

-(unsigned) count
{
    return qSize;
}

//simple BOOL for whether the queue is empty or not.
-(BOOL) isEmpty
{
    if ( qSize < 1)
	return YES;
    else
	return NO;
}

-(void) removeAllObjects
{
    if (theQ)
	[theQ release];
    
    theQ = [[NSMutableArray alloc] initWithCapacity:10];
    backIndex = -1;
    frontIndex = 0;
    qSize = 0;

}

+(ArrayQueue *)queueWithArray:(NSArray *)array
                  ofOrder:(BOOL)direction
{
    ArrayQueue *q;
    int i,s;
    
    q = [[ArrayQueue alloc] init];
    s = [array count];
    i = 0;
    
    if (!array || !s)
    {}//nada
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
