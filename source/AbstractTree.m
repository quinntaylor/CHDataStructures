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

//  Tree.m
//  DataStructuresFramework

#import "AbstractTree.h"
#import "ListStack.h"

@implementation AbstractTree

#pragma mark Concrete Implementations

- (id) initWithObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if ([self init] == nil) {
		[self release];
		return nil;
	}
	[self addObjectsFromEnumerator:enumerator];
	return self;
}

- (void) addObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if (enumerator == nil)
		invalidNilArgumentException([self class], _cmd);
	for (id object in enumerator)
		[self addObject:object];
}

- (void) addObjectsFromTree:(id<Tree>)otherTree
        usingTraversalOrder:(CHTraversalOrder)order {
	[self addObjectsFromEnumerator:[otherTree objectEnumeratorWithTraversalOrder:order]];
}

- (NSSet*) contentsAsSet {
	NSMutableSet *set = [[NSMutableSet alloc] init];
	for (id object in [self objectEnumeratorWithTraversalOrder:CHTraversePreOrder])
		[set addObject:object];
	return [set autorelease];
}

- (NSArray*) contentsAsArrayUsingTraversalOrder:(CHTraversalOrder)order {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (id object in [self objectEnumeratorWithTraversalOrder:order]) {
		[array addObject:object];
	}
	return [array autorelease];
	// Document that the returned object is mutable? Return immutable copy instead?
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

@end
