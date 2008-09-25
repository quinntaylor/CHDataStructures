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

//  ArrayStack.m
//  DataStructuresFramework

#import "ArrayStack.h"

@implementation ArrayStack

- (id) init
{
    //so we set up the array with initial capacity of 10 items.
    return [self initWithCapacity:10];
}

- (id) initWithCapacity:(unsigned)capacity
{
    //set the stack pointer to 0 (we mean an "internal" stack pointer, i.e., where to put the next push)
    [super init];
    theArrayStack = [[NSMutableArray alloc] initWithCapacity:capacity];
    nextIndex = 0;
    return self;
}

- (void) dealloc
{
    [theArrayStack release];
    [super dealloc];
}

- (BOOL) push:(id)object
{
    if ( object == nil )
		return NO;
	
    //it wasn't nil, so push it
    [theArrayStack insertObject:object atIndex:nextIndex];
    ++nextIndex;
    return YES;
}

- (id) pop
{
    //what we'll return
    id theObj;
    
    if ( nextIndex < 1 ) //empty
    {
		return nil;
    }
	
    theObj = [[theArrayStack objectAtIndex: (nextIndex - 1)] retain];
    [theArrayStack removeObjectAtIndex: (nextIndex - 1)];
    --nextIndex;
    
    return [theObj autorelease];
}

- (unsigned int) count
{
    return nextIndex;
}

+ (ArrayStack *) stackWithArray:(NSArray *)array 
                        ofOrder:(BOOL)direction
{
    ArrayStack *s;
    int i,sz;
    
    s = [[ArrayStack alloc] init];
    sz = [array count];
    i = 0;
    
    if (!array || !sz)
    {}//nada
    else if (!direction)//so the order to pop will be from 0...n
    {
        while (i < sz)
            [s push: [array objectAtIndex: i++]];
    }
    else //order to pop will be n...0
    {
        while (sz > i)
            [s push: [array objectAtIndex: --sz]];
    }
	
    return [s autorelease];
}

@end
