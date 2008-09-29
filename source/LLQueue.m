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

- (id) init {
	return [self initWithObjectsFromEnumerator:nil];
}

- (id) initWithObjectsFromEnumerator:(NSEnumerator*)anEnumerator {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [DoublyLinkedList listWithArray:[anEnumerator allObjects] ofOrder:YES];
	return self;
}

- (void) dealloc {
	[list release];
	[super dealloc];
}

- (void) enqueueObject:(id)anObject {
	if (anObject == nil)
		invalidNilArgumentException([self class], _cmd);
	else
		[list addObjectToBack:anObject];
}

- (id) dequeueObject {
	if ([list count] == 0)
		return nil;
	id retval = [[list firstObject] retain];
	[list removeFirstObject];
	return [retval autorelease];
}

- (id) frontObject {
	return [list firstObject];
}

- (NSArray*) allObjects {
	return [list allObjects];
}

- (NSUInteger) count {
	return [list count];
}

- (void) removeAllObjects {
	[list removeAllObjects];
}

- (NSEnumerator*) objectEnumerator {
	return [list objectEnumerator];
}

@end
