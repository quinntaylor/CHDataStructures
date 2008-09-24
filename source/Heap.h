/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyright for this specific file as acknowledged herein.
 
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

//  Heap.h
//  DataStructuresFramework

//  Copyright (c) 2002 Gordon Worley redbird@rbisland.cx
//  Minor contributions by Phillip Morelock for purposes of library integration.
//  Many thanks to Gordon for the very first outside contribution to the library!

#import <Foundation/Foundation.h>
#import "Comparable.h"

/**
 A VERY basic heap interface
 */
@protocol Heap <NSObject>

// if you try to insert nil, it will return false
- (BOOL) addObject:(id <Comparable>)obj;

// returns nil if the heap is empty.
- (id) removeRoot;

// returns nil if the heap is empty
- (id) removeLast;

// measures the size of the heap currently
- (unsigned) count;

// simple BOOL for whether the heap is empty or not.
- (BOOL) isEmpty;

@end
