//
//  CHSortedDictionary.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHSortedDictionary.h>
#import <CHDataStructures/CHAVLTree.h>

@implementation CHSortedDictionary

- (void)dealloc {
	[sortedKeys release];
	[super dealloc];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
	if ((self = [super initWithCapacity:numItems]) == nil) return nil;
	sortedKeys = [[CHAVLTree alloc] init];
	return self;
}

// The NSCoding methods inherited from CHMutableDictionary work fine here.

#pragma mark <NSFastEnumeration>

/** @test Add unit test. */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	return [sortedKeys countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark Querying Contents

- (id)firstKey {
	return [sortedKeys firstObject];
}

- (NSUInteger)hash {
	return CHHashOfCountAndObjects([sortedKeys count], [sortedKeys firstObject], [sortedKeys lastObject]);
}

- (id)lastKey {
	return [sortedKeys lastObject];
}

- (NSEnumerator *)keyEnumerator {
	return [sortedKeys objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator {
	return [sortedKeys reverseObjectEnumerator];
}

- (NSMutableDictionary *)subsetFromKey:(id)start
                                 toKey:(id)end
                               options:(CHSubsetConstructionOptions)options
{
	id<CHSortedSet> keySubset = [sortedKeys subsetFromObject:start toObject:end options:options];
	NSMutableDictionary *subset = [[[[self class] alloc] initWithCapacity:[keySubset count]] autorelease];
	for (id aKey in keySubset) {
		[subset setObject:[self objectForKey:aKey] forKey:aKey];
	}
	return subset;
}

#pragma mark Modifying Contents

- (void)removeAllObjects {
	[super removeAllObjects];
	[sortedKeys removeAllObjects];
}

- (void)removeObjectForKey:(id)aKey {
	if (CFDictionaryContainsKey(dictionary, aKey)) {
		[super removeObjectForKey:aKey];
		[sortedKeys removeObject:aKey];
	}
}

- (void)setObject:(id)anObject forKey:(id)aKey {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	CHRaiseInvalidArgumentExceptionIfNil(aKey);
	id clonedKey = [[aKey copy] autorelease];
	[sortedKeys addObject:clonedKey];
	CFDictionarySetValue(dictionary, clonedKey, anObject);
}

@end
