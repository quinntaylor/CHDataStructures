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
//  RBNode.h
//  DataStructuresFramework
//
//  Created by Phillip Morelock on Sat Apr 06 2002.

#import <Foundation/Foundation.h>
#import "Comparable.h"

#define nRED 0
#define nBLACK 1

@interface RBNode : NSObject 
{
    short int color;
    id <Comparable> object;
    RBNode *left;
    RBNode *right;
}

- (id)initWithObject:(id <Comparable>)theObject;
- (id)initWithObject:(id <Comparable>)theObject
			withLeft:(RBNode *)theLeft
		   withRight:(RBNode *)theRight;

- (short int)color;
- (RBNode *)left;
- (RBNode *)right;
- (id)object;

- (void)setColor:(short int)newColor;
- (void)setLeft:(RBNode *)newLeft;
- (void)setRight:(RBNode *)newRight;
- (void)setObject:(id <Comparable>)newObject;


@end
