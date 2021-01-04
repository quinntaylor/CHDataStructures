//
//  CHMutableArrayHeap.h
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <CHDataStructures/CHHeap.h>

/**
 @file CHMutableArrayHeap.h
 A simple CHHeap implemented as a subclass of NSMutableArray.
 */

/**
 A simple CHHeap implemented as a subclass of NSMutableArray.
 */
@interface CHMutableArrayHeap : NSMutableArray <CHHeap> {
	NSMutableArray *array; // An array to use for storing objects in the heap.
	NSComparisonResult sortOrder; // Whether to sort objects ascending or not.
	unsigned long mutations; // Used to track mutations for NSFastEnumeration.
}

- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER; // Inherited from NSMutableArray
- (instancetype)initWithOrdering:(NSComparisonResult)order array:(NSArray *)array NS_DESIGNATED_INITIALIZER;

/**
 Determine whether the receiver contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the heap.
 @return @c YES if @a anObject is in the heap, @c NO if it is @c nil or not present.
 
 @see containsObject:
 @see removeObjectIdenticalTo:
 */
- (BOOL)containsObjectIdenticalTo:(id)anObject;

/**
 Remove @b all occurrences of @a anObject, matched using @c isEqual:.
 
 @param anObject The object to be removed from the heap.
 
 If the heap is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @see containsObject;
 @see removeAllObjects
 @see removeObjectIdenticalTo:
 */
- (void)removeObject:(id)anObject;

/**
 Remove @b all occurrences of @a anObject, matched using the == operator.
 
 @param anObject The object to be removed from the heap.
 
 If the heap is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @see containsObjectIdenticalTo:
 @see removeAllObjects
 @see removeObject:
 */
- (void)removeObjectIdenticalTo:(id)anObject;
	
@end
