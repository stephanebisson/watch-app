//
//  InterfaceController.m
//  WatchApp WatchKit Extension
//
//  Created by Stephane Bisson on 1/13/15.
//  Copyright (c) 2015 Stephane Bisson. All rights reserved.
//

#import "InterfaceController.h"
#import "ItemTableRowController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
    
    [self addMenuItemWithItemIcon:WKMenuItemIconAdd title:@"Add item" action:@selector(handleMenuAdd)];
    [self addMenuItemWithItemIcon:WKMenuItemIconResume title:@"Refresh" action:@selector(handleMenuRefresh)];
    
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.tw.WatchApp"
                                                         optionalDirectory:@"wormhole"];
    
    [self.wormhole listenForMessageWithIdentifier:@"phoneHasChangedData"
                                         listener:^(id messageObject) {
                                             self.shoppingList = [ShoppingList load];
                                             [self renderData];
                                         }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    self.shoppingList = [ShoppingList load];
    [self renderData];
}

- (void)handleMenuRefresh {
    self.shoppingList = [ShoppingList load];
    [self renderData];
}

- (void)handleMenuAdd {
    NSMutableArray *suggestions = [[NSMutableArray alloc] initWithCapacity:self.shoppingList.sortedCompletedItems.count];
    for (Item *item in self.shoppingList.sortedCompletedItems) {
        [suggestions addObject:item.name];
    }
    
    [self presentTextInputControllerWithSuggestions:suggestions allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
        if (results != nil && results.count == 1) {
            NSString *itemName = results[0];
            Item *item = [self.shoppingList itemWithName:itemName];
            if (item != nil) {
                [item check];
                [self.shoppingList updateLists];
                [self.shoppingList save];
                [self notifyPhoneOfDataChange];
            }
        }
        
        [self renderData];
    }];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
                            inTable:(WKInterfaceTable *)table
                           rowIndex:(NSInteger)rowIndex {
    ItemTableRowController *rowController = [table rowControllerAtIndex:rowIndex];
    return rowController.item;
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (int)findIndexOfItem:(Item*)item {
    for(int i=0; i<self.shoppingList.sortedItems.count; i++) {
        Item *currentItem = self.shoppingList.sortedItems[i];
        if (currentItem.name == item.name) {
            return i;
        }
    }
    return -1;
}

-(void)renderData {
    int numberOfItems = (int)self.shoppingList.sortedItems.count;
    
    if (numberOfItems > 0) {
        [self.itemTable setNumberOfRows:numberOfItems withRowType:@"itemRow"];
        
        int i = 0;
        for (Item *item in self.shoppingList.sortedItems) {
            ItemTableRowController *rowController = [self.itemTable rowControllerAtIndex:i];
            [rowController onItemCheck:^{
                int index = [self findIndexOfItem:item];
                
                [item check];
                [self.shoppingList updateLists];
                [self.shoppingList save];
                
                
                if (index >= 0) {
                    [self.itemTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
                }
                
                if (self.shoppingList.sortedItems.count == 0) {
                    [self showGotItAllMessage];
                }
                
                [self notifyPhoneOfDataChange];
                                
            }];
            rowController.item = item;
            [rowController.itemName setText:item.name];
            i++;
        }
        [self.messageLabel setHidden:YES];
        [self.itemTable setHidden:NO];
    } else {
        [self showGotItAllMessage];
    }
}

- (void)showGotItAllMessage {
    [self.messageLabel setText:@"You've got everything! You can checkout now or hard press to add an item."];
    [self.messageLabel setHidden:NO];
    [self.itemTable setHidden:YES];
}

- (void)notifyPhoneOfDataChange {
    [self.wormhole passMessageObject:@{@"titleString" : @"title"}
                          identifier:@"watchHasChangedData"];
}

@end



