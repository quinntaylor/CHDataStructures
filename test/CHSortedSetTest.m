/*
 CHDataStructures.framework -- CHSortedSetTest.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHSortedSet.h"

#import "CHAbstractBinarySearchTree_Internal.h"
#import "CHAnderssonTree.h"
#import "CHAVLTree.h"
#import "CHRedBlackTree.h"
#import "CHTreap.h"
#import "CHUnbalancedTree.h"

static NSArray *abcde;

#define NonConcreteClass() \
([self classUnderTest] == nil || [self classUnderTest] == [CHAbstractBinarySearchTree class])

#pragma mark -

@interface CHSortedSetTest : SenTestCase {
	id set;
	NSArray *objects;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHSortedSetTest

+ (void) initialize {
	if ([self class] != [CHSortedSetTest class])
		return;
	abcde = [[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",nil];
}

- (Class) classUnderTest {
	return nil;
}

- (id) createSet {
	return [[[[self classUnderTest] alloc] init] autorelease];
}

- (void) setUp {
	set = [self createSet];
}

- (void) testAddObject {
	if ([self classUnderTest] == nil)
		return;
	if ([self classUnderTest] == [CHAbstractBinarySearchTree class]) {
		// This method should be unsupported in the abstract parent class.
		STAssertThrows([set addObject:nil], nil);
	} else {
		STAssertEquals([set count], (NSUInteger)0, nil);
		STAssertThrows([set addObject:nil], nil);
		STAssertEquals([set count], (NSUInteger)0, nil);
		
		// Try adding distinct objects
		NSUInteger expectedCount = 0;
		e = [abcde objectEnumerator];
		while (anObject = [e nextObject]) {
			[set addObject:anObject];
			STAssertEquals([set count], ++expectedCount, nil);
		}
		STAssertEquals([set count], [abcde count], nil);
		
		// Test adding identical object--should be replaced, and count stay the same
		[set addObject:@"A"];
		STAssertEquals([set count], [abcde count], nil);
	}
}

- (void) testAllObjects {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertEqualObjects([set allObjects], [NSArray array], nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	STAssertEqualObjects([set allObjects], abcde, nil);
}

- (void) testAnyObject {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertNil([set anyObject], nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	STAssertNotNil([set anyObject], nil);
}

- (void) testContainsObject {
	if (NonConcreteClass())
		return;
	// Test contains for nil and non-member objects
	STAssertNoThrow([set containsObject:nil], nil);
	STAssertFalse([set containsObject:nil], nil);
	STAssertNoThrow([set containsObject:@"bogus"], nil);
	STAssertFalse([set containsObject:@"bogus"], nil);
	[set addObjectsFromArray:abcde];
	STAssertNoThrow([set containsObject:@"bogus"], nil);
	STAssertFalse([set containsObject:@"bogus"], nil);
	// Test contains for each object in the set 
	e = [abcde objectEnumerator];
	while (anObject = [e nextObject])
		STAssertTrue([set containsObject:anObject], nil);
}

- (void) testFirstObject {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertNoThrow([set firstObject], nil);
	STAssertNil([set firstObject], nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	STAssertNoThrow([set firstObject], nil);
	STAssertEqualObjects([set firstObject], @"A", nil);
}

- (void) testInit {
	if (NonConcreteClass())
		return;
	STAssertNotNil(set, nil);
	STAssertEquals([set count], (NSUInteger)0, nil);
}

- (void) testInitWithArray {
	if (NonConcreteClass())
		return;
	set = [[[[self classUnderTest] alloc] initWithArray:abcde] autorelease];
	STAssertEquals([set count], [abcde count], nil);
}

- (void) testIsEqual {
	if (NonConcreteClass())
		return;
	// Calls to -isEqual: exercise -isEqualToSortedSet: by extension
	STAssertTrue([set isEqual:set], nil);
	[set addObjectsFromArray:abcde];
	STAssertTrue([set isEqual:set], nil);
	STAssertFalse([set isEqual:[self createSet]], nil);
	STAssertFalse([set isEqual:[[NSObject new] autorelease]], nil);
}

- (void) testLastObject {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertNoThrow([set lastObject], nil);
	STAssertNil([set lastObject], nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	STAssertNoThrow([set lastObject], nil);
	STAssertEqualObjects([set lastObject], @"E", nil);
}

- (void) testMember {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertNoThrow([set member:nil], nil);
	STAssertNoThrow([set member:@"bogus"], nil);
	STAssertNil([set member:nil], nil);	
	STAssertNil([set member:@"bogus"], nil);	
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	e = [abcde objectEnumerator];
	while (anObject = [e nextObject])
		STAssertEqualObjects([set member:anObject], anObject, nil);
	STAssertNoThrow([set member:@"bogus"], nil);
	STAssertNil([set member:@"bogus"], nil);
}

// Shortcut macro for determining whether garbage collection is not enabled
#define if_rr if(kCHGarbageCollectionNotEnabled)

- (void) testObjectEnumerator {
	if (NonConcreteClass())
		return;
	
	// Enumerator shouldn't retain collection if there are no objects
	if_rr STAssertEquals([set retainCount], (NSUInteger)1, nil);
	e = [set objectEnumerator];
	STAssertNotNil(e, nil);
	if_rr STAssertEquals([set retainCount], (NSUInteger)1, nil);
	STAssertNil([e nextObject], nil);

	// Enumerator should retain collection when it has 1+ objects, release on 0
	[set addObjectsFromArray:abcde];
	e = [set objectEnumerator];
	STAssertNotNil(e, nil);
	if_rr STAssertEquals([set retainCount], (NSUInteger)2, nil);
	// Grab one object from the enumerator
	[e nextObject];
	if_rr STAssertEquals([set retainCount], (NSUInteger)2, nil);
	// Empty the enumerator of all objects
	[e allObjects];
	if_rr STAssertEquals([set retainCount], (NSUInteger)1, nil);
	
	// Enumerator should release collection on -dealloc
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	if_rr STAssertEquals([set retainCount], (NSUInteger)1, nil);
	e = [set objectEnumerator];
	STAssertNotNil(e, nil);
	if_rr STAssertEquals([set retainCount], (NSUInteger)2, nil);
	[pool drain]; // Force deallocation of autoreleased enumerator
	if_rr STAssertEquals([set retainCount], (NSUInteger)1, nil);
	
	// Test mutation in the middle of enumeration
	e = [set objectEnumerator];
	STAssertNoThrow([e nextObject], nil);
	[set addObject:@"bogus"];
	STAssertThrows([e nextObject], nil);
	STAssertThrows([e allObjects], nil);
}

- (void) testRemoveObject {
	if ([set isMemberOfClass:[CHAbstractBinarySearchTree class]]) {
		// This method should be unsupported in the abstract parent class.
		STAssertThrows([set removeObject:nil], nil);
	}
}

- (void) testRemoveAllObjects {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertNoThrow([set removeAllObjects], nil);
	STAssertEquals([set count], (NSUInteger)0, nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	STAssertEquals([set count], [abcde count], nil);
	STAssertNoThrow([set removeAllObjects], nil);
	STAssertEquals([set count], (NSUInteger)0, nil);
}

- (void) testRemoveFirstObject {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertNoThrow([set removeFirstObject], nil);
	STAssertEquals([set count], (NSUInteger)0, nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	STAssertEqualObjects([set firstObject], @"A", nil);
	STAssertEquals([set count], [abcde count], nil);
	STAssertNoThrow([set removeFirstObject], nil);
	STAssertEqualObjects([set firstObject], @"B", nil);
	STAssertEquals([set count], [abcde count]-1, nil);
}

- (void) testRemoveLastObject {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	STAssertNoThrow([set removeLastObject], nil);
	STAssertEquals([set count], (NSUInteger)0, nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	STAssertEqualObjects([set lastObject], @"E", nil);
	STAssertEquals([set count], [abcde count], nil);
	STAssertNoThrow([set removeLastObject], nil);
	STAssertEqualObjects([set lastObject], @"D", nil);
	STAssertEquals([set count], [abcde count]-1, nil);
}

- (void) testReverseObjectEnumerator {
	if (NonConcreteClass())
		return;
	// Try with empty sorted set
	NSEnumerator *reverse = [set reverseObjectEnumerator];
	STAssertNotNil(reverse, nil);
	STAssertNil([reverse nextObject], nil);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	reverse = [set reverseObjectEnumerator];
	e = [[set allObjects] reverseObjectEnumerator];
	while (anObject = [e nextObject]) {
		STAssertEqualObjects([reverse nextObject], anObject, nil);
	}
}

- (void) testSet {
	if (NonConcreteClass())
		return;
	NSArray *order = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	[set addObjectsFromArray:order];
	STAssertEqualObjects([set set], [NSSet setWithArray:order], nil);
}

- (void) testSubsetFromObjectToObject {
	if (NonConcreteClass())
		return;
	NSArray *acdeg = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",@"G",nil];
	NSArray *acde  = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",nil];
	NSArray *aceg  = [NSArray arrayWithObjects:@"A",@"C",@"E",@"G",nil];
	NSArray *ag    = [NSArray arrayWithObjects:@"A",@"G",nil];
	NSArray *cde   = [NSArray arrayWithObjects:@"C",@"D",@"E",nil];
	NSArray *cdeg  = [NSArray arrayWithObjects:@"C",@"D",@"E",@"G",nil];
	NSArray *subset;
	
	set = [[[self classUnderTest] alloc] initWithArray:acdeg];
	
	// Test including all objects (2 nil params, or match first and last)
	subset = [[set subsetFromObject:nil toObject:nil options:0] allObjects];
	STAssertEqualObjects(subset, acdeg, nil);
	
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:0] allObjects];
	STAssertEqualObjects(subset, acdeg, nil);
	
	// Test excluding elements at the end
	subset = [[set subsetFromObject:nil toObject:@"F" options:0] allObjects];
	STAssertEqualObjects(subset, acde, nil);
	subset = [[set subsetFromObject:nil toObject:@"E" options:0] allObjects];
	STAssertEqualObjects(subset, acde, nil);
	subset = [[set subsetFromObject:@"A" toObject:@"F" options:0] allObjects];
	STAssertEqualObjects(subset, acde, nil);
	subset = [[set subsetFromObject:@"A" toObject:@"E" options:0] allObjects];
	STAssertEqualObjects(subset, acde, nil);
	
	// Test excluding elements at the start
	subset = [[set subsetFromObject:@"B" toObject:nil options:0] allObjects];
	STAssertEqualObjects(subset, cdeg, nil);
	subset = [[set subsetFromObject:@"C" toObject:nil options:0] allObjects];
	STAssertEqualObjects(subset, cdeg, nil);
	
	subset = [[set subsetFromObject:@"B" toObject:@"G" options:0] allObjects];
	STAssertEqualObjects(subset, cdeg, nil);
	subset = [[set subsetFromObject:@"C" toObject:@"G" options:0] allObjects];
	STAssertEqualObjects(subset, cdeg, nil);
	
	// Test excluding elements in the middle (parameters in reverse order)
	subset = [[set subsetFromObject:@"E" toObject:@"C" options:0] allObjects];
	STAssertEqualObjects(subset, aceg, nil);
	
	subset = [[set subsetFromObject:@"F" toObject:@"B" options:0] allObjects];
	STAssertEqualObjects(subset, ag, nil);
	
	// Test using options to exclude zero, one, or both endpoints.
	CHSubsetConstructionOptions o;
	
	o = CHSubsetExcludeLowEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	STAssertEqualObjects(subset, cdeg, nil);
	
	o = CHSubsetExcludeHighEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	STAssertEqualObjects(subset, acde, nil);
	
	o = CHSubsetExcludeLowEndpoint | CHSubsetExcludeHighEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	STAssertEqualObjects(subset, cde, nil);
	
	subset = [[set subsetFromObject:nil toObject:nil options:o] allObjects];
	STAssertEqualObjects(subset, acdeg, nil);
}

- (void) testNSCoding {
	if (NonConcreteClass())
		return;
	NSArray *order = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",@"J",@"L",@"N",@"F",@"A",@"H",nil];
	NSArray *before, *after;
	[set addObjectsFromArray:order];
	STAssertEquals([set count], [order count], nil);
	if ([set conformsToProtocol:@protocol(CHSearchTree)])
		before = [set allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	else
		before = [set allObjects];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:set];
	set = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	STAssertEquals([set count], [order count], nil);
	if ([set conformsToProtocol:@protocol(CHSearchTree)])
		after = [set allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	else
		after = [set allObjects];
	if ([self classUnderTest] != [CHTreap class])
		STAssertEqualObjects(before, after, nil);
}

- (void) testNSCopying {
	if (NonConcreteClass())
		return;
	id copy;
	copy = [[set copy] autorelease];
	STAssertNotNil(copy, nil);
	STAssertEquals([copy count], (NSUInteger)0, nil);
	STAssertEquals([set hash], [copy hash], nil);
	
	[set addObjectsFromArray:abcde];
	copy = [[set copy] autorelease];
	STAssertNotNil(copy, nil);
	STAssertEquals([copy count], [abcde count], nil);
	STAssertEquals([set hash], [copy hash], nil);
	if ([set conformsToProtocol:@protocol(CHSearchTree)] && [self classUnderTest] != [CHTreap class]) {
		STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
							 [copy allObjectsWithTraversalOrder:CHTraverseLevelOrder], nil);
	} else {
		STAssertEqualObjects([set allObjects], [copy allObjects], nil);
	}
}

- (void) testNSFastEnumeration {
	if (NonConcreteClass())
		return;
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
	for (NSUInteger number = 1; number <= limit; number++)
		[set addObject:[NSNumber numberWithUnsignedInteger:number]];
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in set) {
		STAssertEquals([object unsignedIntegerValue], expected++, nil);
		count++;
	}
	STAssertEquals(count, limit, nil);
	
	BOOL raisedException = NO;
	@try {
		for (id object in set)
			[set addObject:[NSNumber numberWithInteger:-1]];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, nil);
}

@end

#pragma mark -

@interface CHAbstractBinarySearchTree (Test)

- (id) headerObject;

@end

@implementation CHAbstractBinarySearchTree (Test)

- (id) headerObject {
	return header->object;
}

@end

@interface CHAbstractBinarySearchTreeTest : CHSortedSetTest
@end

@implementation CHAbstractBinarySearchTreeTest

- (Class) classUnderTest {
	return [CHAbstractBinarySearchTree class];
}

- (void) setUp {
	set = [self createSet];
}

- (void) testAllObjectsWithTraversalOrder {
	if ([self class] == [CHAbstractBinarySearchTreeTest class])
		return;
	// Also tests -objectEnumeratorWithTraversalOrder: implicitly
	[set addObjectsFromArray:abcde];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil]), nil);
	// NOTE: Individual subclasses should test pre/post/level-order traversals
}

- (void) testDescription {
	STAssertEqualObjects([set description], [[set allObjects] description], nil);
}

- (void) testHeaderObject {
	id headerObject = [set headerObject];
	STAssertNotNil(headerObject, nil);
	if (kCHGarbageCollectionNotEnabled) {
		STAssertThrows([headerObject retain],      nil);
		STAssertThrows([headerObject release],     nil);
		STAssertThrows([headerObject autorelease], nil);
	}
}

- (void) testIsEqualToSearchTree {
	if ([self class] != [CHAbstractBinarySearchTreeTest class])
		return;
	NSMutableArray *equalTrees = [NSMutableArray array];
	NSArray *treeClasses = [NSArray arrayWithObjects:
							[CHAnderssonTree class],
							[CHAVLTree class],
							[CHRedBlackTree class],
							[CHTreap class],
							[CHUnbalancedTree class],
							nil];
	e = [treeClasses objectEnumerator];
	Class theClass;
	while (theClass = [e nextObject]) {
		[equalTrees addObject:[[theClass alloc] initWithArray:abcde]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalTrees addObject:[equalTrees objectAtIndex:0]];
	
	NSArray *sortedSetClasses = [[NSArray alloc] initWithObjects:
								 [CHAnderssonTree class],
								 [CHAVLTree class],
								 [CHRedBlackTree class],
								 [CHTreap class],
								 [CHUnbalancedTree class],
								 nil];
	id<CHSearchTree> tree1, tree2;
	for (NSUInteger i = 0; i < [sortedSetClasses count]; i++) {
		tree1 = [equalTrees objectAtIndex:i];
		tree2 = [equalTrees objectAtIndex:i+1];
		STAssertEquals([tree1 hash], [tree2 hash], nil);
		STAssertEqualObjects(tree1, tree2, nil);
	}
	STAssertFalse([tree1 isEqualToSearchTree:[NSArray array]], nil);
	STAssertThrowsSpecificNamed([tree1 isEqualToSearchTree:[NSString string]],
	                            NSException, NSInvalidArgumentException, nil);
}

@end

#pragma mark -

@interface CHAnderssonTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHAnderssonTreeTest

- (Class) classUnderTest {
	return [CHAnderssonTree class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",@"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
	// When inserted in this order, creates the tree from: Weiss pg. 645
}

- (void) testAddObject {
	STAssertEquals([set count], (NSUInteger)0, nil);
	STAssertThrows([set addObject:nil], nil);
	STAssertEquals([set count], (NSUInteger)0, nil);
	
	[set addObjectsFromArray:objects];
	STAssertEquals([set count], [objects count], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"A",@"B",@"D",@"L",@"H",@"F",@"G",@"J",@"I",@"K",@"N",@"M",@"O",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"B",@"A",@"D",@"C",@"G",@"F",@"I",@"K",@"J",@"H",@"M",@"O",@"N",@"L",@"E",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",@"J",@"M",@"O",@"G",@"I",@"K",nil]), nil);
	
	// Test adding identical object--should be replaced, and count stay the same
	[set addObject:@"A"];
	STAssertEquals([set count], [objects count], nil);
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->level = 1;
	STAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[1]\t\"A B C\"", nil);
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->level = 1;
	STAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n1\"];\n", nil);
	free(node);
}

- (void) testRemoveObject {
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	[set addObjectsFromArray:objects];
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	STAssertEquals([set count], [objects count], nil);
	
	[set removeObject:@"J"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",@"I",@"M",@"O",@"G",@"K",nil]), nil);
	[set removeObject:@"N"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"H",@"A",@"D",@"F",@"L",@"B",@"G",@"I",@"M",@"K",@"O",nil]), nil);
	[set removeObject:@"H"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"I",@"A",@"D",@"F",@"L",@"B",@"G",@"K",@"M",@"O",nil]), nil);
	[set removeObject:@"D"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"B",@"I",@"A",@"C",@"F",@"L",@"G",@"K",@"M",@"O",nil]), nil);
	[set removeObject:@"C"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"E",@"L",@"A",@"F",@"K",@"M",@"B",@"G",@"O",nil]), nil);
	[set removeObject:@"K"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"E",@"M",@"A",@"F",@"L",@"O",@"B",@"G",nil]), nil);
	[set removeObject:@"M"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"A",@"I",@"B",@"F",@"L",@"G",@"O",nil]), nil);
	[set removeObject:@"B"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"A",@"I",@"F",@"L",@"G",@"O",nil]), nil);
	[set removeObject:@"A"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"I",@"G",@"L",@"O",nil]), nil);
	[set removeObject:@"G"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"L",@"I",@"O",nil]), nil);
	[set removeObject:@"E"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"F",@"L",@"O",nil]), nil);
	[set removeObject:@"F"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"L",@"I",@"O",nil]), nil);
	[set removeObject:@"L"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"O",nil]), nil);
	[set removeObject:@"I"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"O",nil]), nil);
}

@end

#pragma mark -

@interface CHAVLTree (Test)

- (void) verify;

@end

@implementation CHAVLTree (Test)

- (NSInteger) heightForSubtree:(CHBinaryTreeNode*)node
                    isBalanced:(BOOL*)isBalanced
                   errorString:(NSMutableString*)balanceErrors {
	if (node == sentinel)
		return 0;
	NSInteger leftHeight  = [self heightForSubtree:node->left isBalanced:isBalanced errorString:balanceErrors];
	NSInteger rightHeight = [self heightForSubtree:node->right isBalanced:isBalanced errorString:balanceErrors];
	if (node->balance != (rightHeight-leftHeight)) {
		[balanceErrors appendFormat:@". | At \"%@\" should be %ld, was %d",
		 node->object, (rightHeight-leftHeight), node->balance];
		*isBalanced = NO;
	}
	return MAX(leftHeight, rightHeight) + 1;
}

- (void) verify {
	BOOL isBalanced = YES;
	NSMutableString *balanceErrors = [NSMutableString string];
	[self heightForSubtree:header->right
				isBalanced:&isBalanced
			   errorString:balanceErrors];
	
	if (!isBalanced) {
		[NSException raise:NSInternalInconsistencyException
		            format:@"Violation of AVL balance factors%@", balanceErrors];
	}
}

@end

@interface CHAVLTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHAVLTreeTest

- (Class) classUnderTest {
	return [CHAVLTree class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",@"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
}

- (void) testAddObject {
	[super testAddObject];
	
	[set removeAllObjects];
	e = [objects objectEnumerator];
	
	// Test adding objects one at a time and verify the ordering of tree nodes
	[set addObject:[e nextObject]]; // B
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"B",nil]), nil);
	[set addObject:[e nextObject]]; // N
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"B",@"N",nil]), nil);
	[set addObject:[e nextObject]]; // C
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"N",nil]), nil);
	[set addObject:[e nextObject]]; // L
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"N",@"L",nil]), nil);
	[set addObject:[e nextObject]]; // D
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"L",@"D",@"N",nil]), nil);
	[set addObject:[e nextObject]]; // J
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"D",@"C",@"B",@"L",@"J",@"N",nil]), nil);
}


- (void) testAllObjectsWithTraversalOrder {
	[set addObjectsFromArray:objects];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"B",@"A",@"C",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"N",@"M",@"O",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"A",@"C",@"B",@"F",@"E",@"I",@"H",@"G",@"D",@"K",@"M",@"O",@"N",@"L",@"J",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"L",@"B",@"G",@"K",@"N",@"A",@"C",@"E",@"H",@"M",@"O",@"F",@"I",nil]), nil);
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->balance = 0;
	STAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[ 0]\t\"A B C\"", nil);
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->balance = 0;
	STAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n0\"];\n", nil);
	free(node);
}

- (void) testRemoveObject {
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	[set addObjectsFromArray:objects];
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	STAssertEquals([set count], [objects count], nil);
	
	e = [objects objectEnumerator];
	
	[set removeObject:[e nextObject]]; // B
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"N",@"M",@"O",nil]), nil);
	[set removeObject:[e nextObject]]; // N
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"O",@"M",nil]), nil);
	[set removeObject:[e nextObject]]; // C
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"G",@"D",@"A",@"E",@"F",@"H",@"I",@"L",@"K",@"O",@"M",nil]), nil);
	[set removeObject:[e nextObject]]; // L
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"D",@"A",@"E",@"F",@"J",@"H",@"I",@"M",@"K",@"O",nil]), nil);
	[set removeObject:[e nextObject]]; // D
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"E",@"A",@"F",@"J",@"H",@"I",@"M",@"K",@"O",nil]), nil);
	[set removeObject:[e nextObject]]; // J
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"E",@"A",@"F",@"K",@"H",@"I",@"M",@"O",nil]), nil);
	[set removeObject:[e nextObject]]; // E
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"K",@"H",@"I",@"M",@"O",nil]), nil);
	[set removeObject:[e nextObject]]; // H
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"K",@"I",@"M",@"O",nil]), nil);
	[set removeObject:[e nextObject]]; // K
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"M",@"I",@"O",nil]), nil);
	[set removeObject:[e nextObject]]; // M
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"O",@"I",nil]), nil);
	[set removeObject:[e nextObject]]; // O
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"I",nil]), nil);
	[set removeObject:[e nextObject]]; // G
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"A",@"I",nil]), nil);
	[set removeObject:[e nextObject]]; // A
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"I",nil]), nil);
	[set removeObject:[e nextObject]]; // I
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",nil]), nil);
}

- (void) testRemoveObjectDoubleLeft {
	objects = [NSArray arrayWithObjects:@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",@"E",@"G",@"I",nil];
	[set addObjectsFromArray:objects];
	[set removeObject:@"A"];
	[set removeObject:@"D"];
	STAssertNoThrow([set verify], nil);
	STAssertEquals([set count], [objects count] - 2, nil);	
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"C",@"B",@"E",@"J",@"H",@"G",@"I",@"K",nil]), nil);
}

- (void) testRemoveObjectDoubleRight {
	objects = [NSArray arrayWithObjects:@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",@"E",@"G",@"I",nil];
	[set addObjectsFromArray:objects];
	[set removeObject:@"K"];
	[set removeObject:@"G"];
	STAssertNoThrow([set verify], nil);
	STAssertEquals([set count], [objects count] - 2, nil);	
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"I",@"H",@"J",nil]), nil);
}

@end

#pragma mark -

@interface CHRedBlackTree (Test)

- (void) verify;

@end

@implementation CHRedBlackTree (Test)

// Recursive method for verifying that red-black properties are not violated.
- (NSUInteger) verifySubtreeAtNode:(CHBinaryTreeNode*)node {
	if (node == sentinel)
		return 1;
	/* Test for consecutive red links */
	if (node->color == kRED) {
		if (node->left->color == kRED || node->right->color == kRED) {
			[NSException raise:NSInternalInconsistencyException
						format:@"Consecutive red below %@", node->object];
		}
	}
	NSUInteger leftBlackHeight  = [self verifySubtreeAtNode:node->left];
	NSUInteger rightBlackHeight = [self verifySubtreeAtNode:node->left];
	/* Test for invalid binary search tree */
	if ([node->left->object compare:(node->object)] == NSOrderedDescending ||
		[node->right->object compare:(node->object)] == NSOrderedAscending)
	{
		[NSException raise:NSInternalInconsistencyException
		            format:@"Binary tree violation below %@", node->object];
	}
	/* Test for black height mismatch */
	if (leftBlackHeight != rightBlackHeight && leftBlackHeight != 0) {
		[NSException raise:NSInternalInconsistencyException
		            format:@"Black height violation below %@", node->object];
	}
	/* Count black links */
	if (leftBlackHeight != 0 && rightBlackHeight != 0)
		return (node->color == kRED) ? leftBlackHeight : leftBlackHeight + 1;
	else
		return 0;
}

