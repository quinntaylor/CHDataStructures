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

//  StandardLinkedList.h
//  DataStructuresFramework


//////////////
///A pretty standard linked list class with a header and tail.
///This has changed from earlier versions: the nodes are now simple
///C structs rather than Obj C classes -- much faster.
///Max Horn gave me the suggestion.  Thanks Max.
///Max also has helped steer the interfaces and protocols to follow much more
///closely the API you find in Apple's collections classes.
/////////////

#import <Foundation/Foundation.h>
#import "LinkedList.h"

/**
 * Our struct to hold the data.  This makes it fast.
 * Is it messy to put it here?  In some ways it seems messier
 * to make a separate file just for this.
 */
typedef struct LLNode
{
    struct LLNode *next;
    struct LLNode *prev;
    id data;

} LLNode;

/////A standard Doubly Linked List implementation
/////I called it Standard because i have no plans to implement a singly-linked
/////list...i really don't think the extra pointers matter too much when
/////you're using OO technology with its lot of excess pointers, do they?

@interface StandardLinkedList : NSObject <LinkedList>
{
    int theSize;

    LLNode *beginMarker;
    LLNode *endMarker;
}


//a bonus method.  supplies an enumerator that goes backwards
//meaning from tail to head.
-(NSEnumerator *)reverseObjectEnumerator;

@end
