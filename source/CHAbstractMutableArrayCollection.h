/*
 CHAbstractMutableArrayCollection.h
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

#import <Foundation/Foundation.h>

/**
 An abstract class which implements many common behaviors of array-based collections.
 This class has a single instance variable on which all the implemented methods act,
 and also conforms to several protocols:
 
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
@interface CHAbstractMutableArrayCollection : NSObject
	<NSCoding, NSCopying, NSFastEnumeration>
{
	/** The array used for storing the contents of the data collection. */
	NSMutableArray *array;
}

- (id) initWithArray:(NSArray*)anArray;
- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
- (NSEnumerator*) reverseObjectEnumerator;
- (NSArray*) allObjects;
- (void) removeAllObjects;
- (void) removeObject:(id)anObject;

- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) indexOfObject:(id)anObject;
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;

@end
