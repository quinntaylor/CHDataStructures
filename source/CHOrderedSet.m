/*
 CHDataStructures.framework -- CHOrderedSet.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHOrderedSet.h"
#import "CHAbstractCircularBufferCollection.h"

@implementation CHOrderedSet

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
	ordering = [[CHAbstractCircularBufferCollection alloc] init];
	if (numItems > 0)
		objects = [[NSMutableSet alloc] initWithCapacity:numItems];
	else
		objects = [[NSMutableSet alloc] init];
	return self;
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil) return nil;
	objects = [[decoder decodeObjectForKey:@"objects"] retain];
	ordering = [[decoder decodeObjectForKey:@"ordering"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:objects forKey:@"objects"];
	[encoder encodeObject:ordering forKey:@"ordering"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone*)zone {
	CHOrderedSet *copy = [[CHOrderedSet allocWithZone:zone] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
	for (id anObject in ordering)
#else
	NSEnumerator *e = [ordering objectEnumerator];
	id anObject;
	while (anObject = [e nextObject])
#endif
	{
		[copy addObject:anObject];
	}
	return copy;
}

#pragma mark <NSFastEnumeration>

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return [ordering countByEnumeratingWithState:state objects:stackbuf count:len];
}
#endif

#pragma mark Adding Objects

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (![objects containsObject:anObject])
		[ordering appendObject:anObject];
	[objects addObject:anObject];
}

- (void) addObjectsFromArray:(NSArray*)anArray {
	if (anArray == nil)
		CHNilArgumentException([self class], _cmd);
#if MAC_OS_X_VERSION_10_5_AND_LATER
	for (id anObject in anArray)
#else
	NSEnumerator *e = [anArray objectEnumerator];
	id anObject;
	while (anObject = [e nextObject])
#endif
	{
		if (![objects containsObject:anObject])
			[ordering appendObject:anObject];
		[objects addObject:anObject];
	}
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	[ordering exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (index > [objects count])
		CHIndexOutOfRangeException([self class], _cmd, index, [objects count]);
	if ([objects containsObject:anObject])
		[ordering removeObject:anObject];
	[ordering insertObject:anObject atIndex:index];
	[objects addObject:anObject];
}

- (void) unionSet:(NSSet*)otherSet {
#if MAC_OS_X_VERSION_10_5_AND_LATER
	for (id anObject in otherSet)
#else
	NSEnumerator *e = [otherSet objectEnumerator];
	id anObject;
	while (anObject = [e nextObject])
#endif
	{
		if (![objects containsObject:anObject])
			[ordering appendObject:anObject];
		[objects addObject:anObject];
	}
}

#pragma mark Querying Contents

- (NSArray*) allObjects {
	return [ordering allObjects];
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
	return [[ordering allObjects] description];
}

- (NSString*) debugDescription {
	return [NSString stringWithFormat:@"objects = %@,\nordering = %@",
	        [objects description], [[ordering allObjects] description]];
}

- (id) firstObject {
	return [ordering firstObject];
}

- (NSUInteger) indexOfObject:(id)anObject {
	return [ordering indexOfObject:anObject];
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
	return [ordering lastObject];
}

- (id) member:(id)anObject {
	return [objects member:anObject];
}

- (id) objectAtIndex:(NSUInteger)index {
	return [ordering objectAtIndex:index];
}

- (NSEnumerator*) objectEnumerator {
	return [ordering objectEnumerator];
}

- (NSSet*) set {
	return [[objects copy] autorelease];
}

#pragma mark Removing Objects

- (void) intersectSet:(NSSet*)otherSet {
	// If there are no objects in common with @otherSet, just remove everything.
	if (![objects intersectsSet:otherSet]) {
		[self removeAllObjects];
	}
	else {
		[objects intersectSet:otherSet];
		// Remove from insertion ordering items NOT present in intersected set.
		id newOrdering = [[[ordering class] alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in ordering)
#else
		NSEnumerator *e = [ordering objectEnumerator];
		id anObject;
		while (anObject = [e nextObject])
#endif
		{
			if ([objects containsObject:anObject])
				[newOrdering appendObject:anObject];
		}
		[ordering release];
		ordering = newOrdering;
	}
}

- (void) minusSet:(NSSet*)otherSet {
	if ([otherSet count] > 0) {
		if ([objects isEqual:otherSet]) {
			[self removeAllObjects];
		} else {
			// Remove items present in receiver from insertion ordering first.
#if MAC_OS_X_VERSION_10_5_AND_LATER
			for (id anObject in otherSet)
#else
			NSEnumerator *e = [otherSet objectEnumerator];
			id anObject;
			while (anObject = [e nextObject])
#endif
			{
				if ([objects containsObject:anObject])
					[ordering removeObject:anObject];
			}
			[objects minusSet:otherSet];
		}
	}
}

- (void) removeAllObjects {
	[objects removeAllObjects];
	[ordering removeAllObjects];
}

- (void) removeFirstObject {
	[self removeObject:[ordering firstObject]];
}

- (void) removeLastObject {
	// [self removeObject:] would require a search of the entire linked list...
	if ([objects count] > 0) {
		[objects removeObject:[ordering lastObject]];
		[ordering removeLastObject]; // Much faster than searching for anObject
	}
}

- (void) removeObject:(id)anObject {
	if (anObject != nil) {
		[objects removeObject:anObject];
		[ordering removeObject:anObject];
	}
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	[objects removeObject:[ordering objectAtIndex:index]];
	[ordering removeObjectAtIndex:index];
}

@end
