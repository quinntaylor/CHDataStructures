//  Benchmarks.m
//  CHDataStructures.framework

#import <Foundation/Foundation.h>
#import <CHDataStructures/CHDataStructures.h>
#import <sys/time.h>

static NSMutableArray *testArrays;
static NSUInteger item, arrayCount;
struct timeval timeOfDay;
static double startTime;

/* Return the current time in seconds, using a double precision number. */
double timestamp() {
	gettimeofday(&timeOfDay, NULL);
	return ((double) timeOfDay.tv_sec + (double) timeOfDay.tv_usec * 1e-6);
}

void benchmarkDeque(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n* %@", testClass);
	
	id<CHDeque> deque;
	
	printf("(Operation)         ");
	for (NSArray *array in testArrays)
		printf("\t%-8d", [array count]);

	printf("\nprependObject:    ");
	for (NSArray *array in testArrays) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[deque prependObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nappendObject:     ");
	for (NSArray *array in testArrays) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[deque appendObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveFirstObject: ");
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
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
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkQueue(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n* %@", testClass);
	
	id<CHQueue> queue;
	
	printf("(Operation)         ");
	for (NSArray *array in testArrays)
		printf("\t%-8d", [array count]);
	
	printf("\naddObject:         ");
	for (NSArray *array in testArrays) {
		queue = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[queue addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		[queue removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
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
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkStack(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n%@", testClass);
	
	id<CHStack> stack;
	
	printf("(Operation)         ");
	for (NSArray *array in testArrays)
		printf("\t%-8d", [array count]);
	
	printf("\npushObject:       ");
	for (NSArray *array in testArrays) {
		stack = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[stack pushObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\npopObject:        ");
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		[stack removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		for (id object in stack)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkHeap(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n%@", testClass);

	id<CHHeap> heap;

	printf("(Operation)         ");
	for (NSArray *array in testArrays)
		printf("\t%-8d", [array count]);
	
	printf("\naddObject:         ");
	for (NSArray *array in testArrays) {
		heap = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[heap addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		[heap removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	printf("\nNSEnumerator       ");
	for (NSArray *array in testArrays) {
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
	for (NSArray *array in testArrays) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		for (id object in heap)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkTree(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n%@", testClass);
	
	id<CHTree> tree;
	
	printf("(Operation)         ");
	for (NSArray *array in testArrays) {
		printf("\t%-8d", [array count]);
	}	
	
	printf("\nNSEnumerator       ");
	for (NSArray *array in testArrays) {
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
	
	QuietLog(@"");
	[pool drain];
}

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSUInteger size, item, limit = 1000000;
	testArrays = [[NSMutableArray alloc] init];
	for (size = 1; size <= limit; size *= 10) {
		NSMutableArray *array = (size == 1)
			? [[NSMutableArray alloc] init]
			: [[testArrays lastObject] mutableCopy]; // reuse elements in previous
		for (item = [array count]+1; item <= size; item++)
			[array addObject:[NSNumber numberWithUnsignedInteger:item]];
		[testArrays addObject:array];
		[array release];
	}
	
	QuietLog(@"\n<Deque> Implemenations");
	benchmarkDeque([CHMutableArrayDeque class]);
	benchmarkDeque([CHListDeque class]);

	QuietLog(@"\n<Queue> Implemenations");
	benchmarkQueue([CHMutableArrayQueue class]);
	benchmarkQueue([CHListQueue class]);

	QuietLog(@"\n<Stack> Implemenations");
	benchmarkStack([CHMutableArrayStack class]);
	benchmarkStack([CHListStack class]);

	QuietLog(@"\n<Heap> Implemenations");
	benchmarkHeap([CHMutableArrayHeap class]);

//	QuietLog(@"\n<Tree> Implemenations");
//	benchmarkTree([CHUnbalancedTree class]);
//	benchmarkTree([CHAnderssonTree class]);
//	benchmarkTree([CHRedBlackTree class]);
	
	[testArrays release];

	[pool drain];
	return 0;
}
