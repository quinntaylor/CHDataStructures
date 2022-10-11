//
//  CHSortedSetTest.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHSortedSet.h>

#import "CHAbstractBinarySearchTree_Internal.h"
#import <CHDataStructures/CHAnderssonTree.h>
#import <CHDataStructures/CHAVLTree.h>
#import <CHDataStructures/CHRedBlackTree.h>
#import <CHDataStructures/CHTreap.h>
#import <CHDataStructures/CHUnbalancedTree.h>

#import "NSObject+TestUtilities.h"

static NSArray *abcde;

#define NonConcreteClass() \
([self classUnderTest] == nil || [self classUnderTest] == [CHAbstractBinarySearchTree class])

#pragma mark -

@interface CHSortedSetTest : XCTestCase {
	id/*<CHSortedSet>*/ set;
	NSArray *objects;
}
@end

@implementation CHSortedSetTest

+ (void)initialize {
	if ([self class] != [CHSortedSetTest class]) {
		return;
	}
	abcde = [[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",nil];
}

- (Class)classUnderTest {
	return nil;
}

- (id)createSet {
	return [[[[self classUnderTest] alloc] init] autorelease];
}

- (void)setUp {
	set = [self createSet];
}

- (void)testAddObject {
	if ([self classUnderTest] == nil) {
		return;
	}
	if ([self classUnderTest] == [CHAbstractBinarySearchTree class]) {
		// This method should be unsupported in the abstract parent class.
		XCTAssertThrows([set addObject:nil]);
	} else {
		XCTAssertEqual([set count], (NSUInteger)0);
		XCTAssertThrows([set addObject:nil]);
		XCTAssertEqual([set count], (NSUInteger)0);
		
		// Try adding distinct objects
		NSUInteger expectedCount = 0;
		for (id anObject in abcde) {
			[set addObject:anObject];
			XCTAssertEqual([set count], ++expectedCount);
		}
		XCTAssertEqual([set count], [abcde count]);
		
		// Test adding identical object--should be replaced, and count stay the same
		[set addObject:@"A"];
		XCTAssertEqual([set count], [abcde count]);
	}
}

- (void)testAllObjects {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertEqualObjects([set allObjects], @[]);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	XCTAssertEqualObjects([set allObjects], abcde);
}

- (void)testAnyObject {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertNil([set anyObject]);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	XCTAssertNotNil([set anyObject]);
}

- (void)testContainsObject {
	if (NonConcreteClass()) {
		return;
	}
	// Test contains for nil and non-member objects
	XCTAssertThrows([set containsObject:nil]);
	XCTAssertNoThrow([set containsObject:@"bogus"]);
	XCTAssertFalse([set containsObject:@"bogus"]);
	[set addObjectsFromArray:abcde];
	XCTAssertNoThrow([set containsObject:@"bogus"]);
	XCTAssertFalse([set containsObject:@"bogus"]);
	// Test contains for each object in the set 
	for (id anObject in abcde) {
		XCTAssertTrue([set containsObject:anObject]);
	}
}

- (void)testFirstObject {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertNoThrow([set firstObject]);
	XCTAssertNil([set firstObject]);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	XCTAssertNoThrow([set firstObject]);
	XCTAssertEqualObjects([set firstObject], @"A");
}

- (void)testInit {
	if (NonConcreteClass()) {
		return;
	}
	XCTAssertNotNil(set);
	XCTAssertEqual([set count], (NSUInteger)0);
}

- (void)testInitWithArray {
	if (NonConcreteClass()) {
		return;
	}
	set = [[[[self classUnderTest] alloc] initWithArray:abcde] autorelease];
	XCTAssertEqual([set count], [abcde count]);
}

- (void)testIsEqual {
	if (NonConcreteClass()) {
		return;
	}
	// Calls to -isEqual: exercise -isEqualToSortedSet: by extension
	XCTAssertTrue([set isEqual:set]);
	[set addObjectsFromArray:abcde];
	XCTAssertTrue([set isEqual:set]);
	XCTAssertFalse([set isEqual:[self createSet]]);
	XCTAssertFalse([set isEqual:[[NSObject new] autorelease]]);
}

- (void)testLastObject {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertNoThrow([set lastObject]);
	XCTAssertNil([set lastObject]);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	XCTAssertNoThrow([set lastObject]);
	XCTAssertEqualObjects([set lastObject], @"E");
}

- (void)testMember {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertThrows([set member:nil]);
	XCTAssertNoThrow([set member:@"bogus"]);
	XCTAssertNil([set member:@"bogus"]);	
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	for (id anObject in abcde) {
		XCTAssertEqualObjects([set member:anObject], anObject);
	}
	XCTAssertNoThrow([set member:@"bogus"]);
	XCTAssertNil([set member:@"bogus"]);
}

- (void)testObjectEnumerator {
	if (NonConcreteClass()) {
		return;
	}
	
	// Enumerator shouldn't retain collection if there are no objects
	XCTAssertEqual([set retainCount], (NSUInteger)1);
	NSEnumerator *e = [set objectEnumerator];
	XCTAssertNotNil(e);
	XCTAssertEqual([set retainCount], (NSUInteger)1);
	XCTAssertNil([e nextObject]);

	// Enumerator should retain collection when it has 1+ objects, release on 0
	[set addObjectsFromArray:abcde];
	e = [set objectEnumerator];
	XCTAssertNotNil(e);
	XCTAssertEqual([set retainCount], (NSUInteger)2);
	// Grab one object from the enumerator
	[e nextObject];
	XCTAssertEqual([set retainCount], (NSUInteger)2);
	// Empty the enumerator of all objects
	[e allObjects];
	XCTAssertEqual([set retainCount], (NSUInteger)1);
	
	// Enumerator should release collection on -dealloc
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	XCTAssertEqual([set retainCount], (NSUInteger)1);
	e = [set objectEnumerator];
	XCTAssertNotNil(e);
	XCTAssertEqual([set retainCount], (NSUInteger)2);
	[pool drain]; // Force deallocation of autoreleased enumerator
	XCTAssertEqual([set retainCount], (NSUInteger)1);
	
	// Test mutation in the middle of enumeration
	e = [set objectEnumerator];
	XCTAssertNoThrow([e nextObject]);
	[set addObject:@"bogus"];
	XCTAssertThrows([e nextObject]);
	XCTAssertThrows([e allObjects]);
}

- (void)testRemoveObject {
	if ([set isMemberOfClass:[CHAbstractBinarySearchTree class]]) {
		// This method should be unsupported in the abstract parent class.
		XCTAssertThrows([set removeObject:@"bogus"]);
	}
}

- (void)testRemoveAllObjects {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertNoThrow([set removeAllObjects]);
	XCTAssertEqual([set count], (NSUInteger)0);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	XCTAssertEqual([set count], [abcde count]);
	XCTAssertNoThrow([set removeAllObjects]);
	XCTAssertEqual([set count], (NSUInteger)0);
}

- (void)testRemoveFirstObject {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertNoThrow([set removeFirstObject]);
	XCTAssertEqual([set count], (NSUInteger)0);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	XCTAssertEqualObjects([set firstObject], @"A");
	XCTAssertEqual([set count], [abcde count]);
	XCTAssertNoThrow([set removeFirstObject]);
	XCTAssertEqualObjects([set firstObject], @"B");
	XCTAssertEqual([set count], [abcde count]-1);
}

- (void)testRemoveLastObject {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	XCTAssertNoThrow([set removeLastObject]);
	XCTAssertEqual([set count], (NSUInteger)0);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	XCTAssertEqualObjects([set lastObject], @"E");
	XCTAssertEqual([set count], [abcde count]);
	XCTAssertNoThrow([set removeLastObject]);
	XCTAssertEqualObjects([set lastObject], @"D");
	XCTAssertEqual([set count], [abcde count]-1);
}

- (void)testReverseObjectEnumerator {
	if (NonConcreteClass()) {
		return;
	}
	// Try with empty sorted set
	NSEnumerator *reverse = [set reverseObjectEnumerator];
	XCTAssertNotNil(reverse);
	XCTAssertNil([reverse nextObject]);
	// Try with populated sorted set
	[set addObjectsFromArray:abcde];
	reverse = [set reverseObjectEnumerator];
	for (id anObject in [[set allObjects] reverseObjectEnumerator]) {
		XCTAssertEqualObjects([reverse nextObject], anObject);
	}
}

- (void)testSet {
	if (NonConcreteClass()) {
		return;
	}
	NSArray *order = @[@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",@"J",@"L",@"N",@"F",@"A",@"H"];
	[set addObjectsFromArray:order];
	XCTAssertEqualObjects([(id<CHSortedSet>)set set], [NSSet setWithArray:order]);
}

- (void)testSubsetFromObjectToObject {
	if (NonConcreteClass()) {
		return;
	}
	NSArray *acdeg = @[@"A",@"C",@"D",@"E",@"G"];
	NSArray *acde  = @[@"A",@"C",@"D",@"E"];
	NSArray *aceg  = @[@"A",@"C",@"E",@"G"];
	NSArray *ag    = @[@"A",@"G"];
	NSArray *cde   = @[@"C",@"D",@"E"];
	NSArray *cdeg  = @[@"C",@"D",@"E",@"G"];
	NSArray *subset;
	
	set = [[[self classUnderTest] alloc] initWithArray:acdeg];
	
	// Test including all objects (2 nil params, or match first and last)
	subset = [[set subsetFromObject:nil toObject:nil options:0] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
	
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:0] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
	
	// Test including no objects
	subset = [[set subsetFromObject:@"H" toObject:@"I" options:0] allObjects];
	XCTAssertEqual([subset count], 0ul);
	subset = [[set subsetFromObject:@"A" toObject:@"B"
	           options:CHSubsetConstructionExcludeHighEndpoint|CHSubsetConstructionExcludeLowEndpoint] allObjects];
	XCTAssertEqual([subset count], 0ul);
	subset = [[set subsetFromObject:@"H" toObject:@"A" options:CHSubsetConstructionExcludeHighEndpoint] allObjects];
	XCTAssertEqual([subset count], 0ul);
	subset = [[set subsetFromObject:@"H" toObject:@"" options:0] allObjects];
	XCTAssertEqual([subset count], 0ul);
	
	// Test excluding elements at the end
	subset = [[set subsetFromObject:nil toObject:@"F" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	subset = [[set subsetFromObject:nil toObject:@"E" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	subset = [[set subsetFromObject:@"A" toObject:@"F" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	subset = [[set subsetFromObject:@"A" toObject:@"E" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	
	// Test excluding elements at the start
	subset = [[set subsetFromObject:@"B" toObject:nil options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	subset = [[set subsetFromObject:@"C" toObject:nil options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	
	subset = [[set subsetFromObject:@"B" toObject:@"G" options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	subset = [[set subsetFromObject:@"C" toObject:@"G" options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	
	// Test excluding elements in the middle (parameters in reverse order)
	subset = [[set subsetFromObject:@"E" toObject:@"C" options:0] allObjects];
	XCTAssertEqualObjects(subset, aceg);
	
	subset = [[set subsetFromObject:@"F" toObject:@"B" options:0] allObjects];
	XCTAssertEqualObjects(subset, ag);
	
	// Test using options to exclude zero, one, or both endpoints.
	CHSubsetConstructionOptions o;
	
	o = CHSubsetConstructionExcludeLowEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	subset = [[set subsetFromObject:nil toObject:@"G" options:o] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
	
	o = CHSubsetConstructionExcludeHighEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	XCTAssertEqualObjects(subset, acde);
	subset = [[set subsetFromObject:@"A" toObject:nil options:o] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
	
	o = CHSubsetConstructionExcludeLowEndpoint | CHSubsetConstructionExcludeHighEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	XCTAssertEqualObjects(subset, cde);
	
	subset = [[set subsetFromObject:nil toObject:nil options:o] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
}

- (void)testNSCoding {
	if (NonConcreteClass()) {
		return;
	}
	NSArray *order = @[@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",@"J",@"L",@"N",@"F",@"A",@"H"];
	NSArray *before, *after;
	[set addObjectsFromArray:order];
	XCTAssertEqual([set count], [order count]);
	if ([set conformsToProtocol:@protocol(CHSearchTree)]) {
		before = [set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder];
	} else {
		before = [set allObjects];
	}
	set = [set copyUsingNSCoding];
	
	XCTAssertEqual([set count], [order count]);
	if ([set conformsToProtocol:@protocol(CHSearchTree)]) {
		after = [set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder];
	} else {
		after = [set allObjects];
	}
	if ([self classUnderTest] != [CHTreap class]) {
		XCTAssertEqualObjects(before, after);
	}
}

- (void)testNSCopying {
	if (NonConcreteClass()) {
		return;
	}
	id copy;
	copy = [[set copy] autorelease];
	XCTAssertNotNil(copy);
	XCTAssertEqual([copy count], (NSUInteger)0);
	XCTAssertEqual([set hash], [copy hash]);
	
	[set addObjectsFromArray:abcde];
	copy = [[set copy] autorelease];
	XCTAssertNotNil(copy);
	XCTAssertEqual([copy count], [abcde count]);
	XCTAssertEqual([set hash], [copy hash]);
	if ([set conformsToProtocol:@protocol(CHSearchTree)] && [self classUnderTest] != [CHTreap class]) {
		XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
							 [copy allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder]);
	} else {
		XCTAssertEqualObjects([set allObjects], [copy allObjects]);
	}
}

- (void)testNSFastEnumeration {
	if (NonConcreteClass()) {
		return;
	}
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
	for (NSUInteger number = 1; number <= limit; number++) {
		[set addObject:@(number)];
	}
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in set) {
		XCTAssertEqual([object unsignedIntegerValue], expected++);
		count++;
	}
	XCTAssertEqual(count, limit);
	
	@try {
		for (__unused id object in set) {
			[set addObject:@(-1)];
		}
		XCTFail(@"Expected an exception for mutating during enumeration.");
	}
	@catch (NSException *exception) {
	}
}

@end

#pragma mark -

@interface CHAbstractBinarySearchTree (Test)

- (id)headerObject;

@end

@implementation CHAbstractBinarySearchTree (Test)

- (id)headerObject {
	return header->object;
}

@end

@interface CHAbstractBinarySearchTreeTest : CHSortedSetTest
@end

@implementation CHAbstractBinarySearchTreeTest

- (Class)classUnderTest {
	return [CHAbstractBinarySearchTree class];
}

- (void)setUp {
	set = [self createSet];
}

- (void)testAllObjectsWithTraversalOrder {
	if ([self class] == [CHAbstractBinarySearchTreeTest class]) {
		return;
	}
	// Also tests -objectEnumeratorWithTraversalOrder: implicitly
	[set addObjectsFromArray:abcde];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderAscending],
						 (@[@"A",@"B",@"C",@"D",@"E"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderDescending],
						 (@[@"E",@"D",@"C",@"B",@"A"]));
	// NOTE: Individual subclasses should test pre/post/level-order traversals
	XCTAssertThrows([set objectEnumeratorWithTraversalOrder:42]);
}

- (void)testDescription {
	XCTAssertEqualObjects([set description], [[set allObjects] description]);
}

- (void)testHeaderObject {
	id headerObject = [set headerObject];
	XCTAssertNotNil(headerObject);
	XCTAssertThrows([headerObject retain]);
	XCTAssertThrows([headerObject release]);
	XCTAssertThrows([headerObject autorelease]);
}

- (void)testIsEqualToSearchTree {
	if ([self class] != [CHAbstractBinarySearchTreeTest class]) {
		return;
	}
	NSMutableArray *equalTrees = [NSMutableArray array];
	NSArray *treeClasses = @[
		[CHAnderssonTree class],
		[CHAVLTree class],
		[CHRedBlackTree class],
		[CHTreap class],
		[CHUnbalancedTree class],
	];
	for (Class theClass in treeClasses) {
		[equalTrees addObject:[[theClass alloc] initWithArray:abcde]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalTrees addObject:[equalTrees objectAtIndex:0]];
	
	NSArray *sortedSetClasses = @[
		[CHAnderssonTree class],
		[CHAVLTree class],
		[CHRedBlackTree class],
		[CHTreap class],
		[CHUnbalancedTree class],
	];
	id<CHSearchTree> tree1 = nil;
	id<CHSearchTree> tree2;
	for (NSUInteger i = 0; i < [sortedSetClasses count]; i++) {
		tree1 = [equalTrees objectAtIndex:i];
		tree2 = [equalTrees objectAtIndex:i+1];
		XCTAssertEqual([tree1 hash], [tree2 hash]);
		XCTAssertEqualObjects(tree1, tree2);
	}
	XCTAssertFalse([tree1 isEqualToSearchTree:(id)@[]]);
	XCTAssertThrowsSpecificNamed([tree1 isEqualToSearchTree:(id)[NSString string]], NSException, NSInvalidArgumentException);
}

@end

#pragma mark -

@interface CHAnderssonTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHAnderssonTreeTest

- (Class)classUnderTest {
	return [CHAnderssonTree class];
}

- (void)setUp {
	set = [self createSet];
	objects = @[@"B",@"N",@"C",@"L",@"D",@"J",@"E",@"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F"];
	// When inserted in this order, creates the tree from: Weiss pg. 645
}

- (void)testAddObject {
	XCTAssertEqual([set count], (NSUInteger)0);
	XCTAssertThrows([set addObject:nil]);
	XCTAssertEqual([set count], (NSUInteger)0);
	
	[set addObjectsFromArray:objects];
	XCTAssertEqual([set count], [objects count]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderAscending],
						 (@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderDescending],
						 (@[@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"E",@"C",@"A",@"B",@"D",@"L",@"H",@"F",@"G",@"J",@"I",@"K",@"N",@"M",@"O"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPostOrder],
						 (@[@"B",@"A",@"D",@"C",@"G",@"F",@"I",@"K",@"J",@"H",@"M",@"O",@"N",@"L",@"E"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",@"J",@"M",@"O",@"G",@"I",@"K"]));
	
	// Test adding identical object--should be replaced, and count stay the same
	[set addObject:@"A"];
	XCTAssertEqual([set count], [objects count]);
}

- (void)testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->level = 1;
	XCTAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[1]\t\"A B C\"");
	free(node);
}

- (void)testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->level = 1;
	XCTAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n1\"];\n");
	free(node);
}

- (void)testRemoveObject {
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	[set addObjectsFromArray:objects];
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	XCTAssertEqual([set count], [objects count]);
	
	[set removeObject:@"J"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",@"I",@"M",@"O",@"G",@"K"]));
	[set removeObject:@"N"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"H",@"A",@"D",@"F",@"L",@"B",@"G",@"I",@"M",@"K",@"O"]));
	[set removeObject:@"H"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"I",@"A",@"D",@"F",@"L",@"B",@"G",@"K",@"M",@"O"]));
	[set removeObject:@"D"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"B",@"I",@"A",@"C",@"F",@"L",@"G",@"K",@"M",@"O"]));
	[set removeObject:@"C"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"I",@"E",@"L",@"A",@"F",@"K",@"M",@"B",@"G",@"O"]));
	[set removeObject:@"K"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"I",@"E",@"M",@"A",@"F",@"L",@"O",@"B",@"G"]));
	[set removeObject:@"M"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"A",@"I",@"B",@"F",@"L",@"G",@"O"]));
	[set removeObject:@"B"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"A",@"I",@"F",@"L",@"G",@"O"]));
	[set removeObject:@"A"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"F",@"E",@"I",@"G",@"L",@"O"]));
	[set removeObject:@"G"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"F",@"E",@"L",@"I",@"O"]));
	[set removeObject:@"E"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"I",@"F",@"L",@"O"]));
	[set removeObject:@"F"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"L",@"I",@"O"]));
	[set removeObject:@"L"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"I",@"O"]));
	[set removeObject:@"I"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"O"]));
}

