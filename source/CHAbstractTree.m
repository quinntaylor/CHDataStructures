/*
 CHAbstractTree.m
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

#import "CHAbstractTree.h"

@implementation CHAbstractTree

/**
 Only to be called from concrete child classes to initialize shared variables.
 */
- (id) init {
	if ([super init] == nil) return nil;
	count = 0;
	mutations = 0;
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	// Call the concrete subclass' -init, which calls [super init] declared here
	if ([self init] == nil) return nil;
	for (id anObject in anArray)
		[self addObject:anObject];
	return self;
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	// Gives concrete child class a chance to initialize its own state
	if ([self init] == nil) return nil;
	count = 0;
	mutations = 0;
	for (id anObject in [decoder decodeObjectForKey:@"objects"])
		[self addObject:anObject];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	NSEnumerator *e = [self objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	[encoder encodeObject:[e allObjects] forKey:@"objects"];
}

#pragma mark <NSCopying> methods

- (id) copyWithZone:(NSZone *)zone {
	id<CHTree> newTree = [[[self class] alloc] init];
	NSEnumerator *e = [self objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	for (id anObject in e)
		[newTree addObject:anObject];
	return newTree;
}

#pragma mark Concrete Implementations

- (NSUInteger) count {
	return count;
}

- (NSEnumerator*) objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseAscending];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseDescending];
}

- (NSArray*) allObjects {
	return [self allObjectsWithTraversalOrder:CHTraverseAscending];
}

- (NSArray*) allObjectsWithTraversalOrder:(CHTraversalOrder)order {
	return [[self objectEnumeratorWithTraversalOrder:order] allObjects];
}

#pragma mark Unsupported Implementations

- (void) addObject:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
}

- (BOOL) containsObject:(id)anObject {
	return (BOOL) CHUnsupportedOperationException([self class], _cmd);
}

- (id) findMin {
	return (id) CHUnsupportedOperationException([self class], _cmd);
}

- (id) findMax {
	return (id) CHUnsupportedOperationException([self class], _cmd);
}

- (id) findObject:(id)anObject {
	return (id) CHUnsupportedOperationException([self class], _cmd);
}

- (void) removeObject:(id)element {
	CHUnsupportedOperationException([self class], _cmd);
}

- (void) removeAllObjects {
	CHUnsupportedOperationException([self class], _cmd);
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return (NSEnumerator*) CHUnsupportedOperationException([self class], _cmd);
}

/**
 A method for NSFastEnumeration, called by <code><b>for</b> (type variable <b>in</b>
 collection)</code> constructs.
 
 @param state Context information that is used in the enumeration. In addition to
        other possibilities, it can ensure that the collection has not been mutated.
 @param stackbuf A C array of objects over which the sender is to iterate. The method
        generally saves objects directly to this array.
 @param len The maximum number of objects to return in <i>stackbuf</i>.
 @return The number of objects copied into the <i>stackbuf</i> array.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return CHUnsupportedOperationException([self class], _cmd);
}

@end
