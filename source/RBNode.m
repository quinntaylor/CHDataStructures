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
//  RBNode.m
//  DataStructuresFramework
//
//  Created by Phillip Morelock on Sat Apr 06 2002.

#import "RBNode.h"

@implementation RBNode

-(id)init
{
    return [self initWithObject:nil];
}

-(id)initWithObject:(id <Comparable>)theObject
{
    return [self initWithObject:theObject withLeft:nil withRight:nil];
}

-(id)initWithObject:(id <Comparable>)theObject
		   withLeft:(RBNode *)theLeft
		  withRight:(RBNode *)theRight
{
	if (![super init]) {
		[self release];
		return nil;
	}
    
    color = nBLACK;
    object = [theObject retain];
    left = [theLeft retain];
    right = [theRight retain];
    
    return self;
}

- (void)dealloc
{
    [left release];
    [right release];
    [object release];
	
    [super dealloc];
}

- (RBNode *)left
{
    return left;
}

- (RBNode *)right
{
    return right;
}

- (id)object
{
    return object;
}

- (short int)color
{
    return color;
}

- (void)setColor:(short int)newColor
{
    color = newColor;
}

- (void)setLeft:(RBNode *)newLeft
{
    RBNode *old;
    old = left;
    left = [newLeft retain];
    [old release];
}

- (void)setRight:(RBNode *)newRight
{
    RBNode *old;
    old = right;
    right = [newRight retain];
    [old release];
}

- (void)setObject:(id <Comparable>)newObject
{
    id old;
    old = object;
    object = [newObject retain];
    [old release];
}

@end
