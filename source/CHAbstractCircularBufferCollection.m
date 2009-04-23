/*
 CHDataStructures.framework -- CHAbstractCircularBufferCollection.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHAbstractCircularBufferCollection.h"

static size_t kCHPointerSize = sizeof(void*);
#define transformIndex(index) ((headIndex + index) % arrayCapacity)
#define incrementIndex(index) (index = (index + 1) % arrayCapacity)
#define decrementIndex(index) (index = ((index) ? index : arrayCapacity) - 1)

/**
 An NSEnumerator for traversing a CHAbstractCircularBufferCollection subclass.
 
 Enumerators encapsulate their own state, and more than one may be active at once.
 However, like an enumerator for a mutable data structure, any instances of this
 enumerator become invalid if the underlying collection is modified.
 */
@interface CHCircularBufferEnumerator : NSEnumerator
{
	id *array;                   /**< Underlying circular buffer to be enumerated. */
	NSUInteger arrayCapacity;    /**< Allocated capacity of @a buffer. */
	NSUInteger arrayCount;       /**< Number of elements in @a buffer. */
	NSUInteger enumerationCount; /**< How many objects have been enumerated. */
	NSUInteger enumerationIndex; /**< Index of the next element to enumerate. */
	BOOL reverseEnumeration;     /**< Whether to enumerate back-to-front. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr;  /**< Pointer for checking changes in mutation. */	
}

/**
 Create an enumerator which traverses a circular buffer in the specified order.
 
 @param anArray The circular array that is being enumerated.
 @param capacity The total capacity of the circular buffer being enumerated.
 @param count The number of items currently in the circular buffer
 @param startIndex The index at which to begin enumerating (forward or reverse).
 @param isReversed @c YES if enumerating back-to-front, @c NO if natural ordering.
 @param mutations A pointer to the collection's mutation count for invalidation.
 */
- (id) initWithArray:(id*)anArray
            capacity:(NSUInteger)capacity
               count:(NSUInteger)count
          startIndex:(NSUInteger)startIndex
             reverse:(BOOL)isReversed
     mutationPointer:(unsigned long*)mutations;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return @c nil.
 */
- (NSArray*) allObjects;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or
 @c nil when all objects have been enumerated.
 */
- (id) nextObject;

@end

@implementation CHCircularBufferEnumerator

- (id) initWithArray:(id*)anArray
            capacity:(NSUInteger)capacity
               count:(NSUInteger)count
          startIndex:(NSUInteger)startIndex
             reverse:(BOOL)isReversed
     mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil) return nil;
	array = anArray;
	arrayCapacity = capacity;
	arrayCount = count;
	enumerationCount = 0;
	enumerationIndex = startIndex;
	if (isReversed)
		decrementIndex(enumerationIndex);
	reverseEnumeration = isReversed;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (NSArray*) allObjects {
	NSMutableArray *allObjects = [[NSMutableArray alloc] init];
	if (reverseEnumeration) {
		while (enumerationCount++ < arrayCount) {
			[allObjects addObject:array[enumerationIndex]];
			decrementIndex(enumerationIndex);
		}
	}
	else {
		while (enumerationCount++ < arrayCount) {
			[allObjects addObject:array[enumerationIndex]];
			incrementIndex(enumerationIndex);
		}
	}
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	return [allObjects autorelease];
}

- (id) nextObject {
	id object = nil;
	if (enumerationCount++ < arrayCount) {
		object = array[enumerationIndex];
		if (reverseEnumeration) {
			decrementIndex(enumerationIndex);
		}
		else {
			incrementIndex(enumerationIndex);
		}
	}
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
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

// This is the designated initializer for CHAbstractCircularBufferCollection.
- (id) initWithCapacity:(NSUInteger)capacity {
	if ([super init] == nil) return nil;
	arrayCapacity = capacity;
	array = NSAllocateCollectable(kCHPointerSize*arrayCapacity, NSScannedOption);
	count = headIndex = tailIndex = 0;
	mutations = 0;
	return self;	
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder*)decoder {
	return [self initWithArray:[decoder decodeObjectForKey:@"array"]];
}

- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:[self allObjects] forKey:@"array"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithArray:[self allObjects]];
}

#pragma mark <NSFastEnumeration>

