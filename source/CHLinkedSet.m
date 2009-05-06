/*
 CHDataStructures.framework -- CHLinkedSet.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLinkedSet.h"

@implementation CHLinkedSet

- (id) init {
	return [self initWithCapacity:0];
}

- (id) initWithArray:(NSArray *)array {
	if ([self initWithCapacity:[array count]+10] == nil) return nil;
	[self addObjectsFromArray:array];
	return self;
}

- (id) initWithCapacity:(NSUInteger)numItems {
	if ([super init] == nil) return nil;
	insertionOrder = [[CHDoublyLinkedList alloc] init];
	objects = [NSMutableSet alloc];
	if (numItems > 0)
		[objects initWithCapacity:numItems];
	else
		[objects init];
	return self;
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil) return nil;
	objects = [[decoder decodeObjectForKey:@"objects"] retain];
	insertionOrder = [[decoder decodeObjectForKey:@"insertionOrder"] retain];
	moveToBackOnReinsert = [decoder decodeBoolForKey:@"moveToBackOnReinsert"];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:objects forKey:@"objects"];
	[encoder encodeObject:insertionOrder forKey:@"insertionOrder"];
	[encoder encodeBool:moveToBackOnReinsert forKey:@"moveToBackOnReinsert"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone*)zone {
	CHLinkedSet *copy = [[CHLinkedSet alloc] init];
	for (id anObject in insertionOrder)
		[copy addObject:anObject];
	return copy;
}

#pragma mark <NSFastEnumeration>

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return [insertionOrder countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark Insertion Order

- (BOOL) reinsertionChangesOrder {
	return moveToBackOnReinsert;
}

- (void) setReinsertionChangesOrder:(BOOL)flag {
	moveToBackOnReinsert = flag;
}

#pragma mark Adding Objects

/** @bug Not yet implemented */
- (void) addObject:(id)anObject {
	// TODO: Implement
}

/** @bug Not yet implemented */
- (void) addObjectsFromArray:(NSArray*)anArray {
	// TODO: Implement
}

/** @bug Not yet implemented */
- (void) unionSet:(NSSet*)otherSet {
	// TODO: Implement
}

#pragma mark Querying Contents

- (NSArray*) allObjects {
	return [insertionOrder allObjects];
}

- (id) anyObject {
	return [objects anyObject];
}

- (BOOL) containsObject:(id)anObject {
	return [objects containsObject:anObject];
}

- (NSUInteger) count {
	return [objects count];
}

- (NSString*) description {
	return [[insertionOrder allObjects] description];
}

- (id) firstObject {
	return [insertionOrder firstObject];
}

- (BOOL) intersectsSet:(NSSet*)otherSet {
	return [objects intersectsSet:otherSet];
}

- (BOOL) isEqualToSet:(NSSet*)otherSet {
	return [objects isEqualToSet:otherSet];
}

- (BOOL) isSubsetOfSet:(NSSet*)otherSet {
	return [objects isSubsetOfSet:otherSet];
}

- (id) lastObject {
	return [insertionOrder lastObject];
}

- (id) member:(id)anObject {
	return [objects member:anObject];
}

- (NSEnumerator*) objectEnumerator {
	return [insertionOrder objectEnumerator];
}

- (NSSet*) set {
	return [[objects copy] autorelease];
}

#pragma mark Removing Objects

/** @bug Not yet implemented */
- (void) intersectSet:(NSSet*)otherSet {
	// TODO: Implement
}

/** @bug Not yet implemented */
- (void) minusSet:(NSSet*)otherSet {
	// TODO: Implement
}

- (void) removeAllObjects {
	[objects removeAllObjects];
	[insertionOrder removeAllObjects];
}

- (void) removeFirstObject {
	[self removeObject:[insertionOrder firstObject]];
}

- (void) removeLastObject {
	[self removeObject:[insertionOrder lastObject]];
}

- (void) removeObject:(id)anObject {
	if (anObject != nil) {
		[objects removeObject:anObject];
		[insertionOrder removeObject:anObject];
	}
}

@end
