/*
 CHMultiMapTest.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHMultiMap.h"
#import "Util.h"

void populateMultimap(CHMultiMap* multimap) {
	[multimap addObjects:[NSSet setWithObjects:@"A",@"B",@"C",nil] forKey:@"foo"];
	[multimap addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	[multimap addObjects:[NSSet setWithObjects:@"1",@"2",@"3",nil] forKey:@"baz"];
}

@interface CHMultiMapTest : SenTestCase
{
	CHMultiMap *multimap;
}

@end

@implementation CHMultiMapTest

- (void) setUp {
	multimap = [[CHMultiMap alloc] init];
}

- (void) tearDown {
	[multimap release];
}

#pragma mark -

- (void) testNSCoding {
	populateMultimap(multimap);
	
	NSString *filePath = @"/tmp/multimap.archive";
	[NSKeyedArchiver archiveRootObject:multimap toFile:filePath];
	
	CHMultiMap *multimap2 = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
	STAssertEquals([multimap2 count], [multimap count], @"Incorrect key count.");
	
	// TODO: Complete more in-depth testing of equality
	
	// TODO: Test archive/unarchive of empty multimap
}

- (void) testNSCopying {
	populateMultimap(multimap);
	
	CHMultiMap *multimap2 = [multimap copy];
	STAssertEquals([multimap2 count], [multimap count], @"Incorrect key count.");

	// TODO: Complete more in-depth testing of equality
	
	// TODO: Test copy of empty multimap
}

#pragma mark -

- (void) testAddEntriesFromMultiMap {
	CHMultiMap *multimap2 = [[CHMultiMap alloc] init];
	populateMultimap(multimap2);
	
	STAssertEquals([multimap count], 0u, @"Incorrect key count.");
	[multimap addEntriesFromMultiMap:multimap2];
	STAssertEquals([multimap count], 3u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 9u, @"Incorrect object count.");
}

- (void) testAddObjectForKey {
	STAssertEquals([multimap count], 0u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 0u, @"Incorrect object count.");

	[multimap addObject:@"A" forKey:@"foo"];
	STAssertEquals([multimap count], 1u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 1u, @"Incorrect object count.");
	
	[multimap addObject:@"B" forKey:@"bar"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 2u, @"Incorrect object count.");
	
	// Test adding second object for key
	[multimap addObject:@"C" forKey:@"bar"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 3u, @"Incorrect object count.");

	// Test adding duplicate object for key
	[multimap addObject:@"C" forKey:@"bar"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 3u, @"Incorrect object count.");

	STAssertEquals([multimap countForKey:@"foo"], 1u, @"Incorrect object count.");
	STAssertEquals([multimap countForKey:@"bar"], 2u, @"Incorrect object count.");
}

- (void) testAddObjectsForKey {
	[multimap addObjects:[NSSet setWithObjects:@"A",@"B",nil] forKey:@"foo"];
	STAssertEquals([multimap count], 1u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 2u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 2u, @"Incorrect object count.");

	[multimap addObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"bar"], 3u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 5u, @"Incorrect object count.");
	
	// Test adding an overlapping set of objects for an existing key
	[multimap addObjects:[NSSet setWithObjects:@"B",@"C",nil] forKey:@"foo"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 3u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 6u, @"Incorrect object count.");
}

- (void) testAllKeys {
	populateMultimap(multimap);
	
	NSSet *keys = [NSSet setWithObjects:@"foo", @"bar", @"baz", nil];
	STAssertEqualObjects([NSSet setWithArray:[multimap allKeys]], keys,
						 @"Incorrect results from -allKeys.");
}

- (void) testAllObjects {
	STAssertEquals([[multimap allObjects] count], 0u, @"Incorrect object count.");
	
	populateMultimap(multimap);

	NSArray *allObjects = [multimap allObjects];
	NSSet *objectsForKey;
	
	STAssertEquals([allObjects count], 9u, @"Incorrect object count.");
	for (id key in [multimap allKeys]) {
		objectsForKey = [multimap objectsForKey:key];
		for (id anObject in objectsForKey) {
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
	populateMultimap(multimap);
	description = [multimap description];
	NSMutableString *expected = [NSMutableString string];
	[expected appendString:@"{\n"];
	[expected appendString:@"    bar =     {(\n        Y,\n        X,\n        Z\n    )};\n"];
	[expected appendString:@"    baz =     {(\n        1,\n        2,\n        3\n    )};\n"];
	[expected appendString:@"    foo =     {(\n        B,\n        C,\n        A\n    )};\n"];
	[expected appendString:@"}"];
	STAssertEqualObjects(description, expected, @"Incorrect description.");
}

- (void) testInitWithObjectsAndKeys {
	[multimap release];
	multimap = [[CHMultiMap alloc] initWithObjectsAndKeys:
				[NSSet setWithObjects:@"A",@"B",@"C",nil], @"foo",
				@"Z", @"bar", nil];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 3u, @"Incorrect object count.");
	STAssertEquals([multimap countForKey:@"bar"], 1u, @"Incorrect object count.");
	
	STAssertThrows(([[CHMultiMap alloc] initWithObjectsAndKeys:
					@"A", @"foo", @"Z", nil]),
				   @"Should raise exception for nil key parameter.");

	STAssertThrows([[CHMultiMap alloc] initWithObjectsAndKeys:nil],
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
	multimap = [[CHMultiMap alloc] initWithObjects:objects forKeys:keys];
	
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 3u, @"Incorrect object count.");
	STAssertEquals([multimap countForKey:@"bar"], 1u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 4u, @"Incorrect object count.");
	
	[keys removeLastObject];
	STAssertThrows([[CHMultiMap alloc] initWithObjects:objects forKeys:keys],
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
	STAssertEquals([[keyEnumerator allObjects] count], 3u,
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
	STAssertEquals([[objectEnumerator allObjects] count], 9u,
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
	
	STAssertEquals([multimap count], 3u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 9u, @"Incorrect object count.");
	[multimap removeAllObjects];
	STAssertEquals([multimap count], 0u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 0u, @"Incorrect object count.");
}

- (void) testRemoveObjectForKey {
	populateMultimap(multimap);
	
	STAssertEquals([multimap count], 3u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 3u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 9u, @"Incorrect object count.");

	[multimap removeObject:@"A" forKey:@"foo"];
	STAssertEquals([multimap count], 3u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 2u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 8u, @"Incorrect object count.");
	
	[multimap removeObject:@"B" forKey:@"foo"];
	STAssertEquals([multimap count], 3u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 1u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 7u, @"Incorrect object count.");
	
	[multimap removeObject:@"C" forKey:@"foo"];
	// Removing the last object in the set for a key should also remove the key.
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForKey:@"foo"], 0u, @"Incorrect object count.");
	STAssertEquals([multimap countForAllKeys], 6u, @"Incorrect object count.");
}

- (void) testRemoveObjectsForKey {
	populateMultimap(multimap);
	
	STAssertEquals([multimap count], 3u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 9u, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"foo"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 6u, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"foo"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 6u, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"bar"];
	STAssertEquals([multimap count], 1u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 3u, @"Incorrect object count.");
	[multimap removeObjectsForKey:@"baz"];
	STAssertEquals([multimap count], 0u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 0u, @"Incorrect object count.");
}

- (void) testSetObjectsForKey {
	[multimap addObject:@"XYZ" forKey:@"foo"];
	STAssertEquals([multimap count], 1u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 1u, @"Incorrect object count.");
	STAssertTrue(([[multimap objectsForKey:@"foo"] isEqualToSet:
				   [NSSet setWithObjects:@"XYZ",nil]]),
				 @"Incorrect objects for key");
	
	[multimap setObjects:[NSSet setWithObjects:@"A",@"B",@"C",nil] forKey:@"foo"];
	STAssertEquals([multimap count], 1u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 3u, @"Incorrect object count.");
	STAssertTrue(([[multimap objectsForKey:@"foo"] isEqualToSet:
				   [NSSet setWithObjects:@"A",@"B",@"C",nil]]),
				 @"Incorrect objects for key");
	
	[multimap setObjects:[NSSet setWithObjects:@"X",@"Y",@"Z",nil] forKey:@"bar"];
	STAssertEquals([multimap count], 2u, @"Incorrect key count.");
	STAssertEquals([multimap countForAllKeys], 6u, @"Incorrect object count.");
	STAssertTrue(([[multimap objectsForKey:@"bar"] isEqualToSet:
				   [NSSet setWithObjects:@"X",@"Y",@"Z",nil]]),
				 @"Incorrect objects for key");
}

@end