- (void) verify {
	sentinel->object = nil;
	[self verifySubtreeAtNode:header->right];
}

@end

@interface CHRedBlackTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHRedBlackTreeTest

- (Class) classUnderTest {
	return [CHRedBlackTree class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",@"J",@"L",@"N",@"F",@"A",@"H",nil];
	// When inserted in this order, creates the tree from: Weiss pg. 631 
}

- (void) testAddObject {
	[super testAddObject];
	[set removeAllObjects];
	
	e = [objects objectEnumerator];
	
	[set addObject:[e nextObject]]; // B
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"B",nil]), nil);
	[set addObject:[e nextObject]]; // M
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"B",@"M",nil]), nil);
	[set addObject:[e nextObject]]; // C
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"M",nil]), nil);
	[set addObject:[e nextObject]]; // K
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"M",@"K",nil]), nil);
	[set addObject:[e nextObject]]; // D
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",nil]), nil);
	[set addObject:[e nextObject]]; // I
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",@"I",nil]), nil);
	[set addObject:[e nextObject]]; // E
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"K",@"E",@"M",@"D",@"I",nil]), nil);
	[set addObject:[e nextObject]]; // G
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",nil]), nil);
	[set addObject:[e nextObject]]; // J
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",nil]), nil);
	[set addObject:[e nextObject]]; // L
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",nil]), nil);
	[set addObject:[e nextObject]]; // N
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",@"N",nil]), nil);
	[set addObject:[e nextObject]]; // F
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",@"N",@"F",nil]), nil);
	[set addObject:[e nextObject]]; // A
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",nil]), nil);
	[set addObject:[e nextObject]]; // H
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",@"H",nil]), nil);
	
	// Test adding identical object--should be replaced, and count stay the same
	STAssertEquals([set count], [objects count], nil);
	[set addObject:@"A"];
	STAssertEquals([set count], [objects count], nil);
}

