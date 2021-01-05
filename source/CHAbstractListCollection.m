//
//  CHAbstractListCollection.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <CHDataStructures/CHAbstractListCollection.h>

@implementation CHAbstractListCollection

- (void)dealloc {
	[list release];
	[super dealloc];
}

- (instancetype)init {
	return [self initWithArray:@[]];
}

- (instancetype)initWithArray:(NSArray *)anArray {
	self = [super init];
	if (self == nil) return nil;
	list = [self _createList];
	for (id anObject in anArray) {
		[list addObject:anObject];
	}
	return self;
}

// Child classes must override to provide a value for the "list" instance variable.
- (id<CHLinkedList>)_createList {
	CHRaiseUnsupportedOperationException();
	return nil;
}

#pragma mark <NSCoding>

- (instancetype)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init]) == nil) return nil;
	list = [[decoder decodeObjectForKey:@"list"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:list forKey:@"list"];
}

#pragma mark <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
	id copy = [[[self class] allocWithZone:zone] init];
	for (id anObject in self) {
		[copy addObject:anObject];
	}
	return copy;
}

#pragma mark <NSFastEnumeration>

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	return [list countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark -

- (NSUInteger)count {
	return [list count];
}

- (BOOL)containsObject:(id)anObject {
	return [list containsObject:anObject];
}

- (BOOL)containsObjectIdenticalTo:(id)anObject {
	return [list containsObjectIdenticalTo:anObject];
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	[list exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (NSUInteger)hash {
	return CHHashOfCountAndObjects([list count], [list firstObject], [list lastObject]);
}

- (NSUInteger)indexOfObject:(id)anObject {
	return [list indexOfObject:anObject];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
	return [list indexOfObjectIdenticalTo:anObject];
}

- (id)objectAtIndex:(NSUInteger)index {
	return [list objectAtIndex:index];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
	return [list objectsAtIndexes:indexes];
}

- (void)removeObject:(id)anObject {
	[list removeObject:anObject];
}

- (void)removeObjectIdenticalTo:(id)anObject {
	[list removeObjectIdenticalTo:anObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
	[list removeObjectAtIndex:index];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
	[list removeObjectsAtIndexes:indexes];
}

- (void)removeAllObjects {
	[list removeAllObjects];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	[list replaceObjectAtIndex:index withObject:anObject];
}

- (NSArray *)allObjects {
	return [list allObjects];
}

- (NSEnumerator *)objectEnumerator {
	return [list objectEnumerator];
}

- (NSString *)description {
	return [list description];
}

@end
