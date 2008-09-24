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
/*
 *  ArrayStack.h
 *  Data Structures Framework
/////SEE LICENSE FILE FOR LICENSE INFORMATION///////
 */

////////
//A fairly basic stack implementation that uses an NSMutableArray to store 
//object references
//////////

#import <Foundation/Foundation.h>
#import "Stack.h"

@interface ArrayStack : NSObject <Stack>
{
    //the actual stack
    NSMutableArray *theArrayStack;
    //the "top of stack".  this is the next index that an element will go into.
    unsigned int nextIndex;
}

- init;
- initWithCapacity:(unsigned)capacity;


-(unsigned int)count;

@end