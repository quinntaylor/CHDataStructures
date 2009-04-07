/*
 CHDataStructures.framework -- CHAbstractCircularBufferCollection.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHAbstractCircularBufferCollection.h
 An abstract class which implements common behaviors of circular array buffers.
 */

/**
 An abstract class which implements common behaviors of circular array buffers.
 This class maintains a C array of object pointers in which objects can be added
 or removed from either end cheaply, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration

 This class also contains concrete implementations for the following methods:
 
 <pre><code>
 -(id) initWithArray:
 -(id) initWithCapacity:
 -(NSUInteger) count
 -(NSString*) description
 -(NSEnumerator*) objectEnumerator
 -(NSEnumerator*) reverseObjectEnumerator
 -(NSArray*) allObjects
 -(void) removeObject:
 -(void) removeAllObjects
 
 -(BOOL) containsObject:
 -(BOOL) containsObjectIdenticalTo:
 -(NSUInteger) indexOfObject:
 -(NSUInteger) indexOfObjectIdenticalTo:
 -(id) objectAtIndex:
 </code></pre>
 
 Rather than enforcing that this class be abstract, the contract is implied.
 */

@interface CHAbstractCircularBufferCollection : CHLockable <NSCoding, NSCopying, NSFastEnumeration>
{
	id *array; /**< Primitive C array used for storing contents of collection. */
	NSUInteger arrayCapacity; /**< How many pointers @a array can accommodate. */
	NSUInteger count; /**< The number of objects currently in the buffer. */
	NSUInteger headIndex; /**< The array index of the first object. */
	NSUInteger tailIndex; /**< The array index after the last object. */
	unsigned long mutations; /**< Tracks mutations for NSFastEnumeration. */
}

- (id) initWithArray:(NSArray*)anArray;
- (id) initWithCapacity:(NSUInteger)capacity;

- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
- (NSEnumerator*) reverseObjectEnumerator;

- (void) appendObject:(id)anObject;
- (void) prependObject:(id)anObject;
- (id) firstObject;
- (id) lastObject;
- (NSArray*) allObjects;	

- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) indexOfObject:(id)anObject;
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;

- (void) removeFirstObject;
- (void) removeLastObject;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) removeAllObjects;

@end