@end

#pragma mark -

@interface CHAVLTree (Test)

- (void)verify;

@end

@implementation CHAVLTree (Test)

- (NSInteger)heightForSubtree:(CHBinaryTreeNode *)node
				   isBalanced:(BOOL *)isBalanced
				  errorString:(NSMutableString *)balanceErrors {
	if (node == sentinel) {
		return 0;
	}
	NSInteger leftHeight  = [self heightForSubtree:node->left isBalanced:isBalanced errorString:balanceErrors];
	NSInteger rightHeight = [self heightForSubtree:node->right isBalanced:isBalanced errorString:balanceErrors];
	if (node->balance != (rightHeight-leftHeight)) {
		[balanceErrors appendFormat:@". | At \"%@\" should be %ld, was %d",
		 node->object, (rightHeight-leftHeight), node->balance];
		*isBalanced = NO;
	}
	return MAX(leftHeight, rightHeight) + 1;
}

- (void)verify {
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

- (Class)classUnderTest {
	return [CHAVLTree class];
}

- (void)setUp {
	set = [self createSet];
	objects = @[@"B",@"N",@"C",@"L",@"D",@"J",@"E",@"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F"];
}

- (void)testAddObject {
	[super testAddObject];
	
	[set removeAllObjects];
	NSEnumerator *e = [objects objectEnumerator];
	
	// Test adding objects one at a time and verify the ordering of tree nodes
	[set addObject:[e nextObject]]; // B
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"B"]));
	[set addObject:[e nextObject]]; // N
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"B",@"N"]));
	[set addObject:[e nextObject]]; // C
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"C",@"B",@"N"]));
	[set addObject:[e nextObject]]; // L
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"C",@"B",@"N",@"L"]));
	[set addObject:[e nextObject]]; // D
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"C",@"B",@"L",@"D",@"N"]));
	[set addObject:[e nextObject]]; // J
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"D",@"C",@"B",@"L",@"J",@"N"]));
}


