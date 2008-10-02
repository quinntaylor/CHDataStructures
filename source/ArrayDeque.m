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

//  ArrayDeque.m
//  DataStructuresFramework

#import "ArrayDeque.h"

@implementation ArrayDeque

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc {
	[array release];
	[super dealloc];
}

- (void) prependObject:(id)anObject {
	[array insertObject:anObject atIndex:0];
}

- (void) appendObject:(id)anObject {
	[array addObject:anObject];
}

- (id) firstObject {
	return [array objectAtIndex:0];
}

- (id) lastObject {
	return [array lastObject];
}

- (NSArray*) allObjects {
	return [array copy];
}

- (void) removeFirstObject {
	[array removeObjectAtIndex:0];
}

- (void) removeLastObject {
	[array removeLastObject];
}

- (void) removeAllObjects {
	[array removeAllObjects];
}


- (BOOL) containsObject:(id)anObject {
	return [array containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([array indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger) count {
	return [array count];
}

@end
