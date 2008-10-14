//  CHListQueue.m
//  CHDataStructures.framework

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

#import "CHListQueue.h"

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than using
 a CHDoublyLinkedList, and requires a little less memory. Also, since it's a queue,
 it's unlikely that there is any need to enumerate over the object from back to front.
 */
@implementation CHListQueue

- (void) dealloc {
	[list release];
	[super dealloc];
}

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

/**
 Private initializer for NSCopying; makes a mutable copy of the array
 */
- (id) initWithList:(id<CHLinkedList>)aList {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [aList copyWithZone:nil];
	return self;
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [[decoder decodeObjectForKey:@"ListQueue"] retain];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:list forKey:@"ListQueue"];
}

#pragma mark Queue Implementation

- (void) addObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	else
		[list appendObject:anObject];
}

- (id) nextObject {
	return [list firstObject];
}

- (void) removeNextObject {
	[list removeFirstObject];
}

- (void) removeAllObjects {
	[list removeAllObjects];
}

- (NSArray*) allObjects {
	return [list allObjects];
}

- (NSUInteger) count {
	return [list count];
}

- (BOOL) containsObject:(id)anObject {
	return [list containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return [list containsObjectIdenticalTo:anObject];
}

- (NSEnumerator*) objectEnumerator {
	return [list objectEnumerator];
}

#pragma mark <NSCopying> Methods

- (id) copyWithZone:(NSZone *)zone {
	return [[CHListQueue alloc] initWithList:list];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return [list countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