- (void)testAllObjectsWithTraversalOrder {
	[set addObjectsFromArray:objects];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderAscending],
						 (@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderDescending],
						 (@[@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"J",@"D",@"B",@"A",@"C",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"N",@"M",@"O"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPostOrder],
						 (@[@"A",@"C",@"B",@"F",@"E",@"I",@"H",@"G",@"D",@"K",@"M",@"O",@"N",@"L",@"J"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"J",@"D",@"L",@"B",@"G",@"K",@"N",@"A",@"C",@"E",@"H",@"M",@"O",@"F",@"I"]));
}

- (void)testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->balance = 0;
	XCTAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[ 0]\t\"A B C\"");
	free(node);
}

- (void)testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->balance = 0;
	XCTAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n0\"];\n");
	free(node);
}

- (void)testRemoveObject {
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	[set addObjectsFromArray:objects];
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	XCTAssertEqual([set count], [objects count]);
	
	NSEnumerator *e = [objects objectEnumerator];
	
	[set removeObject:[e nextObject]]; // B
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"N",@"M",@"O"]));
	[set removeObject:[e nextObject]]; // N
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"O",@"M"]));
	[set removeObject:[e nextObject]]; // C
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"J",@"G",@"D",@"A",@"E",@"F",@"H",@"I",@"L",@"K",@"O",@"M"]));
	[set removeObject:[e nextObject]]; // L
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"D",@"A",@"E",@"F",@"J",@"H",@"I",@"M",@"K",@"O"]));
	[set removeObject:[e nextObject]]; // D
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"E",@"A",@"F",@"J",@"H",@"I",@"M",@"K",@"O"]));
	[set removeObject:[e nextObject]]; // J
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"E",@"A",@"F",@"K",@"H",@"I",@"M",@"O"]));
	[set removeObject:[e nextObject]]; // E
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"F",@"A",@"K",@"H",@"I",@"M",@"O"]));
	[set removeObject:[e nextObject]]; // H
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"F",@"A",@"K",@"I",@"M",@"O"]));
	[set removeObject:[e nextObject]]; // K
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"F",@"A",@"M",@"I",@"O"]));
	[set removeObject:[e nextObject]]; // M
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"F",@"A",@"O",@"I"]));
	[set removeObject:[e nextObject]]; // O
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G",@"F",@"A",@"I"]));
	[set removeObject:[e nextObject]]; // G
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"A",@"I"]));
	[set removeObject:[e nextObject]]; // A
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"I"]));
	[set removeObject:[e nextObject]]; // I
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F"]));
}

