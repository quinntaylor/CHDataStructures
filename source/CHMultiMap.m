/*
 CHMultiMap.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import "CHMultiMap.h"

@implementation CHMultiMap

- (void) dealloc {
	[dictionary release];
	[super dealloc];
}

#pragma mark Initialization

- (id) init {
	if ([super init] == nil) return nil;
	dictionary = [[NSMutableDictionary alloc] init];
	count = 0;
	mutations = 0;
	return self;
}

static inline NSMutableSet* wrapInMutableSet(id object) {
	if (object == nil)
		return nil;
	return ([object isKindOfClass:[NSSet class]])
		? [NSMutableSet setWithSet:object]
		: [NSMutableSet setWithObject:object];
}

- (id) initWithObjects:(NSArray*)objectsArray forKeys:(NSArray*)keyArray {
	if ([keyArray count] != [objectsArray count])
		CHInvalidArgumentException([self class], _cmd, @"Unequal array counts.");
	if ([self init] == nil) return nil;
	NSEnumerator *objects = [objectsArray objectEnumerator];
	NSSet *objectSet;
	for (id key in keyArray) {
		objectSet = wrapInMutableSet([objects nextObject]);
		[dictionary setObject:objectSet forKey:key];
		count += [objectSet count];
	}
	return self;
}

- (id) initWithObjectsAndKeys:(id)firstObject, ... {
	if ([self init] == nil) return nil;
	
	if (firstObject == nil)
		CHInvalidArgumentException([self class], _cmd, @"First parameter is nil.");
	
	// Start scanning for arguments after firstObject
	va_list argumentList;
	va_start(argumentList, firstObject);
	
	// The first argument isn't part of the varargs list; handle it separately
	NSSet *objectSet = wrapInMutableSet(firstObject);
	id aKey;
	// Add an entry for each valid pair of object-key parameters.
	do {
		if ((aKey = va_arg(argumentList, id)) == nil)
			CHInvalidArgumentException([self class], _cmd, @"Invalid nil key.");
		[dictionary setObject:objectSet forKey:aKey];
		count += [objectSet count];
	} while (objectSet = wrapInMutableSet(va_arg(argumentList, id)));
	va_end(argumentList);
	return self;
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder*)decoder{
	if ([self init] == nil) return nil;
	dictionary = [[decoder decodeObjectForKey:@"dictionary"] retain];
	count = [decoder decodeIntegerForKey:@"count"];
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:dictionary forKey:@"dictionary"];
	[encoder encodeInteger:count forKey:@"count"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone*)zone {
	CHMultiMap *newDictionary = [[CHMultiMap alloc] init];
	for (id key in [self allKeys])
		[newDictionary setObjects:[[dictionary objectForKey:key] mutableCopy]
						   forKey:key];
	return newDictionary;
}

#pragma mark Queries

- (NSUInteger) count {
	return [dictionary count];
}

- (NSUInteger) countForKey:(id)aKey {
	return [[dictionary objectForKey:aKey] count];
}

- (NSUInteger) countForAllKeys {
	return count;
}

- (BOOL) containsKey:(id)aKey {
	return ([dictionary objectForKey:aKey] != nil);
}

- (BOOL) containsObject:(id)anObject {
	for (id key in [self keyEnumerator]) {
		if ([[dictionary objectForKey:key] containsObject:anObject])
			return YES;
	}
	return NO;
}

- (NSArray*) allKeys {
	return [dictionary allKeys];
}

- (NSArray*) allObjects {
	NSMutableArray *objects = [NSMutableArray array];
	for (id key in [self allKeys])
		for (id object in [dictionary objectForKey:key])
			[objects addObject:object];
	return objects;
}

- (NSEnumerator*) keyEnumerator {
	return [dictionary keyEnumerator];
}

- (NSEnumerator*) objectEnumerator {
	return [[self allObjects] objectEnumerator];
	// TODO: Refine with custom enumerator for greater efficiency?
}

- (NSSet*) objectsForKey:(id)aKey {
	id objectSet = [dictionary objectForKey:aKey];
	return (objectSet == nil) ? nil : [NSSet setWithSet:objectSet];
}

- (NSString*) description {
	return [dictionary description];
}

#pragma mark Mutation

- (void) addEntriesFromMultiMap:(CHMultiMap*)otherMultiMap; {
	for (id key in [otherMultiMap allKeys])
		[self addObjects:[otherMultiMap objectsForKey:key] forKey:key];
	++mutations;
}

- (void) addObject:(id)anObject forKey:(id)aKey {
	NSMutableSet *objects = [dictionary objectForKey:aKey];
	count -= [objects count];
	if (objects == nil) {
		objects = [NSMutableSet set];
		[dictionary setObject:objects forKey:aKey];
	}
	[objects addObject:anObject];
	count += [objects count];
	++mutations;
}

- (void) addObjects:(NSSet*)objectSet forKey:(id)aKey {
	NSMutableSet *objects = [dictionary objectForKey:aKey];
	count -= [objects count];
	if (objects == nil) {
		objects = [NSMutableSet set];
		[dictionary setObject:objects forKey:aKey];
	}
	[objects unionSet:objectSet];
	count += [objects count];
	++mutations;
}

- (void) setObjects:(NSSet*)objectSet forKey:(id)aKey {	
	count += ([objectSet count] - [[dictionary objectForKey:aKey] count]);
	[dictionary setObject:[NSMutableSet setWithSet:objectSet] forKey:aKey];
	++mutations;
}

- (void) removeObject:(id)anObject forKey:(id)aKey {
	NSMutableSet *objects = [dictionary objectForKey:aKey];
	if ([objects containsObject:anObject]) {
		[objects removeObject:anObject];
		--count;
		if ([objects count] == 0)
			[dictionary removeObjectForKey:aKey];
	}
	++mutations;
}

- (void) removeObjectsForKey:(id)aKey {
	count -= [[dictionary objectForKey:aKey] count];
	[dictionary removeObjectForKey:aKey];
	++mutations;
}

- (void) removeAllObjects {
	count = 0;
	[dictionary removeAllObjects];
	++mutations;
}

@end
