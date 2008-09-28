//  AbstractStack.m
//  DataStructuresFramework

#import "AbstractStack.h"

@implementation AbstractStack

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

- (void) pushObject:(id)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (id) popObject {
	[self exceptionForUnsupportedOperation:_cmd];
	return nil;
}

- (id) topObject {
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
	[self exceptionForUnsupportedOperation:_cmd];
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

+ (id<Stack>) stackWithArray:(NSArray *)array byReversingOrder:(BOOL)reverseOrder {
	if (array == nil)
		return nil;
	id<Stack> stack = [[self alloc] init];
	
	// Order in which elements are popped will be (0...n)
	if (reverseOrder)
		for (id object in [array reverseObjectEnumerator])
			[stack pushObject:object];
	// Order in which elements are popped will be (n...0)
	else
		for (id object in [array objectEnumerator])
			[stack pushObject:object];
	return [stack autorelease];
}

@end