- (void) testAddObjectsAscending {
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",nil];
	[set addObjectsFromArray:objects];
	STAssertEquals([set count], [objects count], nil);
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"H",@"D",@"L",@"B",@"F",@"J",@"N",@"A",@"C",@"E",@"G",@"I",@"K",@"M",@"P",@"O",@"Q",@"R",nil]), nil);
}

- (void) testAddObjectsDescending {
	objects = [NSArray arrayWithObjects:@"R",@"Q",@"P",@"O",@"N",@"M",@"L",@"K",
			   @"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	STAssertEquals([set count], [objects count], nil);
	STAssertNoThrow([set verify], nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"K",@"G",@"O",@"E",@"I",@"M",@"Q",@"C",@"F",@"H",@"J",@"L",@"N",@"P",@"R",@"B",@"D",@"A",nil]), nil);
}

- (void) testAllObjectsWithTraversalOrder {
	[set addObjectsFromArray:objects];
	
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"B",@"A",@"D",@"K",@"I",@"G",@"F",@"H",@"J",@"M",@"L",@"N",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"A",@"B",@"D",@"C",@"F",@"H",@"G",@"J",@"I",@"L",@"N",@"M",@"K",@"E",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",@"H",nil]), nil);
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->color = kRED;
	STAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[ RED ]	\"A B C\"", nil);
	node->color = kBLACK;
	STAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[BLACK]	\"A B C\"", nil);
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->color = kRED;
	STAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [color=red];\n", nil);
	node->color = kBLACK;
	STAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [color=black];\n", nil);
	free(node);
}

