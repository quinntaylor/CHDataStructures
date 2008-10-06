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

//  ListStack.m
//  DataStructuresFramework

#import "ListStack.h"

/**
 This implementation uses a SinglyLinkedList, since it's slightly faster than using
 a DoublyLinkedList, and requires a little less memory. Also, since it's a stack, it
 is unlikely that there is any need to enumerate over the object from bottom to top.
 */
@implementation ListStack

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [[SinglyLinkedList alloc] init];
	return self;
}

- (void) dealloc {
	[list release];
	[super dealloc];
}

- (void) pushObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	else
		[list prependObject:anObject];
}

- (id) popObject {
	if ([list count] == 0)
		return nil;
	id retval = [[list firstObject] retain];
	[list removeFirstObject];
	return [retval autorelease];
}

- (id) topObject {
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

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(id*)stackbuf
                                    count:(NSUInteger)len
{
	return [list countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
