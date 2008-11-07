//  Benchmarks.m
//  CHDataStructures.framework

#import <Foundation/Foundation.h>
#import <CHDataStructures/CHDataStructures.h>
#import <sys/time.h>

static NSMutableArray *objects;
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHTree> tree;
	
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSUInteger size, item, limit = 100000;
	objects = [[NSMutableArray alloc] init];
	
/*
	for (size = 1; size <= limit; size *= 10) {
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
*/	
	// Create more disordered arrays of values for testing heap and tree subclasses
	[objects removeAllObjects];
	for (size = 1; size <= limit; size *= 10) {
		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:size+1];
		for (item = 1; item <= size; item++)
			[array addObject:[NSNumber numberWithUnsignedInteger:(item*7%size)]];
		[objects addObject:array];
		[array release];
	}

	CHQuietLog(@"\n<CHTree> Implemenations");
	benchmarkTree([CHAnderssonTree class]);
	benchmarkTree([CHAVLTree class]);
	benchmarkTree([CHRedBlackTree class]);
	benchmarkTree([CHTreap class]);
	//	benchmarkTree([CHUnbalancedTree class]);
	
	CHQuietLog(@"\n<CHHeap> Implemenations");
	benchmarkHeap([CHMutableArrayHeap class]);

	CHQuietLog(@"");
	[objects release];

	[pool drain];
	return 0;
}
