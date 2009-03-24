/*
 CHAbstractCircularBufferCollection.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2009, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import "CHAbstractCircularBufferCollection.h"

static size_t kCHPointerSize = sizeof(void*);

@interface CHCircularBufferEnumerator : NSEnumerator
{
	id *buffer;
	NSUInteger enumerationIndex;
	NSUInteger enumerationCount;
	NSUInteger bufferCount;
	NSUInteger bufferCapacity;
	BOOL reverseEnumeration;
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr; /**< Pointer for checking changes in mutation. */	
}

/**
 Create an enumerator which traverses a circular buffer in the specified order.
 
 @param array The circular array that is being enumerated.
 @param capacity The total size of the circular buffer being enumerated.
 @param head The index of the first element in the circular buffer.
 @param tail The index just beyond the last element in the circular buffer.
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
	id anObject;
	while ((anObject = [self nextObject]))
		[array addObject:anObject];
	return [array autorelease];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	id object = nil;
	if (enumerationCount < bufferCount) {
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
		array[headIndex++] = [anObject retain];
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
 Initialize a collection with data from a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder*)decoder {
	return [self initWithArray:[decoder decodeObjectForKey:@"array"]];
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:[self allObjects] forKey:@"array"];
}

#pragma mark <NSCopying>

/**
 Returns a new instance that is a copy of the receiver.
 
 @param zone The zone identifies an area of memory from which to allocate the
 new instance. If zone is <code>NULL</code>, the instance is allocated
 from the default zone.
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. For this class and its children, all copies are mutable.
 */
- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithArray:[self allObjects]];
}

#pragma mark <NSFastEnumeration>

/**
 Returns by reference a C array of objects over which the sender should iterate,
 and as the return value the number of objects in the array.
 
 @param state Context information that is used in the enumeration to ensure that
 the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return 0;
	// TODO: Implement NSFastEnumeration
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
		NSUInteger iterationIndex = headIndex;
		do {
			[allObjects addObject:array[iterationIndex]];
		} while (++iterationIndex != tailIndex);
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
	// TODO: Consider removing NSArray middleman
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