- (void) testRemoveObject {
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	[set addObjectsFromArray:objects];
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	STAssertEquals([set count], [objects count], nil);
	
	NSUInteger count = [objects count];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject]) {
		[set removeObject:anObject];
		STAssertEquals([set count], --count, nil);
		STAssertNoThrow([set verify], nil);
	}
}

@end

#pragma mark -

@interface CHTreap (Test)

- (void) verify; // Raises an exception on error

@end

@implementation CHTreap (Test)

// Recursive method for verifying that BST and heap properties are not violated.
- (void) verifySubtreeAtNode:(CHBinaryTreeNode*)node {
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

- (void) verify {
	[self verifySubtreeAtNode:header->right];
}

@end

@interface CHTreapTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHTreapTest

- (Class) classUnderTest {
	return [CHTreap class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"G",@"D",@"K",@"B",@"I",@"F",@"L",@"C",
			   @"H",@"E",@"M",@"A",@"J",nil];
}

- (void) testAddObject {
	[super testAddObject];
	
	// Repeat a few times to try to get a decent random spread.
	for (NSUInteger tries = 1, count; tries <= 5; tries++) {
		[set removeAllObjects];
		count = 0;
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[set addObject:anObject];
			STAssertEquals([set count], ++count, nil);
			// Can't test a specific order because of randomly-assigned priorities
			STAssertNoThrow([set verify], nil);
		}
	}
}

