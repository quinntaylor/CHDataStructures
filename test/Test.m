//  Test.m
//  DataStructuresFramework

#import <Foundation/Foundation.h>

#import "UnbalancedTree.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Test object insertion, enumeration, and removal in unbalanced binary trees.
	
	id<Tree> tree = [[UnbalancedTree alloc] init];
	[tree addObject:@"F"];
	[tree addObject:@"B"];
	[tree addObject:@"A"];
	[tree addObject:@"D"];
	[tree addObject:@"C"];
	[tree addObject:@"E"];
	[tree addObject:@"G"];
	[tree addObject:@"I"];
	[tree addObject:@"H"];
	
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
	
	QuietLog(@"In-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder]) {
		QuietLog(@"%@", obj);
	}
	QuietLog(@"Reverse-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder]) {
		QuietLog(@"%@", obj);
	}
	QuietLog(@"Pre-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder]) {
		QuietLog(@"%@", obj);
	}
	QuietLog(@"Post-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder]) {
		QuietLog(@"%@", obj);
	}
	QuietLog(@"Level-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]) {
		QuietLog(@"%@", obj);
	}
	
	[tree removeAllObjects];
	
	[pool drain];
	return 0;
}
