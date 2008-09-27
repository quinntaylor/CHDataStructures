//  AbstractQueue.m
//  DataStructuresFramework

#import "AbstractQueue.h"

@implementation AbstractQueue

- (void) enqueue:(id)anObject {
	[NSException raise:NSInternalInconsistencyException
	            format:@"-[%@ %s] -- Unsupported operation.",
	                   [self class], sel_getName(_cmd)];
}

- (id) dequeue {
	[NSException raise:NSInternalInconsistencyException
	            format:@"-[%@ %s] -- Unsupported operation.",
	                   [self class], sel_getName(_cmd)];
	return nil;
}

- (id) front {
	[NSException raise:NSInternalInconsistencyException
	            format:@"-[%@ %s] -- Unsupported operation.",
	                   [self class], sel_getName(_cmd)];
	return nil;
}

- (NSUInteger) count {
	[NSException raise:NSInternalInconsistencyException
	            format:@"-[%@ %s] -- Unsupported operation.",
	                   [self class], sel_getName(_cmd)];	
	return -1;
}

- (void) removeAllObjects {
}

+ (id<Queue>) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction;
{
	if (array == nil)
		return nil;
	
	id<Queue> queue = [[self alloc] init];
	
	// Order to dequeue will be from 0...n
	if (direction)
		for (id object in [array objectEnumerator])
			[queue enqueue:object];
	// Order to dequeue will be from n...0
	else
		for (id object in [array reverseObjectEnumerator])
			[queue enqueue:object];
	return [queue autorelease];
}

@end
