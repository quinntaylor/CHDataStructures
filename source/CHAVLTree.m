/*
 CHAVLTree.m
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

#import "CHAVLTree.h"

@implementation CHAVLTree

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


@end
