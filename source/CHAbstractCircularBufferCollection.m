/*
 CHDataStructures.framework -- CHAbstractCircularBufferCollection.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHAbstractCircularBufferCollection.h"

static size_t kCHPointerSize = sizeof(void*);

/**
 An NSEnumerator for traversing a CHAbstractCircularBufferCollection subclass.
 
 Enumerators encapsulate their own state, and more than one may be active at once.
 However, like an enumerator for a mutable data structure, any instances of this
 enumerator become invalid if the underlying collection is modified.
 */
@interface CHCircularBufferEnumerator : NSEnumerator
{
	id *buffer;                  /**< Underlying circular buffer to be enumerated. */
	NSUInteger bufferCapacity;   /**< Allocated capacity of @a buffer. */
	NSUInteger bufferCount;      /**< Number of elements in @a buffer. */
	NSUInteger enumerationCount; /**< How many objects have been enumerated. */
	NSUInteger enumerationIndex; /**< Index of the next element to enumerate. */
	BOOL reverseEnumeration;     /**< Whether to enumerate back-to-front. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr;  /**< Pointer for checking changes in mutation. */	
}

/**
 Create an enumerator which traverses a circular buffer in the specified order.
 
 @param array The circular array that is being enumerated.
 @param capacity The total capacity of the circular buffer being enumerated.
 @param count The number of items currently in the circular buffer
 @param startIndex The index at which to begin enumerating (forward or reverse).
 @param isReversed YES if enumerating back-to-front, NO if natural ordering.
 @param mutations A pointer to the collection's mutation count for invalidation.
 */
- (id) initWithArray:(id*)array
            capacity:(NSUInteger)capacity
               count:(NSUInteger)count
          startIndex:(NSUInteger)startIndex
             reverse:(BOOL)isReversed
     mutationPointer:(unsigned long*)mutations;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
 */
- (NSArray*) allObjects;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or
 <code>nil</code> when all objects have been enumerated.
 */
- (id) nextObject;

@end

@implementation CHCircularBufferEnumerator

- (id) initWithArray:(id*)array
            capacity:(NSUInteger)capacity
               count:(NSUInteger)count
          startIndex:(NSUInteger)startIndex
             reverse:(BOOL)isReversed
     mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil) return nil;
	buffer = array;
	enumerationIndex = startIndex;
	enumerationCount = 0;
	bufferCount = count;
	bufferCapacity = capacity;
	reverseEnumeration = isReversed;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while (enumerationCount++ < bufferCount) {
		if (reverseEnumeration) {
			enumerationIndex = (enumerationIndex + bufferCapacity - 1) % bufferCapacity;
			[array addObject:buffer[enumerationIndex]];
		}
		else {
			[array addObject:buffer[enumerationIndex]];
			enumerationIndex = (enumerationIndex + 1) % bufferCapacity;
		}
	}
	return [array autorelease];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	id object = nil;
	if (enumerationCount++ < bufferCount) {
		if (reverseEnumeration) {
			enumerationIndex = (enumerationIndex + bufferCapacity - 1) % bufferCapacity;
			object = buffer[enumerationIndex];
		}
		else {
			object = buffer[enumerationIndex];
			enumerationIndex = (enumerationIndex + 1) % bufferCapacity;
		}
	}
	return object;
}

@end

#pragma mark -

@implementation CHAbstractCircularBufferCollection

- (void) dealloc {
	[self removeAllObjects];
	free(array);
	[super dealloc];
}

- (id) init {
	return [self initWithCapacity:16];
}

- (id) initWithArray:(NSArray*)anArray {
	NSUInteger capacity = 16;
	while (capacity <= [anArray count])
		capacity *= 2;
	if ([self initWithCapacity:capacity] == nil) return nil;
	for (id anObject in anArray)
		array[tailIndex++] = [anObject retain];
	count = [anArray count];
	return self;
}

