/*
 CHMutableArrayQueue.m
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

#import "CHMutableArrayQueue.h"

@implementation CHMutableArrayQueue

#pragma mark Queue Implementation

- (void) addObject: (id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	else
		[array addObject:anObject];
}

- (id) firstObject {
	@try {
		return [array objectAtIndex:0];
	}
	@catch (NSException *exception) {}
	return nil;
}

- (void) removeFirstObject {
	@try {
		[array removeObjectAtIndex:0];
	}
	@catch (NSException *exception) {}
}

@end
