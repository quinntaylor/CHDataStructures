/*
 CHDataStructures.framework -- CHAbstractMutableArrayCollection.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableObject.h"

/**
 @file CHAbstractMutableArrayCollection.h
 An abstract class which implements common behaviors of array-based collections.
 */

/**
 An abstract class which implements common behaviors of array-based collections. This class has a single instance variable on which all the implemented methods act, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration
 
 Rather than enforcing that this class be abstract, the contract is implied.
 */
@interface CHAbstractMutableArrayCollection : CHLockableObject 
#if OBJC_API_2
<NSCoding, NSCopying, NSFastEnumeration>
#else
<NSCoding, NSCopying>
#endif
{
	NSMutableArray *array; /**< Array used for storing contents of collection. */
}

- (id) initWithArray:(NSArray*)anArray;

- (NSArray*) allObjects;
- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) count;
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (NSUInteger) indexOfObject:(id)anObject;
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;
- (NSEnumerator*) objectEnumerator;
- (void) removeAllObjects;
- (void) removeObject:(id)anObject;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) removeObjectIdenticalTo:(id)anObject;
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
/**
 Returns an enumerator that accesses each object in the receiver in reverse order.
 
 @return An enumerator that accesses each object in the receiver in reverse order. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 */
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
