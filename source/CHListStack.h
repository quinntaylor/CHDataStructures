//
//  CHListStack.h
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//  Copyright © 2002, Phillip Morelock
//

#import <CHDataStructures/CHStack.h>
#import <CHDataStructures/CHAbstractListCollection.h>

/**
 @file CHListStack.h
 A simple CHStack implemented using a CHSinglyLinkedList.
 */

/**
 A simple CHStack implemented using a CHSinglyLinkedList. A singly-linked list is a natural choice since objects are only inserted and removed at the top of the stack, which is easily modeled as the head of a linked list. Enumerating from the top of the stack to the bottom also follows the natural ordering of a linked list.
 */
@interface CHListStack : CHAbstractListCollection <CHStack>

@end
