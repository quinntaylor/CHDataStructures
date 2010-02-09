/*
 CHDataStructures.framework -- CHCircularBuffer.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHCircularBuffer.h"

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
	if ((self = [super init]) == nil) return nil;
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

static BOOL objectsAreEqual(id o1, id o2) {
	return [o1 isEqual:o2];
}

static BOOL objectsAreIdentical(id o1, id o2) {
	return (o1 == o2);
}

#define DEFAULT_BUFFER_SIZE 16u

#pragma mark -

/**
 @todo Reimplement @c removeObjectsAtIndexes: for efficiency with multiple objects.
 */
@implementation CHCircularBuffer

+ (void) initialize {
	initializeGCStatus();
}

- (void) dealloc {
	[self removeAllObjects];
	free(array);
	[lock release];
	[super dealloc];
}

// Note: Defined here since -init is not implemented in NS(Mutable)Array.
- (id) init {
	return [self initWithCapacity:DEFAULT_BUFFER_SIZE];
}

- (id) initWithArray:(NSArray*)anArray {
	NSUInteger capacity = DEFAULT_BUFFER_SIZE;
	while (capacity <= [anArray count])
		capacity *= 2;
	if ([self initWithCapacity:capacity] == nil) return nil;
#if OBJC_API_2
	for (id anObject in anArray)
#else
	NSEnumerator *e = [anArray objectEnumerator];
	id anObject;
	while (anObject = [e nextObject])
#endif
	{
		array[tailIndex++] = [anObject retain];
	}
	count = [anArray count];
	return self;
}

// This is the designated initializer for CHCircularBuffer.
- (id) initWithCapacity:(NSUInteger)capacity {
	if ((self = [super init]) == nil) return nil;
	arrayCapacity = capacity ? capacity : DEFAULT_BUFFER_SIZE;
	array = NSAllocateCollectable(kCHPointerSize*arrayCapacity, NSScannedOption);
	return self;	
}

#pragma mark <NSCoding>

// Overridden from NSMutableArray to encode/decode as the proper class.
- (Class) classForKeyedArchiver {
	return [self class];
}

- (id) initWithCoder:(NSCoder*)decoder {
	return [self initWithArray:[decoder decodeObjectForKey:@"array"]];
}

- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:[self allObjects] forKey:@"array"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone*)zone {
	return [[[self class] allocWithZone:zone] initWithArray:[self allObjects]];
}

#pragma mark <NSFastEnumeration>

/*
 Since this class uses a C array for storage, we can return a pointer to any spot in the array and a count greater than "len". This approach avoids copy overhead, and is also more efficient since this method will be called only 2 or 3 times, depending on whether the buffer wraps around the end of the array. (The last call always returns 0 and requires no extra processing.)
 */
#if OBJC_API_2
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
#endif

#pragma mark <CHLockable>

// Private method used for creating a lock on-demand and naming it uniquely.
- (void) createLock {
	@synchronized (self) {
		if (lock == nil) {
			lock = [[NSLock alloc] init];
			if ([lock respondsToSelector:@selector(setName:)])
				[lock performSelector:@selector(setName:)
				           withObject:[NSString stringWithFormat:@"NSLock-%@-0x%x", [self class], self]];
		}
	}
}

- (BOOL) tryLock {
	if (lock == nil)
		[self createLock];
	return [lock tryLock];
}

- (void) lock {
	if (lock == nil)
		[self createLock];
	[lock lock];
}

- (BOOL) lockBeforeDate:(NSDate*)limit {
	if (lock == nil)
		[self createLock];
	return [lock lockBeforeDate:limit];
}

- (void) unlock {
	[lock unlock];
}

#pragma mark Querying Contents

