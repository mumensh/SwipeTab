//
//  SwipeControl.h
//  SwipeTab
//
//  Created by Mumen Shabaro on 4/1/14.
//  Copyright (c) 2014 Mumen Shabaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKHorizMenu.h"

@interface SwipeControl : UIView <MKHorizMenuDataSource, MKHorizMenuDelegate, UIScrollViewDelegate> {
    MKHorizMenu *menuSCView;
    UIScrollView *contentSCView;
    
    NSMutableArray *_items;
    
    int counter;
    float gap;
}

@property (nonatomic, retain) NSMutableArray *items;
- (id)initWithMenu:(NSArray *)menusTitle;
- (void) addNewViewController:(UIView *) v;

- (void) changeTitleColor:(UIColor *)color;
- (void) changeLineColor:(UIColor *)color;

@end
