/*
 CHDataStructures.framework -- CHAbstractMutableArrayCollection.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHAbstractMutableArrayCollection.h
 An abstract class which implements common behaviors of array-based collections.
 */

/**
 An abstract class which implements common behaviors of array-based collections.
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

 Rather than enforcing that this class be abstract, the contract is implied. In
 any case, an instance would be useless since there is no way to add objects.
 */
@interface CHAbstractMutableArrayCollection : CHLockable
	<NSCoding, NSCopying, NSFastEnumeration>
{
	NSMutableArray *array; /**< Array used for storing contents of collection. */
}

- (id) initWithArray:(NSArray*)anArray;
- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
- (NSEnumerator*) reverseObjectEnumerator;
- (NSArray*) allObjects;
- (void) removeAllObjects;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;

- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) indexOfObject:(id)anObject;
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;

@end
