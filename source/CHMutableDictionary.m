//
//  CHMutableDictionary.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHMutableDictionary.h>

#pragma mark CFDictionary callbacks

const void * CHDictionaryRetain(CFAllocatorRef allocator, const void *value) {
	return [(id)value retain];
}

void CHDictionaryRelease(CFAllocatorRef allocator, const void *value) {
	[(id)value release];
}

CFStringRef CHDictionaryCopyDescription(const void *value) {
	return (CFStringRef)[[(id)value description] copy];
}

Boolean CHDictionaryEqual(const void *value1, const void *value2) {
	return [(id)value1 isEqual:(id)value2];
}

CFHashCode CHDictionaryHash(const void *value) {
	return (CFHashCode)[(id)value hash];
}

static const CFDictionaryKeyCallBacks kCHDictionaryKeyCallBacks = {
	0, // default version
	CHDictionaryRetain,
	CHDictionaryRelease,
	CHDictionaryCopyDescription,
	CHDictionaryEqual,
	CHDictionaryHash
};

static const CFDictionaryValueCallBacks kCHDictionaryValueCallBacks = {
	0, // default version
	CHDictionaryRetain,
	CHDictionaryRelease,
	CHDictionaryCopyDescription,
	CHDictionaryEqual
};

HIDDEN CFMutableDictionaryRef CHDictionaryCreateMutable(NSUInteger initialCapacity)
{
	// Create a CFMutableDictionaryRef with callback functions as defined above.
	return CFDictionaryCreateMutable(kCFAllocatorDefault,
									 initialCapacity,
									 &kCHDictionaryKeyCallBacks,
									 &kCHDictionaryValueCallBacks);
}

#pragma mark -

@implementation CHMutableDictionary

- (void)dealloc {
	CFRelease(dictionary); // The dictionary will never be null at this point.
	[super dealloc];
}

// Note: Defined here since -init is not implemented in NS(Mutable)Dictionary.
- (instancetype)init {
	return [self initWithCapacity:0]; // The 0 means we provide no capacity hint
}

// Note: This is the designated initializer for NSMutableDictionary and this class.
// Subclasses may override this as necessary, but must call back here first.
- (instancetype)initWithCapacity:(NSUInteger)numItems {
	if ((self = [super init]) == nil) return nil;
	dictionary = CHDictionaryCreateMutable(numItems);
	return self;
}

#pragma mark <NSCoding>

// Overridden from NSMutableDictionary to encode/decode as the proper class.
- (Class)classForKeyedArchiver {
	return [self class];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	return [self initWithDictionary:[decoder decodeObjectForKey:@"dictionary"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:(NSDictionary *)dictionary forKey:@"dictionary"];
}

#pragma mark <NSCopying>

- (instancetype)copyWithZone:(NSZone *) zone {
	// We could use -initWithDictionary: here, but it would just use more memory.
	// (It marshals key-value pairs into two id* arrays, then inits from those.)
	CHMutableDictionary *copy = [[[self class] allocWithZone:zone] init];
	[copy addEntriesFromDictionary:self];
	return copy;
}

#pragma mark <NSFastEnumeration>

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	return [super countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark Querying Contents

- (NSUInteger)count {
	return CFDictionaryGetCount(dictionary);
}

- (NSString *)debugDescription {
	CFStringRef description = CFCopyDescription(dictionary);
	CFRelease([(id)description retain]);
	return [(id)description autorelease];
}

- (NSEnumerator *)keyEnumerator {
	return [(id)dictionary keyEnumerator];
}

- (NSEnumerator *)objectEnumerator {
	return [(id)dictionary objectEnumerator];
}

- (id)objectForKey:(id)aKey {
	return (id)CFDictionaryGetValue(dictionary, aKey);
}

#pragma mark Modifying Contents

- (void)removeAllObjects {
	CFDictionaryRemoveAllValues(dictionary);
}

- (void)removeObjectForKey:(id)aKey {
	CFDictionaryRemoveValue(dictionary, aKey);
}

- (void)setObject:(id)anObject forKey:(id)aKey {
	if (anObject == nil || aKey == nil)
		CHNilArgumentException([self class], _cmd);
	CFDictionarySetValue(dictionary, [[aKey copy] autorelease], anObject);
}

@end
