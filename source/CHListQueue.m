//  CHListQueue.m
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

#import "CHListQueue.h"

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than using
 a CHDoublyLinkedList, and requires a little less memory. Also, since it's a queue,
 it's unlikely that there is any need to enumerate over the object from back to front.
 */
@implementation CHListQueue

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

// TODO: Add a custom -initWithList: to create a new CHSinglyLinkedList with contents

- (void) addObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	else
		[list appendObject:anObject];
}

- (id) firstObject {
	return [list firstObject];
}

- (void) removeFirstObject {
	[list removeFirstObject];
}

@end
