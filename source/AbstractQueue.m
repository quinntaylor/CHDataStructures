//  AbstractQueue.m
//  DataStructuresFramework

#import "AbstractQueue.h"

@implementation AbstractQueue

+ (id) exceptionForUnsupportedOperation:(SEL)operation {
	[NSException raise:NSInternalInconsistencyException
				format:@"+[%@ %s] -- Unsupported operation.",
					   [self class], sel_getName(operation)];
	return nil;
}

- (id) exceptionForUnsupportedOperation:(SEL)operation {
	[NSException raise:NSInternalInconsistencyException
				format:@"-[%@ %s] -- Unsupported operation.",
					   [self class], sel_getName(operation)];
	return nil;
}

- (id) exceptionForInvalidArgument:(SEL)operation {
	[NSException raise:NSInvalidArgumentException
				format:@"-[%@ %s] -- Invalid nil argument.",
					   [self class], sel_getName(operation)];
	return nil;
}

#pragma mark Default Implementations

- (void) enqueueObject:(id)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (id) dequeueObject {
	[self exceptionForUnsupportedOperation:_cmd];
	return nil;
}

- (id) frontObject {
	[self exceptionForUnsupportedOperation:_cmd];
	return nil;
}

- (NSUInteger) count {
	[self exceptionForUnsupportedOperation:_cmd];	
	return -1;
}

- (void) removeAllObjects {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (NSEnumerator *)objectEnumerator {
	[NSException raise:NSInternalInconsistencyException
				format:@"-[%@ %s] -- Unsupported operation.",
	                   [self class], sel_getName(_cmd)];
	return nil;	
}

- (NSArray *) contentsAsArrayByReversingOrder:(BOOL)reverseOrder {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	if (reverseOrder) {
		for (id object in [self objectEnumerator])
			[array insertObject:object atIndex:0];
	} else {
		for (id object in [self objectEnumerator])
			[array addObject:object];
	}
	return [array autorelease];
}

+ (id<Queue>) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction;
{
	if (array == nil)
		return nil;
	
	id<Queue> queue = [[self alloc] init];
	
	// Order to dequeue will be from 0...n
	if (direction)
		for (id object in [array objectEnumerator])
			[queue enqueueObject:object];
	// Order to dequeue will be from n...0
	else
		for (id object in [array reverseObjectEnumerator])
			[queue enqueueObject:object];
	return [queue autorelease];
}

@end
