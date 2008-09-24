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

//  DSFMutableArray.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>

/**
 A Mutable Array implementation.  Ridiculous, just for fun.
 Not really tested that much, seemed fine on small / insignificant datasets.
 */
@interface DSFMutableArray : NSObject
{
    id *arrayBase;
    int upperBound;
    int currentTop;
}

//default capacity of 32
- (id) init;

//will be rounded to a multiple of 32
- (id) initWithCapacity:(unsigned)capacity;

- (void) insertObject:(id)anObject atIndex:(int)index;

- (void) addObject:(id)anObject;

- (id) objectAtIndex:(int)index;

- (void) removeObjectatIndex:(int)index;

- (void) replaceObjectAtIndex:(int)index withObject:(id)anObject;

//this is the reason for making my own mutable array
//to be able to use nils.
- (void) nilObjectAtIndex:(int)index;

@end
