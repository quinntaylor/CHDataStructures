//  CHAbstractTree.m
//  CHDataStructures.framework

/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

#import "CHAbstractTree.h"

@implementation CHAbstractTree

/**
 Only to be called from concrete child classes to initialize shared variables.
 */
- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	count = 0;
	mutations = 0;
	return self;
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
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

- (NSArray*) contentsAsArrayUsingTraversalOrder:(CHTraversalOrder)order {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (id object in [self objectEnumeratorWithTraversalOrder:order]) {
		[array addObject:object];
	}
	return [array autorelease]; // Currently a mutable array, but doesn't affect tree
}

- (NSSet*) contentsAsSet {
	NSMutableSet *set = [[NSMutableSet alloc] init];
	for (id object in [self objectEnumeratorWithTraversalOrder:CHTraversePreOrder])
		[set addObject:object];
	return [set autorelease];
}

- (NSUInteger) count {
	return count;
}

- (NSEnumerator*) objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseInOrder];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder];
}

#pragma mark Unsupported Implementations

- (void) addObject:(id)anObject {
	unsupportedOperationException([self class], _cmd);
}

- (BOOL) containsObject:(id)anObject {
	unsupportedOperationException([self class], _cmd);
	return NO;
}

- (void) removeObject:(id)element {
	unsupportedOperationException([self class], _cmd);
}

- (void) removeAllObjects {
	unsupportedOperationException([self class], _cmd);
}

- (id) findMin {
	unsupportedOperationException([self class], _cmd);
	return nil;
}

- (id) findMax {
	unsupportedOperationException([self class], _cmd);
	return nil;
}

- (id) findObject:(id)anObject {
	unsupportedOperationException([self class], _cmd);
	return nil;
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	unsupportedOperationException([self class], _cmd);
	return nil;
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
	unsupportedOperationException([self class], _cmd);
	return 0;
}

@end
