/*
 CHDataStructures.framework -- CHCircularBuffer.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHCircularBuffer.h
 
 A circular buffer array with simple built-in locking capabilities.
 */

/**
 A circular buffer array with simple built-in locking capabilities. A <a href="http://en.wikipedia.org/wiki/Circular_buffer">circular buffer</a> is a structure that emulates a continuous ring of N data slots, such that data can be appended without worrying about exceeding the valid indexes of an array. This class uses a C array with start and end indexes to track the front and back of the elements in the buffer. The array is dynamically expanded to accommodate added objects. This type of storage is ideal for scenarios where objects are added and removed only at one or both ends (such as a stack or queue) but still supports all normal NSMutableArray functionality.
 
 Since this class extends NSMutableArray, it or any of its children may be used anywhere an NSArray or NSMutableArray is required. It is designed to behave virtually identically to a standard NSMutableArray, but with the addition of built-in locking.
 
 This class adopts the CHLockable protocol to add simple built-in locking capabilities. An NSLock is used internally to coordinate the operation of multiple threads of execution within the same application, and methods are exposed to allow clients to manipulate the lock in simple ways. Since not all clients will use the lock, it is created lazily the first time a client attempts to acquire the lock.
*/
@interface CHCircularBuffer : NSMutableArray <CHLockable> {
	__strong id *array; /**< Primitive C array for storing collection contents. */
	NSUInteger arrayCapacity; /**< How many pointers @a array can accommodate. */
	NSUInteger count; /**< The number of objects currently in the buffer. */
	NSUInteger headIndex; /**< The array index of the first object. */
	NSUInteger tailIndex; /**< The array index after the last object. */
	unsigned long mutations; /**< Tracks mutations for NSFastEnumeration. */
	
	NSLock* lock; /**< A lock for synchronizing interaction between threads. */
}

// The following methods are undocumented since they are only reimplementations.
// Users should consult the API documentation for NSArray and NSMutableArray.

- (id) initWithArray:(NSArray*)anArray;

- (NSArray*) allObjects;
- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (id) firstObject;
- (NSUInteger) indexOfObject:(id)anObject;
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;
- (id) lastObject;
- (NSEnumerator*) objectEnumerator;
- (NSArray*) objectsAtIndexes:(NSIndexSet*)indexes;
- (void) removeAllObjects;
- (void) removeFirstObject;
- (void) removeLastObject;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;
- (void) removeObjectsAtIndexes:(NSIndexSet*)indexes;
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (NSEnumerator*) reverseObjectEnumerator;

#pragma mark Adopted Protocols

- (void) encodeWithCoder:(NSCoder*)encoder;
- (id) initWithCoder:(NSCoder*)decoder;
- (id) copyWithZone:(NSZone*)zone;
#if OBJC_API_2
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;
#endif

@end
