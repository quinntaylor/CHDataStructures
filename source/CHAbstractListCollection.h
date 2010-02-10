/*
 CHDataStructures.framework -- CHAbstractListCollection.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableObject.h"
#import "CHLinkedList.h"

/**
 @file CHAbstractListCollection.h
 An abstract class which implements common behaviors of list-based collections.
 */

/**
 An abstract class which implements common behaviors of list-based collections. This class has a single instance variable on which all the implemented methods act, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration
 
 Rather than enforcing that this class be abstract, the contract is implied.
 */
@interface CHAbstractListCollection : CHLockableObject 
#if OBJC_API_2
<NSCoding, NSCopying, NSFastEnumeration>
#else
<NSCoding, NSCopying>
#endif
{
	id<CHLinkedList> list; // List used for storing contents of collection.
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
- (NSArray*) objectsAtIndexes:(NSIndexSet*)indexes;
- (void) removeAllObjects;
- (void) removeObject:(id)anObject;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) removeObjectIdenticalTo:(id)anObject;
- (void) removeObjectsAtIndexes:(NSIndexSet*)indexes;
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

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
