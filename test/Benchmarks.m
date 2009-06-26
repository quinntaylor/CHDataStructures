/*
 CHDataStructures.framework -- Benchmarks.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import <CHDataStructures/CHDataStructures.h>
#import <sys/time.h>

@interface CHAbstractBinarySearchTree (Height)
- (NSUInteger) height;
- (NSUInteger) heightOfSubtreeAtNode:(CHBinaryTreeNode*)node;
@end

@implementation CHAbstractBinarySearchTree (Height)

- (NSUInteger) height {
	return [self heightOfSubtreeAtNode:header->right];
}

- (NSUInteger) heightOfSubtreeAtNode:(CHBinaryTreeNode*)node {
	if (node == sentinel)
		return 0;
	else {
		NSUInteger leftHeight = [self heightOfSubtreeAtNode:node->left];
		NSUInteger rightHeight = [self heightOfSubtreeAtNode:node->right];
		return ((leftHeight > rightHeight) ? leftHeight : rightHeight) + 1;
	}
}

@end

#pragma mark -

static id anObject;
static NSEnumerator *objectEnumerator, *arrayEnumerator;
static NSArray *array;
static NSMutableArray *objects;
static NSUInteger item, arrayCount;
struct timeval timeOfDay;
struct timespec sleepDelay = {0,1}, sleepRemain;
static double startTime;

/* Return the current time in seconds, using a double precision number. */
double timestamp() {
	gettimeofday(&timeOfDay, NULL);
	return ((double) timeOfDay.tv_sec + (double) timeOfDay.tv_usec * 1e-6);
}