- (void) testAddObjectWithPriority {
	[super testAddObject];

	STAssertNoThrow([set addObject:@"foo" withPriority:0],
					nil);
	STAssertNoThrow([set addObject:@"foo" withPriority:CHTreapNotFound],
					nil);
	[set removeAllObjects];
	
	NSUInteger priority = 0;
	e = [objects objectEnumerator];
	
	// Simulate by inserting unordered elements with increasing priority
	// This artificially balances the tree, but we can test the result.
	
	[set addObject:[e nextObject] withPriority:(++priority)]; // G
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // D
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"D",@"G",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // K
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"K",@"D",@"G",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // B
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"B",@"K",@"D",@"G",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // I
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"I",@"B",@"D",@"G",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // F
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"D",@"I",@"G",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // L
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"L",@"F",@"B",@"D",@"I",@"G",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // C
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"L",@"F",@"D",@"I",@"G",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // H
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"H",@"C",@"B",@"F",@"D",@"G",@"L",@"I",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // E
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // M
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // A
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"A",@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K",nil]), nil);
	[set addObject:[e nextObject] withPriority:(++priority)]; // J
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"A",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"I",@"M",@"L",@"K",nil]), nil);
}

- (void) testAllObjectsWithTraversalOrder {
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",nil]), nil);	
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]), nil);	
	// Test adding an existing object to the treap
	STAssertEquals([set count], [objects count], nil);
	[set addObject:@"A" withPriority:NSIntegerMin];
	STAssertEquals([set count], [objects count], nil);	
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->priority = 123456789;
	STAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[  123456789]\t\"A B C\"", nil);
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->priority = 123456789;
	STAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n123456789\"];\n", nil);
	free(node);
}

