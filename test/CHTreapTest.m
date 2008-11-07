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
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
}

- (void) tearDown {
	[tree release];
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	NSUInteger count = 0;
	
	// Can't test a specific order because of randomly-assigned priorities
	for (id anObject in objects) {
		[tree addObject:anObject];
		STAssertEquals([tree count], ++count, @"-count is incorrect.");
		STAssertNoThrow([tree verify], @"Not a valid treap: %@",
						[tree debugDescription]);
	}
}

- (void) testAllObjectsWithTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Ascending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseDescending];
	correct = [NSArray arrayWithObjects:@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",
			   @"F",@"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Descending order", order, correct));
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
