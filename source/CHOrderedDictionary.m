/*
 CHDataStructures.framework -- CHOrderedDictionary.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHOrderedDictionary.h"
#import "CHAbstractCircularBufferCollection.h"

@implementation CHOrderedDictionary

- (void) dealloc {
	[keyOrdering release];
	[super dealloc];
}

- (id) initWithCapacity:(NSUInteger)numItems {
	if ((self = [super initWithCapacity:numItems]) == nil) return nil;
	keyOrdering = [[CHAbstractCircularBufferCollection alloc] init];
	return self;
}

- (id) initWithCoder:(NSCoder*)decoder {
	if ((self = [super initWithCoder:decoder]) == nil) return nil;
	keyOrdering = [[decoder decodeObjectForKey:@"keyOrdering"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeObject:keyOrdering forKey:@"keyOrdering"];
}

#pragma mark Adding Objects

- (void) insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)index {
	if (index > [self count])
		CHIndexOutOfRangeException([self class], _cmd, index, [self count]);
	if (anObject == nil || aKey == nil)
		CHNilArgumentException([self class], _cmd);
	
	id clonedKey = [[aKey copy] autorelease];
	if (!CFDictionaryContainsKey(dictionary, clonedKey)) {
		[keyOrdering insertObject:clonedKey atIndex:index];
	}
	CFDictionarySetValue(dictionary, clonedKey, anObject);
}

- (void) setObject:(id)anObject forKey:(id)aKey {
	[self insertObject:anObject forKey:aKey atIndex:[self count]];
}

- (void) setObject:(id)anObject forKeyAtIndex:(NSUInteger)index {
	[self insertObject:anObject forKey:[self keyAtIndex:index] atIndex:index];
}

- (void) exchangeKeyAtIndex:(NSUInteger)idx1 withKeyAtIndex:(NSUInteger)idx2 {
	[keyOrdering exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

#pragma mark Querying Contents

- (id) firstKey {
	return [keyOrdering firstObject];
}

- (id) lastKey {
	return [keyOrdering lastObject];
}

- (NSUInteger) indexOfKey:(id)aKey {
	if (CFDictionaryContainsKey(dictionary, aKey))
		return [keyOrdering indexOfObject:aKey];
	else
		return NSNotFound;
}

- (id) keyAtIndex:(NSUInteger)index {
	if (index >= [self count])
		CHIndexOutOfRangeException([self class], _cmd, index, [self count]);
	return [keyOrdering objectAtIndex:index];
}

- (NSEnumerator*) keyEnumerator {
	return [keyOrdering objectEnumerator];
}

- (id) objectForKeyAtIndex:(NSUInteger)index {
	// Note: -keyAtIndex: will raise an exception if the index is invalid.
	return [self objectForKey:[self keyAtIndex:index]];
}

- (NSEnumerator*) reverseKeyEnumerator {
	return [keyOrdering reverseObjectEnumerator];
}

#pragma mark Removing Objects

- (void) removeAllObjects {
	[keyOrdering removeAllObjects];
	[super removeAllObjects];
}

- (void) removeObjectForKey:(id)aKey {
	if (CFDictionaryContainsKey(dictionary, aKey)) {
		CFDictionaryRemoveValue(dictionary, aKey);
		[keyOrdering removeObject:aKey];
	}
}

- (void) removeObjectForKeyAtIndex:(NSUInteger)index {
	// Note: -keyAtIndex: will raise an exception if the index is invalid.
	CFDictionaryRemoveValue(dictionary, [self keyAtIndex:index]);
	[keyOrdering removeObjectAtIndex:index];
}

@end