- (void)testRemoveObjectDoubleLeft {
	objects = @[@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",@"E",@"G",@"I"];
	[set addObjectsFromArray:objects];
	[set removeObject:@"A"];
	[set removeObject:@"D"];
	XCTAssertNoThrow([set verify]);
	XCTAssertEqual([set count], [objects count] - 2);	
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"C",@"B",@"E",@"J",@"H",@"G",@"I",@"K"]));
}

- (void)testRemoveObjectDoubleRight {
	objects = @[@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",@"E",@"G",@"I"];
	[set addObjectsFromArray:objects];
	[set removeObject:@"K"];
	[set removeObject:@"G"];
	XCTAssertNoThrow([set verify]);
	XCTAssertEqual([set count], [objects count] - 2);	
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"B",@"A",@"D",@"C",@"E",@"I",@"H",@"J"]));
}

@end

#pragma mark -

@interface CHRedBlackTree (Test)

- (void)verify;

@end

@implementation CHRedBlackTree (Test)

// Recursive method for verifying that red-black properties are not violated.
- (NSUInteger)verifySubtreeAtNode:(CHBinaryTreeNode *)node {
	if (node == sentinel) {
		return 1;
	}
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
	if (leftBlackHeight != 0 && rightBlackHeight != 0) {
		return (node->color == kRED) ? leftBlackHeight : leftBlackHeight + 1;
	} else {
		return 0;
	}
}

