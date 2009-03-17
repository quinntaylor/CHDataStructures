//  Benchmarks.m
//  CHDataStructures.framework

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
	for (NSArray *array in objects)
		printf("\t%-8d", [array count]);
	
	printf("\nprependObject:    ");
	for (NSArray *array in objects) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[deque prependObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nappendObject:     ");
	for (NSArray *array in objects) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[deque appendObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveFirstObject: ");
	for (NSArray *array in objects) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		for (item = 1; item <= arrayCount; item++)
			[deque removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveLastObject:  ");
	for (NSArray *array in objects) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		for (item = 1; item <= arrayCount; item++)
			[deque removeLastObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray *array in objects) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		[deque removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray *array in objects) {
		deque = [[testClass alloc] init];
		arrayCount = [array count];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [deque objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray *array in objects) {
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
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkQueue(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n* %@", testClass);
	
	id<CHQueue> queue;
	
	printf("(Operation)         ");
	for (NSArray *array in objects)
		printf("\t%-8d", [array count]);
	
	printf("\naddObject:         ");
	for (NSArray *array in objects) {
		queue = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[queue addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (NSArray *array in objects) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		arrayCount = [array count];
		for (item = 1; item <= arrayCount; item++)
			[queue removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray *array in objects) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		[queue removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray *array in objects) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [queue objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray *array in objects) {
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
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkStack(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHStack> stack;
	
	printf("(Operation)         ");
	for (NSArray *array in objects)
		printf("\t%-8d", [array count]);
	
	printf("\npushObject:       ");
	for (NSArray *array in objects) {
		stack = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[stack pushObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\npopObject:        ");
	for (NSArray *array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		arrayCount = [array count];
		for (item = 1; item <= arrayCount; item++)
			[stack popObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray *array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		[stack removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray *array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [stack objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray *array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		for (id object in stack)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkHeap(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHHeap> heap;
	
	printf("(Operation)         ");
	for (NSArray *array in objects)
		printf("\t%-8d", [array count]);
	
	printf("\naddObject:          ");
	for (NSArray *array in objects) {
		heap = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[heap addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (NSArray *array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		arrayCount = [array count];
		for (item = 1; item <= arrayCount; item++)
			[heap removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray *array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		[heap removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	printf("\nNSEnumerator       ");
	for (NSArray *array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [heap objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray *array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		for (id object in heap)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkTree(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHSearchTree> tree;
	
	printf("(Operation)         ");
	for (NSArray *array in objects) {
		printf("\t%-8d", [array count]);
	}	
	
	printf("\naddObject:          ");
	for (NSArray *array in objects) {
		tree = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[tree addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nfindObject:         ");
	for (NSArray *array in objects) {
		tree = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[tree findObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nremoveObject:       ");
	for (NSArray *array in objects) {
		tree = [[testClass alloc] init];
		for (id anObject in array)
			[tree addObject:anObject];
		arrayCount = [array count];
		startTime = timestamp();
		for (id anObject in array)
			[tree removeObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray *array in objects) {
		tree = [[testClass alloc] init];
		for (id anObject in array)
			[tree addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [tree objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUInteger size, item, limit = 100000;
	objects = [[NSMutableArray alloc] init];
	
	for (size = 10; size <= limit; size *= 10) {
		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:size+1];
		[array addObjectsFromArray:[objects lastObject]];
		for (item = [array count]+1; item <= size; item++)
			[array addObject:[NSNumber numberWithUnsignedInteger:item]];
		[objects addObject:array];
		[array release];
	}
	
	CHQuietLog(@"\n<CHDeque> Implemenations");
	benchmarkDeque([CHMutableArrayDeque class]);
	benchmarkDeque([CHListDeque class]);
	
	CHQuietLog(@"\n<CHQueue> Implemenations");
	benchmarkQueue([CHMutableArrayQueue class]);
	benchmarkQueue([CHListQueue class]);
	
	CHQuietLog(@"\n<CHStack> Implemenations");
	benchmarkStack([CHMutableArrayStack class]);
	benchmarkStack([CHListStack class]);
	
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
	for (Class aClass in testClasses) {
		dictionary = [NSMutableDictionary dictionary];
		[dictionary setObject:[NSMutableArray array] forKey:@"addObject"];
		[dictionary setObject:[NSMutableArray array] forKey:@"findObject"];
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
			for (Class aClass in testClasses) {
				pool = [[NSAutoreleasePool alloc] init];
				printf(" %s", [[aClass className] UTF8String]);
				tree = [[aClass alloc] init];
				dictionary = [treeResults objectForKey:[aClass className]];
				jitteredSize = size + (size * .1 * jitterOffset++);
				
				// addObject:
				nanosleep(&sleepDelay, &sleepRemain);
				startTime = timestamp();
				for (id anObject in objects)
					[tree addObject:anObject];
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"addObject"] addObject:
				 [NSString stringWithFormat:@"%u,%f",
				  jitteredSize, duration/size*scale]];
				
				// findObject:
				nanosleep(&sleepDelay, &sleepRemain);
				int index = 0;
				startTime = timestamp();
				for (id anObject in objects) {
					if (index++ % 4 != 0)
						continue;
					[tree containsObject:anObject];
				}
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"findObject"] addObject:
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
				for (id anObject in objectSet)
					[tree removeObject:anObject];
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"removeObject"] addObject:
				 [NSString stringWithFormat:@"%u,%f",
				  jitteredSize, duration/size*scale]];
				
				[tree release];
				[pool drain];
			}
		}
		[objectSet removeAllObjects];
	}
	
	NSString *path = @"../../benchmark_data/";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path])
		[fileManager createDirectoryAtPath:path
			   withIntermediateDirectories:YES
								attributes:nil
									 error:NULL];
	NSArray *results;
	for (NSString *treeClass in [treeResults allKeys]) {
		NSDictionary *resultSet = [treeResults objectForKey:treeClass];
		for (NSString *operation in [resultSet allKeys]) {
			results = [[resultSet objectForKey:operation]
					   sortedArrayUsingSelector:@selector(compare:)];
			[[results componentsJoinedByString:@"\n"]
			 writeToFile:[path stringByAppendingFormat:@"%@-%@.txt",
						  treeClass, operation]
			 atomically:NO
			 encoding:NSUTF8StringEncoding
			 error:NULL];
		}
	}
	
	[pool drain];
	return 0;
}
