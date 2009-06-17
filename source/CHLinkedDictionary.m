/*
 CHDataStructures.framework -- CHLinkedDictionary.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLinkedDictionary.h"
#import "CHCircularBufferQueue.h"

@implementation CHLinkedDictionary

- (id) initWithObjects:(id*)objects forKeys:(id*)keys count:(NSUInteger)count {
	// Create collection for ordering keys first, since super will add objects.
	insertionOrder = [[CHCircularBufferQueue alloc] init];
	if ((self = [super initWithObjects:objects forKeys:keys count:count]) == nil) return nil;
	return self;
}

/** @todo Check whether keys are equal on decode, fix if they aren't. */
- (id) initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder]) == nil) return nil;
	insertionOrder = [[decoder decodeObjectForKey:@"insertionOrder"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeObject:insertionOrder forKey:@"insertionOrder"];
}

#pragma mark Adding Objects

- (void) setObject:(id)anObject forKey:(id)aKey {
	if (!CFDictionaryContainsKey(dictionary, aKey)) {
		id clonedKey = [[aKey copy] autorelease];
		[insertionOrder addObject:clonedKey];
		CFDictionarySetValue(dictionary, clonedKey, anObject);
	}
}

#pragma mark Querying Contents

- (NSEnumerator*) keyEnumerator {
	return [insertionOrder objectEnumerator];
}

- (id) firstKey {
	return [insertionOrder firstObject];
}

- (id) lastKey {
	return [insertionOrder lastObject];
}

#pragma mark Removing Objects

- (void) removeAllObjects {
	[insertionOrder removeAllObjects];
	[super removeAllObjects];
}

- (void) removeObjectForKey:(id)aKey {
	if (CFDictionaryContainsKey(dictionary, aKey)) {
		[insertionOrder removeObject:aKey];
		CFDictionaryRemoveValue(dictionary, aKey);
	}
}

- (void) removeObjectForFirstKey {
	[self removeObjectForKey:[insertionOrder firstObject]];
}

- (void) removeObjectForLastKey {
	[self removeObjectForKey:[insertionOrder lastObject]];
}

@end
