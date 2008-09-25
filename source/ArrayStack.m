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
    if ([super init] == nil) {
		[self release];
		return nil;
	}
    //set the stack pointer to 0 (we mean an "internal" stack pointer, i.e., where to put the next push)
    stackArray = [[NSMutableArray alloc] initWithCapacity:capacity];
    return self;
}

- (void) dealloc
{
    [stackArray release];
    [super dealloc];
}

- (void) push:(id)anObject
{
	if (anObject == nil) {
		[NSException raise:NSInvalidArgumentException
					format:@"Object to be added cannot be nil."];
	}
	else {
		[stackArray addObject:anObject]; // Inserts at the end of the array
	}
}

- (id) pop
{
    if ([stackArray count] == 0)
		return nil;
	
    id object = [[stackArray lastObject] retain];
    [stackArray removeLastObject];    
    return [object autorelease];
}

- (id) peek
{
    if ([stackArray count] == 0)
		return nil;

	return [stackArray lastObject];
}

- (unsigned int) count
{
    return [stackArray count];
}

+ (ArrayStack *) stackWithArray:(NSArray *)array 
                        ofOrder:(BOOL)direction
{
    if ([array count] == 0)
		return nil;
	
	ArrayStack *stack = [[ArrayStack alloc] init];
    int size = [array count];
    int i = 0;
    
    if (!direction) //so the order to pop will be from 0...n
    {
        while (i < size)
            [stack push: [array objectAtIndex: i++]];
    }
    else //order to pop will be n...0
    {
        while (size > i)
            [stack push: [array objectAtIndex: --size]];
    }
	
    return [stack autorelease];
}

@end
