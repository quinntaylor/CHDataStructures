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

//  ArrayStack.m
//  DataStructuresFramework

#import "ArrayStack.h"

@implementation ArrayStack

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[NSMutableArray alloc] init];
	return self;
}

// Additional method in this implementation
- (id) initWithCapacity:(NSUInteger)capacity {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[NSMutableArray alloc] initWithCapacity:capacity];
	return self;
}

- (void) dealloc {
	[array release];
	[super dealloc];
}

- (void) pushObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	else
		[array addObject:anObject];
}

- (id) popObject {
	if ([array count] == 0)
		return nil;
	id object = [[array lastObject] retain];
	[array removeLastObject];	
	return [object autorelease];
}

- (id) topObject {
	return [array lastObject];
}

- (NSArray*) allObjects {
	return [array copy];
}

- (NSUInteger) count {
	return [array count];
}

- (void) removeAllObjects {
	[array removeAllObjects];
}

- (NSEnumerator*) objectEnumerator {
	return [array objectEnumerator];
}

// Additional method in this implementation
- (NSEnumerator*) reverseObjectEnumerator {
	return [array reverseObjectEnumerator];
}

@end
