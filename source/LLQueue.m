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

//  LLQueue.m
//  DataStructuresFramework

#import "LLQueue.h"
#import "DoublyLinkedList.h"

@implementation LLQueue

- (id)init
{
	[super init];
	list = [[DoublyLinkedList alloc] init];
	return self;
}

- (void)dealloc
{
	[list release];
	[super dealloc];
}

//if you try to enqueue nil, it will return false
- (BOOL) enqueue:(id)pushedObj
{
	if (!pushedObj)
		return NO;
	
	[list addObjectToBack:pushedObj];
	return YES;
}

//returns nil if the queue is empty.
- (id) dequeue
{
	id retval = [[list firstObject] retain];
	[list removeFirstObject];
	return [retval autorelease];
}

- (id) front
{
	return [list firstObject];
}

- (unsigned int) count
{
	return [list count];
}

- (void) removeAllObjects
{
	[list removeAllObjects];
}

- (NSEnumerator *)objectEnumerator
{
	return [list objectEnumerator];
}

+ (LLQueue *) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction
{
	LLQueue *q;
	int i,s;
	
	q = [[LLQueue alloc] init];
	s = [array count];
	i = 0;
	
	if (!array || !s)
		;
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
