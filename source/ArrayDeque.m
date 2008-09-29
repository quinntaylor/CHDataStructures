//  ArrayDeque.m
//  DataStructuresFramework

#import "ArrayDeque.h"

@implementation ArrayDeque

- (id) init {
	return [self initWithObjectsFromEnumerator:nil];
}

- (id) initWithObjectsFromEnumerator:(NSEnumerator*)anEnumerator {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	if (anEnumerator != nil)
		array = [[anEnumerator allObjects] mutableCopy];
	else
		array = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc {
	[array release];
	[super dealloc];
}

- (void) addObjectToFront:(id)anObject {
	[array insertObject:anObject atIndex:0];
}

- (void) addObjectToBack:(id)anObject {
	[array addObject:anObject];
}

- (id) firstObject {
	return [array objectAtIndex:0];
}

- (id) lastObject {
	return [array lastObject];
}

- (NSArray*) allObjects {
	return [array copy];
}


- (void) removeFirstObject {
	[array removeObjectAtIndex:0];
}

- (void) removeLastObject {
	[array removeLastObject];
}

- (void) removeAllObjects {
	[array removeAllObjects];
}


- (BOOL) containsObject:(id)anObject {
	return [array containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([array indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger) count {
	return [array count];
}

@end
