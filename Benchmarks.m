//  Benchmarks.m
//  DataStructures.framework

#import <Foundation/Foundation.h>
#import <DataStructures/DataStructures.h>
#import <sys/time.h>

static NSUInteger limit = 1000000;
struct timeval timeOfDay;
static double startTime;

/* Return the current time in seconds, using a double precision number. */
double timestamp() {
	gettimeofday(&timeOfDay, NULL);
	return ((double) timeOfDay.tv_sec + (double) timeOfDay.tv_usec * 1e-6);
}

void benchmarkDeque(Class testClass) {
	QuietLog(@"\n* %@", testClass);
	
	id<Deque> deque;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	

	printf("\nprependObject:    ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque prependObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nappendObject:     ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveFirstObject: ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveLastObject:  ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque removeLastObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}

	printf("\nremoveAllObjects:  ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		[deque removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}

	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [deque objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (id object in deque)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	QuietLog(@"");
}

void benchmarkQueue(Class testClass) {
	QuietLog(@"\n* %@", testClass);
	
	id<Queue> queue;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	
	
	printf("\nenqueueObject:    ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[queue enqueueObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\ndequeueObject:    ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue enqueueObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[queue dequeueObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue enqueueObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		[queue removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue enqueueObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [queue objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue enqueueObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (id object in queue)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	QuietLog(@"");
}

void benchmarkStack(Class testClass) {
	QuietLog(@"\n%@", testClass);
	
	id<Stack> stack;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	
	
	printf("\npushObject:       ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\npopObject:        ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[stack popObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		[stack removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [stack objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (id object in stack)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	QuietLog(@"");
}

void benchmarkTree(Class testClass) {
	QuietLog(@"\n%@", testClass);
	
	id<Tree> tree;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	
	
	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		tree = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[tree addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [tree objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	QuietLog(@"");
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	QuietLog(@"\n<Deque> Implemenations");
	benchmarkDeque([ArrayDeque class]);
	benchmarkDeque([ListDeque class]);

	QuietLog(@"\n<Queue> Implemenations");
	benchmarkQueue([ArrayQueue class]);
	benchmarkQueue([ListQueue class]);

	QuietLog(@"\n<Stack> Implemenations");
	benchmarkStack([ArrayStack class]);
	benchmarkStack([ListStack class]);

//	QuietLog(@"\n<Tree> Implemenations");
//	benchmarkTree([UnbalancedTree class]);
//	benchmarkTree([RedBlackTree class]);
//	benchmarkTree([AATree class]);

    [pool drain];
    return 0;
}