/*
 Since this class uses a C array for storage, we can return a pointer to any spot in the array and a count greater than "len". This approach avoids copy overhead, and is also more efficient since this method will be called only 2 or 3 times, depending on whether the buffer wraps around the end of the array. (The last call always returns 0 and requires no extra processing.)
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	if (state->state == 0) {
		state->mutationsPtr = &mutations;
		state->itemsPtr = array + headIndex; // pointer arithmetic for offset
		// If the buffer wraps, only provide elements to the end of the array.
		NSUInteger enumeratedCount = MIN(arrayCapacity - headIndex, count);
		state->state = (unsigned long) enumeratedCount;
		return enumeratedCount;
	}
	else if (state->state < count) {
		// This means the buffer wrapped around; now return the wrapped segment.
		state->itemsPtr = array;
		NSUInteger enumeratedCount = (NSUInteger) state->state;
		state->state = (unsigned long) count;
		return (count - enumeratedCount);
	}
	else {
		return 0;
	}
}

#pragma mark Adding Objects

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	array[tailIndex] = [anObject retain];
	incrementIndex(tailIndex);
	if (headIndex == tailIndex) {
		array = NSReallocateCollectable(array, kCHPointerSize * arrayCapacity * 2, NSScannedOption);
		// Copy wrapped-around portion to end of queue and move tail index
		memcpy(array + arrayCapacity, array, kCHPointerSize * tailIndex);
		tailIndex += arrayCapacity;
		arrayCapacity *= 2;
	}
	++count;
	++mutations;
}

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	decrementIndex(headIndex);
	array[headIndex] = [anObject retain];
	if (headIndex == tailIndex) {
		array = NSReallocateCollectable(array, kCHPointerSize * arrayCapacity * 2, NSScannedOption);
		// Copy wrapped-around portion to end of queue and move tail index
		memcpy(array + arrayCapacity, array, kCHPointerSize * tailIndex);
		tailIndex += arrayCapacity;
		arrayCapacity *= 2;
	}
	++count;
	++mutations;
}

#pragma mark Querying Contents

- (NSArray*) allObjects {
	NSMutableArray *allObjects = [[NSMutableArray alloc] init];
	if (count > 0) {
		for (id anObject in self)
			[allObjects addObject:anObject];
	}
	return [allObjects autorelease];
}

- (BOOL) containsObject:(id)anObject {
	NSUInteger iterationIndex = headIndex;
	while (iterationIndex != tailIndex) {
		if ([array[iterationIndex] isEqual:anObject])
			return YES;
		incrementIndex(iterationIndex);
	}
	return NO;
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	NSUInteger iterationIndex = headIndex;
	while (iterationIndex != tailIndex) {
		if (array[iterationIndex] == anObject)
			return YES;
		incrementIndex(iterationIndex);
	}
	return NO;
}

- (NSUInteger) count {
	return count;
}

- (id) firstObject {
	return (count > 0) ? array[headIndex] : nil;
}

- (id) lastObject {
	return (count > 0) ? array[((tailIndex) ? tailIndex : arrayCapacity) - 1] : nil;
}

- (NSUInteger) indexOfObject:(id)anObject {
	NSUInteger iterationIndex = headIndex;
	NSUInteger relativeIndex = 0;
	while (iterationIndex != tailIndex) {
		if ([array[iterationIndex] isEqual:anObject])
			return relativeIndex;
		incrementIndex(iterationIndex);
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
		incrementIndex(iterationIndex);
		relativeIndex++;
	}
	return CHNotFound;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	return array[transformIndex(index)];
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

#pragma mark Removing Objects

- (void) removeFirstObject {
	if (count == 0)
		return;
	[array[headIndex] release];
	array[headIndex] = nil; // Let GC do its thing
	incrementIndex(headIndex);
	--count;
	++mutations;
}

- (void) removeLastObject {
	if (count == 0)
		return;
	[array[tailIndex] release];
	array[tailIndex] = nil; // Let GC do its thing
	decrementIndex(tailIndex);
	--count;
	++mutations;
}

- (void) removeObject:(id)anObject {
	if (count == 0 || anObject == nil)
		return;
	// Strip off leading matches if any exist in the buffer.
	while (count > 0 && [array[headIndex] isEqual:anObject]) {
		[array[headIndex] release];
		array[headIndex] = nil; // Let GC do its thing
		incrementIndex(headIndex);
		--count; // Necessary in case the only matches are at the beginning.
	}
	// Scan to find the first match, if one exists
	NSUInteger scanIndex = headIndex;
	while (scanIndex != tailIndex && ![array[scanIndex] isEqual:anObject])
		incrementIndex(scanIndex);
	// Bail out here if no objects need to be removed internally.
	if (scanIndex == tailIndex)
		return;
	// Copy individual elements, excluding objects to be removed
	NSUInteger copyIndex = scanIndex;
	incrementIndex(scanIndex);
	while (scanIndex != tailIndex) {
		if (![array[scanIndex] isEqual:anObject]) {
			[array[copyIndex] release];
			array[copyIndex] = array[scanIndex];
			incrementIndex(copyIndex);
		}
		incrementIndex(scanIndex);
	}
	// Under GC, zero the rest of the array to avoid holding unneeded references
	if (objc_collectingEnabled()) {
		if (tailIndex > copyIndex) {
			memset(&array[copyIndex], 0, kCHPointerSize * (tailIndex - copyIndex));
		}
		else {
			memset(array + copyIndex, 0, kCHPointerSize * (arrayCapacity - copyIndex));
			memset(array,             0, kCHPointerSize * tailIndex);
		}
	}
	// Set the tail pointer to the new end point and recalculate element count.
	tailIndex = copyIndex;
	count = (tailIndex + arrayCapacity - headIndex) % arrayCapacity;
	++mutations;
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (count == 0 || anObject == nil)
		return;
	// Strip off leading or trailing matches if any exist in the buffer.
	while (count > 0 && array[headIndex] == anObject) {
		[array[headIndex] release];
		array[headIndex] = nil; // Let GC do its thing
		incrementIndex(headIndex);
		--count;
	}
	// Scan to find the first match, if one exists
	NSUInteger scanIndex = headIndex;
	while (scanIndex != tailIndex && array[scanIndex] != anObject)
		incrementIndex(scanIndex);
	// Bail out here if no objects need to be removed internally.
	if (scanIndex == tailIndex)
		return;
	// Copy individual elements, excluding objects to be removed
	NSUInteger copyIndex = scanIndex;
	incrementIndex(scanIndex);
	while (scanIndex != tailIndex) {
		if (array[scanIndex] != anObject) {
			[array[copyIndex] release];
			array[copyIndex] = array[scanIndex];
			incrementIndex(copyIndex);
		}
		incrementIndex(scanIndex);
	}
	// Under GC, zero the rest of the array to avoid holding unneeded references
	if (objc_collectingEnabled()) {
		if (tailIndex > copyIndex) {
			memset(&array[copyIndex], 0, kCHPointerSize * (tailIndex - copyIndex));
		}
		else {
			memset(array + copyIndex, 0, kCHPointerSize * (arrayCapacity - copyIndex));
			memset(array,             0, kCHPointerSize * tailIndex);
		}
	}
	// Set the tail pointer to the new end point and recalculate element count.
	tailIndex = copyIndex;
	count = (tailIndex + arrayCapacity - headIndex) % arrayCapacity;
	++mutations;
}

// This algorithm is from: http://www.javafaq.nu/java-article808.html
// It could be optimized so the smaller half is always moved, but that requires
// 1-2 memmove()s and usually copying of a single object. Since this operation
// is inherently less efficient no matter the code, I just left it this way.
- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	NSUInteger actualIndex = transformIndex(index);
	[array[actualIndex] release];
	if (actualIndex == headIndex) {
		array[actualIndex] = nil; // Let GC do its thing
		incrementIndex(headIndex);
	} else if (actualIndex == tailIndex - 1) {
		array[actualIndex] = nil; // Let GC do its thing
		decrementIndex(tailIndex);
	} else {
		// If the buffer wraps and index is between head and end, shift right.
		if (actualIndex > tailIndex) {
			memmove(&array[headIndex+1], &array[headIndex],
					kCHPointerSize * index);
			//array[headIndex] = nil; // for debugging purposes only
			incrementIndex(headIndex);
		}
		// Otherwise, shift everything from given index to the tail to the left.
		else {
			memmove(&array[actualIndex], &array[actualIndex+1],
					kCHPointerSize * (tailIndex - actualIndex - 1));
			decrementIndex(tailIndex);
			//array[tailIndex] = nil; // for debugging purposes only
		}
		// (In both cases, the pointer to the removed object is overwritten.)
	}
	--count;
	++mutations;
}

- (void) removeAllObjects {
	if (count > 0) {
		if (!objc_collectingEnabled()) {
			while (headIndex != tailIndex) {
				[array[headIndex] release];
				incrementIndex(headIndex);
			}
		}
		if (arrayCapacity > 16) {
			arrayCapacity = 16;
			// Shrink the size of allocated memory; calls realloc() under non-GC
			array = NSReallocateCollectable(array, kCHPointerSize * arrayCapacity, NSScannedOption);
		}
	}
	headIndex = tailIndex = 0;
	count = 0;
	++mutations;
}

@end
