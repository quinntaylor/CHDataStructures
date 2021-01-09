//
//  CHOrderedSet.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHOrderedSet.h>
#import <CHDataStructures/CHCircularBuffer.h>

@implementation CHOrderedSet

- (void)dealloc {
	[ordering release];
	[super dealloc];
}

- (instancetype)init {
	return [self initWithCapacity:0];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
	if ((self = [super initWithCapacity:numItems]) == nil) return nil;
	ordering = [[CHCircularBuffer alloc] initWithCapacity:numItems];
	return self;
}

#pragma mark Querying Contents

- (NSArray *)allObjects {
	return [ordering allObjects];
}

- (id)firstObject {
	return [ordering firstObject];
}

- (NSUInteger)hash {
	return [ordering hash];
}

- (NSUInteger)indexOfObject:(id)anObject {
	return [ordering indexOfObject:anObject];
}

- (BOOL)isEqualToOrderedSet:(CHOrderedSet *)otherOrderedSet {
	return CHCollectionsAreEqual(self, otherOrderedSet);
}

- (id)lastObject {
	return [ordering lastObject];
}

- (id)objectAtIndex:(NSUInteger)index {
	return [ordering objectAtIndex:index];
}

- (NSEnumerator *)objectEnumerator {
	return [ordering objectEnumerator];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
	CHRaiseInvalidArgumentExceptionIfNil(indexes);
	if ([indexes count] == 0) {
		return @[];
	}
	CHRaiseIndexOutOfRangeExceptionIf([indexes lastIndex], >=, [self count]);
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[self count]];
	NSUInteger index = [indexes firstIndex];
	while (index != NSNotFound) {
		[objects addObject:[self objectAtIndex:index]];
		index = [indexes indexGreaterThanIndex:index];
	}
	return objects;
}

- (CHOrderedSet *)orderedSetWithObjectsAtIndexes:(NSIndexSet *)indexes {
	CHRaiseInvalidArgumentExceptionIfNil(indexes);
	if ([indexes count] == 0) {
		return [[self class] set];
	}
	CHOrderedSet *newSet = [[self class] setWithCapacity:[indexes count]];
	NSUInteger index = [indexes firstIndex];
	while (index != NSNotFound) {
		[newSet addObject:[ordering objectAtIndex:index]];
		index = [indexes indexGreaterThanIndex:index];
	}
	return newSet;
}

#pragma mark Modifying Contents

- (void)addObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	if (![self containsObject:anObject]) {
		[ordering addObject:anObject];
	}
	[super addObject:anObject];
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	[ordering exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
	CHRaiseIndexOutOfRangeExceptionIf(index, >, [self count]);
	if ([self containsObject:anObject]) {
		[ordering removeObject:anObject];
	}
	[ordering insertObject:anObject atIndex:index];
	[super addObject:anObject];
}

- (void)removeAllObjects {
	[super removeAllObjects];
	[ordering removeAllObjects];
}

- (void)removeFirstObject {
	[self removeObject:[ordering firstObject]];
}

- (void)removeLastObject {
	[self removeObject:[ordering lastObject]];
}

- (void)removeObject:(id)anObject {
	[super removeObject:anObject];
	[ordering removeObject:anObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
	[super removeObject:[ordering objectAtIndex:index]];
	[ordering removeObjectAtIndex:index];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
	[(NSMutableSet *)set minusSet:[NSSet setWithArray:[self objectsAtIndexes:indexes]]];
	[ordering removeObjectsAtIndexes:indexes];
}

#pragma mark <NSFastEnumeration>

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	return [ordering countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
