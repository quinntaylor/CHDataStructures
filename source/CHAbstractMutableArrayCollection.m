/*
 CHDataStructures.framework -- CHAbstractMutableArrayCollection.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHAbstractMutableArrayCollection.h"

@implementation CHAbstractMutableArrayCollection

- (void) dealloc {
	[array release];
	[super dealloc];
}

/**
 Initialize a collection with no objects.
 */
- (id) init {
	if ([super init] == nil) return nil;
	array = [[NSMutableArray alloc] init];
	return self;
}

/**
 Initialize a collection with the contents of the given array.
 */
- (id) initWithArray:(NSArray*)anArray {
	if ([super init] == nil) return nil;
	array = [anArray mutableCopy];
	return self;
}

#pragma mark <NSCoding>

/**
 Initialize a collection with data from a given keyed unarchiver.
 
 @param decoder A keyed unarchiver object.

 @see NSCoding protocol
*/
- (id) initWithCoder:(NSCoder*)decoder {
	if ([super init] == nil) return nil;
	array = [[decoder decodeObjectForKey:@"array"] retain];
	return self;
}

/**
 Encodes data from the receiver using a given keyed archiver.
 
 @param encoder A keyed archiver object.

 @see NSCoding protocol
*/
- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:array forKey:@"array"];
}

#pragma mark <NSCopying>

/**
 Returns a new instance that's a copy of the receiver. The returned object is
 implicitly retained by the sender, who is responsible for releasing it. For
 this class and its children, all copies are mutable. Invoked automatically by
 the default <code>-copy</code> method inherited from NSObject.
 
 @param zone Identifies an area of memory from which to allocate the new
 instance. If zone is <code>NULL</code>, the new instance is allocated
 from the default zone. (<code>-copy</code> invokes with a NULL param.)
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithArray:array];
}

#pragma mark <NSFastEnumeration>

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs.
 Returns by reference a C array of objects over which the sender should iterate,
 and as the return value the number of objects in the array.
 
 @param state Context information that is used in the enumeration to ensure that
        the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 
 @see NSFastEnumeration protocol
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return [array countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark -

- (NSUInteger) count {
	return [array count];
}

- (BOOL) containsObject:(id)anObject {
	return [array containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([array indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger) indexOfObject:(id)anObject {
	return [array indexOfObject:anObject];
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	return [array indexOfObjectIdenticalTo:anObject];
}

- (id) objectAtIndex:(NSUInteger)index {
	return [array objectAtIndex:index];
}

- (void) removeObject:(id)anObject {
	[array removeObject:anObject];
}

- (void) removeObjectIdenticalTo:(id)anObject {
	[array removeObjectIdenticalTo:anObject];
}

- (void) removeAllObjects {
	[array removeAllObjects];
}

- (NSArray*) allObjects {
	return [[array copy] autorelease];
}

- (NSEnumerator*) objectEnumerator {
	return [array objectEnumerator];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [array reverseObjectEnumerator];
}

- (NSString*) description {
	return [array description];
}

@end