- (void)verify {
	sentinel->object = nil;
	[self verifySubtreeAtNode:header->right];
}

@end

@interface CHRedBlackTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHRedBlackTreeTest

- (Class)classUnderTest {
	return [CHRedBlackTree class];
}

- (void)setUp {
	set = [self createSet];
	objects = @[@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",@"J",@"L",@"N",@"F",@"A",@"H"];
	// When inserted in this order, creates the tree from: Weiss pg. 631 
}

- (void)testAddObject {
	[super testAddObject];
	[set removeAllObjects];
	
	NSEnumerator *e = [objects objectEnumerator];
	
	[set addObject:[e nextObject]]; // B
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"B"]));
	[set addObject:[e nextObject]]; // M
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"B",@"M"]));
	[set addObject:[e nextObject]]; // C
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"C",@"B",@"M"]));
	[set addObject:[e nextObject]]; // K
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"C",@"B",@"M",@"K"]));
	[set addObject:[e nextObject]]; // D
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"C",@"B",@"K",@"D",@"M"]));
	[set addObject:[e nextObject]]; // I
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"C",@"B",@"K",@"D",@"M",@"I"]));
	[set addObject:[e nextObject]]; // E
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"C",@"B",@"K",@"E",@"M",@"D",@"I"]));
	[set addObject:[e nextObject]]; // G
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G"]));
	[set addObject:[e nextObject]]; // J
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J"]));
	[set addObject:[e nextObject]]; // L
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L"]));
	[set addObject:[e nextObject]]; // N
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",@"N"]));
	[set addObject:[e nextObject]]; // F
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",@"N",@"F"]));
	[set addObject:[e nextObject]]; // A
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F"]));
	[set addObject:[e nextObject]]; // H
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",@"H"]));
	
	// Test adding identical object--should be replaced, and count stay the same
	XCTAssertEqual([set count], [objects count]);
	[set addObject:@"A"];
	XCTAssertEqual([set count], [objects count]);
}

