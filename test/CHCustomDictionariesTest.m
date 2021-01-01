/*
 CHDataStructures.framework -- CHCustomDictionariesTest.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <XCTest/XCTest.h>

#import <CHDataStructures/CHBidirectionalDictionary.h>
#import <CHDataStructures/CHMutableDictionary.h>
#import <CHDataStructures/CHMultiDictionary.h>
#import <CHDataStructures/CHOrderedDictionary.h>
#import <CHDataStructures/CHSortedDictionary.h>

id replicateWithNSCoding(id dictionary) {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];	
}

static NSArray *keyArray;

#pragma mark -

@interface CHMutableDictionary (Test)

- (NSString *)debugDescription; // Declare here to prevent compiler warnings.

@end

@interface CHMutableDictionaryTest : XCTestCase {
	id dictionary;
	NSEnumerator *enumerator;
}
@end

@implementation CHMutableDictionaryTest

+ (void)initialize {
	keyArray = [[NSArray arrayWithObjects:@"baz", @"foo", @"bar", @"yoo", @"hoo", nil] retain];
}

- (void)setUp {
	dictionary = [[[CHMutableDictionary alloc] init] autorelease];
}

- (void)populateDictionary {
	enumerator = [keyArray objectEnumerator];
	id aKey;
	while (aKey = [enumerator nextObject]) {
		[dictionary setObject:aKey forKey:aKey];
	}
}

- (void)testInitWithObjectsForKeysCount {
	dictionary = [[[dictionary class] alloc] initWithObjects:keyArray forKeys:keyArray];
	// Should call down to -initWithObjects:forKeys:count:
}

- (void)testDebugDescription {
	XCTAssertNotNil([dictionary debugDescription]);
	[dictionary setObject:@"xyz" forKey:@"abc"];
	XCTAssertNotNil([dictionary debugDescription]);
}

- (void)testDescription {
	XCTAssertNotNil([dictionary description]);
	[dictionary setObject:@"xyz" forKey:@"abc"];
	XCTAssertNotNil([dictionary description]);
}

- (void)testKeyEnumerator {
	// Test that key enumerator is non-nil, even for an empty dictionary.
	enumerator = [dictionary keyEnumerator];
	XCTAssertNotNil(enumerator);
	// An enumerator with zero objects should return an empty, non-nil array
	NSArray *allKeys = [enumerator allObjects];
	XCTAssertNotNil(allKeys);
	XCTAssertEqual([allKeys count], (NSUInteger)0);
	
	[self populateDictionary];
	enumerator = [dictionary keyEnumerator];
	XCTAssertNotNil(enumerator);
	XCTAssertNotNil([enumerator allObjects]);
}

- (void)testObjectEnumerator {
	// Test that object enumerator is non-nil, even for an empty dictionary.
	enumerator = [dictionary objectEnumerator];
	XCTAssertNotNil(enumerator);
	// An enumerator with zero objects should return an empty, non-nil array
	NSArray *allObjects = [enumerator allObjects];
	XCTAssertNotNil(allObjects);
	XCTAssertEqual([allObjects count], (NSUInteger)0);
	
	[self populateDictionary];
	enumerator = [dictionary objectEnumerator];
	XCTAssertNotNil(enumerator);
	XCTAssertNotNil([enumerator allObjects]);
}

- (void)testRemoveAllObjects {
	// Removal shouldn't raise exception even if dictionary is empty
	XCTAssertEqual([dictionary count], (NSUInteger)0);
	XCTAssertNoThrow([dictionary removeAllObjects]);
	// Test that removal works for a non-empty dictionary
	[self populateDictionary];
	XCTAssertEqual([dictionary count], [keyArray count]);
	XCTAssertNoThrow([dictionary removeAllObjects]);
	XCTAssertEqual([dictionary count], (NSUInteger)0);
}

- (void)testRemoveObjectForKey {
	// Removal shouldn't raise exception even if dictionary is empty
	XCTAssertNil([dictionary objectForKey:@"foo"]);
	XCTAssertNoThrow([dictionary removeObjectForKey:@"foo"]);
	// Test that removal works for a non-empty dictionary
	[self populateDictionary];
	XCTAssertNotNil([dictionary objectForKey:@"foo"]);
	XCTAssertNoThrow([dictionary removeObjectForKey:@"foo"]);
	XCTAssertNil([dictionary objectForKey:@"foo"]);
}

- (void)testSetObjectForKey {
	// Verify that nil key and/or object raises an exception
	XCTAssertThrows([dictionary setObject:@"" forKey:nil]);
	XCTAssertThrows([dictionary setObject:nil forKey:@""]);
	
	XCTAssertNil([dictionary objectForKey:@"foo"]);
	[dictionary setObject:@"bar" forKey:@"foo"];
	XCTAssertEqualObjects([dictionary objectForKey:@"foo"], @"bar");
	
	// Verify that setting a different value for a key "takes" the new value
	[dictionary removeAllObjects];
	[self populateDictionary];
	id key = [keyArray lastObject];
	NSString *value = [dictionary objectForKey:key];
	
	[dictionary setObject:value forKey:key];
	XCTAssertEqualObjects(value, [dictionary objectForKey:key]);
	
	[dictionary setObject:[NSString string] forKey:key];
	XCTAssertFalse([value isEqual:[dictionary objectForKey:key]]);
}

- (void)testNSCoding {
	[self populateDictionary];
	id clone = replicateWithNSCoding(dictionary);
	XCTAssertEqualObjects([NSSet setWithArray:[clone allKeys]],
						 [NSSet setWithArray:[dictionary allKeys]]);
}

- (void)testNSCopying {
	id copy = [[dictionary copy] autorelease];
	XCTAssertEqual([copy count], [dictionary count]);
	XCTAssertEqual([copy hash], [dictionary hash]);
	XCTAssertEqualObjects([copy class], [dictionary class]);
	
	[self populateDictionary];
	copy = [[dictionary copy] autorelease];
	XCTAssertEqual([copy count], [dictionary count]);
	XCTAssertEqual([copy hash], [dictionary hash]);
}

@end

#pragma mark -

@interface CHBidirectionalDictionaryTest : CHMutableDictionaryTest
@end

@implementation CHBidirectionalDictionaryTest

- (void)setUp {
	dictionary = [[[CHBidirectionalDictionary alloc] init] autorelease];
}

- (void)testInverseDictionary {
	id inverse = [dictionary inverseDictionary];
	XCTAssertNotNil([dictionary inverseDictionary]);
	// Test identity of dictionary and inverse with respect to each other.
	XCTAssertEqual([inverse inverseDictionary], dictionary);
	XCTAssertEqual([inverse count], [dictionary count]);
	
	id key = @"A", value = @"B";
	// Make sure the mappings show up correctly in the dictionary.
	[dictionary setObject:value forKey:key];
	XCTAssertEqual([inverse count], [dictionary count]);
	XCTAssertEqualObjects([dictionary objectForKey:key], value);
	XCTAssertEqualObjects([dictionary keyForObject:value], key);
	XCTAssertNil([dictionary objectForKey:value]);
	// Make sure added mappings appear in the inverse dictionary.
	XCTAssertEqualObjects([inverse objectForKey:value], key);
	XCTAssertEqualObjects([inverse keyForObject:key], value);
	XCTAssertNil([inverse objectForKey:key]);
	// Make sure removed mappings disappear from the inverse dictionary.
	[dictionary removeObjectForKey:key];
	XCTAssertEqual([inverse count], [dictionary count]);
	XCTAssertNil([dictionary objectForKey:key]);
	XCTAssertNil([inverse objectForKey:value]);
}

- (void)testRemoveKeyForObject {
	XCTAssertNoThrow([dictionary removeKeyForObject:nil]);
	
	[dictionary setObject:@"B" forKey:@"A"];
	[dictionary setObject:@"D" forKey:@"C"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	// Try to remove non-existent values
	XCTAssertNoThrow([dictionary removeKeyForObject:@"A"]);
	XCTAssertNoThrow([dictionary removeKeyForObject:@"C"]);
	XCTAssertNoThrow([dictionary removeKeyForObject:@"bogus"]);
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	// Remove existing objects and associated keys
	[dictionary removeKeyForObject:@"B"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertNil([dictionary objectForKey:@"A"]);
	XCTAssertNil([dictionary keyForObject:@"B"]);
	[dictionary removeKeyForObject:@"D"];
	XCTAssertEqual([dictionary count], (NSUInteger)0);
	XCTAssertNil([dictionary objectForKey:@"C"]);
	XCTAssertNil([dictionary keyForObject:@"D"]);
}

- (void)testRemoveObjectForKey {
	XCTAssertNoThrow([dictionary removeObjectForKey:nil]);
	
	[dictionary setObject:@"B" forKey:@"A"];
	[dictionary setObject:@"D" forKey:@"C"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	// Try to remove non-existent keys
	XCTAssertNoThrow([dictionary removeObjectForKey:@"B"]);
	XCTAssertNoThrow([dictionary removeObjectForKey:@"D"]);
	XCTAssertNoThrow([dictionary removeObjectForKey:@"bogus"]);
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	// Remove existing objects and associated keys
	[dictionary removeObjectForKey:@"A"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertNil([dictionary objectForKey:@"A"]);
	XCTAssertNil([dictionary keyForObject:@"B"]);
	[dictionary removeObjectForKey:@"C"];
	XCTAssertEqual([dictionary count], (NSUInteger)0);
	XCTAssertNil([dictionary objectForKey:@"C"]);
	XCTAssertNil([dictionary keyForObject:@"D"]);
}

- (void)testSetAndQueryKeyAndObject {
	// Verify that nil key and/or object raises an exception
	XCTAssertThrows([dictionary setObject:@"" forKey:nil]);
	XCTAssertThrows([dictionary setObject:nil forKey:@""]);
	
	// Test basic key/value queries for an empty dictionary
	XCTAssertEqual([dictionary count], (NSUInteger)0);
	XCTAssertNoThrow([dictionary objectForKey:nil]);
	XCTAssertNoThrow([dictionary keyForObject:nil]);
	XCTAssertNil([dictionary objectForKey:@"A"]);
	XCTAssertNil([dictionary keyForObject:@"A"]);
	
	// Insert an object and test count, key, and value
	[dictionary setObject:@"B" forKey:@"A"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertEqualObjects([dictionary objectForKey:@"A"], @"B");
	XCTAssertEqualObjects([dictionary keyForObject:@"B"], @"A");
	
	// Verify that setting a different value for a key replaces the old value
	[dictionary setObject:@"C" forKey:@"A"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertNil([dictionary keyForObject:@"B"]);
	XCTAssertEqualObjects([dictionary objectForKey:@"A"], @"C");
	XCTAssertEqualObjects([dictionary keyForObject:@"C"], @"A");
	
	// Verify that setting a different key for a value replaces the old key
	[dictionary setObject:@"C" forKey:@"B"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertNil([dictionary objectForKey:@"A"]);
	XCTAssertEqualObjects([dictionary objectForKey:@"B"], @"C");
	XCTAssertEqualObjects([dictionary keyForObject:@"C"], @"B");
	
	// Verify that adding a different key and different value increases count
	[dictionary setObject:@"D" forKey:@"A"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqualObjects([dictionary objectForKey:@"A"], @"D");
	XCTAssertEqualObjects([dictionary objectForKey:@"B"], @"C");
	XCTAssertEqualObjects([dictionary keyForObject:@"D"], @"A");
	XCTAssertEqualObjects([dictionary keyForObject:@"C"], @"B");
	
	// Verify that modifying existing key-value pairs happens correctly
	[dictionary setObject:@"B" forKey:@"A"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqualObjects([dictionary objectForKey:@"A"], @"B");
	XCTAssertEqualObjects([dictionary objectForKey:@"B"], @"C");
	XCTAssertEqualObjects([dictionary keyForObject:@"B"], @"A");
	XCTAssertEqualObjects([dictionary keyForObject:@"C"], @"B");
	
	[dictionary setObject:@"D" forKey:@"C"];
	XCTAssertEqual([dictionary count], (NSUInteger)3);
	XCTAssertEqualObjects([dictionary objectForKey:@"A"], @"B");
	XCTAssertEqualObjects([dictionary objectForKey:@"B"], @"C");
	XCTAssertEqualObjects([dictionary objectForKey:@"C"], @"D");
	XCTAssertEqualObjects([dictionary keyForObject:@"B"], @"A");
	XCTAssertEqualObjects([dictionary keyForObject:@"C"], @"B");
	XCTAssertEqualObjects([dictionary keyForObject:@"D"], @"C");

	[dictionary setObject:@"D" forKey:@"A"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqualObjects([dictionary objectForKey:@"A"], @"D");
	XCTAssertEqualObjects([dictionary objectForKey:@"B"], @"C");
	XCTAssertEqualObjects([dictionary keyForObject:@"D"], @"A");
	XCTAssertEqualObjects([dictionary keyForObject:@"C"], @"B");
}

@end

#pragma mark -

@interface CHMultiDictionaryTest : CHMutableDictionaryTest
@end

@implementation CHMultiDictionaryTest

- (void)setUp {
	dictionary = [[[CHMultiDictionary alloc] init] autorelease];
}

- (void)populateDictionary {
	[dictionary addObjects:[NSSet setWithObjects:@"A",@"B",@"C",nil] forKey:@"foo"];
	[dictionary addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	[dictionary addObjects:[NSSet setWithObjects:@"1",@"2",@"3",nil] forKey:@"baz"];
}

- (void)testAddObjectForKey {
	XCTAssertEqual([dictionary count], (NSUInteger)0);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)0);
	
	[dictionary addObject:@"A" forKey:@"foo"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)1);
	
	[dictionary addObject:@"B" forKey:@"bar"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)2);
	
	// Test adding second object for key
	[dictionary addObject:@"C" forKey:@"bar"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)3);
	
	// Test adding duplicate object for key
	[dictionary addObject:@"C" forKey:@"bar"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)3);
	
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)1);
	XCTAssertEqual([dictionary countForKey:@"bar"], (NSUInteger)2);
}

- (void)testAddObjectsForKey {
	[dictionary addObjects:[NSSet setWithObjects:@"A",@"B",nil] forKey:@"foo"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)2);
	
	[dictionary addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqual([dictionary countForKey:@"bar"], (NSUInteger)3);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)5);
	
	// Test adding an overlapping set of objects for an existing key
	[dictionary addObjects:[NSSet setWithObjects:@"B",@"C",nil] forKey:@"foo"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)3);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)6);
}

- (void)testInitWithObjectsAndKeys {
	// Test initializing with no objects or keys
	XCTAssertNoThrow([[CHMultiDictionary alloc] initWithObjectsAndKeys:nil]);
	// Test initializing with invalid nil key parameter (unmatched values/keys)
	XCTAssertThrows(([[CHMultiDictionary alloc] initWithObjectsAndKeys:
					 @"A",@"B",@"C",nil]));
	// Test initializing with values from sets, arrays, and normal objects
	dictionary = [[[CHMultiDictionary alloc] initWithObjectsAndKeys:
				   [NSSet setWithObjects:@"A",@"B",@"C",nil], @"foo",
				   [NSArray arrayWithObjects:@"X",@"Y",nil], @"bar",
				   @"Z", @"baz", nil] autorelease];
	XCTAssertEqual([dictionary count],              (NSUInteger)3);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)3);
	XCTAssertEqual([dictionary countForKey:@"bar"], (NSUInteger)2);
	XCTAssertEqual([dictionary countForKey:@"baz"], (NSUInteger)1);
}

- (void)testInitWithObjectsForKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSMutableArray *objects = [NSMutableArray array];
	
	[keys addObject:@"foo"];
	[objects addObject:[NSSet setWithObjects:@"A",@"B",@"C",nil]];
	
	[keys addObject:@"bar"];
	[objects addObject:[NSNull null]];
	
	dictionary = [[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys];
	
	XCTAssertEqual([dictionary count],              (NSUInteger)2);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)3);
	XCTAssertEqual([dictionary countForKey:@"bar"], (NSUInteger)1);
	XCTAssertEqual([dictionary countForAllKeys],    (NSUInteger)4);
	
	// Test initializing with key and object arrays of different lengths
	[keys removeLastObject];
	XCTAssertThrows([[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys]);
}

- (void)testObjectEnumerator {
	[self populateDictionary];
	
	enumerator = [dictionary objectEnumerator];
	XCTAssertEqual([[enumerator allObjects] count], [dictionary count]);
	id anObject;
	while (anObject = [enumerator nextObject]) {
		XCTAssertTrue([anObject isKindOfClass:[NSSet class]]);
	}
}

- (void)testObjectsForKey {
	[self populateDictionary];
	
	XCTAssertEqualObjects([dictionary objectsForKey:@"foo"],
						 ([NSSet setWithObjects:@"A",@"B",@"C",nil]));
	XCTAssertEqualObjects([dictionary objectsForKey:@"bar"],
	                     ([NSSet setWithObjects:@"X",@"Y",@"Z",nil]));
	XCTAssertEqualObjects([dictionary objectsForKey:@"baz"],
	                     ([NSSet setWithObjects:@"1",@"2",@"3",nil]));
	XCTAssertNil([dictionary objectsForKey:@"bogus"]);
}

- (void)testRemoveAllObjects {
	[self populateDictionary];
	
	XCTAssertEqual([dictionary count], (NSUInteger)3);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)9);
	[dictionary removeAllObjects];
	XCTAssertEqual([dictionary count], (NSUInteger)0);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)0);
}

- (void)testRemoveObjectForKey {
	[self populateDictionary];
	
	XCTAssertEqual([dictionary count], (NSUInteger)3);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)3);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)9);
	
	[dictionary removeObject:@"A" forKey:@"foo"];
	XCTAssertEqual([dictionary count], (NSUInteger)3);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)8);
	
	[dictionary removeObject:@"B" forKey:@"foo"];
	XCTAssertEqual([dictionary count], (NSUInteger)3);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)1);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)7);
	
	[dictionary removeObject:@"C" forKey:@"foo"];
	// Removing the last object in the set for a key should also remove the key.
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqual([dictionary countForKey:@"foo"], (NSUInteger)0);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)6);
}

- (void)testRemoveObjectsForKey {
	[self populateDictionary];
	
	XCTAssertEqual([dictionary count],           (NSUInteger)3);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)9);
	[dictionary removeObjectsForKey:@"foo"];
	XCTAssertEqual([dictionary count],           (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)6);
	[dictionary removeObjectsForKey:@"foo"];
	XCTAssertEqual([dictionary count],           (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)6);
	[dictionary removeObjectsForKey:@"bar"];
	XCTAssertEqual([dictionary count],           (NSUInteger)1);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)3);
	[dictionary removeObjectsForKey:@"baz"];
	XCTAssertEqual([dictionary count],           (NSUInteger)0);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)0);
}

- (void)testSetObjectForKey {
	// Verify that nil key and/or object raises an exception
	XCTAssertThrows([dictionary setObject:@"" forKey:nil]);
	XCTAssertThrows([dictionary setObject:nil forKey:@""]);

	XCTAssertNil([dictionary objectForKey:@"foo"]);
	[dictionary setObject:@"bar" forKey:@"foo"];
	XCTAssertEqualObjects([dictionary objectForKey:@"foo"],
						 [NSSet setWithObject:@"bar"]);
	
	// Verify that setting a different value for a key "takes" the new value
	[dictionary removeAllObjects];
	[self populateDictionary];
	id key = [[dictionary keyEnumerator] nextObject];
	NSString *value = [dictionary objectForKey:key];
	
	[dictionary setObject:value forKey:key];
	XCTAssertEqualObjects(value, [dictionary objectForKey:key]);
	
	[dictionary setObject:[NSString string] forKey:key];
	XCTAssertFalse([value isEqual:[dictionary objectForKey:key]]);
}

- (void)testSetObjectsForKey {
	// Verify that nil key and/or object raises an exception
	XCTAssertThrows([dictionary setObjects:[NSSet set] forKey:nil]);
	XCTAssertThrows([dictionary setObjects:nil forKey:@""]);

	NSSet *objectSet;
	
	[dictionary addObject:@"XYZ" forKey:@"foo"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)1);
	XCTAssertEqualObjects([dictionary objectsForKey:@"foo"],
						 [NSSet setWithObject:@"XYZ"]);
	
	objectSet = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[dictionary setObjects:objectSet forKey:@"foo"];
	XCTAssertEqual([dictionary count], (NSUInteger)1);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)3);
	XCTAssertEqualObjects([dictionary objectsForKey:@"foo"], objectSet);
	
	objectSet = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	[dictionary setObjects:objectSet forKey:@"bar"];
	XCTAssertEqual([dictionary count], (NSUInteger)2);
	XCTAssertEqual([dictionary countForAllKeys], (NSUInteger)6);
	XCTAssertEqualObjects([dictionary objectsForKey:@"bar"], objectSet);
}

@end

#pragma mark -

@interface CHDictionaryWithOrderingTest : CHMutableDictionaryTest
{
	NSArray *expectedKeyOrder;
}

@end

@implementation CHDictionaryWithOrderingTest

- (void)testFirstKey {
	if (![dictionary respondsToSelector:@selector(firstKey)])
		return;
	XCTAssertNil([dictionary firstKey]);
	[self populateDictionary];
	XCTAssertEqualObjects([dictionary firstKey], [expectedKeyOrder objectAtIndex:0]);
}

- (void)testKeyEnumerator {
	enumerator = [dictionary keyEnumerator];
	XCTAssertNotNil(enumerator);
	NSArray *allKeys = [enumerator allObjects];
	XCTAssertNotNil(allKeys);
	XCTAssertEqual([allKeys count], (NSUInteger)0);
	
	[self populateDictionary];
	
	enumerator = [dictionary keyEnumerator];
	XCTAssertNotNil(enumerator);
	allKeys = [enumerator allObjects];
	XCTAssertNotNil(allKeys);
	XCTAssertEqualObjects(allKeys, [dictionary allKeys]);
}

- (void)testLastKey {
	if (![dictionary respondsToSelector:@selector(lastKey)])
		return;
	XCTAssertNil([dictionary lastKey]);
	[self populateDictionary];
	XCTAssertEqualObjects([dictionary lastKey], [expectedKeyOrder lastObject]);
}

- (void)testReverseKeyEnumerator {
	if (![dictionary respondsToSelector:@selector(reverseKeyEnumerator)])
		return;
	enumerator = [dictionary reverseKeyEnumerator];
	XCTAssertNotNil(enumerator);
	NSArray *allKeys = [enumerator allObjects];
	XCTAssertNotNil(allKeys);
	XCTAssertEqual([allKeys count], (NSUInteger)0);
	
	[self populateDictionary];
	
	enumerator = [dictionary reverseKeyEnumerator];
	XCTAssertNotNil(enumerator);
	allKeys = [enumerator allObjects];
	XCTAssertNotNil(allKeys);
	XCTAssertEqual([allKeys count], [keyArray count]);
	
	if ([dictionary isMemberOfClass:[CHOrderedDictionary class]]) {
		expectedKeyOrder = keyArray;
	} else {
		expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
	}
	XCTAssertEqualObjects([[dictionary reverseKeyEnumerator] allObjects],
	                     [[expectedKeyOrder reverseObjectEnumerator] allObjects]);
}

- (void)testNSCoding {
	[self populateDictionary];
	id clone = replicateWithNSCoding(dictionary);
	XCTAssertEqualObjects(clone, dictionary);
}

- (void)testNSCopying {
	id copy = [[dictionary copy] autorelease];
	XCTAssertEqualObjects([copy class], [dictionary class]);
	XCTAssertEqual([copy hash], [dictionary hash]);
	XCTAssertEqual([copy count], [dictionary count]);
	
	[self populateDictionary];
	copy = [[dictionary copy] autorelease];
	XCTAssertEqual([copy hash], [dictionary hash]);
	XCTAssertEqual([copy count], [dictionary count]);
	XCTAssertEqualObjects(copy, dictionary);
	XCTAssertEqualObjects([copy allKeys], [dictionary allKeys]);
}

@end

#pragma mark -

@interface CHSortedDictionaryTest : CHDictionaryWithOrderingTest
@end

@implementation CHSortedDictionaryTest

- (void)setUp {
	dictionary = [[[CHSortedDictionary alloc] init] autorelease];
	expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
}

- (void)testAllKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSNumber *key;
	for (NSUInteger i = 0; i <= 20; i++) {
		key = [NSNumber numberWithUnsignedInt:arc4random()];
		[keys addObject:key];
		[dictionary setObject:[NSNull null] forKey:key];
	}
	[keys sortUsingSelector:@selector(compare:)];
	XCTAssertEqualObjects([dictionary allKeys], keys);
}

- (void)testNSFastEnumeration {
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
	// Insert keys in reverse sorted order
	for (NSUInteger number = limit; number >= 1; number--)
		[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithUnsignedInteger:number]];
	// Verify that keys are enumerated in sorted order
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in dictionary) {
		XCTAssertEqual([object unsignedIntegerValue], expected++);
		count++;
	}
	XCTAssertEqual(count, limit);
	
	BOOL raisedException = NO;
	@try {
		for (id key in dictionary)
			[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithInteger:-1]];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	XCTAssertTrue(raisedException);	
}

- (void)testSubsetFromKeyToKeyOptions {
	XCTAssertNoThrow([dictionary subsetFromKey:nil toKey:nil options:0]);
	XCTAssertNoThrow([dictionary subsetFromKey:@"A" toKey:@"Z" options:0]);
	
	[self populateDictionary];
	NSMutableDictionary *subset;
	
	XCTAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:0]
												 toKey:[expectedKeyOrder lastObject]
											   options:0]);
	XCTAssertEqual([subset count], [expectedKeyOrder count]);

	XCTAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:1]
												 toKey:[expectedKeyOrder objectAtIndex:3]
											   options:0]);
	XCTAssertEqual([subset count], (NSUInteger)3);
}

@end

#pragma mark -

@interface CHOrderedDictionaryTest : CHDictionaryWithOrderingTest
@end

@implementation CHOrderedDictionaryTest

- (void)setUp {
	dictionary = [[[CHOrderedDictionary alloc] init] autorelease];
	expectedKeyOrder = keyArray;
}

- (void)testAllKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSNumber *key;
	for (NSUInteger i = 0; i <= 20; i++) {
		key = [NSNumber numberWithUnsignedInt:arc4random()];
		[keys addObject:key];
		[dictionary setObject:[NSNull null] forKey:key];
	}
	XCTAssertEqualObjects([dictionary allKeys], keys);
}

- (void)testExchangeKeyAtIndexWithKeyAtIndex {
	// Test for exceptions when trying to exchange when collection is empty.
	XCTAssertThrows([dictionary exchangeKeyAtIndex:0 withKeyAtIndex:1]);
	XCTAssertThrows([dictionary exchangeKeyAtIndex:1 withKeyAtIndex:0]);
	
	[self populateDictionary];
	// Exchanging objects at the same index should have no effect
	[dictionary exchangeKeyAtIndex:1 withKeyAtIndex:1];
	XCTAssertEqualObjects([dictionary allKeys], keyArray);
	// Test swapping first and last objects
	[dictionary exchangeKeyAtIndex:0 withKeyAtIndex:[keyArray count]-1];
	XCTAssertEqualObjects([dictionary firstKey], @"hoo");
	XCTAssertEqualObjects([dictionary lastKey],  @"baz");
}

- (void)testIndexOfKey {
	XCTAssertTrue([dictionary indexOfKey:@"foo"] == NSNotFound);
	[self populateDictionary];
	for (NSUInteger i = 0; i < [keyArray count]; i++) {
		XCTAssertEqual([dictionary indexOfKey:[keyArray objectAtIndex:i]], i);
	}
}

- (void)testInsertObjectForKeyAtIndex {
	// Test inserting at bad index, and with nil key and object.
	XCTAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:1]);
	XCTAssertThrows([dictionary insertObject:nil    forKey:@"foo" atIndex:0]);
	XCTAssertThrows([dictionary insertObject:@"foo" forKey:nil    atIndex:0]);
	
	[self populateDictionary];
	NSUInteger count = [dictionary count];
	XCTAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:count+1]);
	// Test inserting a new value at the back
	XCTAssertNoThrow([dictionary insertObject:@"xyz" forKey:@"xyz" atIndex:count]);
	XCTAssertEqualObjects([dictionary lastKey], @"xyz");
	// Test inserting a new value at the front
	XCTAssertNoThrow([dictionary insertObject:@"abc" forKey:@"abc" atIndex:0]);
	XCTAssertEqualObjects([dictionary firstKey], @"abc");
}

- (void)testKeyAtIndex {
	XCTAssertThrows([dictionary keyAtIndex:0]);
	XCTAssertThrows([dictionary keyAtIndex:1]);
	[self populateDictionary];
	NSUInteger i;
	for (i = 0; i < [keyArray count]; i++) {
		XCTAssertEqualObjects([dictionary keyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong key at index %d.", i);
	}
	XCTAssertThrows([dictionary keyAtIndex:i]);
}

- (void)testKeysAtIndexes {
	XCTAssertThrows([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:0]]);
	[self populateDictionary];
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet *indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		XCTAssertNoThrow([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:location]]);
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			XCTAssertNoThrow([dictionary keysAtIndexes:indexes]);
			XCTAssertEqualObjects([dictionary keysAtIndexes:indexes],
			                     [keyArray objectsAtIndexes:indexes]);
		}
	}
	XCTAssertThrows([dictionary keysAtIndexes:nil]);
}

- (void)testNSFastEnumeration {
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
	// Insert keys in reverse sorted order
	for (NSUInteger number = limit; number >= 1; number--)
		[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithUnsignedInteger:number]];
	// Verify that keys are enumerated in sorted order
	NSUInteger expected = 32, count = 0;
	for (NSNumber *object in dictionary) {
		XCTAssertEqual([object unsignedIntegerValue], expected--);
		count++;
	}
	XCTAssertEqual(count, limit);
	
	BOOL raisedException = NO;
	@try {
		for (id key in dictionary)
			[dictionary setObject:[NSNull null] forKey:[NSNumber numberWithInteger:-1]];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	XCTAssertTrue(raisedException);	
}

- (void)testObjectForKeyAtIndex {
	XCTAssertThrows([dictionary objectForKeyAtIndex:0]);
	
	[self populateDictionary];
	NSUInteger i;	
	for (i = 0; i < [keyArray count]; i++) {
		XCTAssertEqualObjects([dictionary objectForKeyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong object for key at index %d.", i);
	}
	XCTAssertThrows([dictionary objectForKeyAtIndex:i]);
}

- (void)testObjectsForKeyAtIndexes {
	XCTAssertThrows([dictionary objectsForKeysAtIndexes:nil]);
	[self populateDictionary];
	XCTAssertThrows([dictionary objectsForKeysAtIndexes:nil]);
	
	NSIndexSet *indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)];
			
			[dictionary objectsForKeysAtIndexes:indexes];
		}
	}
	XCTAssertThrows([dictionary objectsForKeysAtIndexes:nil]);
}

- (void)testOrderedDictionaryWithKeysAtIndexes {
	XCTAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil]);
	[self populateDictionary];
	XCTAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil]);

	CHOrderedDictionary *newDictionary;
	XCTAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:[NSIndexSet indexSet]]);
	XCTAssertNotNil(newDictionary);
	XCTAssertEqual([newDictionary count], (NSUInteger)0);
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet *indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			XCTAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:indexes]);
			XCTAssertEqualObjects([newDictionary allKeys], [keyArray objectsAtIndexes:indexes]);
		}
	}
	XCTAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil]);
}

- (void)testRemoveObjectForKeyAtIndex {
	// Test removing with invalid indexes
	XCTAssertThrows([dictionary removeObjectForKeyAtIndex:0]);
	[self populateDictionary];
	XCTAssertThrows([dictionary removeObjectForKeyAtIndex:[keyArray count]]);
	
	NSMutableArray *expected = [keyArray mutableCopy];
	[expected removeObjectAtIndex:4];
	XCTAssertNoThrow([dictionary removeObjectForKeyAtIndex:4]);
	XCTAssertEqualObjects([dictionary allKeys], expected);	
	[expected removeObjectAtIndex:2];
	XCTAssertNoThrow([dictionary removeObjectForKeyAtIndex:2]);
	XCTAssertEqualObjects([dictionary allKeys], expected);	
	[expected removeObjectAtIndex:0];
	XCTAssertNoThrow([dictionary removeObjectForKeyAtIndex:0]);
	XCTAssertEqualObjects([dictionary allKeys], expected);	
}

- (void)testSetObjectForKeyAtIndex {
	// Test that specifying a key index for an empty dictionary raises exception
	XCTAssertThrows([dictionary setObject:@"bogus" forKeyAtIndex:0]);
	XCTAssertThrows([dictionary setObject:@"bogus" forKeyAtIndex:1]);
	// Test replacing the value for a key at a valid index
	[self populateDictionary];
	XCTAssertEqualObjects([dictionary objectForKey:@"foo"], @"foo");
	[dictionary setObject:@"X" forKeyAtIndex:1];
	XCTAssertEqualObjects([dictionary objectForKey:@"foo"], @"X");
	// Test that an out-of-bounds key index results in an exception
	XCTAssertThrows([dictionary setObject:@"X" forKeyAtIndex:[keyArray count]]);
	// Test that a nil object results in an exception
	XCTAssertThrows([dictionary setObject:nil forKeyAtIndex:0]);
}

- (void)testRemoveObjectsForKeysAtIndexes {
	XCTAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil]);
	[self populateDictionary];
	XCTAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil]);
	
	NSDictionary *master = [NSDictionary dictionaryWithDictionary:dictionary];
	NSMutableDictionary *expected = [NSMutableDictionary dictionary];
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet *indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate dictionary and reset expected
			[dictionary removeAllObjects];
			[dictionary addEntriesFromDictionary:master];
			expected = [NSMutableDictionary dictionaryWithDictionary:master];
			[expected removeObjectsForKeys:[dictionary keysAtIndexes:indexes]];
			XCTAssertNoThrow([dictionary removeObjectsForKeysAtIndexes:indexes]);
			XCTAssertEqualObjects([dictionary allKeys], [expected allKeys]);
		}
	}	
	XCTAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil]);
}

@end