- (NSArray*) allObjects {
	NSMutableArray *allObjects = [[NSMutableArray alloc] init];
	if (count > 0) {
#if OBJC_API_2
		for (id anObject in self)
#else
		NSEnumerator *e = [self objectEnumerator];
		id anObject;
		while (anObject = [e nextObject])
#endif
		{
			[allObjects addObject:anObject];
		}
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

// NSArray primitive method
- (NSUInteger) count {
	return count;
}

- (id) firstObject {
	return (count > 0) ? array[headIndex] : nil;
}

- (NSUInteger) hash {
	return hashOfCountAndObjects(count, [self firstObject], [self lastObject]);
}

- (id) lastObject {
	return (count > 0) ? array[((tailIndex) ? tailIndex : arrayCapacity) - 1] : nil;
}

- (NSUInteger) indexOfObject:(id)anObject {
	return [self indexOfObject:anObject inRange:NSMakeRange(0, count)];
}

- (NSUInteger) indexOfObject:(id)anObject inRange:(NSRange)range {
	NSUInteger onePastLastRelativeIndex = range.location + range.length;
	if (onePastLastRelativeIndex > count)
		CHIndexOutOfRangeException([self class], _cmd, onePastLastRelativeIndex, count);
	NSUInteger iterationIndex = transformIndex(range.location);
	NSUInteger relativeIndex = range.location;
	while (relativeIndex < onePastLastRelativeIndex) {
		if ([array[iterationIndex] isEqual:anObject])
			return relativeIndex;
		incrementIndex(iterationIndex);
		relativeIndex++;
	}
	return NSNotFound;
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	return [self indexOfObjectIdenticalTo:anObject inRange:NSMakeRange(0, count)];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
	NSUInteger onePastLastRelativeIndex = range.location + range.length;
	if (onePastLastRelativeIndex > count)
		CHIndexOutOfRangeException([self class], _cmd, onePastLastRelativeIndex, count);
	NSUInteger iterationIndex = transformIndex(range.location);
	NSUInteger relativeIndex = range.location;
	while (relativeIndex < onePastLastRelativeIndex) {
		if (array[iterationIndex] == anObject)
			return relativeIndex;
		incrementIndex(iterationIndex);
		relativeIndex++;
	}
	return NSNotFound;
}

// NSArray primitive method
- (id) objectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	return array[transformIndex(index)];
}

- (NSArray*) objectsAtIndexes:(NSIndexSet*)indexes {
	if (indexes == nil)
		CHNilArgumentException([self class], _cmd);
	if ([indexes count] == 0)
		return [NSArray array];
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[indexes count]];
	NSUInteger index = [indexes firstIndex];
	while (index != NSNotFound) {
		[objects addObject:[self objectAtIndex:index]];
		index = [indexes indexGreaterThanIndex:index];
	}
	return objects;
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

#pragma mark Modifying Contents

// NSMutableArray primitive method
- (void) addObject:(id)anObject {
	[self insertObject:anObject atIndex:count];
}

// NSMutableArray primitive method
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (index > count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[anObject retain];
	if (index == count || count == 0) {
		// To append, just move the tail forward one slot (wrapping if needed)
		array[tailIndex] = anObject;
		incrementIndex(tailIndex);
	} else if (index == 0) {
		// To prepend, just move the head backward one slot (wrapping if needed)
		decrementIndex(headIndex);
		array[headIndex] = anObject;
	} else {
		NSUInteger actualIndex = transformIndex(index);
		if (actualIndex > tailIndex) {
			// If the buffer wraps and index is between head and end, shift left.
			memmove(&array[headIndex-1], &array[headIndex],
					kCHPointerSize * index);
			decrementIndex(headIndex);
			decrementIndex(actualIndex); // Head moved back, so does destination
		}
		else {
			// Otherwise, shift everything from given index onward to the right.
			memmove(&array[actualIndex+1], &array[actualIndex],
					kCHPointerSize * (tailIndex - actualIndex));
			incrementIndex(tailIndex);
		}
		array[actualIndex] = anObject;
	}
	++count;
	++mutations;	
	// If this insertion filled the array to capacity, double its size and copy.
	if (headIndex == tailIndex) {
		array = NSReallocateCollectable(array, kCHPointerSize * arrayCapacity * 2, NSScannedOption);
		// Copy wrapped-around portion to end of queue and move tail index
		memcpy(array + arrayCapacity, array, kCHPointerSize * tailIndex);
		bzero(array, kCHPointerSize * tailIndex); // Zero the source of the copy
		tailIndex += arrayCapacity;
		arrayCapacity *= 2;
	}
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	if (idx1 > count)
		CHIndexOutOfRangeException([self class], _cmd, idx1, count);
	if (idx2 > count)
		CHIndexOutOfRangeException([self class], _cmd, idx2, count);
	if (idx1 != idx2) {
		NSUInteger realIdx1 = transformIndex(idx1);
		NSUInteger realIdx2 = transformIndex(idx2);
		id tempObject = array[realIdx1];
		array[realIdx1] = array[realIdx2];
		array[realIdx2] = tempObject;
		++mutations;
	}
}

- (void) removeFirstObject {
	if (count == 0)
		return;
	[array[headIndex] release];
	array[headIndex] = nil; // Let GC do its thing
	incrementIndex(headIndex);
	--count;
	++mutations;
}

// NSMutableArray primitive method
- (void) removeLastObject {
	if (count == 0)
		return;
	decrementIndex(tailIndex);
	[array[tailIndex] release];
	array[tailIndex] = nil; // Let GC do its thing
	--count;
	++mutations;
}

// Remove method that accepts a function pointer for testing object equality.
- (void) removeObject:(id)anObject withEqualityTest:(BOOL(*)(id,id))objectsMatch {
	if (count == 0 || anObject == nil)
		return;
	// Strip off leading matches if any exist in the buffer.
	while (count > 0 && objectsMatch(array[headIndex], anObject)) {
		[array[headIndex] release];
		array[headIndex] = nil; // Let GC do its thing
		incrementIndex(headIndex);
		--count; // Necessary in case the only matches are at the beginning.
	}
	// Scan to find the first match, if one exists
	NSUInteger scanIndex = headIndex;
	while (scanIndex != tailIndex && !objectsMatch(array[scanIndex], anObject))
		incrementIndex(scanIndex);
	// Bail out here if no objects need to be removed internally (none found)
	if (scanIndex == tailIndex)
		return;
	// Copy individual elements, excluding objects to be removed
	NSUInteger copyIndex = scanIndex;
	incrementIndex(scanIndex);
	while (scanIndex != tailIndex) {
		if (!objectsMatch(array[scanIndex], anObject)) {
			[array[copyIndex] release];
			array[copyIndex] = array[scanIndex];
			incrementIndex(copyIndex);
		}
		incrementIndex(scanIndex);
	}
	// Under GC, zero the rest of the array to avoid holding unneeded references
	if (!kCHGarbageCollectionNotEnabled) {
		if (tailIndex > copyIndex) {
			memset(&array[copyIndex], 0, kCHPointerSize * (tailIndex - copyIndex));
		} else {
			memset(array + copyIndex, 0, kCHPointerSize * (arrayCapacity - copyIndex));
			memset(array,             0, kCHPointerSize * tailIndex);
		}
	}
	// Set the tail pointer to the new end point and recalculate element count.
	tailIndex = copyIndex;
	count = (tailIndex + arrayCapacity - headIndex) % arrayCapacity;
	++mutations;
}

- (void) removeObject:(id)anObject {
	[self removeObject:anObject withEqualityTest:&objectsAreEqual];
}

- (void) removeObjectIdenticalTo:(id)anObject {
	[self removeObject:anObject withEqualityTest:&objectsAreIdentical];
}

// NSMutableArray primitive method
- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	NSUInteger actualIndex = transformIndex(index);
	[array[actualIndex] release];
	// This algorithm is from: http://www.javafaq.nu/java-article808.html
	// It could be optimized so the smaller half is always moved, but that would
	// require 1-2 memmove()s and usually copying of a single object. Since this
	// operation is inherently inefficient, I just left it this way.
	if (actualIndex == headIndex) {
		array[actualIndex] = nil; // Let GC do its thing
		incrementIndex(headIndex);
	} else if (actualIndex == tailIndex - 1) {
		array[actualIndex] = nil; // Let GC do its thing
		decrementIndex(tailIndex);
	} else {
		if (actualIndex > tailIndex) {
			// If the buffer wraps and index is in "the right side", shift right.
			memmove(&array[headIndex+1], &array[headIndex],
					kCHPointerSize * index);
			array[headIndex] = nil; // Prevents possible memory leak under GC
			incrementIndex(headIndex);
		} else {
			// Otherwise, shift everything from index to tail one to the left.
			memmove(&array[actualIndex], &array[actualIndex+1],
					kCHPointerSize * (tailIndex - actualIndex - 1));
			decrementIndex(tailIndex);
			array[tailIndex] = nil; // Prevents possible memory leak under GC
		}
	}
	--count;
	++mutations;
}

