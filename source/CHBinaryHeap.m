//
//  CHBinaryHeap.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHBinaryHeap.h>

#pragma mark CFBinaryHeap callbacks

const void * CHBinaryHeapRetain(CFAllocatorRef allocator, const void *value) {
	return [(id)value retain];
}

void CHBinaryHeapRelease(CFAllocatorRef allocator, const void *value) {
	[(id)value release];
}

CFStringRef CHBinaryHeapCopyDescription(const void *value) {
	return CFRetain([(id)value description]);
}

CFComparisonResult CHBinaryHeapCompareAscending(const void *value1, const void *value2, void *info) {
	return (CFComparisonResult)[(id)value1 compare:(id)value2];
}

CFComparisonResult CHBinaryHeapCompareDescending(const void *value1, const void *value2, void *info) {
	return [(id)value1 compare:(id)value2] * -1;
}

static const CFBinaryHeapCallBacks kCHBinaryHeapCallBacksAscending = {
	0, // default version
	CHBinaryHeapRetain,
	CHBinaryHeapRelease,
	CHBinaryHeapCopyDescription,
	CHBinaryHeapCompareAscending
};

static const CFBinaryHeapCallBacks kCHBinaryHeapCallBacksDescending = {
	0, // default version
	CHBinaryHeapRetain,
	CHBinaryHeapRelease,
	CHBinaryHeapCopyDescription,
	CHBinaryHeapCompareDescending
};

#pragma mark -

@implementation CHBinaryHeap

- (void)dealloc {
	CFRelease(heap); // The heap will never be null at this point.
	[super dealloc];
}

- (instancetype)init {
	return [self initWithOrdering:NSOrderedAscending array:@[]];
}

- (instancetype)initWithArray:(NSArray *)anArray {
	return [self initWithOrdering:NSOrderedAscending array:anArray];
}

- (instancetype)initWithOrdering:(NSComparisonResult)order {
	return [self initWithOrdering:order array:@[]];
}

// This is the designated initializer
- (instancetype)initWithOrdering:(NSComparisonResult)order array:(NSArray *)anArray {
	if ((self = [super init]) == nil) return nil;
	sortOrder = order;
	if (sortOrder == NSOrderedAscending) {
		heap = CFBinaryHeapCreate(kCFAllocatorDefault, 0, &kCHBinaryHeapCallBacksAscending, NULL);
	} else if (sortOrder == NSOrderedDescending) {
		heap = CFBinaryHeapCreate(kCFAllocatorDefault, 0, &kCHBinaryHeapCallBacksDescending, NULL);
	} else {
		CHRaiseInvalidArgumentException(@"Invalid sort order.");
	}
	[self addObjectsFromArray:anArray];
	return self;
}

#pragma mark Querying Contents

- (NSArray *)allObjects {
	return [self allObjectsInSortedOrder];
}

- (NSArray *)allObjectsInSortedOrder {
	NSUInteger count = [self count];
	void *values = malloc(kCHPointerSize * count);
	CFBinaryHeapGetValues(heap, values);
	NSArray *objects = [NSArray arrayWithObjects:values count:count];
	free(values);
	return objects;
}

- (BOOL)containsObject:(id)anObject {
	return CFBinaryHeapContainsValue(heap, anObject);
}

- (NSUInteger)count {
	return CFBinaryHeapGetCount(heap);
}

- (NSString *)description {
	return [[self allObjectsInSortedOrder] description];
}

- (NSString *)debugDescription {
	CFStringRef description = CFCopyDescription(heap);
	CFRelease([(id)description retain]);
	return [(id)description autorelease];
}

- (id)firstObject {
	return (id)CFBinaryHeapGetMinimum(heap);
}

- (NSUInteger)hash {
	id anObject = [self firstObject];
	return CHHashOfCountAndObjects([self count], anObject, anObject);
}

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHHeap)]) {
		return [self isEqualToHeap:otherObject];
	} else {
		return NO;
	}
}

- (BOOL)isEqualToHeap:(id<CHHeap>)otherHeap {
	return CHCollectionsAreEqual(self, otherHeap);
}

- (NSEnumerator *)objectEnumerator {
	return [[self allObjectsInSortedOrder] objectEnumerator];
}

#pragma mark Modifying Contents

- (void)addObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	CFBinaryHeapAddValue(heap, anObject);
	++mutations;
}

- (void)addObjectsFromArray:(NSArray *)anArray {
	if ([anArray count] == 0) { // includes implicit check for nil array
		return;
	}
	for (id anObject in anArray) {
		CFBinaryHeapAddValue(heap, anObject);
	}
	++mutations;
}

- (void)removeAllObjects {
	CFBinaryHeapRemoveAllValues(heap);
	++mutations;
}

- (void)removeFirstObject {
	CFBinaryHeapRemoveMinimumValue(heap);
	++mutations;
}

#pragma mark <NSCoding>

- (instancetype)initWithCoder:(NSCoder *)decoder {
	return [self initWithOrdering:([decoder decodeBoolForKey:@"sortAscending"]
	                               ? NSOrderedAscending : NSOrderedDescending)
	                        array:[decoder decodeObjectForKey:@"objects"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:[self allObjectsInSortedOrder] forKey:@"objects"];
	[encoder encodeBool:(sortOrder == NSOrderedAscending) forKey:@"sortAscending"];
}

#pragma mark <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
	return [[CHBinaryHeap alloc] initWithArray:[self allObjects]];
}

#pragma mark <NSFastEnumeration>

// This overridden method returns the heap contents in fully-sorted order.
// Just as -objectEnumerator above, the first call incurs a hidden sorting cost.
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	// Currently (in Leopard) NSEnumerators from NSArray only return 1 each time
	if (state->state == 0) {
		// Create a sorted array to use for enumeration, store it in the state.
		state->extra[4] = (unsigned long) [self allObjectsInSortedOrder];
	}
	NSArray *sorted = (NSArray *) state->extra[4];
	NSUInteger count = [sorted countByEnumeratingWithState:state
	                                               objects:stackbuf
	                                                 count:len];
	state->mutationsPtr = &mutations; // point state to mutations for heap array
	return count;
}

@end