- (void) testPriorityForObject {
	// Priority value should indicate that an object not in the treap is absent.
	STAssertEquals([set priorityForObject:nil],      (NSUInteger)CHTreapNotFound, nil);
	STAssertEquals([set priorityForObject:@"bogus"], (NSUInteger)CHTreapNotFound, nil);
	[set addObjectsFromArray:objects];
	STAssertEquals([set priorityForObject:nil],      (NSUInteger)CHTreapNotFound, nil);
	STAssertEquals([set priorityForObject:@"bogus"], (NSUInteger)CHTreapNotFound, nil);
	
	// Inserting from 'objects' with these priorities creates a known ordering.
	NSUInteger priorities[] = {8,11,13,12,1,4,5,9,6,3,10,7,2};
	
	NSUInteger index = 0;
	[set removeAllObjects];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject]) {
		[set addObject:anObject withPriority:(priorities[index++])];
		[set verify];
	}
	
	// Verify that the assigned priorities are what we expect
	index = 0;
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		STAssertEquals([set priorityForObject:anObject], priorities[index++], nil);
	
	// Verify the required tree structure with these objects and priorities.
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"K",@"B",@"A",@"D",@"C",@"G",@"F",@"E",@"H",@"J",@"I",@"M",@"L",nil]), nil);
}

