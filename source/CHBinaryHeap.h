//
//  CHBinaryHeap.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHHeap.h>

/**
 @file CHBinaryHeap.h
 A CHHeap implemented using a CFBinaryHeapRef internally.
 */

/**
 A CHHeap implemented using a CFBinaryHeapRef internally.
 */
@interface CHBinaryHeap<__covariant ObjectType> : NSObject <CHHeap>
{
	CFBinaryHeapRef heap; // Used for storing objects in the heap.
	NSComparisonResult sortOrder; // Whether to sort objects ascending or not.
	unsigned long mutations; // Used to track mutations for NSFastEnumeration.
}

- (instancetype)initWithOrdering:(NSComparisonResult)order array:(NSArray<ObjectType> *)array NS_DESIGNATED_INITIALIZER;

@end
