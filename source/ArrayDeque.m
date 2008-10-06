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

//  ArrayDeque.m
//  DataStructuresFramework

#import "ArrayDeque.h"

@implementation ArrayDeque

- (void) dealloc {
	[array release];
	[super dealloc];
}

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[NSMutableArray alloc] init];
	return self;
}

/**
 Private initializer for NSCopying; makes a mutable copy of the array
 */
- (id) initWithArray:(NSArray*)anArray {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [anArray mutableCopy];
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
	array = [[decoder decodeObjectForKey:@"ArrayDeque"] retain];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:array forKey:@"ArrayDeque"];
}

#pragma mark Deque Implementation

- (void) prependObject:(id)anObject {
	[array insertObject:anObject atIndex:0];
}

- (void) appendObject:(id)anObject {
	[array addObject:anObject];
}

- (id) firstObject {
	return [array objectAtIndex:0];
}

- (id) lastObject {
	return [array lastObject];
}

- (NSArray*) allObjects {
	return [array copy];
}

- (void) removeFirstObject {
	[array removeObjectAtIndex:0];
}

- (void) removeLastObject {
	[array removeLastObject];
}

- (void) removeAllObjects {
	[array removeAllObjects];
}

- (BOOL) containsObject:(id)anObject {
	return [array containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([array indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger) count {
	return [array count];
}

- (NSEnumerator*) objectEnumerator {
	return [array objectEnumerator];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [array reverseObjectEnumerator];
}

#pragma mark <NSCopying> Methods

- (id) copyWithZone:(NSZone *)zone {
	return [[ArrayDeque alloc] initWithArray:array];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(id*)stackbuf
                                    count:(NSUInteger)len
{
	return [array countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