- (void) testRemoveObject {
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	[set addObjectsFromArray:objects];
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	STAssertEquals([set count], [objects count], nil);

	// Remove all nodes one by one, and test treap validity at each step
	NSUInteger count = [objects count];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject]) {
		[set removeObject:anObject];
		STAssertEquals([set count], --count, nil);
		STAssertNoThrow([set verify], nil);
	}
	
	// Test removing a node which has been removed from the tree
	STAssertEquals([set count], (NSUInteger)0, nil);
	[set removeObject:@"bogus"];
	STAssertEquals([set count], (NSUInteger)0, nil);
}

@end

#pragma mark -

@interface CHUnbalancedTreeTest : CHAbstractBinarySearchTreeTest {
	CHAbstractBinarySearchTree *insideTree, *outsideTree, *zigzagTree;
}
@end

@implementation CHUnbalancedTreeTest

- (Class) classUnderTest {
	return [CHUnbalancedTree class];
}

- (void) setUp {
	set = [self createSet];

	objects = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",
			   @"H",nil]; // Specified using level-order travesal
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example

	outsideTree = [[CHUnbalancedTree alloc] initWithArray:
				   [NSArray arrayWithObjects:@"C",@"B",@"A",@"D",@"E",nil]];
	insideTree = [[CHUnbalancedTree alloc] initWithArray:
				  [NSArray arrayWithObjects:@"C",@"A",@"B",@"E",@"D",nil]];
	zigzagTree = [[CHUnbalancedTree alloc] initWithArray:
				  [NSArray arrayWithObjects:@"A",@"E",@"B",@"D",@"C",nil]];
}

