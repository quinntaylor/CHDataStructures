/*
 CHDataStructures.framework -- CHCustomDictionariesTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>

#import "CHLockableDictionary.h"
#import "CHLinkedDictionary.h"
#import "CHSortedDictionary.h"

@interface CHCustomDictionariesTest : SenTestCase {
	id dictionary;
	NSArray *keyArray;
	NSArray *expectedKeyOrder;
	NSEnumerator *enumerator;
}
@end

@implementation CHCustomDictionariesTest

- (void) setUp {
	dictionary = [[[CHLockableDictionary alloc] init] autorelease];
	keyArray = [NSArray arrayWithObjects:@"baz", @"foo", @"bar", @"yoo", @"hoo", nil];
	expectedKeyOrder = nil;
}

- (void) populateDictionary {
	enumerator = [keyArray objectEnumerator];
	id aKey;
	while (aKey = [enumerator nextObject]) {
		[dictionary setObject:aKey forKey:aKey];
	}
}

- (void) verifyKeyCountAndOrdering:(NSArray*)allKeys {
	STAssertEquals([dictionary count], [keyArray count], @"Incorrect key count.");

	if (expectedKeyOrder != nil) {
		if (allKeys == nil)
			allKeys = [dictionary allKeys];
		NSUInteger count = MIN([dictionary count], [expectedKeyOrder count]);
		for (int i = 0; i < count; i++) {
			STAssertEqualObjects([allKeys objectAtIndex:i],
								 [expectedKeyOrder objectAtIndex:i],
								 @"Wrong output ordering of keys.");
		}
	}
}

- (void) verifyKeyCountAndOrdering {
	[self verifyKeyCountAndOrdering:nil];
}

- (void) testInitWithObjectsForKeysCount {
	dictionary = [[[dictionary class] alloc] initWithObjects:keyArray forKeys:keyArray];
	// Should call down to -initWithObjects:forKeys:count:
}

- (void) testSetObjectForKey {
	STAssertNil([dictionary objectForKey:@"foo"], @"Object should be nil.");
	[dictionary setObject:@"bar" forKey:@"foo"];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"bar",
						 @"Wrong object for key.");
}

- (void) testDescription {
	STAssertEqualObjects([dictionary description], [[NSDictionary dictionary] description], @"Incorrect description");
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

- (void) testLastKey {
	if (![dictionary respondsToSelector:@selector(lastKey)])
		return;
	STAssertNil([dictionary lastKey], @"Last key should be nil.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary lastKey],
						 [expectedKeyOrder lastObject],
						 @"Wrong last key.");
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
	
	[self verifyKeyCountAndOrdering];
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
	
	if ([dictionary isMemberOfClass:[CHLinkedDictionary class]]) {
		expectedKeyOrder = keyArray;
	} else {
		expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
	}
	expectedKeyOrder = [[expectedKeyOrder reverseObjectEnumerator] allObjects];
	[self verifyKeyCountAndOrdering:[[dictionary reverseKeyEnumerator] allObjects]];
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

#pragma mark -

- (void) testNSCoding {
	[self populateDictionary];
	[self verifyKeyCountAndOrdering];
	
	NSString *filePath = @"/tmp/CHDataStructures-dictionary.plist";
	[NSKeyedArchiver archiveRootObject:dictionary toFile:filePath];
	id oldDictionary = dictionary;
	
	dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
	[self verifyKeyCountAndOrdering];
	STAssertEqualObjects([dictionary allKeys], [oldDictionary allKeys],
						 @"Wrong key ordering on reconstruction.");
	
	[[NSFileManager defaultManager] removeFileAtPath:filePath handler:nil];
}

- (void) testNSCopying {
	id copy = [dictionary copy];
	STAssertEquals([copy count], (NSUInteger)0, @"Copy of dictionary should be empty.");
	STAssertEqualObjects([copy class], [dictionary class], @"Wrong class.");
	[copy release];
	
	[self populateDictionary];
	dictionary = [dictionary copy];
	[self verifyKeyCountAndOrdering];
	[dictionary release];
}

@end

#pragma mark -

@interface CHSortedDictionaryTest : CHCustomDictionariesTest
@end

@implementation CHSortedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHSortedDictionary alloc] init] autorelease];
	expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
}

/*
- (void) testSubsetFromKeyToKey {
	STAssertNoThrow([dictionary subsetFromKey:nil toKey:nil],
					@"Should not raise exception.");
	STAssertNoThrow([dictionary subsetFromKey:@"A" toKey:@"Z"],
					@"Should not raise exception.");
	
	STFail(@"Incomplete test.");
}
*/

@end

#pragma mark -

@interface CHLinkedDictionaryTest : CHCustomDictionariesTest
@end

@implementation CHLinkedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHLinkedDictionary alloc] init] autorelease];
	expectedKeyOrder = keyArray;
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

- (void) testRemoveObjectForKeyAtIndex {
	STAssertThrows([dictionary removeObjectForKeyAtIndex:0], @"Should raise exception");
	
	[self populateDictionary];
	STAssertThrows([dictionary removeObjectForKeyAtIndex:5], @"Should raise exception");
	
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

@end