- (void)testAddObjectsAscending {
	objects = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R"];
	[set addObjectsFromArray:objects];
	XCTAssertEqual([set count], [objects count]);
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"H",@"D",@"L",@"B",@"F",@"J",@"N",@"A",@"C",@"E",@"G",@"I",@"K",@"M",@"P",@"O",@"Q",@"R"]));
}

- (void)testAddObjectsDescending {
	objects = @[@"R",@"Q",@"P",@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A"];
	[set addObjectsFromArray:objects];
	XCTAssertEqual([set count], [objects count]);
	XCTAssertNoThrow([set verify]);
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"K",@"G",@"O",@"E",@"I",@"M",@"Q",@"C",@"F",@"H",@"J",@"L",@"N",@"P",@"R",@"B",@"D",@"A"]));
}

- (void)testAllObjectsWithTraversalOrder {
	[set addObjectsFromArray:objects];
	
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderAscending],
						 (@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderDescending],
						 (@[@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"E",@"C",@"B",@"A",@"D",@"K",@"I",@"G",@"F",@"H",@"J",@"M",@"L",@"N"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPostOrder],
						 (@[@"A",@"B",@"D",@"C",@"F",@"H",@"G",@"J",@"I",@"L",@"N",@"M",@"K",@"E"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",@"H"]));
}

- (void)testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->color = kRED;
	XCTAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[ RED ]	\"A B C\"");
	node->color = kBLACK;
	XCTAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[BLACK]	\"A B C\"");
	free(node);
}

- (void)testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->color = kRED;
	XCTAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [color=red];\n");
	node->color = kBLACK;
	XCTAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [color=black];\n");
	free(node);
}

- (void)testRemoveObject {
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	[set addObjectsFromArray:objects];
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	XCTAssertEqual([set count], [objects count]);
	
	NSUInteger count = [objects count];
	for (id anObject in objects) {
		[set removeObject:anObject];
		XCTAssertEqual([set count], --count);
		XCTAssertNoThrow([set verify]);
	}
}

@end

#pragma mark -

@interface CHTreap (Test)

- (void)verify; // Raises an exception on error

@end

@implementation CHTreap (Test)

// Recursive method for verifying that BST and heap properties are not violated.
- (void)verifySubtreeAtNode:(CHBinaryTreeNode *)node {
	if (node == sentinel) {
		return;
	}
	if (node->left != sentinel) {
		// Verify BST property
		if ([node->left->object compare:node->object] == NSOrderedDescending) {
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation left of %@", node->object];
		}
		// Verify heap property
		if (node->left->priority > node->priority) {
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation left of %@", node->object];
		}
		// Recursively verity left subtree
		[self verifySubtreeAtNode:node->left];
	}
	
	if (node->right != sentinel) {
		// Verify BST property
		if ([node->right->object compare:node->object] == NSOrderedAscending) {
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation right of %@", node->object];
		}
		// Verify heap property
		if (node->right->priority > node->priority) {
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation right of %@", node->object];
		}
		// Recursively verity right subtree
		[self verifySubtreeAtNode:node->right];
	}
}

- (void)verify {
	[self verifySubtreeAtNode:header->right];
}

@end

@interface CHTreapTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHTreapTest

