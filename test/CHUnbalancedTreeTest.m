/*
 CHUnbalancedTreeTest.m
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
#import "CHUnbalancedTree.h"

static BOOL gcDisabled;

static NSString* badOrder(NSArray *order, NSArray *correctOrder) {
	return [[[NSString stringWithFormat:@"Should be %@, not %@", correctOrder, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

@interface CHUnbalancedTreeTest : SenTestCase {
	CHUnbalancedTree *tree;
	NSArray *objects;
	NSArray *order, *correct;
}
@end

@implementation CHUnbalancedTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
    tree = [[CHUnbalancedTree alloc] init];
	objects = [NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",@"H",nil];
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
}

- (void) tearDown {
    [tree release];
}

- (void) testAddObject {
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
}

- (void) testObjectEnumerator {
	NSEnumerator *e;
	// Enumerator shouldn't retain collection if there are no objects
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
	e = [tree objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Should not retain collection");
	
	// Enumerator should retain collection when it has 1+ objects, release when 0
	for (id object in objects)
		[tree addObject:object];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
	e = [tree objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([tree retainCount], 2u, @"Enumerator should retain collection");
	// Grab one object from the enumerator
	[e nextObject];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 2u, @"Collection should still be retained.");
	// Empty the enumerator of all objects
	[e allObjects];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Enumerator should release collection");
	
	// Test that enumerator releases on -dealloc
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
	e = [tree objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([tree retainCount], 2u, @"Enumerator should retain collection");
	[pool drain]; // Force deallocation of enumerator
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Enumerator should release collection");
}

- (void) testTraversalInOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalReverseOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPreOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",@"H",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPostOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"A",@"C",@"E",@"D",@"B",@"H",@"I",@"G",@"F",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalLevelOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",@"H",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testRemoveObject {
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
	[tree removeObject:@"A"];
	STAssertEquals([tree count], 8u, @"-count is incorrect.");	
}

- (void) testRemoveAllObjects {
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
	[tree removeAllObjects];
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
}

@end
