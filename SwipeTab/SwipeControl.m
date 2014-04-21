//
//  SwipeControl.m
//  SwipeTab
//
//  Created by Mumen Shabaro on 4/1/14.
//  Copyright (c) 2014 Mumen Shabaro. All rights reserved.
//

#import "SwipeControl.h"

@implementation SwipeControl
@synthesize items = _items;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithMenu:(NSArray *)menusTitle;
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        // Initialization code
        
        counter = 0;

        menuSCView = [[MKHorizMenu alloc] initWithFrame:CGRectMake(0, 10, self.bounds.size.width, 41)];
        contentSCView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 52, self.bounds.size.width, self.bounds.size.height - 41)];
        
        [menuSCView setDelegate:self];
        [menuSCView setDataSource:self];
        [menuSCView setItemSelectedDelegate:self];
        [menuSCView setShowsHorizontalScrollIndicator:NO];
        [menuSCView setShowsVerticalScrollIndicator:NO];
        
        [contentSCView setDelegate:self];
        
        self.items = [[NSArray arrayWithArray:menusTitle] mutableCopy]; //arrayWithObjects:@"Headlines", @"UK", @"International", nil] mutableCopy];
        [menuSCView reloadData];
        
        [menuSCView setSelectedIndex:0 animated:NO];
        
         gap = contentSCView.frame.size.width;
        
        [contentSCView setPagingEnabled:YES];
        [contentSCView setBounces:NO];
        
        menuSCView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
        
        contentSCView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:menuSCView];
        [self addSubview:contentSCView];
    }
    return self;
}

#pragma mark -
#pragma mark HorizMenu Data Source
- (UIImage*) selectedItemImageForMenu:(MKHorizMenu*) tabMenu
{
    return nil;
}

- (UIColor*) backgroundColorForMenu:(MKHorizMenu *)tabView
{
    return [UIColor whiteColor];
}

- (int) numberOfItemsForMenu:(MKHorizMenu *)tabView
{
    return [self.items count];
}

- (NSString*) horizMenu:(MKHorizMenu *)horizMenu titleForItemAtIndex:(NSUInteger)index
{
    return [self.items objectAtIndex:index];
}

#pragma mark -
#pragma mark HorizMenu Delegate
-(void) horizMenu:(MKHorizMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
    CGRect frame = contentSCView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    [contentSCView scrollRectToVisible:frame animated:YES];
}

#pragma mark -
#pragma mark scrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.panGestureRecognizer.numberOfTouches == 1) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
        [menuSCView setSelectedIndex:page animated:YES];
    }
}

#pragma mark -
#pragma mark Handel ViewController

- (void) addNewViewController:(UIView *) v {
    
    [v setFrame:CGRectMake(counter * gap, 0, contentSCView.frame.size.width, contentSCView.frame.size.height)];
    
    [contentSCView addSubview:v];
    
    counter++;
    
    [contentSCView setContentSize:CGSizeMake(contentSCView.frame.size.width * [self.items count], contentSCView.frame.size.height)];
}

- (void) changeTitleColor:(UIColor *)color {
    [menuSCView setTitleColors:color];
}

- (void) changeLineColor:(UIColor *)color {
    [menuSCView setLineColor:color];
}


@end
