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
#import "LLStack.h"

@implementation AbstractTree

+ (id) exceptionForUnsupportedOperation:(SEL)operation {
	[NSException raise:NSInternalInconsistencyException
				format:@"+[%@ %s] -- Unsupported operation.",
                       [self class], sel_getName(operation)];
	return nil;
}

- (id) exceptionForUnsupportedOperation:(SEL)operation {
	[NSException raise:NSInternalInconsistencyException
				format:@"-[%@ %s] -- Unsupported operation.",
                       [self class], sel_getName(operation)];
	return nil;
}

- (id) exceptionForInvalidArgument:(SEL)operation {
	[NSException raise:NSInvalidArgumentException
				format:@"-[%@ %s] -- Invalid nil argument.",
	                   [self class], sel_getName(operation)];
	return nil;
}


#pragma mark Default Error Implementations

- (void) addObject:(id <Comparable>)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (void) addObjectsFromArray:(NSArray *)anArray {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (BOOL) containsObject:(id <Comparable>)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
	return NO;
}

- (void) removeObject:(id <Comparable>)element {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (void) removeAllObjects {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (id) findMin {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (id) findMax {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (id) findObject:(id <Comparable>)anObject {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (BOOL) isEmpty {
	[self exceptionForUnsupportedOperation:_cmd];
	return NO;
}

#pragma mark Convenience Constructors

+ (id<Tree>) treeWithObjectsFromEnumerator:(NSEnumerator*)enumerator {
	id<Tree> tree = [[self alloc] init];
	id object;
	while (object = [enumerator nextObject]) {
		[tree addObject:object];
	}
	return [tree autorelease];
}

+ (id<Tree>) treeWithObjectsFromFastEnumeration:(id<NSFastEnumeration>)collection {
    id<Tree> tree = [[self alloc] init];
	for (id object in collection) {
		[tree addObject:object];
	}
	return [tree autorelease];
}

#pragma mark Collection Conversions

- (NSSet *) contentsAsSet {
	NSEnumerator *enumerator = [self objectEnumeratorWithTraversalOrder:CHTraversePreOrder];
	
	NSMutableSet *set = [[NSMutableSet alloc] init];
	id object;
	while ((object = [enumerator nextObject])) {
        [set addObject:object];
	}
    return [set autorelease];
}

- (NSArray *) contentsAsArrayWithOrder:(CHTraversalOrder)order {
    NSEnumerator *enumerator = [self objectEnumeratorWithTraversalOrder:order];
	
    NSMutableArray *array = [[NSMutableArray alloc] init];
	id object;
	while ((object = [enumerator nextObject])) {
        [array addObject:object];
	}
    return [array autorelease];
	// Document that the returned object is mutable? Return immutable copy instead?
}

- (id <Stack>) contentsAsStackWithInsertionOrder:(CHTraversalOrder)order {
    NSEnumerator *enumerator = [self objectEnumeratorWithTraversalOrder:order];
	
	id <Stack> stack = [[LLStack alloc] init];
	id object;
	while ((object = [enumerator nextObject])) {
        [stack push:object];
	}
	return [stack autorelease];
}

#pragma mark Object Enumerators

- (NSEnumerator *) objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseInOrder];
}

/* Must be specified by concrete child classes. */
- (NSEnumerator *) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [self exceptionForUnsupportedOperation:_cmd];
}

@end
