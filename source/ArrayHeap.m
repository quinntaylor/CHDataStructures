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
//  ArrayHeap.m
//  DataStructuresFramework
//
//  Created by Gordon Worley on Tue Apr 02 2002.
//  Copyright (c) 2002 Gordon Worley redbird@rbisland.cx
//  Contributions by Phillip Morelock for purposes of integration with the library.
/////SEE LICENSE FILE FOR LICENSE INFORMATION///////

/*******
/////Additions by Phillip Morelock Apr 03 02
/////fine-tuned memory management / object releases, etc.
/////replaced some internal method calls with the "straight call" so as
/////to reduce obj_c multiple messaging
/////PM 04.14.02 -- converted bubbleup and bubbledown to static C functions instead of
/////////////////////messages to self.
//
/////many thanks to Gordon for the very first outside contribution to the library!
*******/

#import "ArrayHeap.h"

/*************
C functions to speed the bubble up and bubble down
***************/

static void _bubbleup(NSMutableArray *heap)
{
    int i, parent;
     
    //get the last index...
    i = [heap count] - 1;
    
    while (i > 0)
    {
        parent = i / 2;
        if ([[heap objectAtIndex: i] compare: [heap objectAtIndex: parent]] > 0)
        {
            [heap exchangeObjectAtIndex: i withObjectAtIndex: parent];
            i = parent;
        }
        else
            i = 0;
    }
    
    return;
}

static void _bubbledown(NSMutableArray *heap)
{
    int parent = 0, lchild, rchild;
    
    while (parent < [heap count] / 2)	
    {
        lchild = parent * 2;
        rchild = parent * 2 + 1;
    
        if ([heap objectAtIndex: lchild] != nil && [heap objectAtIndex: rchild] != nil)
        {
            if ([[heap objectAtIndex: lchild] compare: [heap objectAtIndex: rchild]] > 0)
            {
                if ([[heap objectAtIndex: lchild] compare: [heap objectAtIndex: parent]] > 0)
                {
                    [heap exchangeObjectAtIndex: lchild withObjectAtIndex: parent];
                    parent = lchild;
                }
                else
                    parent = [heap count];
            }
            else
            {
                if ([[heap objectAtIndex: rchild] compare: [heap objectAtIndex: parent]] > 0)
                {
                    [heap exchangeObjectAtIndex: rchild withObjectAtIndex: parent];
                    parent = rchild;
                }
                else
                    parent = [heap count];
            }
        }
        else if ([heap objectAtIndex: lchild])
        {
            if ([[heap objectAtIndex: lchild] compare: [heap objectAtIndex: parent]] > 0)
            {
                [heap exchangeObjectAtIndex: lchild withObjectAtIndex: parent];
                parent = lchild;
            }
            else
                parent = [heap count];
        }
        else if ([heap objectAtIndex: rchild])	
        {
            if ([[heap objectAtIndex: rchild] compare: [heap objectAtIndex: parent]] > 0)
            {
                [heap exchangeObjectAtIndex: rchild withObjectAtIndex: parent];
                parent = rchild;
            }
            else
                parent = [heap count];
        }
        else
            parent = [heap count];
    }
    
}

/***************
@interface ArrayHeap : NSObject <Heap>
{
    NSMutableArray *irep;
}
*****************/

@implementation ArrayHeap

-(id)init
{
    [super init];

    irep = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc
{
    [irep release];

    [super dealloc];
}

- (BOOL)addObject:(id <Comparable>)obj
{
    if (!obj)
        return NO;
    
    [irep addObject: obj];

    _bubbleup(irep);

    return YES;
}
        
- (id)removeRoot
{
    id obj;
    
    if (![irep count])
        return nil;

    obj = [[irep objectAtIndex: 0] retain];
    [irep exchangeObjectAtIndex: 0 withObjectAtIndex: [irep count] - 1];
    [irep removeLastObject];

    _bubbledown(irep);
    
    return [obj autorelease];
}

- (id) removeLast
{
    id obj;
    
    if (![irep count])
        return nil;
    
    obj = [[irep lastObject] retain];
    [irep removeLastObject];

    return [obj autorelease];
}

- (unsigned)count
{
    return [irep count];
}

- (BOOL) isEmpty
{
    return ([irep count] > 0) ? YES : NO;
}

@end
