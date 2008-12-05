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
	STFail(@"Unimplemented unit test.");
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
	STFail(@"Unimplemented unit test.");
}

- (void) testObjectEnumerator {
	STFail(@"Unimplemented unit test.");
}

- (void) testObjectsForKey {
	STFail(@"Unimplemented unit test.");
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
	
	STFail(@"Unimplemented unit test.");
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
	STFail(@"Unimplemented unit test.");
}

@end
