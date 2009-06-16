/*
 CHDataStructures.framework -- CHLockableDictionary.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableDictionary.h"

#pragma mark CHDictionary callbacks

const void* CHSortedDictionaryRetain(CFAllocatorRef allocator, const void *value) {
	return [(id)value retain];
}

void CHSortedDictionaryRelease(CFAllocatorRef allocator, const void *value) {
	[(id)value release];
}

CFStringRef CHSortedDictionaryDescription(const void *value) {
	return (CFStringRef)[(id)value description];
}

Boolean CHSortedDictionaryEqual(const void *value1, const void *value2) {
	return [(id)value1 isEqual:(id)value2];
}

CFHashCode CHSortedDictionaryHash(const void *value) {
	return (CFHashCode)[(id)value hash];
}

static const CFDictionaryKeyCallBacks kCHSortedDictionaryKeyCallBacks = {
	0, // default version
	CHSortedDictionaryRetain,
	CHSortedDictionaryRelease,
	CHSortedDictionaryDescription,
	CHSortedDictionaryEqual,
	CHSortedDictionaryHash
};

static const CFDictionaryValueCallBacks kCHSortedDictionaryValueCallBacks = {
	0, // default version
	CHSortedDictionaryRetain,
	CHSortedDictionaryRelease,
	CHSortedDictionaryDescription,
	CHSortedDictionaryEqual
};

#pragma mark -

@implementation CHLockableDictionary

+ (void) initialize {
	initializeGCStatus();
}

- (void) dealloc {
	[lock release];
	[super dealloc];
}

- (id) initWithObjects:(id*)objects forKeys:(id*)keys count:(NSUInteger)count {
	if ((self = [super init]) == nil) return nil;
	dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,
										   0, // no maximum capacity limit
										   &kCHSortedDictionaryKeyCallBacks,
										   &kCHSortedDictionaryValueCallBacks);
	for (int i = 0; i < count; i++) {
		[self setObject:objects[i] forKey:keys[i]];
	}
	return self;
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil) return nil;
	dictionary = (CFMutableDictionaryRef)[[decoder decodeObjectForKey:@"dictionary"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:(NSMutableDictionary*)dictionary forKey:@"dictionary"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone*) zone {
	CHLockableDictionary *copy = [[[self class] alloc] init];
	NSEnumerator *keys = [self keyEnumerator];
	id aKey;
	while (aKey = [keys nextObject]) {
		[copy setObject:[self objectForKey:aKey] forKey:aKey];
	}
	return copy;
}

#pragma mark <NSFastEnumeration>

//#if MAC_OS_X_VERSION_10_5_AND_LATER
//- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
//                                   objects:(id*)stackbuf
//                                     count:(NSUInteger)len
//{
//	
//}
//#endif

#pragma mark Adding Objects

- (void) setObject:(id)anObject forKey:(id)aKey {
	CFDictionarySetValue(dictionary, [[aKey copy] autorelease], anObject);
}

#pragma mark Querying Contents

- (NSUInteger) count {
	return CFDictionaryGetCount(dictionary);
}

- (NSEnumerator*) keyEnumerator {
	NSUInteger count = CFDictionaryGetCount(dictionary);
	id *keyBuffer = NSAllocateCollectable(count * sizeof(void*), 0);
	CFDictionaryGetKeysAndValues(dictionary, (const void **)keyBuffer, NULL);
	NSArray *keys = [NSArray arrayWithObjects:keyBuffer count:count];
	if (kCHGarbageCollectionNotEnabled)
		free(keys);
	return [keys objectEnumerator];
}

- (id) objectForKey:(id)aKey {
	return (id)CFDictionaryGetValue(dictionary, aKey);
}

#pragma mark Removing Objects

- (void) removeAllObjects {
	CFDictionaryRemoveAllValues(dictionary);
}

- (void) removeObjectForKey:(id)aKey {
	CFDictionaryRemoveValue(dictionary, aKey);
}

#pragma mark <CHLockable>

// Private method used for creating a lock on-demand and naming it uniquely.
- (void) createLock {
	lock = [[NSLock alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
	[lock setName:[NSString stringWithFormat:@"NSLock-%@-0x%x", [self class], self]];
#endif
}

#pragma mark -

- (BOOL) tryLock {
	if (lock == nil)
		[self createLock];
	return [lock tryLock];
}

- (void) lock {
	if (lock == nil)
		[self createLock];
	[lock lock];
}

- (BOOL) lockBeforeDate:(NSDate*)limit {
	if (lock == nil)
		[self createLock];
	return [lock lockBeforeDate:limit];
}

- (void) unlock {
	[lock unlock];
}

@end
