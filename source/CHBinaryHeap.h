/*
 CHDataStructures.framework -- CHBinaryHeap.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHHeap.h>

/**
 @file CHBinaryHeap.h
 A CHHeap implemented using a CFBinaryHeapRef internally.
 */

/**
 A CHHeap implemented using a CFBinaryHeapRef internally.
 */
@interface CHBinaryHeap : NSObject <CHHeap> {
	CFBinaryHeapRef heap; // Used for storing objects in the heap.
	NSComparisonResult sortOrder; // Whether to sort objects ascending or not.
	unsigned long mutations; // Used to track mutations for NSFastEnumeration.
}

- (instancetype)initWithOrdering:(NSComparisonResult)order array:(NSArray *)array NS_DESIGNATED_INITIALIZER;

@end