- (void) testAddObject {
	[super testAddObject];
	
	[set removeAllObjects];
	[set addObjectsFromArray:objects];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 objects, nil);
}

- (void) testAllObjectsWithTraversalOrder {
	[super testAllObjectsWithTraversalOrder];
	[set removeAllObjects];
	[set addObjectsFromArray:objects];
	
	// Test all traversal orderings by individual tree
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",@"H",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"A",@"C",@"E",@"D",@"B",@"H",@"I",@"G",@"F",nil]), nil);
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",@"H",nil]), nil);
	
	// Test pre-order traversal of some degenerate unbalanced trees
	STAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"A",@"D",@"E",nil]), nil);
	STAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"A",@"B",@"E",@"D",nil]), nil);
	STAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"A",@"E",@"B",@"D",@"C",nil]), nil);
	
	// Test that no matter of how a tree is structured, forward and reverse work
	NSArray *ascending = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil];
	STAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraverseAscending], ascending, nil);
	STAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraverseAscending],  ascending, nil);
	STAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraverseAscending],  ascending, nil);
	NSArray *descending = [NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil];
	STAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraverseDescending], descending, nil);
	STAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraverseDescending],  descending, nil);
	STAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraverseDescending],  descending, nil);
}

- (void) testDebugDescription {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	STAssertEqualObjects([set debugDescriptionForNode:node], @"\"A B C\"", nil);
	free(node);

	NSMutableString *expected = [NSMutableString string];
	[expected appendFormat:@"<CHUnbalancedTree: 0x%x> = {\n", zigzagTree];
	[expected appendString:@"\t\"A\" -> \"(null)\" and \"E\"\n"
	                       @"\t\"E\" -> \"B\" and \"(null)\"\n"
	                       @"\t\"B\" -> \"(null)\" and \"D\"\n"
	                       @"\t\"D\" -> \"C\" and \"(null)\"\n"
	                       @"\t\"C\" -> \"(null)\" and \"(null)\"\n"
	                       @"}"];
	
	STAssertEqualObjects([zigzagTree debugDescription], expected,
						 @"Wrong string from -debugDescription.");
}

- (void) testDotGraphString {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	STAssertEqualObjects([set dotGraphStringForNode:node], @"  \"A B C\";\n", nil);
	free(node);
	
	NSMutableString *expected = [NSMutableString string];
	[expected appendString:@"digraph CHUnbalancedTree\n{\n"];
	[expected appendFormat:@"  \"A\";\n  \"A\" -> {nil1;\"E\"};\n"
	                       @"  \"E\";\n  \"E\" -> {\"B\";nil2};\n"
	                       @"  \"B\";\n  \"B\" -> {nil3;\"D\"};\n"
	                       @"  \"D\";\n  \"D\" -> {\"C\";nil4};\n"
	                       @"  \"C\";\n  \"C\" -> {nil5;nil6};\n"];
	for (int i = 1; i <= 6; i++)
		[expected appendFormat:@"  nil%d [shape=point,fillcolor=black];\n", i];
	[expected appendFormat:@"}\n"];
	
	STAssertEqualObjects([zigzagTree dotGraphString], expected, nil);
	
	// Test for empty tree
	STAssertEqualObjects([set dotGraphString],
						 @"digraph CHUnbalancedTree\n{\n  nil;\n}\n", nil);
}

- (void) testRemoveObject {
	objects = [NSArray arrayWithObjects:
			   @"F",@"B",@"A",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil];

	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	[set addObjectsFromArray:objects];
	STAssertNoThrow([set removeObject:nil], nil);
	STAssertNoThrow([set removeObject:@"bogus"], nil);
	STAssertEquals([set count], [objects count], nil);

	// Test remove and subsequent pre-order of nodes for 4 broad possible cases
	
	// 1 - Remove a node with no children
	[set removeObject:@"A"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil]), nil);
	[set removeObject:@"K"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",nil]), nil);
	
	// 2 - Remove a node with only a right child
	[set removeObject:@"C"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"E",@"D",@"J",@"I",@"G",@"H",nil]), nil);
	[set removeObject:@"B"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"I",@"G",@"H",nil]), nil);
	
	// 3 - Remove a node with only a left child
	[set removeObject:@"I"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"G",@"H",nil]), nil);
	[set removeObject:@"J"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"D",@"G",@"H",nil]), nil);
	
	// 4 - Remove a node with two children
	[set removeAllObjects];
	[set addObjectsFromArray:[NSArray arrayWithObjects: @"B",@"A",@"E",@"C",@"D",@"F",nil]];
	
	[set removeObject:@"B"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"C",@"A",@"E",@"D",@"F",nil]), nil);
	[set removeObject:@"C"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"D",@"A",@"E",@"F",nil]), nil);
	[set removeObject:@"D"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"E",@"A",@"F",nil]), nil);
	[set removeObject:@"E"];
	STAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"F",@"A",nil]), nil);
}

@end
