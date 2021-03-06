//
//  ItemTableRowController.h
//  WatchApp
//
//  Created by Stephane Bisson on 1/13/15.
//  Copyright (c) 2015 Stephane Bisson. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "ShoppingListAPI.h"

@interface ItemTableRowController : NSObject
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *itemName;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *checkButton;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *buttonGroup;
@property (copy) void (^itemCheckCAllbackBlock)(void);
@property Item *item;
- (IBAction)buttonPressed;
- (void)onItemCheck:(void (^)(void))callbackBlock;
@end
