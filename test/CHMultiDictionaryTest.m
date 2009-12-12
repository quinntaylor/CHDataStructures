/*
 CHDataStructures.framework -- CHMultiDictionaryTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHMultiDictionary.h"
#import "Util.h"

void populateMultimap(CHMultiDictionary* multimap) {
	[multimap addObjects:[NSSet setWithObjects:@"A",@"B",@"C",nil] forKey:@"foo"];
	[multimap addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	[multimap addObjects:[NSSet setWithObjects:@"1",@"2",@"3",nil] forKey:@"baz"];
}

@interface CHMultiDictionaryTest : SenTestCase
{
	CHMultiDictionary *multimap;
	NSEnumerator *e;
	id anObject;
}

@end

@implementation CHMultiDictionaryTest

- (void) setUp {
	multimap = [[CHMultiDictionary alloc] init];
}

- (void) tearDown {
	[multimap release];
}

#pragma mark -

- (void) testNSCoding {
	populateMultimap(multimap);
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:multimap];
	CHMultiDictionary *multimap2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	STAssertEquals([multimap2 count], [multimap count], @"Incorrect key count.");
	NSEnumerator *keys1 = [multimap keyEnumerator];
	NSEnumerator *keys2 = [multimap2 keyEnumerator];
	id key1, key2;
	while ((key1 = [keys1 nextObject]) && (key2 = [keys2 nextObject])) {
		STAssertEqualObjects(key1, key2, @"Keys are not equal.");
		STAssertEqualObjects([multimap objectsForKey:key1],
							 [multimap2 objectsForKey:key2], @"Values are not equal.");
	}
}

- (void) testNSCopying {
	populateMultimap(multimap);
	
	CHMultiDictionary *multimap2 = [multimap copy];
	STAssertEquals([multimap2 count], [multimap count], @"Incorrect key count.");
	STAssertEquals([multimap2 hash], [multimap hash], @"Hashes should match.");

	NSEnumerator *keys1 = [multimap keyEnumerator];
	NSEnumerator *keys2 = [multimap2 keyEnumerator];
	id key1, key2;
	while ((key1 = [keys1 nextObject]) && (key2 = [keys2 nextObject])) {
		STAssertEqualObjects(key1, key2, @"Keys are not equal.");
		STAssertEqualObjects([multimap objectsForKey:key1],
							 [multimap2 objectsForKey:key2], @"Values are not equal.");
	}
}

#if OBJC_API_2
- (void) testNSFastEnumeration {
	populateMultimap(multimap);
	
	NSEnumerator *keys = [multimap keyEnumerator];
	for (id key in multimap) {
		STAssertEqualObjects(key, [keys nextObject], @"Key enumeration mismatch.");
	}
	STAssertNil([keys nextObject], @"Key enumerator should be exhausted");
}
#endif

#pragma mark -

- (void) testAddEntriesFromMultiDictionary {
	CHMultiDictionary *multimap2 = [[CHMultiDictionary alloc] init];
	populateMultimap(multimap2);
	
	STAssertEquals([multimap count], (NSUInteger)0, @"Incorrect key count.");
	[multimap addEntriesFromMultiDictionary:multimap2];
	STAssertEquals([multimap count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)9, @"Incorrect object count.");
}

- (void) testAddObjectForKey {
	STAssertEquals([multimap count], (NSUInteger)0, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)0, @"Incorrect object count.");

	[multimap addObject:@"A" forKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)1, @"Incorrect object count.");
	
	[multimap addObject:@"B" forKey:@"bar"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)2, @"Incorrect object count.");
	
	// Test adding second object for key
	[multimap addObject:@"C" forKey:@"bar"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)3, @"Incorrect object count.");

	// Test adding duplicate object for key
	[multimap addObject:@"C" forKey:@"bar"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)3, @"Incorrect object count.");

	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)1, @"Incorrect object count.");
	STAssertEquals([multimap countForKey:@"bar"], (NSUInteger)2, @"Incorrect object count.");
}

- (void) testAddObjectsForKey {
	[multimap addObjects:[NSSet setWithObjects:@"A",@"B",nil] forKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)2, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)2, @"Incorrect object count.");

	[multimap addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"bar"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)5, @"Incorrect object count.");
	
	// Test adding an overlapping set of objects for an existing key
	[multimap addObjects:[NSSet setWithObjects:@"B",@"C",nil] forKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
}

- (void) testAllKeys {
	populateMultimap(multimap);
	
	NSSet *keys = [NSSet setWithObjects:@"foo", @"bar", @"baz", nil];
	STAssertEqualObjects([NSSet setWithArray:[multimap allKeys]], keys,
						 @"Incorrect results from -allKeys.");
}

- (void) testAllObjects {
	STAssertEquals([[multimap allObjects] count], (NSUInteger)0, @"Incorrect object count.");
	
	populateMultimap(multimap);

	NSArray *allObjects = [multimap allObjects];
	
	STAssertEquals([allObjects count], (NSUInteger)9, @"Incorrect object count.");
	NSEnumerator *keys = [multimap keyEnumerator];
	id key;
	while (key = [keys nextObject]) {
		e = [[multimap objectsForKey:key] objectEnumerator];
		while (anObject = [e nextObject]) {
			STAssertTrue([allObjects containsObject:anObject],
						 @"Should contain object.");
		}
	}
}

- (void) testContainsKey {
	populateMultimap(multimap);
	
	STAssertTrue([multimap containsKey:@"foo"], @"Should contain key.");
	STAssertFalse([multimap containsKey:@"yoohoo"], @"Should not contain key.");
}

- (void) testContainsObject {
	populateMultimap(multimap);
	
	STAssertTrue([multimap containsObject:@"C"], @"Should contain object.");
	STAssertTrue([multimap containsObject:@"Y"], @"Should contain object.");
	STAssertTrue([multimap containsObject:@"1"], @"Should contain object.");
	STAssertFalse([multimap containsObject:@"?"], @"Should not contain object.");
}

- (void) testDescription {
	NSString *description;
	
	// Test description for an empty multimap
	description = [multimap description];
	STAssertEqualObjects(description, @"{\n}", @"Incorrect empty description.");
	
	// Test description for a populated multimap
//	populateMultimap(multimap);
//	description = [multimap description];
//	NSMutableString *expected = [NSMutableString string];
//	[expected appendString:@"{\n"];
//	// Account for how -[NSSet description] produces different results on 64-bit
//#if defined(__x86_64__) || defined(__ppc64__)
//	[expected appendString:@"    bar =     {(\n        Y,\n        Z,\n        X\n    )};\n"];
//	[expected appendString:@"    baz =     {(\n        1,\n        3,\n        2\n    )};\n"];
//	[expected appendString:@"    foo =     {(\n        C,\n        B,\n        A\n    )};\n"];
//#else
//	[expected appendString:@"    bar =     {(\n        Y,\n        X,\n        Z\n    )};\n"];
//	[expected appendString:@"    baz =     {(\n        1,\n        2,\n        3\n    )};\n"];
//	[expected appendString:@"    foo =     {(\n        B,\n        C,\n        A\n    )};\n"];
//#endif
//	[expected appendString:@"}"];
//	STAssertEqualObjects(description, expected, @"Incorrect description.");
}

- (void) testInitWithObjectsAndKeys {
	[multimap release];
	multimap = [[CHMultiDictionary alloc] initWithObjectsAndKeys:
				[NSSet setWithObjects:@"A",@"B",@"C",nil], @"foo",
				[NSArray arrayWithObjects:@"X",@"Y",nil], @"bar",
				@"z", @"baz", nil];
	STAssertEquals([multimap count],              (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([multimap countForKey:@"bar"], (NSUInteger)2, @"Incorrect object count.");
	STAssertEquals([multimap countForKey:@"baz"], (NSUInteger)1, @"Incorrect object count.");
	
	STAssertThrows(([[CHMultiDictionary alloc] initWithObjectsAndKeys:
					@"A", @"foo", @"Z", nil]),
				   @"Should raise exception for nil key parameter.");

	STAssertThrows([[CHMultiDictionary alloc] initWithObjectsAndKeys:nil],
				   @"Should raise exception for nil first parameter.");
}

- (void) testInitWithObjectsForKeys {
	NSMutableArray *keys = [NSMutableArray array];
	NSMutableArray *objects = [NSMutableArray array];
	
	[keys addObject:@"foo"];
	[objects addObject:[NSSet setWithObjects:@"A",@"B",@"C",nil]];

	[keys addObject:@"bar"];
	[objects addObject:[NSNull null]];
	
	[multimap release];
	multimap = [[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys];
	
	STAssertEquals([multimap count],              (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([multimap countForKey:@"bar"], (NSUInteger)1, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys],    (NSUInteger)4, @"Incorrect object count.");
	
	[keys removeLastObject];
	STAssertThrows([[CHMultiDictionary alloc] initWithObjects:objects forKeys:keys],
				   @"Init with arrays of unequal length should raise exception.");
}

- (void) testKeyEnumerator {
	populateMultimap(multimap);
	NSEnumerator *keyEnumerator;
	
	keyEnumerator = [multimap keyEnumerator];
	for (int count = 1; count <= 3; count++)
		STAssertNotNil([keyEnumerator nextObject], @"Should not be nil.");
	STAssertNil([keyEnumerator nextObject], @"Should be nil.");
	
	keyEnumerator = [multimap keyEnumerator];
	STAssertEquals([[keyEnumerator allObjects] count], (NSUInteger)3,
				   @"Wrong key count.");
}

- (void) testObjectEnumerator {
	populateMultimap(multimap);
	NSEnumerator *objectEnumerator;
	
	objectEnumerator = [multimap objectEnumerator];
	for (int count = 1; count <= 9; count++)
		STAssertNotNil([objectEnumerator nextObject], @"Should not be nil.");
	STAssertNil([objectEnumerator nextObject], @"Should be nil.");

	objectEnumerator = [multimap objectEnumerator];
	STAssertEquals([[objectEnumerator allObjects] count], (NSUInteger)9,
				   @"Wrong object count.");
}

- (void) testObjectsForKey {
	populateMultimap(multimap);

	STAssertTrue(([[multimap objectsForKey:@"foo"] isEqualToSet:
				   [NSSet setWithObjects:@"A",@"B",@"C",nil]]),
				 @"Incorrect objects for key");
	STAssertTrue(([[multimap objectsForKey:@"bar"] isEqualToSet:
				   [NSSet setWithObjects:@"X",@"Y",@"Z",nil]]),
				 @"Incorrect objects for key");
	STAssertTrue(([[multimap objectsForKey:@"baz"] isEqualToSet:
				   [NSSet setWithObjects:@"1",@"2",@"3",nil]]),
				 @"Incorrect objects for key");
	
	STAssertNil([multimap objectsForKey:@"bogus"], @"Should be nil for bad key.");
}

- (void) testRemoveAllObjects {
	populateMultimap(multimap);
	
	STAssertEquals([multimap count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)9, @"Incorrect object count.");
	[multimap removeAllObjects];
	STAssertEquals([multimap count], (NSUInteger)0, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)0, @"Incorrect object count.");
}

- (void) testRemoveObjectForKey {
	populateMultimap(multimap);
	
	STAssertEquals([multimap count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)3, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)9, @"Incorrect object count.");

	[multimap removeObject:@"A" forKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)2, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)8, @"Incorrect object count.");
	
	[multimap removeObject:@"B" forKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)1, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)7, @"Incorrect object count.");
	
	[multimap removeObject:@"C" forKey:@"foo"];
	// Removing the last object in the set for a key should also remove the key.
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], (NSUInteger)0, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
}

- (void) testRemoveObjectsForKey {
	populateMultimap(multimap);
	
	STAssertEquals([multimap count], (NSUInteger)3, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)9, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"bar"];
	STAssertEquals([multimap count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)3, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"baz"];
	STAssertEquals([multimap count], (NSUInteger)0, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)0, @"Incorrect object count.");
}

- (void) testSetObjectsForKey {
	[multimap addObject:@"XYZ" forKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)1, @"Incorrect object count.");
	STAssertTrue(([[multimap objectsForKey:@"foo"] isEqualToSet:
				   [NSSet setWithObjects:@"XYZ",nil]]),
				 @"Incorrect objects for key");
	
	[multimap setObjects:[NSSet setWithObjects:@"A",@"B",@"C",nil] forKey:@"foo"];
	STAssertEquals([multimap count], (NSUInteger)1, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)3, @"Incorrect object count.");
	STAssertTrue(([[multimap objectsForKey:@"foo"] isEqualToSet:
				   [NSSet setWithObjects:@"A",@"B",@"C",nil]]),
				 @"Incorrect objects for key");
	
	[multimap setObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	STAssertEquals([multimap count], (NSUInteger)2, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], (NSUInteger)6, @"Incorrect object count.");
	STAssertTrue(([[multimap objectsForKey:@"bar"] isEqualToSet:
				   [NSSet setWithObjects:@"X",@"Y",@"Z",nil]]),
				 @"Incorrect objects for key");
}

@end