- (id) initWithCapacity:(NSUInteger)capacity {
	if ([super init] == nil) return nil;
	arrayCapacity = capacity;
	array = NSAllocateCollectable(kCHPointerSize*arrayCapacity, NSScannedOption);
	count = headIndex = tailIndex = 0;
	mutations = 0;
	return self;	
}

#pragma mark <NSCoding>

/**
 Initialize a collection with data from a given keyed unarchiver.
 
 @param decoder A keyed unarchiver object.
 
 @see NSCoding protocol
 */
- (id) initWithCoder:(NSCoder*)decoder {
	return [self initWithArray:[decoder decodeObjectForKey:@"array"]];
}

/**
 Encodes data from the receiver using a given keyed archiver.
 
 @param encoder A keyed archiver object.
 
 @see NSCoding protocol
 */
- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:[self allObjects] forKey:@"array"];
}

#pragma mark <NSCopying>

/**
 Returns a new instance that's a copy of the receiver. The returned object is
 implicitly retained by the sender, who is responsible for releasing it. For
 this class and its children, all copies are mutable. Invoked automatically by
 the default <code>-copy</code> method inherited from NSObject.
 
 @param zone Identifies an area of memory from which to allocate the new
 instance. If zone is <code>NULL</code>, the new instance is allocated
 from the default zone. (<code>-copy</code> invokes with a NULL param.)
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithArray:[self allObjects]];
}

#pragma mark <NSFastEnumeration>

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs.
 Returns by reference a C array of objects over which the sender should iterate,
 and as the return value the number of objects in the array.
 
 @param state Context information that is used in the enumeration to ensure that
 the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 
 @see NSFastEnumeration protocol
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	/*
	 Since this class uses a C array for storage, we can return a pointer to any
	 spot in the array and a count greater than "len". This approach avoids copy
	 overhead, and is also more efficient since this method will be called only
	 2 or 3 times, depending on whether the buffer wraps around the end of the
	 array. (The last call always returns 0 and requires no extra processing.)
	 */
	NSUInteger enumeratedCount;
	if (state->state == 0) {
		state->mutationsPtr = &mutations;
		state->itemsPtr = array + headIndex; // pointer arithmetic for offset
		// If the buffer wraps, only provide elements to the end of the array.
		enumeratedCount = MIN(arrayCapacity - headIndex, count);
		state->state = (unsigned long) enumeratedCount;
		return enumeratedCount;
	}
	else if (state->state < count) {
		// This means the buffer wrapped around; now return the wrapped segment.
		state->itemsPtr = array;
		enumeratedCount = (NSUInteger) state->state;
		state->state = (unsigned long) count;
		return (count - enumeratedCount);
	}
	else {
		return 0;
	}
}

#pragma mark Insertion

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	array[tailIndex++] = [anObject retain];
	tailIndex %= arrayCapacity;
	if (headIndex == tailIndex) {
		array = NSReallocateCollectable(array, kCHPointerSize * arrayCapacity * 2, NSScannedOption);
		// Copy wrapped-around portion to end of queue and move tail index
		memcpy(array + arrayCapacity, array, kCHPointerSize * tailIndex);
		tailIndex += arrayCapacity;
		arrayCapacity *= 2;
	}
	count++;
	mutations++;
}

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (headIndex == 0)
		headIndex += arrayCapacity;
	array[--headIndex] = [anObject retain];
	if (headIndex == tailIndex) {
		array = NSReallocateCollectable(array, kCHPointerSize * arrayCapacity * 2, NSScannedOption);
		// Copy wrapped-around portion to end of queue and move tail index
		memcpy(array + arrayCapacity, array, kCHPointerSize * tailIndex);
		tailIndex += arrayCapacity;
		arrayCapacity *= 2;
	}
	count++;
	mutations++;
}

#pragma mark Access

- (NSUInteger) count {
	return count;
}

- (id) firstObject {
	return (count > 0) ? array[headIndex] : nil;
}

- (id) lastObject {
	return (count > 0) ? array[(tailIndex + arrayCapacity - 1) % arrayCapacity] : nil;
}