- (Class)classUnderTest {
	return [CHTreap class];
}

- (void)setUp {
	set = [self createSet];
	objects = @[@"G",@"D",@"K",@"B",@"I",@"F",@"L",@"C",@"H",@"E",@"M",@"A",@"J"];
}

- (void)testAddObject {
	[super testAddObject];
	
	// Repeat a few times to try to get a decent random spread.
	for (NSUInteger tries = 1, count; tries <= 5; tries++) {
		[set removeAllObjects];
		count = 0;
		for (id anObject in objects) {
			[set addObject:anObject];
			XCTAssertEqual([set count], ++count);
			// Can't test a specific order because of randomly-assigned priorities
			XCTAssertNoThrow([set verify]);
		}
	}
}

- (void)testAddObjectWithPriority {
	[super testAddObject];

	XCTAssertNoThrow([set addObject:@"foo" withPriority:0]);
	XCTAssertNoThrow([set addObject:@"foo" withPriority:CHTreapNotFound]);
	[set removeAllObjects];
	
	NSUInteger priority = 0;
	NSEnumerator *e = [objects objectEnumerator];
	
	// Simulate by inserting unordered elements with increasing priority
	// This artificially balances the tree, but we can test the result.
	
	[set addObject:[e nextObject] withPriority:(++priority)]; // G
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"G"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // D
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"D",@"G"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // K
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"K",@"D",@"G"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // B
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"B",@"K",@"D",@"G"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // I
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"I",@"B",@"D",@"G",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // F
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"B",@"D",@"I",@"G",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // L
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"L",@"F",@"B",@"D",@"I",@"G",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // C
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"C",@"B",@"L",@"F",@"D",@"I",@"G",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // H
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"H",@"C",@"B",@"F",@"D",@"G",@"L",@"I",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // E
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // M
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // A
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"A",@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K"]));
	[set addObject:[e nextObject] withPriority:(++priority)]; // J
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"J",@"A",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"I",@"M",@"L",@"K"]));
}

- (void)testAllObjectsWithTraversalOrder {
	[set addObjectsFromArray:objects];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderAscending],
						 (@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M"]));	
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderDescending],
						 (@[@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A"]));	
	// Test adding an existing object to the treap
	XCTAssertEqual([set count], [objects count]);
	[set addObject:@"A" withPriority:NSIntegerMin];
	XCTAssertEqual([set count], [objects count]);	
}

- (void)testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->priority = 123456789;
	XCTAssertEqualObjects([set debugDescriptionForNode:node],
						 @"[  123456789]\t\"A B C\"");
	free(node);
}

- (void)testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	node->priority = 123456789;
	XCTAssertEqualObjects([set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n123456789\"];\n");
	free(node);
}

- (void)testPriorityForObject {
	// Priority value should indicate that an object not in the treap is absent.
	XCTAssertThrows([set priorityForObject:nil]);
	XCTAssertEqual([set priorityForObject:@"bogus"], (NSUInteger)CHTreapNotFound);
	[set addObjectsFromArray:objects];
	XCTAssertEqual([set priorityForObject:@"bogus"], (NSUInteger)CHTreapNotFound);
	
	// Inserting from 'objects' with these priorities creates a known ordering.
	NSUInteger priorities[] = {8,11,13,12,1,4,5,9,6,3,10,7,2};
	
	NSUInteger index = 0;
	[set removeAllObjects];
	for (id anObject in objects) {
		[set addObject:anObject withPriority:(priorities[index++])];
		[set verify];
	}
	
	// Verify that the assigned priorities are what we expect
	index = 0;
	for (id anObject in objects) {
		XCTAssertEqual([set priorityForObject:anObject], priorities[index++]);
	}
	// Verify the required tree structure with these objects and priorities.
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"K",@"B",@"A",@"D",@"C",@"G",@"F",@"E",@"H",@"J",@"I",@"M",@"L"]));
}

- (void)testRemoveObject {
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	[set addObjectsFromArray:objects];
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	XCTAssertEqual([set count], [objects count]);

	// Remove all nodes one by one, and test treap validity at each step
	NSUInteger count = [objects count];
	for (id anObject in objects) {
		[set removeObject:anObject];
		XCTAssertEqual([set count], --count);
		XCTAssertNoThrow([set verify]);
	}
	
	// Test removing a node which has been removed from the tree
	XCTAssertEqual([set count], (NSUInteger)0);
	[set removeObject:@"bogus"];
	XCTAssertEqual([set count], (NSUInteger)0);
}

@end

#pragma mark -

@interface CHUnbalancedTreeTest : CHAbstractBinarySearchTreeTest {
	CHAbstractBinarySearchTree *insideTree, *outsideTree, *zigzagTree;
}
@end

@implementation CHUnbalancedTreeTest

- (Class)classUnderTest {
	return [CHUnbalancedTree class];
}

- (void)setUp {
	set = [self createSet];

	objects = @[@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",@"H"]; // Specified using level-order travesal
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example

	outsideTree = [[CHUnbalancedTree alloc] initWithArray:
				   @[@"C",@"B",@"A",@"D",@"E"]];
	insideTree = [[CHUnbalancedTree alloc] initWithArray:
				  @[@"C",@"A",@"B",@"E",@"D"]];
	zigzagTree = [[CHUnbalancedTree alloc] initWithArray:
				  @[@"A",@"E",@"B",@"D",@"C"]];
}

- (void)testAddObject {
	[super testAddObject];
	
	[set removeAllObjects];
	[set addObjectsFromArray:objects];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 objects);
}

