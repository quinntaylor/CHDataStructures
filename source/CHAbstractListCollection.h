/*
 CHAbstractListCollection.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
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
#import "CHLinkedList.h"

/**
 @file CHAbstractListCollection.h
 An abstract class which implements common behaviors of list-based collections.
 */

/**
 An abstract class which implements common behaviors of list-based collections.
 This class has a single instance variable on which all the implemented methods
 act, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration
 
 This class also contains concrete implementations for the following methods:
 
 <pre><code>
 -(id) initWithArray:
 -(NSUInteger) count
 -(NSString*) description
 -(NSEnumerator*) objectEnumerator
 -(NSArray*) allObjects
 -(void) removeAllObjects
 -(void) removeObject:
 
 -(BOOL) containsObject:
 -(BOOL) containsObjectIdenticalTo:
 -(NSUInteger) indexOfObject:
 -(NSUInteger) indexOfObjectIdenticalTo:
 -(id) objectAtIndex:
 </code></pre>

 Rather than enforcing that this class be abstract, the contract is implied. In
 any case, an instance would be useless since there is no way to add objects.
 */
@interface CHAbstractListCollection : CHLockable
	<NSCoding, NSCopying, NSFastEnumeration>
{
	id<CHLinkedList> list; /**< List used for storing contents of collection. */
}

- (id) initWithArray:(NSArray*)anArray;
- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
- (NSArray*) allObjects;
- (void) removeAllObjects;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;

- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) indexOfObject:(id)anObject;
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;

#pragma mark Adopted Protocols

/**
 Returns a new instance that's a copy of the receiver. Invoked automatically by
 the default <code>-copy</code> method inherited from NSObject.
 
 @param zone Identifies an area of memory from which to allocate the new
        instance. If zone is <code>NULL</code>, the new instance is allocated
        from the default zone. (<code>-copy</code> invokes with a NULL param.)
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. Copies returned by this method are always mutable.
 */
- (id) copyWithZone:(NSZone *)zone;

/**
 Returns an object initialized from data in a given keyed unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder;

/**
 Encodes the receiver using a given keyed archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder;

/**
 A method for NSFastEnumeration, called by <code><b>for</b> (type variable
 <b>in</b> collection)</code> constructs.
 
 @param state Context information that is used in the enumeration to ensure that
        the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

@end
