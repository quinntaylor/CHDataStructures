/*
 CHDataStructures.framework -- CHMultiMap.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHMultiMap.h"

/**
 Utility function for creating a new NSMutableSet containing object; if object
 is a set or array, the set containts all objects in the collection.
 */
static inline NSMutableSet* createMutableSetFromObject(id object) {
	if (object == nil)
		return nil;
	if ([object isKindOfClass:[NSSet class]])
		return [NSMutableSet setWithSet:object];
	if ([object isKindOfClass:[NSArray class]])
		return [NSMutableSet setWithArray:object];
	else
		return [NSMutableSet setWithObject:object];
}


/**
 @todo Combine -addObject:forKey: and -addObjects:forKey: into a single method
 that accepts an NSArray, NSSet, or generic object, then wraps in a mutable set.
 */
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

- (id) initWithObjects:(NSArray*)objectsArray forKeys:(NSArray*)keyArray {
	if ([keyArray count] != [objectsArray count])
		CHInvalidArgumentException([self class], _cmd, @"Unequal array counts.");
	if ([self init] == nil) return nil;
	NSEnumerator *objects = [objectsArray objectEnumerator];
	NSSet *objectSet;
	for (id key in keyArray) {
		objectSet = createMutableSetFromObject([objects nextObject]);
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
	NSSet *objectSet = createMutableSetFromObject(firstObject);
	id aKey;
	// Add an entry for each valid pair of object-key parameters.
	do {
		if ((aKey = va_arg(argumentList, id)) == nil)
			CHInvalidArgumentException([self class], _cmd, @"Invalid nil key.");
		[dictionary setObject:objectSet forKey:aKey];
		count += [objectSet count];
	} while (objectSet = createMutableSetFromObject(va_arg(argumentList, id)));
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
	CHMultiMap *newMultiMap = [[CHMultiMap alloc] init];
	for (id key in [self allKeys])
		[newMultiMap setObjects:[[[dictionary objectForKey:key] mutableCopy] autorelease]
						 forKey:key];
	return newMultiMap;
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
		if ([[dictionary objectForKey:key] containsObject:anObject]) {
			return YES;
		}
	}
	return NO;
}

- (NSArray*) allKeys {
	return [dictionary allKeys];
}

- (NSArray*) allObjects {
	NSMutableArray *objects = [NSMutableArray array];
	for (id key in [self allKeys]) {
		[objects addObjectsFromArray:[[dictionary objectForKey:key] allObjects]];
		// objectForKey: returns an NSSet -- get array from that with -allObjects
	}
	return objects;
}

- (NSEnumerator*) keyEnumerator {
	return [dictionary keyEnumerator];
}

/**
 @todo Refine with custom enumerator for greater efficiency?
 */
- (NSEnumerator*) objectEnumerator {
	return [[self allObjects] objectEnumerator];
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
	if (objects == nil)
		[dictionary setObject:(objects = [NSMutableSet set]) forKey:aKey];
	else
		count -= [objects count];
	[objects addObject:anObject];
	count += [objects count];
	++mutations;
}

- (void) addObjects:(NSSet*)objectSet forKey:(id)aKey {
	NSMutableSet *objects = [dictionary objectForKey:aKey];
	if (objects == nil)
		[dictionary setObject:(objects = [NSMutableSet set]) forKey:aKey];
	else
		count -= [objects count];
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
