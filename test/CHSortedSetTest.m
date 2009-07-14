/*
 CHDataStructures.framework -- CHSortedSetTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHSortedSet.h"

#import "CHAnderssonTree.h"
#import "CHAVLTree.h"
#import "CHRedBlackTree.h"
#import "CHTreap.h"
#import "CHUnbalancedTree.h"

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
#if MAC_OS_X_VERSION_10_5_AND_LATER
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
	          traversal, correct, order]
	         stringByReplacingOccurrencesOfString:@"\n" withString:@""]
	        stringByReplacingOccurrencesOfString:@"    " withString:@""];
#else
	return [NSString stringWithFormat:@"%@ should be %@, was %@",
	        traversal, correct, order];
#endif
}

@interface CHSortedSetTest : SenTestCase {
	NSArray *sortedSetClasses;
	NSArray *objects;
	id sortedSet;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHSortedSetTest

- (void) setUp {
	sortedSetClasses = [NSArray arrayWithObjects:
						[CHAnderssonTree class],
						[CHAVLTree class],
						[CHRedBlackTree class],
						[CHTreap class],
						[CHUnbalancedTree class],
						nil];
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil];
}

- (void) tearDown {
	
}

#pragma mark -

- (void) testAllObjects {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertEqualObjects([sortedSet allObjects], [NSArray array],
							 @"Incorrect object array.");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertEqualObjects([sortedSet allObjects], objects,
							 @"Incorrect object array.");
		[sortedSet release];
	}
}

- (void) testAnyObject {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertNil([sortedSet anyObject], @"Should return a nil object");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertNotNil([sortedSet anyObject], @"Should return a non-nil object");
		[sortedSet release];
	}
}

- (void) testFirstObject {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertNoThrow([sortedSet firstObject], @"Should not raise exception");
		STAssertNil([sortedSet firstObject], @"Wrong first object.");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertNoThrow([sortedSet firstObject], @"Should not raise exception");
		STAssertEqualObjects([sortedSet firstObject], @"A", @"Wrong first object.");
		[sortedSet release];
	}
}

- (void) testInit {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] initWithArray:nil];
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		[sortedSet release];
	}
}

- (void) testInitWithArray {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertEquals([sortedSet count], [objects count], @"Incorrect count.");
		[sortedSet release];
	}
}

- (void) testIsEqualToSortedSet {
	// TODO: Write this test
}

- (void) testLastObject {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertNoThrow([sortedSet lastObject], @"Should not raise exception");
		STAssertNil([sortedSet lastObject], @"Wrong last object.");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertNoThrow([sortedSet lastObject], @"Should not raise exception");
		STAssertEqualObjects([sortedSet lastObject], @"E", @"Wrong last object.");
		[sortedSet release];
	}
}

- (void) testMember {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertNoThrow([sortedSet member:nil], @"Should not raise an exception.");
		STAssertNoThrow([sortedSet member:@"A"], @"Should not raise an exception.");
		STAssertNil([sortedSet member:nil], @"Should return nil for empty set.");	
		STAssertNil([sortedSet member:@"A"], @"Should return nil for empty set.");	
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			STAssertEqualObjects([sortedSet member:anObject], anObject, @"Objects should match.");
		STAssertNoThrow([sortedSet member:@"Z"], @"Should not raise an exception.");
		STAssertNil([sortedSet member:@"Z"], @"Should return nil for value not in tree");
		[sortedSet release];
	}
}

- (void) testObjectEnumerator {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] init];
		
		// Enumerator shouldn't retain collection if there are no objects
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)1,
			               @"Wrong retain count");
		e = [sortedSet objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)1,
			               @"Should not retain collection");
		
		// Enumerator should retain collection when it has 1+ objects, release when 0
		[sortedSet addObjectsFromArray:objects];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)1,
			               @"Wrong retain count");
		e = [sortedSet objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)2,
			               @"Enumerator should retain collection");
		// Grab one object from the enumerator
		[e nextObject];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)2,
			               @"Collection should still be retained.");
		// Empty the enumerator of all objects
		[e allObjects];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)1,
			               @"Enumerator should release collection");
		
		// Test that enumerator releases on -dealloc
		NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)1,
			               @"Wrong retain count");
		e = [sortedSet objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)2,
			               @"Enumerator should retain collection");
		[pool drain]; // Force deallocation of enumerator
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([sortedSet retainCount], (NSUInteger)1,
			               @"Enumerator should release collection");
		
		// Test mutation in the middle of enumeration
		e = [sortedSet objectEnumerator];
		[sortedSet addObject:@"Z"];
		STAssertThrows([e nextObject], @"Should raise mutation exception.");
		STAssertThrows([e allObjects], @"Should raise mutation exception.");
		
		// Test deallocation in the middle of enumeration
		pool = [[NSAutoreleasePool alloc] init];
		e = [sortedSet objectEnumerator];
		[e nextObject];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
		
		pool = [[NSAutoreleasePool alloc] init];
		e = [sortedSet objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
		[sortedSet release];
	}
}

- (void) testRemoveAllObjects {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		STAssertNoThrow([sortedSet removeAllObjects], @"Should not raise exception");
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertEquals([sortedSet count], [objects count], @"Incorrect count.");
		STAssertNoThrow([sortedSet removeAllObjects], @"Should not raise exception");
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		[sortedSet release];
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		STAssertNoThrow([sortedSet removeFirstObject], @"Should not raise exception");
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertEqualObjects([sortedSet firstObject], @"A", @"Wrong first object.");
		STAssertEquals([sortedSet count], [objects count], @"Incorrect count.");
		STAssertNoThrow([sortedSet removeFirstObject], @"Should not raise exception");
		STAssertEqualObjects([sortedSet firstObject], @"B", @"Wrong first object.");
		STAssertEquals([sortedSet count], [objects count]-1, @"Incorrect count.");
		[sortedSet release];
	}
}

- (void) testRemoveLastObject {
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		STAssertNoThrow([sortedSet removeLastObject], @"Should not raise exception");
		STAssertEquals([sortedSet count], (NSUInteger)0, @"Incorrect count.");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertEqualObjects([sortedSet lastObject], @"E", @"Wrong last object.");
		STAssertEquals([sortedSet count], [objects count], @"Incorrect count.");
		STAssertNoThrow([sortedSet removeLastObject], @"Should not raise exception");
		STAssertEqualObjects([sortedSet lastObject], @"D", @"Wrong last object.");
		STAssertEquals([sortedSet count], [objects count]-1, @"Incorrect count.");
		[sortedSet release];
	}
}

- (void) testReverseObjectEnumerator {
	NSEnumerator *reverse;
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Try with empty sorted set
		sortedSet = [[aClass alloc] init];
		reverse = [sortedSet reverseObjectEnumerator];
		STAssertNotNil(reverse, @"Enumerator should not be nil.");
		STAssertNil([reverse nextObject], @"Next object should be nil.");
		[sortedSet release];
		
		// Try with populated sorted set
		sortedSet = [[aClass alloc] initWithArray:objects];
		reverse = [sortedSet reverseObjectEnumerator];
		e = [[sortedSet allObjects] reverseObjectEnumerator];
		while (anObject =[e nextObject]) {
			STAssertEqualObjects([reverse nextObject], anObject, @"Bad ordering.");
		}
		[sortedSet release];
	}
}

- (void) testSet {
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	NSSet *set = [NSSet setWithArray:objects];
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertEqualObjects([(id<CHSortedSet>)sortedSet set], set, @"Unequal sets");
		[sortedSet release];
	}
}

- (void) testSubsetFromObjectToObject {
	objects = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",@"G",nil];
	NSArray *acde = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",nil];
	NSArray *aceg = [NSArray arrayWithObjects:@"A",@"C",@"E",@"G",nil];
	NSArray *ag   = [NSArray arrayWithObjects:@"A",@"G",nil];
	NSArray *cde  = [NSArray arrayWithObjects:@"C",@"D",@"E",nil];
	NSArray *cdeg = [NSArray arrayWithObjects:@"C",@"D",@"E",@"G",nil];
	NSArray *subset;
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] initWithArray:objects];
		
		// Test including all objects (2 nil params, or match first and last)
		subset = [[sortedSet subsetFromObject:nil toObject:nil options:0] allObjects];
		STAssertTrue([subset isEqual:objects], badOrder(@"Subset", subset, objects));
		
		subset = [[sortedSet subsetFromObject:@"A" toObject:@"G" options:0] allObjects];
		STAssertTrue([subset isEqual:objects], badOrder(@"Subset", subset, objects));
		
		// Test excluding elements at the end
		subset = [[sortedSet subsetFromObject:nil toObject:@"F" options:0] allObjects];
		STAssertTrue([subset isEqual:acde], badOrder(@"Subset", subset, acde));
		subset = [[sortedSet subsetFromObject:nil toObject:@"E" options:0] allObjects];
		STAssertTrue([subset isEqual:acde], badOrder(@"Subset", subset, acde));
		
		subset = [[sortedSet subsetFromObject:@"A" toObject:@"F" options:0] allObjects];
		STAssertTrue([subset isEqual:acde], badOrder(@"Subset", subset, acde));
		subset = [[sortedSet subsetFromObject:@"A" toObject:@"E" options:0] allObjects];
		STAssertTrue([subset isEqual:acde], badOrder(@"Subset", subset, acde));
		
		// Test excluding elements at the start
		subset = [[sortedSet subsetFromObject:@"B" toObject:nil options:0] allObjects];
		STAssertTrue([subset isEqual:cdeg], badOrder(@"Subset", subset, cdeg));
		subset = [[sortedSet subsetFromObject:@"C" toObject:nil options:0] allObjects];
		STAssertTrue([subset isEqual:cdeg], badOrder(@"Subset", subset, cdeg));
		
		subset = [[sortedSet subsetFromObject:@"B" toObject:@"G" options:0] allObjects];
		STAssertTrue([subset isEqual:cdeg], badOrder(@"Subset", subset, cdeg));
		subset = [[sortedSet subsetFromObject:@"C" toObject:@"G" options:0] allObjects];
		STAssertTrue([subset isEqual:cdeg], badOrder(@"Subset", subset, cdeg));
		
		// Test excluding elements in the middle (parameters in reverse order)
		subset = [[sortedSet subsetFromObject:@"E" toObject:@"C" options:0] allObjects];
		STAssertTrue([subset isEqual:aceg], badOrder(@"Subset", subset, aceg));
		
		subset = [[sortedSet subsetFromObject:@"F" toObject:@"B" options:0] allObjects];
		STAssertTrue([subset isEqual:ag], badOrder(@"Subset", subset, ag));
		
		// Test using options to exclude zero, one, or both endpoints.
		CHSubsetConstructionOptions o;
		
		o = CHSubsetExcludeLowEndpoint;
		subset = [[sortedSet subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
		STAssertTrue([subset isEqual:cdeg], badOrder(@"Subset", subset, cdeg));
		
		o = CHSubsetExcludeHighEndpoint;
		subset = [[sortedSet subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
		STAssertTrue([subset isEqual:acde], badOrder(@"Subset", subset, acde));
		
		o = CHSubsetExcludeLowEndpoint | CHSubsetExcludeHighEndpoint;
		subset = [[sortedSet subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
		STAssertTrue([subset isEqual:cde], badOrder(@"Subset", subset, cde));
		
		subset = [[sortedSet subsetFromObject:nil toObject:nil options:o] allObjects];
		STAssertTrue([subset isEqual:objects], badOrder(@"Subset", subset, objects));
		[sortedSet release];
	}
}

#pragma mark -

- (void) testNSCoding {
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	NSArray *before, *after;
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] initWithArray:objects];
		STAssertEquals([sortedSet count], [objects count], @"Incorrect count.");
		if ([sortedSet conformsToProtocol:@protocol(CHSortedSet)])
			before = [sortedSet allObjectsWithTraversalOrder:CHTraverseLevelOrder];
		else
			before = [sortedSet allObjects];
		
		NSString *filePath = @"/tmp/CHDataStructures-sortedSet.plist";
		[NSKeyedArchiver archiveRootObject:sortedSet toFile:filePath];
		[sortedSet release];
		
		sortedSet = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
		STAssertEquals([sortedSet count], [objects count], @"Incorrect count.");
		if ([sortedSet conformsToProtocol:@protocol(CHSortedSet)])
			after = [sortedSet allObjectsWithTraversalOrder:CHTraverseLevelOrder];
		else
			after = [sortedSet allObjects];
		if (aClass != [CHTreap class])
			STAssertEqualObjects(before, after,
								 badOrder(@"Bad order after decode", after, before));
		[sortedSet release];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
#else
		[[NSFileManager defaultManager] removeFileAtPath:filePath handler:nil];
#endif
	}	
}

- (void) testNSCopying {
	id copy;
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] init];
		copy = [sortedSet copyWithZone:nil];
		STAssertNotNil(copy, @"-copy should not return nil for valid sortedSet.");
		STAssertEquals([copy count], (NSUInteger)0, @"Incorrect count.");
		STAssertEquals([sortedSet hash], [copy hash], @"Hashes should match.");
		[copy release];
		
		[sortedSet addObjectsFromArray:objects];
		copy = [sortedSet copyWithZone:nil];
		STAssertNotNil(copy, @"-copy should not return nil for valid sortedSet.");
		STAssertEquals([copy count], [objects count], @"Incorrect count.");
		STAssertEquals([sortedSet hash], [copy hash], @"Hashes should match.");
		if ([sortedSet conformsToProtocol:@protocol(CHSortedSet)] && aClass != [CHTreap class]) {
			STAssertEqualObjects([sortedSet allObjectsWithTraversalOrder:CHTraverseLevelOrder],
			                     [copy allObjectsWithTraversalOrder:CHTraverseLevelOrder],
			                     @"Unequal sortedSets.");
		} else {
			STAssertEqualObjects([sortedSet allObjects], [copy allObjects],
			                     @"Unequal sortedSets.");
		}
		[sortedSet release];
		[copy release];
	}
}

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (void) testNSFastEnumeration {
	int limit = 32; // NSFastEnumeration asks for 16 objects at a time
	NSEnumerator *classes = [sortedSetClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		sortedSet = [[aClass alloc] init];
		int number, expected, count = 0;
		for (number = 1; number <= limit; number++)
			[sortedSet addObject:[NSNumber numberWithInt:number]];
		expected = 1;
		for (NSNumber *object in sortedSet) {
			STAssertEquals([object intValue], expected++,
						   @"Objects should be enumerated in ascending order.");
			count++;
		}
		STAssertEquals(count, limit, @"Count of enumerated items is incorrect.");
		
		BOOL raisedException = NO;
		@try {
			for (id object in sortedSet)
				[sortedSet addObject:[NSNumber numberWithInt:-1]];
		}
		@catch (NSException *exception) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise mutation exception.");
		
		[sortedSet release];
	}
}
#endif


@end
