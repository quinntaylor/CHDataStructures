//  CHAbstractListCollection.m
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

#import "CHAbstractListCollection.h"

@implementation CHAbstractListCollection

- (void) dealloc {
	[list release];
	[super dealloc];
}

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil)
		return nil;
	for (id anObject in anArray)
		[list appendObject:anObject];
	return self;
}

- (id) initWithList:(id<CHLinkedList>)aList {
	if ([self init] == nil)
		return nil;
	for (id anObject in aList)
		[list appendObject:anObject];
	return self;
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil)
		return nil;
	list = [[decoder decodeObjectForKey:@"list"] retain];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:list forKey:@"list"];
}

#pragma mark <NSCopying> Methods

/**
 Returns a new instance that is a copy of the receiver.
 
 @param zone The zone identifies an area of memory from which to allocate for the new
        instance. If zone is <code>NULL</code>, the instance is allocated from the
        default zone, returned from the function <code>NSDefaultMallocZone</code>.
 
 The returned object is implicitly retained by the sender, who is responsible for
 releasing it. For this class and its children, all copies are mutable.
 */
- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithList:list];
}

#pragma mark <NSFastEnumeration> Methods

/**
 Returns by reference a C array of objects over which the sender should iterate, and
 as the return value the number of objects in the array.
 
 @param state Context information that is used in the enumeration to, in addition to
        other possibilities, ensure that the collection has not been mutated.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is finished.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return [list countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark -

- (NSUInteger) count {
	return [list count];
}

- (BOOL) containsObject:(id)anObject {
	return [list containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return [list containsObjectIdenticalTo:anObject];
}

- (NSUInteger) indexOfObject:(id)anObject {
	return [list indexOfObject:anObject];
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	return [list indexOfObjectIdenticalTo:anObject];
}

- (id) objectAtIndex:(NSUInteger)index {
	return [list objectAtIndex:index];
}

- (void) removeObject:(id)anObject {
	[list removeObject:anObject];
}

- (void) removeAllObjects {
	[list removeAllObjects];
}

- (NSArray*) allObjects {
	return [list allObjects];
}

- (NSEnumerator*) objectEnumerator {
	return [list objectEnumerator];
}

- (NSString*) description {
	return [list description];
}

@end
