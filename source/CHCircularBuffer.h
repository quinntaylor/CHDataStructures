//
//  CHCircularBuffer.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHUtil.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @file CHCircularBuffer.h
 
 A circular buffer array.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Circular_buffer">circular buffer</a> is a structure that emulates a continuous ring of N data slots. This class uses a C array and tracks the indexes of the front and back elements in the buffer, such that the first element is treated as logical index 0 regardless of where it is actually stored. The buffer dynamically expands to accommodate added objects. This type of storage is ideal for scenarios where objects are added and removed only at one or both ends (such as a stack or queue) but still supports all normal NSMutableArray functionality.
 
 @note Any method inherited from NSArray or NSMutableArray is supported by this class and its children. Please see the documentation for those classes for details.
*/
@interface CHCircularBuffer<__covariant ObjectType> : NSMutableArray
{
	__strong id *array; // Primitive C array for storing collection contents.
	NSUInteger arrayCapacity; // How many pointers @a array can accommodate.
	NSUInteger count; // The number of objects currently in the buffer.
	NSUInteger headIndex; // The array index of the first object.
	NSUInteger tailIndex; // The array index after the last object.
	unsigned long mutations; // Tracks mutations for NSFastEnumeration.
}

- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER; // Inherited from NSMutableArray

- (NSArray<ObjectType> *)allObjects;
- (BOOL)containsObjectIdenticalTo:(ObjectType)anObject;
- (void)removeFirstObject;
- (void)removeLastObject;

@end

NS_ASSUME_NONNULL_END