- (NSArray*) allObjects {
	NSMutableArray *allObjects = [[[NSMutableArray alloc] init] autorelease];
	if (count > 0) {
		for (id anObject in self)
			[allObjects addObject:anObject];
	}
	return allObjects;
}

- (NSEnumerator*) objectEnumerator {
	return [[[CHCircularBufferEnumerator alloc]
	         initWithArray:array
                  capacity:arrayCapacity
	                 count:count
	            startIndex:headIndex
	               reverse:NO
	       mutationPointer:&mutations] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [[[CHCircularBufferEnumerator alloc]
	         initWithArray:array
                  capacity:arrayCapacity
	                 count:count
	            startIndex:tailIndex
                   reverse:YES
           mutationPointer:&mutations] autorelease];
}

- (NSString*) description {
	return [[self allObjects] description];
	// TODO: Consider removing NSArray middleman -- need additional testing
//	NSMutableString *description = [NSMutableString string];
//	if (count > 0) {
//		NSUInteger descriptionIndex = headIndex;
//		[description appendFormat:@"\n    %@", array[descriptionIndex++]];
//		while (descriptionIndex != tailIndex) {
//			[description appendFormat:@",\n    %@", array[descriptionIndex++]];
//			descriptionIndex %= arrayCapacity;
//		}
//	}
//	return [NSString stringWithFormat:@"(%@\n)", description];
}

#pragma mark Search

- (BOOL) containsObject:(id)anObject {
	NSUInteger iterationIndex = headIndex;
	while (iterationIndex != tailIndex) {
		if ([array[iterationIndex] isEqual:anObject])
			return YES;
		iterationIndex = (iterationIndex + 1) % arrayCapacity;
	}
	return NO;
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	NSUInteger iterationIndex = headIndex;
	while (iterationIndex != tailIndex) {
		if (array[iterationIndex] == anObject)
			return YES;
		iterationIndex = (iterationIndex + 1) % arrayCapacity;
	}
	return NO;
}

- (NSUInteger) indexOfObject:(id)anObject {
	NSUInteger iterationIndex = headIndex;
	NSUInteger relativeIndex = 0;
	while (iterationIndex != tailIndex) {
		if ([array[iterationIndex] isEqual:anObject])
			return iterationIndex;
		iterationIndex = (iterationIndex + 1) % arrayCapacity;
		relativeIndex++;
	}
	return CHNotFound;
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	NSUInteger iterationIndex = headIndex;
	NSUInteger relativeIndex = 0;
	while (iterationIndex != tailIndex) {
		if (array[iterationIndex] == anObject)
			return relativeIndex;
		iterationIndex = (iterationIndex + 1) % arrayCapacity;
		relativeIndex++;
	}
	return CHNotFound;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	return array[(headIndex + index) % arrayCapacity];
}

#pragma mark Removal

- (void) removeFirstObject {
	if (count == 0)
		return;
	[array[headIndex++] release];
	headIndex %= arrayCapacity;
	count--;
	mutations++;
}

- (void) removeLastObject {
	if (count == 0)
		return;
	[array[tailIndex--] release];
	if (tailIndex < 0)
		tailIndex += arrayCapacity;
	count--;
	mutations++;
}

- (void) removeObject:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
	// TODO: Add support for removing internal to a circular buffer
}

- (void) removeObjectIdenticalTo:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
	// TODO: Add support for removing internal to a circular buffer
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	CHUnsupportedOperationException([self class], _cmd);
	// TODO: Add support for removing internal to a circular buffer
}

- (void) removeAllObjects {
	if (count > 0 && !objc_collectingEnabled()) {
		while (headIndex != tailIndex) {
			[array[headIndex++] release];
			headIndex %= arrayCapacity;
		}
		if (arrayCapacity > 16) {
			free(array);
			arrayCapacity = 16;
			array = NSAllocateCollectable(kCHPointerSize*arrayCapacity, NSScannedOption);
		}
	}
	headIndex = tailIndex = 0;
	count = 0;
	mutations++;
}

@end
