//  CHAnderssonTreeTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHAnderssonTree.h"

static BOOL gcDisabled;

@interface CHAnderssonTreeTest : SenTestCase {
	CHAnderssonTree *tree;
	NSArray *testArray;
	NSEnumerator *e;
}
@end

@implementation CHAnderssonTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
	tree = [[CHAnderssonTree alloc] init];
	testArray = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",
				 @"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
	// Creates the tree from: Weiss pg. 645
}

- (void) tearDown {
	[tree release];
}

- (void) testAddObject {
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[tree addObject:object];
	STAssertEquals([tree count], 15u, @"-count is incorrect.");
}

- (void) testObjectEnumerator {
	// Enumerator shouldn't retain collection if there are no objects
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
	e = [tree objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Should not retain collection");
	
	// Enumerator should retain collection when it has 1+ objects, release when 0
	for (id object in testArray)
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
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder];
	
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"J", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"K", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"L", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"M", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"N", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"O", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalReverseOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder];
	
	STAssertEqualObjects([e nextObject], @"O", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"N", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"M", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"L", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"K", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"J", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalPreOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder];
	
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"L", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"J", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"K", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"N", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"M", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"O", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalPostOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder];
	
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"K", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"J", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"M", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"O", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"N", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"L", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalLevelOrder {
	for (id object in testArray)
		[tree addObject:object];

	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"L", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"N", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"J", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"M", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"O", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"K", @"-nextObject is wrong.");
	
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testRemove {
	NSArray *correctLevelOrder;
	for (id object in testArray)
		[tree addObject:object];

	[tree removeObject: @"J"];
	correctLevelOrder = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",
						 @"H",@"N",@"B",@"F",@"I",@"M",@"O",@"G",@"K",nil];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	STAssertTrue([[e allObjects] isEqualToArray:correctLevelOrder], @"Bad order");
	
	
}

@end
