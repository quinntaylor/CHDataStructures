/*
 CHDataStructures.framework -- CHLinkedDictionary.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLinkedDictionary.h"
#import "CHDoublyLinkedList.h"

@implementation CHLinkedDictionary

- (void) dealloc {
	[keyOrdering release];
	[super dealloc];
}

- (id) initWithObjects:(id*)objects forKeys:(id*)keys count:(NSUInteger)count {
	// Create collection for ordering keys first, since super will add objects.
	keyOrdering = [[CHDoublyLinkedList alloc] init];
	if ((self = [super initWithObjects:objects forKeys:keys count:count]) == nil) return nil;
	return self;
}

- (id) initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder]) == nil) return nil;
	keyOrdering = [[decoder decodeObjectForKey:@"keyOrdering"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
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
		[keyOrdering removeObject:aKey];
		CFDictionaryRemoveValue(dictionary, aKey);
	}
}

@end
