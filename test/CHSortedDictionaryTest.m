/*
 CHDataStructures.framework -- CHSortedDictionaryTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHSortedDictionary.h"

@interface CHSortedDictionaryTest : SenTestCase {
	CHSortedDictionary *dictionary;
	NSArray *keysJumbled, *keysSorted;
}

@end

@implementation CHSortedDictionaryTest

- (void) setUp {
	dictionary = [[CHSortedDictionary alloc] init];
	keysJumbled = [NSArray arrayWithObjects:@"baz", @"foo", @"bar", @"yoo", @"hoo", nil];
	keysSorted = [keysJumbled sortedArrayUsingSelector:@selector(compare:)];
}

- (void) tearDown {
	[dictionary release];
}

- (void) populateDictionary {
	NSEnumerator *keys = [keysJumbled objectEnumerator];
	id aKey;
	while (aKey = [keys nextObject]) {
		[dictionary setObject:@"X" forKey:aKey];
	}
}

#pragma mark -

- (void) testFirstKey {
	STAssertNil([dictionary firstKey], @"First key should be nil.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary firstKey], [keysSorted objectAtIndex:0],
						 @"Wrong first key.");
}

- (void) testLastKey {
	STAssertNil([dictionary lastKey], @"Last key should be nil.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary lastKey], [keysSorted lastObject],
						 @"Wrong last key.");
}

- (void) testKeyEnumerator {
	NSEnumerator *keyEnumerator = [dictionary keyEnumerator];
	STAssertNotNil(keyEnumerator, @"Key enumerator should be non-nil");
	NSArray *allKeys = [keyEnumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], 0u, @"Wrong number of keys.");
	
	[self populateDictionary];
	
	keyEnumerator = [dictionary keyEnumerator];
	STAssertNotNil(keyEnumerator, @"Key enumerator should be non-nil");
	allKeys = [keyEnumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], [keysJumbled count], @"Wrong number of keys.");
	for (int i = 0; i < [keysSorted count]; i++) {
		STAssertEqualObjects([allKeys objectAtIndex:i], [keysSorted objectAtIndex:i],
		                     @"Wrong output ordering of keys.");
	}
}

- (void) testRemoveAllObjects {
	STAssertEquals([dictionary count], 0u, @"Dictionary should be empty.");
	STAssertNoThrow([dictionary removeAllObjects], @"Should be no exception.");
	[self populateDictionary];
	STAssertEquals([dictionary count], [keysJumbled count], @"Wrong key count.");
				   [dictionary removeAllObjects];
	STAssertEquals([dictionary count], 0u, @"Dictionary should be empty.");
}

- (void) testRemoveObjectForFirstKey {
	STAssertEquals([dictionary count], 0u, @"Dictionary should be empty.");
	STAssertNoThrow([dictionary removeObjectForFirstKey], @"Should be no exception.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary firstKey], [keysSorted objectAtIndex:0],
						 @"Wrong first key.");
	[dictionary removeObjectForFirstKey];
	STAssertEqualObjects([dictionary firstKey], [keysSorted objectAtIndex:1],
						 @"Wrong last key.");
}

- (void) testRemoveObjectForLastKey {
	STAssertEquals([dictionary count], 0u, @"Dictionary should be empty.");
	STAssertNoThrow([dictionary removeObjectForLastKey], @"Should be no exception.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary lastKey], [keysSorted objectAtIndex:[keysSorted count]-1],
						 @"Wrong last key.");
	[dictionary removeObjectForLastKey];
	STAssertEqualObjects([dictionary lastKey], [keysSorted objectAtIndex:[keysSorted count]-2],
						 @"Wrong last key.");
}

@end
