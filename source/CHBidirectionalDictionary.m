//
//  CHBidirectionalDictionary.m
//  CHDataStructures
//
//  Copyright © 2010-2021, Quinn Taylor
//

#import <CHDataStructures/CHBidirectionalDictionary.h>

@implementation CHBidirectionalDictionary

// This macro is used as an alias for the 'dictionary' ivar in the parent class.
#define keysToObjects dictionary

- (void)dealloc {
	if (inverse != nil)
		inverse->inverse = nil; // Unlink from inverse dictionary if one exists.
	CFRelease(objectsToKeys); // The dictionary can never be null at this point.
	[super dealloc];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
	if ((self = [super initWithCapacity:numItems]) == nil) return nil;
	objectsToKeys = CHDictionaryCreateMutable(numItems);
	return self;
}

#pragma mark Querying Contents

/** @todo Determine the proper ownership/lifetime of the inverse dictionary. */
- (CHBidirectionalDictionary *)inverseDictionary {
	if (inverse == nil) {
		// Create a new instance of this class to represent the inverse mapping
		inverse = [[CHBidirectionalDictionary alloc] init];
		// Release the CFMutableDictionary -init creates so we don't leak memory
		CFRelease(inverse->dictionary);
		// Set its dictionary references to the reverse of what they are here
		CFRetain(inverse->keysToObjects = objectsToKeys);
		CFRetain(inverse->objectsToKeys = keysToObjects);
		// Set this instance as the mutual inverse of the newly-created instance 
		inverse->inverse = self;
	}
	return inverse;
}

- (id)keyForObject:(id)anObject {
	return (id)CFDictionaryGetValue(objectsToKeys, anObject);
}

- (NSEnumerator *)objectEnumerator {
	return [(id)objectsToKeys keyEnumerator];
}

#pragma mark Modifying Contents

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
	[super addEntriesFromDictionary:otherDictionary];
}

- (void)removeAllObjects {
	[super removeAllObjects];
	CFDictionaryRemoveAllValues(objectsToKeys);
}

- (void)removeKeyForObject:(id)anObject {
	[super removeObjectForKey:[self keyForObject:anObject]];
	CFDictionaryRemoveValue(objectsToKeys, anObject);
}

- (void)removeObjectForKey:(id)aKey {
	CFDictionaryRemoveValue(objectsToKeys, [self objectForKey:aKey]);
	[super removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id)aKey {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	CHRaiseInvalidArgumentExceptionIfNil(aKey);
	// Remove existing mappings for aKey and anObject if they currently exist.
	CFDictionaryRemoveValue(keysToObjects, CFDictionaryGetValue(objectsToKeys, anObject));
	CFDictionaryRemoveValue(objectsToKeys, CFDictionaryGetValue(keysToObjects, aKey));
	aKey = [[aKey copy] autorelease];
	anObject = [[anObject copy] autorelease];
	CFDictionarySetValue(keysToObjects, aKey, anObject); // May replace key-value pair
	CFDictionarySetValue(objectsToKeys, anObject, aKey); // May replace value-key pair
}

@end
