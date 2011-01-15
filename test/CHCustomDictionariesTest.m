/*
 CHDataStructures.framework -- CHCustomDictionariesTest.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>

#import "CHBidirectionalDictionary.h"
#import "CHMutableDictionary.h"
#import "CHMultiDictionary.h"
#import "CHOrderedDictionary.h"
#import "CHSortedDictionary.h"

id replicateWithNSCoding(id dictionary) {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];	
}

static NSArray* keyArray;

#pragma mark -

@interface CHMutableDictionary (Test)

- (NSString*) debugDescription; // Declare here to prevent compiler warnings.

@end

@interface CHMutableDictionaryTest : SenTestCase {
	id dictionary;
	NSEnumerator *enumerator;
}
@end

@implementation CHMutableDictionaryTest

+ (void) initialize {
	keyArray = [[NSArray arrayWithObjects:@"baz", @"foo", @"bar", @"yoo", @"hoo", nil] retain];
}

- (void) setUp {
	dictionary = [[[CHMutableDictionary alloc] init] autorelease];
}

- (void) populateDictionary {
	enumerator = [keyArray objectEnumerator];
	id aKey;
	while (aKey = [enumerator nextObject]) {
		[dictionary setObject:aKey forKey:aKey];
	}
}

- (void) testInitWithObjectsForKeysCount {
	dictionary = [[[dictionary class] alloc] initWithObjects:keyArray forKeys:keyArray];
	// Should call down to -initWithObjects:forKeys:count:
}

- (void) testDebugDescription {
	STAssertNotNil([dictionary debugDescription], nil);
	[dictionary setObject:@"xyz" forKey:@"abc"];
	STAssertNotNil([dictionary debugDescription], nil);
}

- (void) testDescription {
	STAssertNotNil([dictionary description], nil);
	[dictionary setObject:@"xyz" forKey:@"abc"];
	STAssertNotNil([dictionary description], nil);
}

- (void) testKeyEnumerator {
	// Test that key enumerator is non-nil, even for an empty dictionary.
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, nil);
	// An enumerator with zero objects should return an empty, non-nil array
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, nil);
	STAssertEquals([allKeys count], (NSUInteger)0, nil);
	
	[self populateDictionary];
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, nil);
	STAssertNotNil([enumerator allObjects], nil);
}

- (void) testObjectEnumerator {
	// Test that object enumerator is non-nil, even for an empty dictionary.
	enumerator = [dictionary objectEnumerator];
	STAssertNotNil(enumerator, nil);
	// An enumerator with zero objects should return an empty, non-nil array
	NSArray *allObjects = [enumerator allObjects];
	STAssertNotNil(allObjects, nil);
	STAssertEquals([allObjects count], (NSUInteger)0, nil);
	
	[self populateDictionary];
	enumerator = [dictionary objectEnumerator];
	STAssertNotNil(enumerator, nil);
	STAssertNotNil([enumerator allObjects], nil);
}

- (void) testRemoveAllObjects {
	// Removal shouldn't raise exception even if dictionary is empty
	STAssertEquals([dictionary count], (NSUInteger)0, nil);
	STAssertNoThrow([dictionary removeAllObjects], nil);
	// Test that removal works for a non-empty dictionary
	[self populateDictionary];
	STAssertEquals([dictionary count], [keyArray count], nil);
	STAssertNoThrow([dictionary removeAllObjects], nil);
	STAssertEquals([dictionary count], (NSUInteger)0, nil);
}

- (void) testRemoveObjectForKey {
	// Removal shouldn't raise exception even if dictionary is empty
	STAssertNil([dictionary objectForKey:@"foo"],  nil);
	STAssertNoThrow([dictionary removeObjectForKey:@"foo"], nil);
	// Test that removal works for a non-empty dictionary
	[self populateDictionary];
	STAssertNotNil([dictionary objectForKey:@"foo"],  nil);
	STAssertNoThrow([dictionary removeObjectForKey:@"foo"], nil);
	STAssertNil([dictionary objectForKey:@"foo"],  nil);
}

- (void) testSetObjectForKey {
	// Verify that nil key and/or object raises an exception
	STAssertThrows([dictionary setObject:@"" forKey:nil], nil);
	STAssertThrows([dictionary setObject:nil forKey:@""], nil);
	
	STAssertNil([dictionary objectForKey:@"foo"], nil);
	[dictionary setObject:@"bar" forKey:@"foo"];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"bar", nil);
	
	// Verify that setting a different value for a key "takes" the new value
	[dictionary removeAllObjects];
	[self populateDictionary];
	id key = [keyArray lastObject];
	NSString *value = [dictionary objectForKey:key];
	
	[dictionary setObject:value forKey:key];
	STAssertEqualObjects(value, [dictionary objectForKey:key], nil);
	
	[dictionary setObject:[NSString string] forKey:key];
	STAssertFalse([value isEqual:[dictionary objectForKey:key]], nil);
}

- (void) testNSCoding {
	[self populateDictionary];
	id clone = replicateWithNSCoding(dictionary);
	STAssertEqualObjects([NSSet setWithArray:[clone allKeys]],
						 [NSSet setWithArray:[dictionary allKeys]], nil);
}

- (void) testNSCopying {
	id copy = [[dictionary copy] autorelease];
	STAssertEquals([copy count], [dictionary count], nil);
	STAssertEquals([copy hash], [dictionary hash], nil);
	STAssertEqualObjects([copy class], [dictionary class], nil);
	
	[self populateDictionary];
	copy = [[dictionary copy] autorelease];
	STAssertEquals([copy count], [dictionary count], nil);
	STAssertEquals([copy hash], [dictionary hash], nil);
}

@end

#pragma mark -

@interface CHBidirectionalDictionaryTest : CHMutableDictionaryTest
@end

@implementation CHBidirectionalDictionaryTest

- (void) setUp {
	dictionary = [[[CHBidirectionalDictionary alloc] init] autorelease];
}

- (void) testInverseDictionary {
	id inverse = [dictionary inverseDictionary];
	STAssertNotNil([dictionary inverseDictionary], nil);
	// Test identity of dictionary and inverse with respect to each other.
	STAssertEquals([inverse inverseDictionary], dictionary, nil);
	STAssertEquals([inverse count], [dictionary count], nil);
	
	id key = @"A", value = @"B";
	// Make sure the mappings show up correctly in the dictionary.
	[dictionary setObject:value forKey:key];
	STAssertEquals([inverse count], [dictionary count], nil);
	STAssertEqualObjects([dictionary objectForKey:key], value, nil);
	STAssertEqualObjects([dictionary keyForObject:value], key, nil);
	STAssertNil([dictionary objectForKey:value], nil);
	// Make sure added mappings appear in the inverse dictionary.
	STAssertEqualObjects([inverse objectForKey:value], key, nil);
	STAssertEqualObjects([inverse keyForObject:key], value, nil);
	STAssertNil([inverse objectForKey:key], nil);
	// Make sure removed mappings disappear from the inverse dictionary.
	[dictionary removeObjectForKey:key];
	STAssertEquals([inverse count], [dictionary count], nil);
	STAssertNil([dictionary objectForKey:key], nil);
	STAssertNil([inverse objectForKey:value], nil);
}

- (void) testRemoveKeyForObject {
	STAssertNoThrow([dictionary removeKeyForObject:nil], nil);
	
	[dictionary setObject:@"B" forKey:@"A"];
	[dictionary setObject:@"D" forKey:@"C"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	// Try to remove non-existent values
	STAssertNoThrow([dictionary removeKeyForObject:@"A"], nil);
	STAssertNoThrow([dictionary removeKeyForObject:@"C"], nil);
	STAssertNoThrow([dictionary removeKeyForObject:@"bogus"], nil);
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	// Remove existing objects and associated keys
	[dictionary removeKeyForObject:@"B"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertNil([dictionary objectForKey:@"A"], nil);
	STAssertNil([dictionary keyForObject:@"B"], nil);
	[dictionary removeKeyForObject:@"D"];
	STAssertEquals([dictionary count], (NSUInteger)0, nil);
	STAssertNil([dictionary objectForKey:@"C"], nil);
	STAssertNil([dictionary keyForObject:@"D"], nil);
}

- (void) testRemoveObjectForKey {
	STAssertNoThrow([dictionary removeObjectForKey:nil], nil);
	
	[dictionary setObject:@"B" forKey:@"A"];
	[dictionary setObject:@"D" forKey:@"C"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	// Try to remove non-existent keys
	STAssertNoThrow([dictionary removeObjectForKey:@"B"], nil);
	STAssertNoThrow([dictionary removeObjectForKey:@"D"], nil);
	STAssertNoThrow([dictionary removeObjectForKey:@"bogus"], nil);
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	// Remove existing objects and associated keys
	[dictionary removeObjectForKey:@"A"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertNil([dictionary objectForKey:@"A"], nil);
	STAssertNil([dictionary keyForObject:@"B"], nil);
	[dictionary removeObjectForKey:@"C"];
	STAssertEquals([dictionary count], (NSUInteger)0, nil);
	STAssertNil([dictionary objectForKey:@"C"], nil);
	STAssertNil([dictionary keyForObject:@"D"], nil);
}

- (void) testSetAndQueryKeyAndObject {
	// Verify that nil key and/or object raises an exception
	STAssertThrows([dictionary setObject:@"" forKey:nil], nil);
	STAssertThrows([dictionary setObject:nil forKey:@""], nil);
	
	// Test basic key/value queries for an empty dictionary
	STAssertEquals([dictionary count], (NSUInteger)0, nil);
	STAssertNoThrow([dictionary objectForKey:nil], nil);
	STAssertNoThrow([dictionary keyForObject:nil], nil);
	STAssertNil([dictionary objectForKey:@"A"], nil);
	STAssertNil([dictionary keyForObject:@"A"], nil);
	
	// Insert an object and test count, key, and value
	[dictionary setObject:@"B" forKey:@"A"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertEqualObjects([dictionary objectForKey:@"A"], @"B", nil);
	STAssertEqualObjects([dictionary keyForObject:@"B"], @"A", nil);
	
	// Verify that setting a different value for a key replaces the old value
	[dictionary setObject:@"C" forKey:@"A"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertNil([dictionary keyForObject:@"B"], nil);
	STAssertEqualObjects([dictionary objectForKey:@"A"], @"C", nil);
	STAssertEqualObjects([dictionary keyForObject:@"C"], @"A", nil);
	
	// Verify that setting a different key for a value replaces the old key
	[dictionary setObject:@"C" forKey:@"B"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertNil([dictionary objectForKey:@"A"], nil);
	STAssertEqualObjects([dictionary objectForKey:@"B"], @"C", nil);
	STAssertEqualObjects([dictionary keyForObject:@"C"], @"B", nil);
	
	// Verify that adding a different key and different value increases count
	[dictionary setObject:@"D" forKey:@"A"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEqualObjects([dictionary objectForKey:@"A"], @"D", nil);
	STAssertEqualObjects([dictionary objectForKey:@"B"], @"C", nil);
	STAssertEqualObjects([dictionary keyForObject:@"D"], @"A", nil);
	STAssertEqualObjects([dictionary keyForObject:@"C"], @"B", nil);
	
	// Verify that modifying existing key-value pairs happens correctly
	[dictionary setObject:@"B" forKey:@"A"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEqualObjects([dictionary objectForKey:@"A"], @"B", nil);
	STAssertEqualObjects([dictionary objectForKey:@"B"], @"C", nil);
	STAssertEqualObjects([dictionary keyForObject:@"B"], @"A", nil);
	STAssertEqualObjects([dictionary keyForObject:@"C"], @"B", nil);
	
	[dictionary setObject:@"D" forKey:@"C"];
	STAssertEquals([dictionary count], (NSUInteger)3, nil);
	STAssertEqualObjects([dictionary objectForKey:@"A"], @"B", nil);
	STAssertEqualObjects([dictionary objectForKey:@"B"], @"C", nil);
	STAssertEqualObjects([dictionary objectForKey:@"C"], @"D", nil);
	STAssertEqualObjects([dictionary keyForObject:@"B"], @"A", nil);
	STAssertEqualObjects([dictionary keyForObject:@"C"], @"B", nil);
	STAssertEqualObjects([dictionary keyForObject:@"D"], @"C", nil);

	[dictionary setObject:@"D" forKey:@"A"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEqualObjects([dictionary objectForKey:@"A"], @"D", nil);
	STAssertEqualObjects([dictionary objectForKey:@"B"], @"C", nil);
	STAssertEqualObjects([dictionary keyForObject:@"D"], @"A", nil);
	STAssertEqualObjects([dictionary keyForObject:@"C"], @"B", nil);
}

@end

#pragma mark -

@interface CHMultiDictionaryTest : CHMutableDictionaryTest
@end

@implementation CHMultiDictionaryTest

- (void) setUp {
	dictionary = [[[CHMultiDictionary alloc] init] autorelease];
}

- (void) populateDictionary {
	[dictionary addObjects:[NSSet setWithObjects:@"A",@"B",@"C",nil] forKey:@"foo"];
	[dictionary addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	[dictionary addObjects:[NSSet setWithObjects:@"1",@"2",@"3",nil] forKey:@"baz"];
}

- (void) testAddObjectForKey {
	STAssertEquals([dictionary count], (NSUInteger)0, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)0, nil);
	
	[dictionary addObject:@"A" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)1, nil);
	
	[dictionary addObject:@"B" forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)2, nil);
	
	// Test adding second object for key
	[dictionary addObject:@"C" forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, nil);
	
	// Test adding duplicate object for key
	[dictionary addObject:@"C" forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, nil);
	
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)1, nil);
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)2, nil);
}

- (void) testAddObjectsForKey {
	[dictionary addObjects:[NSSet setWithObjects:@"A",@"B",nil] forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)2, nil);
	
	[dictionary addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)5, nil);
	
	// Test adding an overlapping set of objects for an existing key
	[dictionary addObjects:[NSSet setWithObjects:@"B",@"C",nil] forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, nil);
}

- (void) testInitWithObjectsAndKeys {
	// Test initializing with no objects or keys
	STAssertNoThrow([[CHMultiDictionary alloc] initWithObjectsAndKeys:nil], nil);
	// Test initializing with invalid nil key parameter (unmatched values/keys)
	STAssertThrows(([[CHMultiDictionary alloc] initWithObjectsAndKeys:
					 @"A",@"B",@"C",nil]), nil);
	// Test initializing with values from sets, arrays, and normal objects
	dictionary = [[[CHMultiDictionary alloc] initWithObjectsAndKeys:
				   [NSSet setWithObjects:@"A",@"B",@"C",nil], @"foo",
				   [NSArray arrayWithObjects:@"X",@"Y",nil], @"bar",
				   @"Z", @"baz", nil] autorelease];
	STAssertEquals([dictionary count],              (NSUInteger)3, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForKey:@"baz"], (NSUInteger)1, nil);
}

- (void) testInitWithObjectsForKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSMutableArray *objects = [NSMutableArray array];
	
	[keys addObject:@"foo"];
	[objects addObject:[NSSet setWithObjects:@"A",@"B",@"C",nil]];
	
	[keys addObject:@"bar"];
	[objects addObject:[NSNull null]];
	
	dictionary = [[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys];
	
	STAssertEquals([dictionary count],              (NSUInteger)2, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)1, nil);
	STAssertEquals([dictionary countForAllKeys],    (NSUInteger)4, nil);
	
	// Test initializing with key and object arrays of different lengths
	[keys removeLastObject];
	STAssertThrows([[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys], nil);
}

- (void) testObjectEnumerator {
	[self populateDictionary];
	
	enumerator = [dictionary objectEnumerator];
	STAssertEquals([[enumerator allObjects] count], [dictionary count], nil);
	id anObject;
	while (anObject = [enumerator nextObject]) {
		STAssertTrue([anObject isKindOfClass:[NSSet class]], nil);
	}
}

- (void) testObjectsForKey {
	[self populateDictionary];
	
	STAssertEqualObjects([dictionary objectsForKey:@"foo"],
						 ([NSSet setWithObjects:@"A",@"B",@"C",nil]), nil);
	STAssertEqualObjects([dictionary objectsForKey:@"bar"],
	                     ([NSSet setWithObjects:@"X",@"Y",@"Z",nil]), nil);
	STAssertEqualObjects([dictionary objectsForKey:@"baz"],
	                     ([NSSet setWithObjects:@"1",@"2",@"3",nil]), nil);
	STAssertNil([dictionary objectsForKey:@"bogus"], nil);
}

- (void) testRemoveAllObjects {
	[self populateDictionary];
	
	STAssertEquals([dictionary count], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)9, nil);
	[dictionary removeAllObjects];
	STAssertEquals([dictionary count], (NSUInteger)0, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)0, nil);
}

- (void) testRemoveObjectForKey {
	[self populateDictionary];
	
	STAssertEquals([dictionary count], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)9, nil);
	
	[dictionary removeObject:@"A" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)8, nil);
	
	[dictionary removeObject:@"B" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)3, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)1, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)7, nil);
	
	[dictionary removeObject:@"C" forKey:@"foo"];
	// Removing the last object in the set for a key should also remove the key.
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)0, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, nil);
}

- (void) testRemoveObjectsForKey {
	[self populateDictionary];
	
	STAssertEquals([dictionary count],           (NSUInteger)3, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)9, nil);
	[dictionary removeObjectsForKey:@"foo"];
	STAssertEquals([dictionary count],           (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, nil);
	[dictionary removeObjectsForKey:@"foo"];
	STAssertEquals([dictionary count],           (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, nil);
	[dictionary removeObjectsForKey:@"bar"];
	STAssertEquals([dictionary count],           (NSUInteger)1, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, nil);
	[dictionary removeObjectsForKey:@"baz"];
	STAssertEquals([dictionary count],           (NSUInteger)0, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)0, nil);
}

- (void) testSetObjectForKey {
	// Verify that nil key and/or object raises an exception
	STAssertThrows([dictionary setObject:@"" forKey:nil], nil);
	STAssertThrows([dictionary setObject:nil forKey:@""], nil);

	STAssertNil([dictionary objectForKey:@"foo"], nil);
	[dictionary setObject:@"bar" forKey:@"foo"];
	STAssertEqualObjects([dictionary objectForKey:@"foo"],
						 [NSSet setWithObject:@"bar"], nil);
	
	// Verify that setting a different value for a key "takes" the new value
	[dictionary removeAllObjects];
	[self populateDictionary];
	id key = [[dictionary keyEnumerator] nextObject];
	NSString *value = [dictionary objectForKey:key];
	
	[dictionary setObject:value forKey:key];
	STAssertEqualObjects(value, [dictionary objectForKey:key], nil);
	
	[dictionary setObject:[NSString string] forKey:key];
	STAssertFalse([value isEqual:[dictionary objectForKey:key]], nil);
}

- (void) testSetObjectsForKey {
	// Verify that nil key and/or object raises an exception
	STAssertThrows([dictionary setObjects:[NSSet set] forKey:nil], nil);
	STAssertThrows([dictionary setObjects:nil forKey:@""], nil);

	NSSet* objectSet;
	
	[dictionary addObject:@"XYZ" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)1, nil);
	STAssertEqualObjects([dictionary objectsForKey:@"foo"],
						 [NSSet setWithObject:@"XYZ"], nil);
	
	objectSet = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[dictionary setObjects:objectSet forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, nil);
	STAssertEqualObjects([dictionary objectsForKey:@"foo"], objectSet, nil);
	
	objectSet = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	[dictionary setObjects:objectSet forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, nil);
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, nil);
	STAssertEqualObjects([dictionary objectsForKey:@"bar"], objectSet, nil);
}

@end

#pragma mark -

@interface CHDictionaryWithOrderingTest : CHMutableDictionaryTest
{
	NSArray *expectedKeyOrder;
}

@end

@implementation CHDictionaryWithOrderingTest

- (void) testFirstKey {
	if (![dictionary respondsToSelector:@selector(firstKey)])
		return;
	STAssertNil([dictionary firstKey], nil);
	[self populateDictionary];
	STAssertEqualObjects([dictionary firstKey], [expectedKeyOrder objectAtIndex:0], nil);
}

- (void) testKeyEnumerator {
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, nil);
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, nil);
	STAssertEquals([allKeys count], (NSUInteger)0, nil);
	
	[self populateDictionary];
	
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, nil);
	allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, nil);
	STAssertEqualObjects(allKeys, [dictionary allKeys], nil);
}

- (void) testLastKey {
	if (![dictionary respondsToSelector:@selector(lastKey)])
		return;
	STAssertNil([dictionary lastKey], nil);
	[self populateDictionary];
	STAssertEqualObjects([dictionary lastKey], [expectedKeyOrder lastObject], nil);
}

- (void) testReverseKeyEnumerator {
	if (![dictionary respondsToSelector:@selector(reverseKeyEnumerator)])
		return;
	enumerator = [dictionary reverseKeyEnumerator];
	STAssertNotNil(enumerator, nil);
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, nil);
	STAssertEquals([allKeys count], (NSUInteger)0, nil);
	
	[self populateDictionary];
	
	enumerator = [dictionary reverseKeyEnumerator];
	STAssertNotNil(enumerator, nil);
	allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, nil);
	STAssertEquals([allKeys count], [keyArray count], nil);
	
	if ([dictionary isMemberOfClass:[CHOrderedDictionary class]]) {
		expectedKeyOrder = keyArray;
	} else {
		expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
	}
	STAssertEqualObjects([[dictionary reverseKeyEnumerator] allObjects],
	                     [[expectedKeyOrder reverseObjectEnumerator] allObjects], nil);
}

- (void) testNSCoding {
	[self populateDictionary];
	id clone = replicateWithNSCoding(dictionary);
	STAssertEqualObjects(clone, dictionary, nil);
}

- (void) testNSCopying {
	id copy = [[dictionary copy] autorelease];
	STAssertEqualObjects([copy class], [dictionary class], nil);
	STAssertEquals([copy hash], [dictionary hash], nil);
	STAssertEquals([copy count], [dictionary count], nil);
	
	[self populateDictionary];
	copy = [[dictionary copy] autorelease];
	STAssertEquals([copy hash], [dictionary hash], nil);
	STAssertEquals([copy count], [dictionary count], nil);
	STAssertEqualObjects(copy, dictionary, nil);
	STAssertEqualObjects([copy allKeys], [dictionary allKeys], nil);
}

@end

#pragma mark -

@interface CHSortedDictionaryTest : CHDictionaryWithOrderingTest
@end

@implementation CHSortedDictionaryTest

- (void) setUp {
	dictionary = [[[CHSortedDictionary alloc] init] autorelease];
	expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
}

- (void) testAllKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSNumber *key;
	for (NSUInteger i = 0; i <= 20; i++) {
		key = [NSNumber numberWithUnsignedInt:arc4random()];
		[keys addObject:key];
		[dictionary setObject:[NSNull null] forKey:key];
	}
	[keys sortUsingSelector:@selector(compare:)];
	STAssertEqualObjects([dictionary allKeys], keys, nil);
}

- (void) testNSFastEnumeration {
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
	// Insert keys in reverse sorted order
	for (NSUInteger number = limit; number >= 1; number--)
		[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithUnsignedInteger:number]];
	// Verify that keys are enumerated in sorted order
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in dictionary) {
		STAssertEquals([object unsignedIntegerValue], expected++, nil);
		count++;
	}
	STAssertEquals(count, limit, nil);
	
	BOOL raisedException = NO;
	@try {
		for (id key in dictionary)
			[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithInteger:-1]];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, nil);	
}

- (void) testSubsetFromKeyToKeyOptions {
	STAssertNoThrow([dictionary subsetFromKey:nil toKey:nil options:0],
					nil);
	STAssertNoThrow([dictionary subsetFromKey:@"A" toKey:@"Z" options:0],
					nil);
	
	[self populateDictionary];
	NSMutableDictionary* subset;
	
	STAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:0]
												 toKey:[expectedKeyOrder lastObject]
											   options:0], nil);
	STAssertEquals([subset count], [expectedKeyOrder count], nil);

	STAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:1]
												 toKey:[expectedKeyOrder objectAtIndex:3]
											   options:0], nil);
	STAssertEquals([subset count], (NSUInteger)3, nil);
}

@end

#pragma mark -

@interface CHOrderedDictionaryTest : CHDictionaryWithOrderingTest
@end

@implementation CHOrderedDictionaryTest

- (void) setUp {
	dictionary = [[[CHOrderedDictionary alloc] init] autorelease];
	expectedKeyOrder = keyArray;
}

- (void) testAllKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSNumber *key;
	for (NSUInteger i = 0; i <= 20; i++) {
		key = [NSNumber numberWithUnsignedInt:arc4random()];
		[keys addObject:key];
		[dictionary setObject:[NSNull null] forKey:key];
	}
	STAssertEqualObjects([dictionary allKeys], keys, nil);
}

- (void) testExchangeKeyAtIndexWithKeyAtIndex {
	// Test for exceptions when trying to exchange when collection is empty.
	STAssertThrows([dictionary exchangeKeyAtIndex:0 withKeyAtIndex:1], nil);
	STAssertThrows([dictionary exchangeKeyAtIndex:1 withKeyAtIndex:0], nil);
	
	[self populateDictionary];
	// Exchanging objects at the same index should have no effect
	[dictionary exchangeKeyAtIndex:1 withKeyAtIndex:1];
	STAssertEqualObjects([dictionary allKeys], keyArray, nil);
	// Test swapping first and last objects
	[dictionary exchangeKeyAtIndex:0 withKeyAtIndex:[keyArray count]-1];
	STAssertEqualObjects([dictionary firstKey], @"hoo", nil);
	STAssertEqualObjects([dictionary lastKey],  @"baz", nil);
}

- (void) testIndexOfKey {
	STAssertTrue([dictionary indexOfKey:@"foo"] == NSNotFound, nil);
	[self populateDictionary];
	for (NSUInteger i = 0; i < [keyArray count]; i++) {
		STAssertEquals([dictionary indexOfKey:[keyArray objectAtIndex:i]], i, nil);
	}
}

- (void) testInsertObjectForKeyAtIndex {
	// Test inserting at bad index, and with nil key and object.
	STAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:1], nil);
	STAssertThrows([dictionary insertObject:nil    forKey:@"foo" atIndex:0], nil);
	STAssertThrows([dictionary insertObject:@"foo" forKey:nil    atIndex:0], nil);
	
	[self populateDictionary];
	NSUInteger count = [dictionary count];
	STAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:count+1], nil);
	// Test inserting a new value at the back
	STAssertNoThrow([dictionary insertObject:@"xyz" forKey:@"xyz" atIndex:count], nil);
	STAssertEqualObjects([dictionary lastKey], @"xyz", nil);
	// Test inserting a new value at the front
	STAssertNoThrow([dictionary insertObject:@"abc" forKey:@"abc" atIndex:0], nil);
	STAssertEqualObjects([dictionary firstKey], @"abc", nil);
}

- (void) testKeyAtIndex {
	STAssertThrows([dictionary keyAtIndex:0], nil);
	STAssertThrows([dictionary keyAtIndex:1], nil);
	[self populateDictionary];
	NSUInteger i;
	for (i = 0; i < [keyArray count]; i++) {
		STAssertEqualObjects([dictionary keyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong key at index %d.", i);
	}
	STAssertThrows([dictionary keyAtIndex:i], nil);
}

- (void) testKeysAtIndexes {
	STAssertThrows([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:0]], nil);
	[self populateDictionary];
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		STAssertNoThrow([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:location]], nil);
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			STAssertNoThrow([dictionary keysAtIndexes:indexes], nil);
			STAssertEqualObjects([dictionary keysAtIndexes:indexes],
			                     [keyArray objectsAtIndexes:indexes], nil);
		}
	}
	STAssertThrows([dictionary keysAtIndexes:nil], nil);
}

- (void) testNSFastEnumeration {
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
	// Insert keys in reverse sorted order
	for (NSUInteger number = limit; number >= 1; number--)
		[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithUnsignedInteger:number]];
	// Verify that keys are enumerated in sorted order
	NSUInteger expected = 32, count = 0;
	for (NSNumber *object in dictionary) {
		STAssertEquals([object unsignedIntegerValue], expected--, nil);
		count++;
	}
	STAssertEquals(count, limit, nil);
	
	BOOL raisedException = NO;
	@try {
		for (id key in dictionary)
			[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithInteger:-1]];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, nil);	
}

- (void) testObjectForKeyAtIndex {
	STAssertThrows([dictionary objectForKeyAtIndex:0], nil);
	
	[self populateDictionary];
	NSUInteger i;	
	for (i = 0; i < [keyArray count]; i++) {
		STAssertEqualObjects([dictionary objectForKeyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong object for key at index %d.", i);
	}
	STAssertThrows([dictionary objectForKeyAtIndex:i], nil);
}

- (void) testObjectsForKeyAtIndexes {
	STAssertThrows([dictionary objectsForKeysAtIndexes:nil], nil);
	[self populateDictionary];
	STAssertThrows([dictionary objectsForKeysAtIndexes:nil], nil);
	
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)];
			
			[dictionary objectsForKeysAtIndexes:indexes];
		}
	}
	STAssertThrows([dictionary objectsForKeysAtIndexes:nil], nil);
}

- (void) testOrderedDictionaryWithKeysAtIndexes {
	STAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil], nil);
	[self populateDictionary];
	STAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil], nil);

	CHOrderedDictionary* newDictionary;
	STAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:[NSIndexSet indexSet]], nil);
	STAssertNotNil(newDictionary, nil);
	STAssertEquals([newDictionary count], (NSUInteger)0, nil);
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			STAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:indexes], nil);
			STAssertEqualObjects([newDictionary allKeys], [keyArray objectsAtIndexes:indexes], nil);
		}
	}
	STAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil], nil);
}

- (void) testRemoveObjectForKeyAtIndex {
	// Test removing with invalid indexes
	STAssertThrows([dictionary removeObjectForKeyAtIndex:0], nil);
	[self populateDictionary];
	STAssertThrows([dictionary removeObjectForKeyAtIndex:[keyArray count]], nil);
	
	NSMutableArray *expected = [keyArray mutableCopy];
	[expected removeObjectAtIndex:4];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:4], nil);
	STAssertEqualObjects([dictionary allKeys], expected, nil);	
	[expected removeObjectAtIndex:2];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:2], nil);
	STAssertEqualObjects([dictionary allKeys], expected, nil);	
	[expected removeObjectAtIndex:0];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:0], nil);
	STAssertEqualObjects([dictionary allKeys], expected, nil);	
}

- (void) testSetObjectForKeyAtIndex {
	// Test that specifying a key index for an empty dictionary raises exception
	STAssertThrows([dictionary setObject:@"bogus" forKeyAtIndex:0], nil);
	STAssertThrows([dictionary setObject:@"bogus" forKeyAtIndex:1], nil);
	// Test replacing the value for a key at a valid index
	[self populateDictionary];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"foo", nil);
	[dictionary setObject:@"X" forKeyAtIndex:1];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"X", nil);
	// Test that an out-of-bounds key index results in an exception
	STAssertThrows([dictionary setObject:@"X" forKeyAtIndex:[keyArray count]], nil);
	// Test that a nil object results in an exception
	STAssertThrows([dictionary setObject:nil forKeyAtIndex:0], nil);
}

- (void) testRemoveObjectsForKeysAtIndexes {
	STAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil], nil);
	[self populateDictionary];
	STAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil], nil);
	
	NSDictionary* master = [NSDictionary dictionaryWithDictionary:dictionary];
	NSMutableDictionary* expected = [NSMutableDictionary dictionary];
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate dictionary and reset expected
			[dictionary removeAllObjects];
			[dictionary addEntriesFromDictionary:master];
			expected = [NSMutableDictionary dictionaryWithDictionary:master];
			[expected removeObjectsForKeys:[dictionary keysAtIndexes:indexes]];
			STAssertNoThrow([dictionary removeObjectsForKeysAtIndexes:indexes], nil);
			STAssertEqualObjects([dictionary allKeys], [expected allKeys], nil);
		}
	}	
	STAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil], nil);
}

@end
