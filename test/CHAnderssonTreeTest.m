//  CHAnderssonTreeTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHAnderssonTree.h"

static BOOL gcDisabled;

static NSString* badOrder(NSArray *order, NSArray *correctOrder) {
	return [[[NSString stringWithFormat:@"Should be %@, not %@", correctOrder, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			 stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

@interface CHAnderssonTreeTest : SenTestCase {
	CHAnderssonTree *tree;
	NSArray *testArray;
	NSArray *order, *correct;
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
	NSEnumerator *e = [tree objectEnumerator];
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
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
					@"I",@"J",@"K",@"L",@"M",@"N",@"O",nil];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder] allObjects];	
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalReverseOrder {
	for (id object in testArray)
		[tree addObject:object];
	correct = [NSArray arrayWithObjects:@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",
					@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder] allObjects];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPreOrder {
	for (id object in testArray)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"E",@"C",@"A",@"B",@"D",@"L",@"H",@"F",
					@"G",@"J",@"I",@"K",@"N",@"M",@"O",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPostOrder {
	for (id object in testArray)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"B",@"A",@"D",@"C",@"G",@"F",@"I",@"K",
					@"J",@"H",@"M",@"O",@"N",@"L",@"E",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalLevelOrder {
	for (id object in testArray)
		[tree addObject:object];

	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",
					@"F",@"J",@"M",@"O",@"G",@"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testRemoveObject {
	for (id object in testArray)
		[tree addObject:object];

	[tree removeObject:@"J"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",
			   @"I",@"M",@"O",@"G",@"K",nil];
	STAssertFalse([order containsObject:@"J"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"N"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"H",@"A",@"D",@"F",@"L",@"B",@"G",
			   @"I",@"M",@"K",@"O",nil];
	STAssertFalse([order containsObject:@"N"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"H"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"I",@"A",@"D",@"F",@"L",@"B",@"G",
			   @"K",@"M",@"O",nil];
	STAssertFalse([order containsObject:@"H"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"D"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"B",@"I",@"A",@"C",@"F",@"L",@"G",@"K",
			   @"M",@"O",nil];
	STAssertFalse([order containsObject:@"D"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"C"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"E",@"L",@"A",@"F",@"K",@"M",@"B",@"G",
			   @"O",nil];
	STAssertFalse([order containsObject:@"C"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"K"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"E",@"M",@"A",@"F",@"L",@"O",@"B",@"G",
			   nil];
	STAssertFalse([order containsObject:@"K"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"M"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"A",@"I",@"B",@"F",@"L",@"G",@"O",nil];
	STAssertFalse([order containsObject:@"M"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"B"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"A",@"I",@"F",@"L",@"G",@"O",nil];
	STAssertFalse([order containsObject:@"B"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"A"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"F",@"E",@"I",@"G",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"A"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"G"];
	correct = [NSArray arrayWithObjects:@"F",@"E",@"L",@"I",@"O",nil];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	STAssertFalse([order containsObject:@"G"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"E"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"F",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"E"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"F"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"L",@"I",@"O",nil];
	STAssertFalse([order containsObject:@"F"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"L"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"O",nil];
	STAssertFalse([order containsObject:@"L"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	
	[tree removeObject:@"I"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"O",nil];
	STAssertFalse([order containsObject:@"I"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

@end
