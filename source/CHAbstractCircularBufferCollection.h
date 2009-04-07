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

@interface CHAbstractCircularBufferCollection : CHLockable
	<NSCoding, NSCopying, NSFastEnumeration>
{
	id *array;
	NSUInteger arrayCapacity;
	NSUInteger count;
	NSUInteger headIndex;
	NSUInteger tailIndex;
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
