//
//  CHOrderedDictionary.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHOrderedDictionary.h>
#import <CHDataStructures/CHCircularBuffer.h>

@implementation CHOrderedDictionary

- (void)dealloc {
	[keyOrdering release];
	[super dealloc];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
	if ((self = [super initWithCapacity:numItems]) == nil) return nil;
	keyOrdering = [[CHCircularBuffer alloc] initWithCapacity:numItems];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder]) == nil) return nil;
	[keyOrdering release];
	keyOrdering = [[decoder decodeObjectForKey:@"keyOrdering"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeObject:keyOrdering forKey:@"keyOrdering"];
}

#pragma mark <NSFastEnumeration>

/** @test Add unit test. */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	return [keyOrdering countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark Querying Contents

- (id)firstKey {
	return [keyOrdering firstObject];
}

- (NSUInteger)hash {
	return [keyOrdering hash];
}

- (id)lastKey {
	return [keyOrdering lastObject];
}

- (NSUInteger)indexOfKey:(id)aKey {
	if (CFDictionaryContainsKey(dictionary, aKey))
		return [keyOrdering indexOfObject:aKey];
	else
		return NSNotFound;
}

- (id)keyAtIndex:(NSUInteger)index {
	return [keyOrdering objectAtIndex:index];
}

- (NSArray *)keysAtIndexes:(NSIndexSet *)indexes {
	return [keyOrdering objectsAtIndexes:indexes];
}

- (NSEnumerator *)keyEnumerator {
	return [keyOrdering objectEnumerator];
}

- (id)objectForKeyAtIndex:(NSUInteger)index {
	// Note: -keyAtIndex: will raise an exception if the index is invalid.
	return [self objectForKey:[self keyAtIndex:index]];
}

- (NSArray *)objectsForKeysAtIndexes:(NSIndexSet *)indexes {
	return [self objectsForKeys:[self keysAtIndexes:indexes] notFoundMarker:self];
}

- (CHOrderedDictionary *)orderedDictionaryWithKeysAtIndexes:(NSIndexSet *)indexes {
	CHRaiseInvalidArgumentExceptionIfNil(indexes);
	if ([indexes count] == 0)
		return [[self class] dictionary];
	CHOrderedDictionary *newDictionary = [[self class] dictionaryWithCapacity:[indexes count]];
	NSUInteger index = [indexes firstIndex];
	while (index != NSNotFound) {
		id key = [self keyAtIndex:index];
		[newDictionary setObject:[self objectForKey:key] forKey:key];
		index = [indexes indexGreaterThanIndex:index];
	}
	return newDictionary;
}

- (NSEnumerator *)reverseKeyEnumerator {
	return [keyOrdering reverseObjectEnumerator];
}

#pragma mark Modifying Contents

- (void)exchangeKeyAtIndex:(NSUInteger)idx1 withKeyAtIndex:(NSUInteger)idx2 {
	[keyOrdering exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)index {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	CHRaiseInvalidArgumentExceptionIfNil(aKey);
	CHRaiseIndexOutOfRangeExceptionIf(index, >, [self count]);
	
	id clonedKey = [[aKey copy] autorelease];
	if (!CFDictionaryContainsKey(dictionary, clonedKey)) {
		[keyOrdering insertObject:clonedKey atIndex:index];
	}
	CFDictionarySetValue(dictionary, clonedKey, anObject);
}

- (void)removeAllObjects {
	[super removeAllObjects];
	[keyOrdering removeAllObjects];
}

- (void)removeObjectForKey:(id)aKey {
	if (CFDictionaryContainsKey(dictionary, aKey)) {
		[super removeObjectForKey:aKey];
		[keyOrdering removeObject:aKey];
	}
}

- (void)removeObjectForKeyAtIndex:(NSUInteger)index {
	// Note: -keyAtIndex: will raise an exception if the index is invalid.
	[super removeObjectForKey:[self keyAtIndex:index]];
	[keyOrdering removeObjectAtIndex:index];
}

- (void)removeObjectsForKeysAtIndexes:(NSIndexSet *)indexes {
	NSArray *keysToRemove = [keyOrdering objectsAtIndexes:indexes];
	[keyOrdering removeObjectsAtIndexes:indexes];
	[(NSMutableDictionary *)dictionary removeObjectsForKeys:keysToRemove];
}

- (void)setObject:(id)anObject forKey:(id)aKey {
	[self insertObject:anObject forKey:aKey atIndex:[self count]];
}

- (void)setObject:(id)anObject forKeyAtIndex:(NSUInteger)index {
	[self insertObject:anObject forKey:[self keyAtIndex:index] atIndex:index];
}

@end
