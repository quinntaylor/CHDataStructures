//
//  Test.m
//  DataStructures

#import <Foundation/Foundation.h>

#import "UnbalancedTree.h"
#import "RedBlackTree.h"

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
	
	NSLog(@"*** In-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder]) {
		NSLog(@"%@", obj);
	}
	NSLog(@"*** Reverse-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder]) {
		NSLog(@"%@", obj);
	}
	NSLog(@"*** Pre-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder]) {
		NSLog(@"%@", obj);
	}
	NSLog(@"*** Post-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder]) {
		NSLog(@"%@", obj);
	}
	NSLog(@"*** Level-order traversal");
	for (id obj in [tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]) {
		NSLog(@"%@", obj);
	}
	
	[tree removeAllObjects];
	
	[pool drain];
	return 0;
}
