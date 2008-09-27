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

- (id) init
{
	return [self initWithCapacity:10];
}

- (id) initWithCapacity:(NSUInteger)capacity
{
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	array = [[NSMutableArray alloc] initWithCapacity:capacity];
	return self;
}

- (void) dealloc
{
	[array release];
	[super dealloc];
}

- (void) push:(id)anObject
{
	if (anObject == nil) {
		[NSException raise:NSInvalidArgumentException
					format:@"Object to be added cannot be nil."];
	}
	[array addObject:anObject]; // Inserts at the end of the array
}

- (id) pop
{
	if ([array count] == 0)
		return nil;
	id object = [[array lastObject] retain];
	[array removeLastObject];	
	return [object autorelease];
}

- (id) top
{
	return [array lastObject];
}

- (NSUInteger) count
{
	return [array count];
}

- (NSEnumerator *) objectEnumerator
{
	return [array objectEnumerator];
}

@end
