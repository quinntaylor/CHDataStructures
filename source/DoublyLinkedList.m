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

//  StandardLinkedList.m
//  DataStructuresFramework

#import "DoublyLinkedList.h"


/**
 An NSEnumerator for traversing a DoublyLinkedList in forward or reverse order.
 */
@interface DoublyLinkedListEnumerator : NSEnumerator
{
    struct DoublyLinkedNode *header;
    struct DoublyLinkedNode *tail;
    struct DoublyLinkedNode *current;
    
    BOOL direction; //YES == forward
}

/**
 Create an enumerator which traverses a given (sub)list in the specified order.
 
 @param beginMarker The leftmost element to include in the enumeration.
 @param endMarker The rightmost element to include in the enumeration.
 @param dir The order in which to enumerate over the list. YES means the natural
		index order (0...n), NO means reverse index order (n...0).
 */
- (id)initWithHead:(struct DoublyLinkedNode *)beginMarker
		  withTail:(struct DoublyLinkedNode *)endMarker
		   forward:(BOOL)dir;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
 */
- (NSArray *) allObjects;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or <code>nil</code>
         when all objects have been enumerated.
 */
- (id) nextObject;

@end


#pragma mark -

@implementation DoublyLinkedListEnumerator
//forward means YES == same order as linked list, NO == reverse.
/**
 
 */
- (id)initWithHead:(struct DoublyLinkedNode *)beginMarker
		 withTail:(struct DoublyLinkedNode *)endMarker
		  forward:(BOOL)dir
{
    if ([super init] == nil || beginMarker == nil || endMarker == nil) {
		[self release];
		return nil;
	}
    
    header = beginMarker;
    tail = endMarker;
    
    direction = dir;
    
    if (direction)
        current = header;
    else
        current = tail;
    
    return self;
}

- (id)nextObject
{
    struct DoublyLinkedNode *old = current;
	
    if (direction)
    {
        if ( !(old->next) || old->next == tail)
            return nil;
        else
            return (current = old->next)->data; //return and advance the list
    }
    else
    {
        if (!(old->prev) || old->prev == header)
            return nil;
        else
            return (current = old->prev)->data;
    }
}

- (NSArray *)allObjects
{
    struct DoublyLinkedNode *old = current;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (direction)
    {
        while ( (current = old->next) != tail)
            if (current) [array addObject: current->data];
    }
    else
    {
        while ( (current = old->prev) != header)
            if (current) [array addObject: current->data];
    }
    
    return [array autorelease];
}

@end

#pragma mark -

@implementation DoublyLinkedList

- (id) init
{
    if ([super init] == nil) {
		[self release];
		return nil;
	}
    
    // set up the markers pointing to each other    
    beginMarker = malloc(NODESIZE);
    endMarker = malloc(NODESIZE);
    
    beginMarker->next = endMarker;
    beginMarker->prev = NULL;
    beginMarker->data = nil;
    
    endMarker->next = NULL;
    endMarker->prev = beginMarker;
    endMarker->data = nil;
    
    return self;
}

- (void)dealloc
{
    [self removeAllObjects];
    
    if (beginMarker != NULL)
    {
        [beginMarker->data release];
        free(beginMarker);
    }
    if (endMarker != NULL)
    {
        [endMarker->data release];
        free(endMarker);
    }
    
    [super dealloc];
}

- (unsigned int) count
{
    return listSize;
}

- (struct DoublyLinkedNode *) _findPos:(id)obj
								 identical:(BOOL)ident
{
    struct DoublyLinkedNode *p;
    
    if (!obj)
		return nil;
    
    //simply iterate through
    for (p = beginMarker->next; p != endMarker; p = p->next)
    {
        if (!ident) {
            if ( [obj isEqual:p->data] )
                return p;
			
		}
        else {
            if ( obj == p->data )
                return p;
		}
    }
    
    //not found
    return nil;
}

- (struct DoublyLinkedNode *) _nodeAtIndex:(unsigned int)index
{
    int i;
    struct DoublyLinkedNode *p; //a runner, also our return val
    
    //need to handle special case -- they can "insert it" at the
    //index of the size of the list (in other words, at the end)
    //but not beyond.
    if (index > listSize)
		return nil;
    else if (index == 0)
        return beginMarker->next;
    
    if (index < listSize / 2)
    {
		p = beginMarker->next;
		for (i = 0; i < index; ++i)
			p = p->next;
    }
    else
    {
        //note that we start at the tail itself, because we may just be displacing it
        //with a new object at the end.
		p = endMarker;
		for (i = listSize; i > index; --i)
			p = p->prev;
    }
    
    return p;
}