- (void)testAllObjectsWithTraversalOrder {
	[super testAllObjectsWithTraversalOrder];
	[set removeAllObjects];
	[set addObjectsFromArray:objects];
	
	// Test all traversal orderings by individual tree
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderAscending],
						 (@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderDescending],
						 (@[@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",@"H"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPostOrder],
						 (@[@"A",@"C",@"E",@"D",@"B",@"H",@"I",@"G",@"F"]));
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderLevelOrder],
						 (@[@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",@"H"]));
	
	// Test pre-order traversal of some degenerate unbalanced trees
	XCTAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"C",@"B",@"A",@"D",@"E"]));
	XCTAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"C",@"A",@"B",@"E",@"D"]));
	XCTAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"A",@"E",@"B",@"D",@"C"]));
	
	// Test that no matter of how a tree is structured, forward and reverse work
	NSArray *ascending = @[@"A",@"B",@"C",@"D",@"E"];
	XCTAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraversalOrderAscending], ascending);
	XCTAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraversalOrderAscending],  ascending);
	XCTAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraversalOrderAscending],  ascending);
	NSArray *descending = @[@"E",@"D",@"C",@"B",@"A"];
	XCTAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraversalOrderDescending], descending);
	XCTAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraversalOrderDescending],  descending);
	XCTAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraversalOrderDescending],  descending);
}

- (void)testDebugDescription {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	XCTAssertEqualObjects([set debugDescriptionForNode:node], @"\"A B C\"");
	free(node);

	NSMutableString *expected = [NSMutableString string];
	[expected appendFormat:@"<CHUnbalancedTree: 0x%p> = {\n", zigzagTree];
	[expected appendString:@"\t\"A\" -> \"(null)\" and \"E\"\n"
	                       @"\t\"E\" -> \"B\" and \"(null)\"\n"
	                       @"\t\"B\" -> \"(null)\" and \"D\"\n"
	                       @"\t\"D\" -> \"C\" and \"(null)\"\n"
	                       @"\t\"C\" -> \"(null)\" and \"(null)\"\n"
	                       @"}"];
	
	XCTAssertEqualObjects([zigzagTree debugDescription], expected,
						 @"Wrong string from -debugDescription.");
}

- (void)testDotGraphString {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	XCTAssertEqualObjects([set dotGraphStringForNode:node], @"  \"A B C\";\n");
	free(node);
	
	NSMutableString *expected = [NSMutableString string];
	[expected appendString:@"digraph CHUnbalancedTree\n{\n"];
	[expected appendFormat:@"  \"A\";\n  \"A\" -> {nil1;\"E\"};\n"
	                       @"  \"E\";\n  \"E\" -> {\"B\";nil2};\n"
	                       @"  \"B\";\n  \"B\" -> {nil3;\"D\"};\n"
	                       @"  \"D\";\n  \"D\" -> {\"C\";nil4};\n"
	                       @"  \"C\";\n  \"C\" -> {nil5;nil6};\n"];
	for (int i = 1; i <= 6; i++) {
		[expected appendFormat:@"  nil%d [shape=point,fillcolor=black];\n", i];
	}
	[expected appendFormat:@"}\n"];
	
	XCTAssertEqualObjects([zigzagTree dotGraphString], expected);
	
	// Test for empty tree
	XCTAssertEqualObjects([set dotGraphString],
						 @"digraph CHUnbalancedTree\n{\n  nil;\n}\n");
}

- (void)testRemoveObject {
	objects = @[@"F",@"B",@"A",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K"];

	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	[set addObjectsFromArray:objects];
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	XCTAssertEqual([set count], [objects count]);

	// Test remove and subsequent pre-order of nodes for 4 broad possible cases
	
	// 1 - Remove a node with no children
	[set removeObject:@"A"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K"]));
	[set removeObject:@"K"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H"]));
	
	// 2 - Remove a node with only a right child
	[set removeObject:@"C"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"B",@"E",@"D",@"J",@"I",@"G",@"H"]));
	[set removeObject:@"B"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"E",@"D",@"J",@"I",@"G",@"H"]));
	
	// 3 - Remove a node with only a left child
	[set removeObject:@"I"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"E",@"D",@"J",@"G",@"H"]));
	[set removeObject:@"J"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"E",@"D",@"G",@"H"]));
	
	// 4 - Remove a node with two children
	[set removeAllObjects];
	[set addObjectsFromArray:@[@"B",@"A",@"E",@"C",@"D",@"F"]];
	
	[set removeObject:@"B"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"C",@"A",@"E",@"D",@"F"]));
	[set removeObject:@"C"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"D",@"A",@"E",@"F"]));
	[set removeObject:@"D"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"E",@"A",@"F"]));
	[set removeObject:@"E"];
	XCTAssertEqualObjects([set allObjectsWithTraversalOrder:CHTraversalOrderPreOrder],
						 (@[@"F",@"A"]));
}

@end