- (void) removeObjectsAtIndexes:(NSIndexSet*)indexes {
	if (indexes == nil)
		CHNilArgumentException([self class], _cmd);
	if ([indexes count] > 0) {
		NSUInteger index = [indexes lastIndex];
		while (index != NSNotFound) {
			[self removeObjectAtIndex:index];
			index = [indexes indexLessThanIndex:index];
		}
	}
}

- (void) removeAllObjects {
	if (count > 0) {
		if (kCHGarbageCollectionNotEnabled) {
			while (headIndex != tailIndex) {
				[array[headIndex] release];
				incrementIndex(headIndex);
			}
		}
		else {
			// Only zero out pointers that will remain when the buffer shrinks.
			bzero(array, kCHPointerSize * MIN(arrayCapacity, DEFAULT_BUFFER_SIZE));
		}
		if (arrayCapacity > DEFAULT_BUFFER_SIZE) {
			arrayCapacity = DEFAULT_BUFFER_SIZE;
			// Shrink the size of allocated memory; calls realloc() under non-GC
			array = NSReallocateCollectable(array, kCHPointerSize * arrayCapacity, NSScannedOption);
		}
	}
	headIndex = tailIndex = 0;
	count = 0;
	++mutations;
}

// NSMutableArray primitive method
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	[anObject retain];
	[array[transformIndex(index)] release];
	array[transformIndex(index)] = anObject;
}

@end
