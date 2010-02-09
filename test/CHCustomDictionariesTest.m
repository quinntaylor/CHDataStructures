/*
 CHDataStructures.framework -- CHCustomDictionariesTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>

#import "CHLockableDictionary.h"
#import "CHMultiDictionary.h"
#import "CHOrderedDictionary.h"
#import "CHSortedDictionary.h"

id replicateWithNSCoding(id dictionary) {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];	
}

#pragma mark -

@interface CHLockableDictionary (Test)

- (NSString*) debugDescription; // Declare here to prevent compiler warnings.

@end

#pragma mark -

@interface CHLockableDictionaryTest : SenTestCase {
	id dictionary;
	NSArray *keyArray;
	NSEnumerator *enumerator;
}
@end

@implementation CHLockableDictionaryTest

- (void) setUp {
	dictionary = [[[CHLockableDictionary alloc] init] autorelease];
	keyArray = [NSArray arrayWithObjects:@"baz", @"foo", @"bar", @"yoo", @"hoo", nil];
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
	STAssertNotNil([dictionary debugDescription], @"Description was nil.");
	[dictionary setObject:@"xyz" forKey:@"abc"];
	STAssertNotNil([dictionary debugDescription], @"Description was nil.");
}

- (void) testDescription {
	STAssertEqualObjects([dictionary description], [[NSDictionary dictionary] description], @"Incorrect description");
}

- (void) testKeyEnumerator {
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], (NSUInteger)0, @"Wrong number of keys.");
	
	[self populateDictionary];
	
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
}

- (void) testRemoveAllObjects {
	STAssertEquals([dictionary count], (NSUInteger)0, @"Dictionary should be empty.");
	STAssertNoThrow([dictionary removeAllObjects], @"Should be no exception.");
	[self populateDictionary];
	STAssertEquals([dictionary count], [keyArray count], @"Wrong key count.");
	[dictionary removeAllObjects];
	STAssertEquals([dictionary count], (NSUInteger)0, @"Dictionary should be empty.");
}

- (void) testRemoveObjectForKey {
	STAssertNoThrow([dictionary removeObjectForKey:@"foo"], @"Should be no exception.");
	STAssertNil([dictionary objectForKey:@"foo"], @"Object should not exist.");
	[self populateDictionary];
	STAssertNotNil([dictionary objectForKey:@"foo"], @"Object should exist.");
	[dictionary removeObjectForKey:@"foo"];
	STAssertNil([dictionary objectForKey:@"foo"], @"Object should not exist.");
}

- (void) testSetObjectForKey {
	// Verify that nil key and/or object raises an exception
	STAssertThrows([dictionary setObject:nil forKey:nil], @"Should raise exception");
	STAssertThrows([dictionary setObject:@"" forKey:nil], @"Should raise exception");
	STAssertThrows([dictionary setObject:nil forKey:@""], @"Should raise exception");
	
	STAssertNil([dictionary objectForKey:@"foo"], @"Object should be nil.");
	[dictionary setObject:@"bar" forKey:@"foo"];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"bar",
						 @"Wrong object for key.");
	
	// Verify that setting a different value for a key "takes" the new value
	[dictionary removeAllObjects];
	[self populateDictionary];
	id key = [keyArray lastObject];
	NSString *value = [dictionary objectForKey:key];
	
	[dictionary setObject:value forKey:key];
	STAssertTrue([value isEqual:[dictionary objectForKey:key]], @"Should be equal.");
	
	[dictionary setObject:[NSString string] forKey:key];
	STAssertFalse([value isEqual:[dictionary objectForKey:key]], @"Should not be equal.");
}

- (void) testNSCoding {
	[self populateDictionary];
	id clone = replicateWithNSCoding(dictionary);
	STAssertEqualObjects([NSSet setWithArray:[clone allKeys]],
						 [NSSet setWithArray:[dictionary allKeys]],
						 @"Wrong keys on reconstruction.");
}

- (void) testNSCopying {
	id copy = [dictionary copy];
	STAssertEquals([copy count], [dictionary count], @"Wrong count.");
	STAssertEquals([copy hash], [dictionary hash], @"Hashes should match.");
	STAssertEqualObjects([copy class], [dictionary class], @"Wrong class.");
	[copy release];
	
	[self populateDictionary];
	copy = [dictionary copy];
	STAssertEquals([copy count], [dictionary count], @"Wrong count.");
	STAssertEquals([copy hash], [dictionary hash], @"Hashes should match.");
	[copy release];
}

@end

#pragma mark -

@interface CHMultiDictionaryTest : CHLockableDictionaryTest
@end

@implementation CHMultiDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHMultiDictionary alloc] init] autorelease];
}

- (void) populateDictionary {
	[dictionary addObjects:[NSSet setWithObjects:@"A",@"B",@"C",nil] forKey:@"foo"];
	[dictionary addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	[dictionary addObjects:[NSSet setWithObjects:@"1",@"2",@"3",nil] forKey:@"baz"];
}

- (void) testAddObjectForKey {
	STAssertEquals([dictionary count], (NSUInteger)0, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)0, @"Incorrect object count.");
	
	[dictionary addObject:@"A" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)1, @"Incorrect object count.");
	
	[dictionary addObject:@"B" forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)2, @"Incorrect object count.");
	
	// Test adding second object for key
	[dictionary addObject:@"C" forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, @"Incorrect object count.");
	
	// Test adding duplicate object for key
	[dictionary addObject:@"C" forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, @"Incorrect object count.");
	
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)1, @"Incorrect object count.");
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)2, @"Incorrect object count.");
}

- (void) testAddObjectsForKey {
	[dictionary addObjects:[NSSet setWithObjects:@"A",@"B",nil] forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)2, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)2, @"Incorrect object count.");
	
	[dictionary addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)5, @"Incorrect object count.");
	
	// Test adding an overlapping set of objects for an existing key
	[dictionary addObjects:[NSSet setWithObjects:@"B",@"C",nil] forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
}

- (void) testInitWithObjectsAndKeys {
	[dictionary release];
	dictionary = [[CHMultiDictionary alloc] initWithObjectsAndKeys:
				  [NSSet setWithObjects:@"A",@"B",@"C",nil], @"foo",
				  [NSArray arrayWithObjects:@"X",@"Y",nil], @"bar",
				  @"Z", @"baz", nil];
	STAssertEquals([dictionary count],              (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)2, @"Incorrect object count.");
	STAssertEquals([dictionary countForKey:@"baz"], (NSUInteger)1, @"Incorrect object count.");
	
	STAssertThrows(([[CHMultiDictionary alloc] initWithObjectsAndKeys:
					 @"A", @"foo", @"Z", nil]),
				   @"Should raise exception for nil key parameter.");
	
	STAssertNoThrow([[CHMultiDictionary alloc] initWithObjectsAndKeys:nil],
				   @"Should not raise exception for nil first parameter.");
}

- (void) testInitWithObjectsForKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSMutableArray *objects = [NSMutableArray array];
	
	[keys addObject:@"foo"];
	[objects addObject:[NSSet setWithObjects:@"A",@"B",@"C",nil]];
	
	[keys addObject:@"bar"];
	[objects addObject:[NSNull null]];
	
	[dictionary release];
	dictionary = [[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys];
	
	STAssertEquals([dictionary count],              (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([dictionary countForKey:@"bar"], (NSUInteger)1, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys],    (NSUInteger)4, @"Incorrect object count.");
	
	[keys removeLastObject];
	STAssertThrows([[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys],
				   @"Init with arrays of unequal length should raise exception.");
}

- (void) testObjectEnumerator {
	[self populateDictionary];
	
	enumerator = [dictionary objectEnumerator];
	STAssertEquals([[enumerator allObjects] count], [dictionary count],
				   @"Wrong object count.");
	id anObject;
	while (anObject = [enumerator nextObject]) {
		STAssertTrue([anObject isKindOfClass:[NSSet class]], @"Not a set");
	}
}

- (void) testObjectsForKey {
	[self populateDictionary];
	
	STAssertTrue(([[dictionary objectsForKey:@"foo"] isEqualToSet:
				   [NSSet setWithObjects:@"A",@"B",@"C",nil]]),
				 @"Incorrect objects for key");
	STAssertTrue(([[dictionary objectsForKey:@"bar"] isEqualToSet:
				   [NSSet setWithObjects:@"X",@"Y",@"Z",nil]]),
				 @"Incorrect objects for key");
	STAssertTrue(([[dictionary objectsForKey:@"baz"] isEqualToSet:
				   [NSSet setWithObjects:@"1",@"2",@"3",nil]]),
				 @"Incorrect objects for key");
	
	STAssertNil([dictionary objectsForKey:@"bogus"], @"Should be nil for bad key.");
}

- (void) testRemoveAllObjects {
	[self populateDictionary];
	
	STAssertEquals([dictionary count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)9, @"Incorrect object count.");
	[dictionary removeAllObjects];
	STAssertEquals([dictionary count], (NSUInteger)0, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)0, @"Incorrect object count.");
}

- (void) testRemoveObjectForKey {
	[self populateDictionary];
	
	STAssertEquals([dictionary count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)9, @"Incorrect object count.");
	
	[dictionary removeObject:@"A" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)2, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)8, @"Incorrect object count.");
	
	[dictionary removeObject:@"B" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)1, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)7, @"Incorrect object count.");
	
	[dictionary removeObject:@"C" forKey:@"foo"];
	// Removing the last object in the set for a key should also remove the key.
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForKey:@"foo"], (NSUInteger)0, @"Incorrect object count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
}

- (void) testRemoveObjectsForKey {
	[self populateDictionary];
	
	STAssertEquals([dictionary count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)9, @"Incorrect object count.");
	[dictionary removeObjectsForKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
	[dictionary removeObjectsForKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
	[dictionary removeObjectsForKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, @"Incorrect object count.");
	[dictionary removeObjectsForKey:@"baz"];
	STAssertEquals([dictionary count], (NSUInteger)0, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)0, @"Incorrect object count.");
}

- (void) testSetObjectForKey {
	// Verify that nil key and/or object raises an exception
	STAssertThrows([dictionary setObject:nil forKey:nil], @"Should raise exception");
	STAssertThrows([dictionary setObject:@"" forKey:nil], @"Should raise exception");
	STAssertThrows([dictionary setObject:nil forKey:@""], @"Should raise exception");

	STAssertNil([dictionary objectForKey:@"foo"], @"Object should be nil.");
	[dictionary setObject:@"bar" forKey:@"foo"];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], [NSSet setWithObject:@"bar"],
						 @"Wrong object for key.");
	
	// Verify that setting a different value for a key "takes" the new value
	[dictionary removeAllObjects];
	[self populateDictionary];
	id key = [[dictionary keyEnumerator] nextObject];
	NSString *value = [dictionary objectForKey:key];
	
	[dictionary setObject:value forKey:key];
	STAssertEqualObjects(value, [dictionary objectForKey:key], @"Should be equal.");
	
	[dictionary setObject:[NSString string] forKey:key];
	STAssertFalse([value isEqual:[dictionary objectForKey:key]], @"Should not be equal.");
}

- (void) testSetObjectsForKey {
	// Verify that nil key and/or object raises an exception
	STAssertThrows([dictionary setObjects:nil forKey:nil], @"Should raise exception");
	STAssertThrows([dictionary setObjects:@"" forKey:nil], @"Should raise exception");
	STAssertThrows([dictionary setObjects:nil forKey:@""], @"Should raise exception");

	NSSet* objectSet;
	
	[dictionary addObject:@"XYZ" forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)1, @"Incorrect object count.");
	STAssertEqualObjects([dictionary objectsForKey:@"foo"], [NSSet setWithObject:@"XYZ"],
				 @"Incorrect objects for key");
	
	objectSet = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[dictionary setObjects:objectSet forKey:@"foo"];
	STAssertEquals([dictionary count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)3, @"Incorrect object count.");
	STAssertEqualObjects([dictionary objectsForKey:@"foo"], objectSet,
				 @"Incorrect objects for key");
	
	objectSet = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	[dictionary setObjects:objectSet forKey:@"bar"];
	STAssertEquals([dictionary count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([dictionary countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
	STAssertEqualObjects([dictionary objectsForKey:@"bar"], objectSet,
				 @"Incorrect objects for key");
}

@end

#pragma mark -

@interface CHDictionaryWithOrderingTest : CHLockableDictionaryTest
{
	NSArray *expectedKeyOrder;
}

@end

@implementation CHDictionaryWithOrderingTest

- (void) verifyKeyCountAndOrdering:(NSArray*)allKeys forDictionary:(id)aDictionary {
	STAssertEquals([aDictionary count], [keyArray count], @"Incorrect key count.");
	
	if (expectedKeyOrder != nil) {
		if (allKeys == nil)
			allKeys = [aDictionary allKeys];
		NSUInteger count = MIN([aDictionary count], [expectedKeyOrder count]);
		for (NSUInteger i = 0; i < count; i++) {
			STAssertEqualObjects([allKeys objectAtIndex:i],
								 [expectedKeyOrder objectAtIndex:i],
								 @"Wrong output ordering of keys.");
		}
	}
}

- (void) verifyKeyCountAndOrderingForDictionary:(id)aDictionary {
	[self verifyKeyCountAndOrdering:nil forDictionary:aDictionary];
}

- (void) verifyKeyCountAndOrdering:(NSArray*)ordering {
	[self verifyKeyCountAndOrdering:ordering forDictionary:dictionary];
}

- (void) testFirstKey {
	if (![dictionary respondsToSelector:@selector(firstKey)])
		return;
	STAssertNil([dictionary firstKey], @"First key should be nil.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary firstKey],
						 [expectedKeyOrder objectAtIndex:0],
						 @"Wrong first key.");
}

- (void) testKeyEnumerator {
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], (NSUInteger)0, @"Wrong number of keys.");
	
	[self populateDictionary];
	
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	
	[self verifyKeyCountAndOrderingForDictionary:dictionary];
}

- (void) testLastKey {
	if (![dictionary respondsToSelector:@selector(lastKey)])
		return;
	STAssertNil([dictionary lastKey], @"Last key should be nil.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary lastKey],
						 [expectedKeyOrder lastObject],
						 @"Wrong last key.");
}

- (void) testReverseKeyEnumerator {
	if (![dictionary respondsToSelector:@selector(reverseKeyEnumerator)])
		return;
	enumerator = [dictionary reverseKeyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], (NSUInteger)0, @"Wrong number of keys.");
	
	[self populateDictionary];
	
	enumerator = [dictionary reverseKeyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	
	if ([dictionary isMemberOfClass:[CHOrderedDictionary class]]) {
		expectedKeyOrder = keyArray;
	} else {
		expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
	}
	expectedKeyOrder = [[expectedKeyOrder reverseObjectEnumerator] allObjects];
	[self verifyKeyCountAndOrdering:[[dictionary reverseKeyEnumerator] allObjects]];
}

- (void) testNSCoding {
	[self populateDictionary];
	[self verifyKeyCountAndOrderingForDictionary:dictionary];
	
	id clone = replicateWithNSCoding(dictionary);
	[self verifyKeyCountAndOrderingForDictionary:clone];
	STAssertEqualObjects([clone allKeys], [dictionary allKeys],
						 @"Wrong key ordering on reconstruction.");
}

- (void) testNSCopying {
	id copy = [dictionary copy];
	STAssertEquals([copy count], (NSUInteger)0, @"Copy of dictionary should be empty.");
	STAssertEquals([dictionary hash], [copy hash], @"Hashes should match.");
	STAssertEqualObjects([copy class], [dictionary class], @"Wrong class.");
	[copy release];
	
	[self populateDictionary];
	copy = [dictionary copy];
	[self verifyKeyCountAndOrderingForDictionary:copy];
	STAssertEquals([copy hash], [dictionary hash], @"Hashes should match.");
	[copy release];
}

@end

#pragma mark -

@interface CHSortedDictionaryTest : CHDictionaryWithOrderingTest
@end

@implementation CHSortedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHSortedDictionary alloc] init] autorelease];
	expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
}

- (void) testSubsetFromKeyToKeyOptions {
	STAssertNoThrow([dictionary subsetFromKey:nil toKey:nil options:0],
					@"Should not raise exception.");
	STAssertNoThrow([dictionary subsetFromKey:@"A" toKey:@"Z" options:0],
					@"Should not raise exception.");
	
	[self populateDictionary];
	NSMutableDictionary* subset;
	
	STAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:0]
												 toKey:[expectedKeyOrder lastObject]
											   options:0],
					@"Should not raise exception.");
	STAssertEquals([subset count], [expectedKeyOrder count], @"Wrong count for subset");

	STAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:1]
												 toKey:[expectedKeyOrder objectAtIndex:3]
											   options:0],
					@"Should not raise exception.");
	STAssertEquals([subset count], (NSUInteger)3, @"Wrong count for subset");
}

@end

#pragma mark -

@interface CHOrderedDictionaryTest : CHDictionaryWithOrderingTest
@end

@implementation CHOrderedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHOrderedDictionary alloc] init] autorelease];
	expectedKeyOrder = keyArray;
}

- (void) testExchangeKeyAtIndexWithKeyAtIndex {
	STAssertThrows([dictionary exchangeKeyAtIndex:0 withKeyAtIndex:1],
				   @"Should raise exception, collection is empty.");
	STAssertThrows([dictionary exchangeKeyAtIndex:1 withKeyAtIndex:0],
				   @"Should raise exception, collection is empty.");
	
	[self populateDictionary];
	[dictionary exchangeKeyAtIndex:1 withKeyAtIndex:1];
	STAssertEqualObjects([dictionary allKeys], keyArray, @"Should have no effect.");
	[dictionary exchangeKeyAtIndex:0 withKeyAtIndex:[keyArray count]-1];
	STAssertEqualObjects([dictionary firstKey], @"hoo", @"Bad order after swap.");
	STAssertEqualObjects([dictionary lastKey],  @"baz", @"Bad order after swap.");
}

- (void) testIndexOfKey {
	STAssertEquals([dictionary indexOfKey:@"foo"], (NSUInteger)NSNotFound,
				   @"Key should not be found in dictionary");
	[self populateDictionary];
	for (NSUInteger i = 0; i < [keyArray count]; i++) {
		STAssertEquals([dictionary indexOfKey:[keyArray objectAtIndex:i]], i,
					   @"Wrong index for key.");
	}
}

- (void) testInsertObjectForKeyAtIndex {
	STAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:1],
	               @"Should raise NSRangeException for bad index.");
	STAssertThrows([dictionary insertObject:nil forKey:@"foo" atIndex:0],
	               @"Should raise NSInvalidArgumentException for nil param.");
	STAssertThrows([dictionary insertObject:@"foo" forKey:nil atIndex:0],
	               @"Should raise NSInvalidArgumentException for nil param.");
	
	[self populateDictionary];
	NSUInteger count = [dictionary count];
	STAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:count+1],
	               @"Should raise NSRangeException for bad index.");
	STAssertNoThrow([dictionary insertObject:@"xyz" forKey:@"xyz" atIndex:count],
	                @"Should be able to insert a new value at the end");
	STAssertEqualObjects([dictionary lastKey], @"xyz", @"Last key should be 'xyz'.");
	STAssertNoThrow([dictionary insertObject:@"abc" forKey:@"abc" atIndex:0],
	                @"Should be able to insert a new value at the end");
	STAssertEqualObjects([dictionary firstKey], @"abc", @"First key should be 'abc'.");
}

- (void) testKeyAtIndex {
	STAssertThrows([dictionary keyAtIndex:0], @"Should raise exception.");
	STAssertThrows([dictionary keyAtIndex:1], @"Should raise exception.");
	[self populateDictionary];
	NSUInteger i;
	for (i = 0; i < [keyArray count]; i++) {
		STAssertEqualObjects([dictionary keyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong key at index %d.", i);
	}
	STAssertThrows([dictionary keyAtIndex:i], @"Should raise exception.");
}

- (void) testKeysAtIndexes {
	STAssertThrows([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:0]],
				   @"Should raise NSRangeException for nonexistent index.");
	[self populateDictionary];
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		STAssertNoThrow([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:location]],
		                @"Should not raise exception, valid index.");
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			STAssertNoThrow([dictionary keysAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			STAssertEqualObjects([dictionary keysAtIndexes:indexes],
			                     [keyArray objectsAtIndexes:indexes],
								 @"Key selection mismatch.");
		}
	}
}

- (void) testObjectForKeyAtIndex {
	STAssertThrows([dictionary objectForKeyAtIndex:0], @"Should raise exception");
	
	[self populateDictionary];
	NSUInteger i;	
	for (i = 0; i < [keyArray count]; i++) {
		STAssertEqualObjects([dictionary objectForKeyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong object for key at index %d.", i);
	}
	STAssertThrows([dictionary objectForKeyAtIndex:i], @"Should raise exception.");
}

- (void) testObjectsForKeyAtIndexes {
	STAssertThrows([dictionary objectsForKeysAtIndexes:nil], @"Should raise exception.");
	[self populateDictionary];
	STAssertThrows([dictionary objectsForKeysAtIndexes:nil], @"Should raise exception.");
	
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)];
			
			[dictionary objectsForKeysAtIndexes:indexes];
		}
	}
}

- (void) testOrderedDictionaryWithKeysAtIndexes {
	STAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil], @"Index set cannot be nil.");
	[self populateDictionary];
	STAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil], @"Index set cannot be nil.");

	CHOrderedDictionary* newDictionary;
	STAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:[NSIndexSet indexSet]],
	                @"Should not raise exception");
	STAssertNotNil(newDictionary, @"Result should not be nil.");
	STAssertEquals([newDictionary count], (NSUInteger)0, @"Wrong count.");
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			STAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			STAssertEqualObjects([newDictionary allKeys],
			                     [keyArray objectsAtIndexes:indexes],
								 @"Key selection mismatch.");
		}
	}
}

- (void) testRemoveObjectForKeyAtIndex {
	STAssertThrows([dictionary removeObjectForKeyAtIndex:0], @"Nonexistent index.");
	
	[self populateDictionary];
	STAssertThrows([dictionary removeObjectForKeyAtIndex:[keyArray count]], @"Nonexistent index.");
	
	NSMutableArray *expected = [keyArray mutableCopy];
	[expected removeObjectAtIndex:4];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:4], @"Should be no exception");
	STAssertEqualObjects([dictionary allKeys], expected, @"Wrong key ordering");	
	[expected removeObjectAtIndex:2];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:2], @"Should be no exception");
	STAssertEqualObjects([dictionary allKeys], expected, @"Wrong key ordering");	
	[expected removeObjectAtIndex:0];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:0], @"Should be no exception");
	STAssertEqualObjects([dictionary allKeys], expected, @"Wrong key ordering");	
}

- (void) testSetObjectForKeyAtIndex {
	STAssertThrows([dictionary setObject:@"new foo" forKeyAtIndex:0],
	               @"Should raise exception");
	
	[self populateDictionary];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"foo", @"Wrong object");
	[dictionary setObject:@"X" forKeyAtIndex:1];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"X", @"Wrong object");
	STAssertThrows([dictionary setObject:@"X" forKeyAtIndex:[keyArray count]],
	               @"Should raise exception");
}

- (void) testRemoveObjectsForKeysAtIndexes {
	STAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil], @"Index set cannot be nil.");
	[self populateDictionary];
	STAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil], @"Index set cannot be nil.");
	
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
			STAssertNoThrow([dictionary removeObjectsForKeysAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			STAssertEqualObjects([dictionary allKeys],
			                     [expected allKeys],
								 @"Key selection mismatch.");
		}
	}	
}

@end