void benchmarkDeque(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n* %@", testClass);
	
	id<CHDeque> deque;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8d", [array count]);
	
	printf("\nprependObject:    ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[deque prependObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nappendObject:     ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[deque appendObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveFirstObject: ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[deque appendObject:anObject];
		startTime = timestamp();
		for (item = 1; item <= arrayCount; item++)
			[deque removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveLastObject:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[deque appendObject:anObject];
		startTime = timestamp();
		for (item = 1; item <= arrayCount; item++)
			[deque removeLastObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[deque appendObject:anObject];
		startTime = timestamp();
		[deque removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[deque appendObject:anObject];
		startTime = timestamp();
		objectEnumerator = [deque objectEnumerator];
		while ([objectEnumerator nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
#if MAC_OS_X_VERSION_10_5_AND_LATER
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		for (id object in deque)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
#endif
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkQueue(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n* %@", testClass);
	
	id<CHQueue> queue;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8d", [array count]);
	
	printf("\naddObject:         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[queue addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveFirstObject:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[queue addObject:anObject];
		startTime = timestamp();
		arrayCount = [array count];
		for (item = 1; item <= arrayCount; item++)
			[queue removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[queue addObject:anObject];
		startTime = timestamp();
		[queue removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[queue addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [queue objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
#if MAC_OS_X_VERSION_10_5_AND_LATER
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		arrayCount = [array count];
		for (id object in queue)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
#endif
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkStack(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHStack> stack;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8d", [array count]);
	
	printf("\npushObject:       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[stack pushObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\npopObject:        ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[stack pushObject:anObject];
		startTime = timestamp();
		arrayCount = [array count];
		for (item = 1; item <= arrayCount; item++)
			[stack popObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[stack pushObject:anObject];
		startTime = timestamp();
		[stack removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[stack pushObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [stack objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
#if MAC_OS_X_VERSION_10_5_AND_LATER
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		for (id object in stack)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
#endif
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkHeap(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHHeap> heap;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8d", [array count]);
	
	printf("\naddObject:          ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[heap addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveFirstObject:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[heap addObject:anObject];
		startTime = timestamp();
		arrayCount = [array count];
		for (item = 1; item <= arrayCount; item++)
			[heap removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[heap addObject:anObject];
		startTime = timestamp();
		[heap removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[heap addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [heap objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
#if MAC_OS_X_VERSION_10_5_AND_LATER
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		for (id object in heap)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
#endif
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkTree(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHSearchTree> tree;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		printf("\t%-8d", [array count]);
	}	
	
	printf("\naddObject:          ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] init];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[tree addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nmember:         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] init];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[tree member:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nremoveObject:       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] init];
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
			[tree addObject:anObject];
		arrayCount = [array count];
		startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[tree removeObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
		for (id anObject in array)
#else
		objectEnumerator = [array objectEnumerator];
		while (anObject = [objectEnumerator nextObject])
#endif
			[tree addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [tree objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int size, item, limit = 100000;
	objects = [[NSMutableArray alloc] init];
	
	for (size = 10; size <= limit; size *= 10) {
		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:size+1];
		[array addObjectsFromArray:[objects lastObject]];
		for (item = [array count]+1; item <= size; item++)
			[array addObject:[NSNumber numberWithInt:item]];
		[objects addObject:array];
		[array release];
	}
	
	CHQuietLog(@"\n<CHDeque> Implemenations");
	benchmarkDeque([CHMutableArrayDeque class]);
	benchmarkDeque([CHListDeque class]);
	benchmarkDeque([CHCircularBufferDeque class]);
	
	CHQuietLog(@"\n<CHQueue> Implemenations");
	benchmarkQueue([CHMutableArrayQueue class]);
	benchmarkQueue([CHListQueue class]);
	benchmarkQueue([CHCircularBufferQueue class]);
	
	CHQuietLog(@"\n<CHStack> Implemenations");
	benchmarkStack([CHMutableArrayStack class]);
	benchmarkStack([CHListStack class]);
	benchmarkStack([CHCircularBufferStack class]);
	
	[objects release];
	
	
	// Create more disordered sets of values for testing heap and tree subclasses
	
	CHQuietLog(@"\n<CHSearchTree> Implemenations");
	
	NSArray *testClasses = [NSArray arrayWithObjects:
							[CHAnderssonTree class],
							[CHAVLTree class],
							[CHRedBlackTree class],
							[CHTreap class],
							[CHUnbalancedTree class],
							nil];
	NSMutableDictionary *treeResults = [NSMutableDictionary dictionary];
	NSMutableDictionary *dictionary;
	Class aClass;
	NSEnumerator *classEnumerator = [testClasses objectEnumerator];
	while (aClass = [classEnumerator nextObject]) {
		dictionary = [NSMutableDictionary dictionary];
		[dictionary setObject:[NSMutableArray array] forKey:@"addObject"];
		[dictionary setObject:[NSMutableArray array] forKey:@"member"];
		[dictionary setObject:[NSMutableArray array] forKey:@"removeObject"];
		if ([aClass conformsToProtocol:@protocol(CHSearchTree)])
			[dictionary setObject:[NSMutableArray array] forKey:@"height"];
		[treeResults setObject:dictionary forKey:[aClass className]];
	}
	
	NSMutableSet *objectSet = [NSMutableSet set];
	CHAbstractBinarySearchTree *tree;
	double startTime, duration;
	
	NSUInteger jitteredSize; // For making sure scatterplot dots not overlap
	NSInteger jitterOffset;
	
	limit = 100000;
	NSUInteger reps  = 20;
	NSUInteger scale = 1000000; // 10^6, which gives microseconds
	
	for (NSUInteger trial = 1; trial <= reps; trial++) {
		printf("\nPass %u / %u", trial, reps);
		for (NSUInteger size = 10; size <= limit; size *= 10) {
			printf("\n%8u objects --", size);
			// Create a set of N unique random numbers
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			while ([objectSet count] < size)
				[objectSet addObject:[NSNumber numberWithInt:arc4random()]];
			[pool drain];
			NSArray *objects = [objectSet allObjects];
			jitterOffset = -([testClasses count]/2);
			classEnumerator = [testClasses objectEnumerator];
			while (aClass = [classEnumerator nextObject]) {
				pool = [[NSAutoreleasePool alloc] init];
				printf(" %s", [[aClass className] UTF8String]);
				tree = [[aClass alloc] init];
				dictionary = [treeResults objectForKey:[aClass className]];
				jitteredSize = size + (size * .1 * jitterOffset++);
				
				// addObject:
				nanosleep(&sleepDelay, &sleepRemain);
				startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
				for (id anObject in objects)
#else
					objectEnumerator = [objects objectEnumerator];
				while (anObject = [objectEnumerator nextObject])
#endif
					[tree addObject:anObject];
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"addObject"] addObject:
				 [NSString stringWithFormat:@"%u,%f",
				  jitteredSize, duration/size*scale]];
				
				// containsObject:
				nanosleep(&sleepDelay, &sleepRemain);
				int index = 0;
				startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
				for (id anObject in objects)
#else
					objectEnumerator = [objects objectEnumerator];
				while (anObject = [objectEnumerator nextObject])
#endif
				{
					if (index++ % 4 != 0)
						continue;
					[tree containsObject:anObject];
				}
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"member"] addObject:
				 [NSString stringWithFormat:@"%u,%f",
				  jitteredSize, duration/size*scale]];
				
				// Maximum height
				if ([aClass conformsToProtocol:@protocol(CHSearchTree)])
					[[dictionary objectForKey:@"height"] addObject:
					 [NSString stringWithFormat:@"%u,%u",
					  jitteredSize, [tree height]]];
				
				// removeObject:
				nanosleep(&sleepDelay, &sleepRemain);
				startTime = timestamp();
#if MAC_OS_X_VERSION_10_5_AND_LATER
				for (id anObject in objectSet)
#else
				objectEnumerator = [objectSet objectEnumerator];
				while (anObject = [objectEnumerator nextObject])
#endif
					[tree removeObject:anObject];
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"removeObject"] addObject:
				 [NSString stringWithFormat:@"%u,%f", jitteredSize, duration/size*scale]];
				
				[tree release];
				[pool drain];
			}
		}
		[objectSet removeAllObjects];
	}
	
	NSString *path = @"../../benchmark_data/";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path])
#if MAC_OS_X_VERSION_10_5_AND_LATER
		[fileManager createDirectoryAtPath:path
			   withIntermediateDirectories:YES
								attributes:nil
									 error:NULL];
#else
		[fileManager createDirectoryAtPath:path
								attributes:nil];
#endif
	NSArray *results;
	NSEnumerator *classNames = [[treeResults allKeys] objectEnumerator], *operations;
	NSString *className, *operation;
	while (className = [classNames nextObject]) {
		NSDictionary *resultSet = [treeResults objectForKey:className];
		operations = [[resultSet allKeys] objectEnumerator];
		while (operation = [operations nextObject]) {
			results = [[resultSet objectForKey:operation]
					   sortedArrayUsingSelector:@selector(compare:)];
			[[results componentsJoinedByString:@"\n"]
			 writeToFile:[path stringByAppendingFormat:@"%@-%@.txt",
						  className, operation]
			 atomically:NO
			 encoding:NSUTF8StringEncoding
			 error:NULL];
		}
	}
	
	[pool drain];
	return 0;
}
