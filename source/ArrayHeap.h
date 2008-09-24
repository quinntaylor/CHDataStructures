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
//
//  ArrayHeap.h
//  DataStructuresFramework
//
//  Created by Gordon Worley on Tue Apr 02 2002.
//  Copyright (c) 2002 Gordon Worley redbird@rbisland.cx
//  Edits and refactoring by Phillip Morelock for purposes 
//  of integration with the library, and for performance.
/////SEE LICENSE FILE FOR LICENSE INFORMATION///////
/////many thanks to Gordon for the very first outside contribution to the library!

#import <Foundation/Foundation.h>
#import <Heap.h>
#import <Comparable.h>

@interface ArrayHeap : NSObject <Heap>
{
    NSMutableArray *irep;
}

@end
