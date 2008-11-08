/*
 CHTreapTest.m
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
#import "CHTreap.h"

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
			  traversal, correct, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

#pragma mark -

@interface CHTreap (Test)

- (void) verify;
- (void) verifySubtreeAtNode:(CHTreeNode*)node;

@end

@implementation CHTreap (Test)

- (void) verify {
	[self verifySubtreeAtNode:header->right]; // Raises an exception on error
}

// Recursive method for verifying that BST and heap properties are not violated.
- (void) verifySubtreeAtNode:(CHTreeNode*)node {
	if (node == sentinel)
		return;
	
	if (node->left != sentinel) {
		// Verify BST property
		if ([node->left->object compare:node->object] == NSOrderedDescending)
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation left of %@", node->object];
		// Verify heap property
		if (node->left->priority > node->priority)
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation left of %@", node->object];
		// Recursively verity left subtree
		[self verifySubtreeAtNode:node->left];
	}
	
	if (node->right != sentinel) {
		// Verify BST property
		if ([node->right->object compare:node->object] == NSOrderedAscending)
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation right of %@", node->object];
		// Verify heap property
		if (node->right->priority > node->priority)
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation right of %@", node->object];
		// Recursively verity right subtree
		[self verifySubtreeAtNode:node->right];
	}
}

@end

#pragma mark -

@interface CHTreapTest : SenTestCase {
	CHTreap *tree;
	NSArray *objects, *order, *correct;
}

@end

@implementation CHTreapTest

- (void) setUp {
	tree = [[CHTreap alloc] init];
	objects = [NSArray arrayWithObjects:@"G",@"D",@"K",@"B",@"I",@"F",@"L",@"C",
			   @"H",@"E",@"M",@"A",@"J",nil];
}

- (void) tearDown {
	[tree release];
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	NSUInteger count = 0;
	for (id anObject in objects) {
		[tree addObject:anObject];
		STAssertEquals([tree count], ++count, @"-count is incorrect.");
		// Can't test a specific order because of randomly-assigned priorities
		STAssertNoThrow([tree verify], @"Not a valid treap: %@",
						[tree debugDescription]);
		CHLocationLog([tree debugDescription]);
	}
	
	// Test adding an existing object to the treap
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
}

- (void) testAddObjectWithPriority {
	STAssertThrows([tree addObject:@"foo" withPriority:NSIntegerMax],
				   @"Should raise an exception.");
	
	NSUInteger priority = 0;
	NSEnumerator *e = [objects objectEnumerator];
	
	// Simulate by inserting unordered elements with increasing priority
	// This artificially balances the tree, but we can test the result.

	[tree addObject:[e nextObject] withPriority:(++priority)]; // G
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // D
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"D",@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // K
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"K",@"D",@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // B
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"B",@"K",@"D",@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // I
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"I",@"B",@"D",@"G",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // F
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"D",@"I",@"G",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // L
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"L",@"F",@"B",@"D",@"I",@"G",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // C
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"L",@"F",@"D",@"I",@"G",@"K",
			   nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // H
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"H",@"C",@"B",@"F",@"D",@"G",@"L",@"I",
			   @"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // E
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",
			   @"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // M
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",
			   @"L",@"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // A
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"A",@"M",@"E",@"C",@"B",@"D",@"H",@"F",
			   @"G",@"L",@"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // J
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"J",@"A",@"E",@"C",@"B",@"D",@"H",@"F",
			   @"G",@"I",@"M",@"L",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
}

- (void) testAllObjectsWithTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Ascending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseDescending];
	correct = [NSArray arrayWithObjects:@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",
			   @"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Descending order", order, correct));
	
	// Test adding an existing object to the treap
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree addObject:@"A" withPriority:NSIntegerMin];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");	
}

- (void) testPriorityForObject {
	STAssertEquals([tree priorityForObject:nil], NSNotFound,
	               @"Priority should indicate that the object is absent.");
	STAssertEquals([tree priorityForObject:@"Z"], NSNotFound,
	               @"Priority should indicate that the object is absent.");

	NSInteger priority = 0;
	for (id object in objects)
		[tree addObject:object withPriority:(++priority)];
	
	STAssertEquals([tree priorityForObject:nil], NSNotFound,
	               @"Priority should indicate that the object is absent.");
	STAssertEquals([tree priorityForObject:@"Z"], NSNotFound,
	               @"Priority should indicate that the object is absent.");
	
	// TODO: Verify actual priorities.
}

- (void) testRemoveObject {
	for (id object in objects)
		[tree addObject:object];
	
	// Test removing nil
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");
	
	// Test removing a node which doesn't occur in the tree
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	
	NSUInteger count = [objects count];
	for (id anObject in objects) {
		[tree removeObject:anObject];
		STAssertEquals([tree count], --count, @"-count is incorrect.");
		STAssertNoThrow([tree verify], @"Not a valid treap: %@",
						[tree debugDescription]);
	}
	
}

@end