- (BOOL) containsObject:(id)anObject
{
    // if that returns nil, we'll return NO automagically
    return ([self _findPos:anObject identical:NO] != nil);
}

- (BOOL) containsObjectIdenticalTo:(id)anObject
{
    return ([self _findPos:anObject identical:YES] != nil);
}

- (void) insertObject:(id)anObject atIndex:(unsigned int)index
{
    struct DoublyLinkedNode *p, *newNode;
	
    if (anObject == nil)
		return;
    
    // find node to attach to
    // _nodeAtIndex: does range checking, etc., by returning nil on error
    if ((p = [self _nodeAtIndex:index]) == nil)
        return;
    
    newNode = malloc(NODESIZE);
    
    newNode->data = [anObject retain];
    // prev is set to the prev pointer of the node it displaces
    newNode->prev = p->prev;
    // next is set to the node it displaces
    newNode->next = p;
    // previous node is set to point to us as next
    newNode->prev->next = newNode;
    // next node is set to point to us as previous
    p->prev = newNode;
    
    ++listSize;
}

- (void) addFirst:(id)obj
{
    [self insertObject:obj atIndex:0];
}

- (void) addLast:(id)obj
{
    [self insertObject:obj atIndex:listSize];
}

- (id) first
{
    struct DoublyLinkedNode *thenode = [self _nodeAtIndex:0];
    return thenode->data;
}

- (id) last
{
    struct DoublyLinkedNode *thenode = [self _nodeAtIndex:(listSize - 1)];
    return thenode->data;
}

- (id) objectAtIndex:(unsigned int)index
{
    struct DoublyLinkedNode *thenode = [self _nodeAtIndex:index];
    
    if (!thenode)
        return nil;
    
    return thenode->data;
}

- (void) _removeNode:(struct DoublyLinkedNode *)node
{
    if (!node || node == beginMarker || node == endMarker)
		return;
	
    //break the links.
    node->next->prev = node->prev;
    node->prev->next = node->next;
    
    [node->data release];
    
    //remember we're using C...we malloced it in the first place!
    free(node);
    
    --listSize;
}

- (void) removeFirst
{
    [self _removeNode: (beginMarker->next)  ];
}

- (void)removeLast
{
    [self _removeNode: (endMarker->prev)  ];
}

- (void)removeObjectAtIndex:(unsigned int)index
{
    [ self _removeNode:[self _nodeAtIndex:index] ];
}

- (void)removeObject:(id)obj
{
    struct DoublyLinkedNode *pos;
    pos = [self _findPos:obj identical:NO];
    
    //removeNode: will check for nils, etc.
    [self _removeNode:pos];
}

- (void)removeObjectIdenticalTo:(id)obj
{
    struct DoublyLinkedNode *pos;
    pos = [self _findPos:obj identical:YES];
    
    //removeNode: will check for nils, etc.
    [self _removeNode:pos];
}

- (void) removeAllObjects
{
    struct DoublyLinkedNode *runner, *old;
    
    runner = beginMarker->next;
	
    while ( runner != endMarker )
    {
        old = runner;  runner = runner->next;
        [old->data release];
        free(old);
    }
	
    listSize = 0;
    
    beginMarker->next = endMarker;
    endMarker->prev = beginMarker;
    
}

- (NSEnumerator *)objectEnumerator
{
    return [[[DoublyLinkedListEnumerator alloc] 
			 initWithHead:beginMarker
			 withTail:endMarker
			 forward:YES]autorelease];
}

- (NSEnumerator *)reverseObjectEnumerator
{
    return [[[DoublyLinkedListEnumerator alloc] 
			 initWithHead:beginMarker
			 withTail:endMarker
			 forward:NO]autorelease];   
}

+(DoublyLinkedList *)listFromArray:(NSArray *)array ofOrder:(BOOL)direction
{
    DoublyLinkedList *list;
    int i,s;
    
    list = [[DoublyLinkedList alloc] init];
    s = [array count];
    i = 0;
    
    if (!array || s < 1)
    {}//nada
    else if (direction)//so the order will be 0...n
    {
        while (i < s)
            [list addLast: [array objectAtIndex: i++]];
    }
    else //order to dequeue will be n...0
    {
        while (s > i)
            [list addFirst: [array objectAtIndex: --s]];
    }
    
    return [list autorelease];
}

@end
