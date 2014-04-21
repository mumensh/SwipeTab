//
//  MKHorizMenu.m
//  MKHorizMenuDemo
//  Created by Mugunth on 09/05/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/8h on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKHorizMenu.h"
#define kButtonBaseTag 10000
#define kLeftOffset 70

@implementation MKHorizMenu

@synthesize titles = _titles;
@synthesize selectedImage = _selectedImage;

@synthesize itemSelectedDelegate;
@synthesize dataSource;
@synthesize itemCount = _itemCount;

-(void) awakeFromNib
{
    self.bounces = YES;
    self.scrollEnabled = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [self reloadData];
}
     
-(void) reloadData
{
    NSArray *viewsToRemove = [self subviews];
	for (UIView *v in viewsToRemove) {
		[v removeFromSuperview];
	}
    
    self.itemCount = [dataSource numberOfItemsForMenu:self];
    self.backgroundColor = [dataSource backgroundColorForMenu:self];
    self.selectedImage = [dataSource selectedItemImageForMenu:self];
    
    line = [[UIView alloc] initWithFrame:CGRectZero];
    [line setBackgroundColor:[UIColor redColor]];

    UIFont *buttonFont = [UIFont boldSystemFontOfSize:15];
    int buttonPadding = kLeftOffset;
    
    int tag = kButtonBaseTag;    
    int xPos = kLeftOffset;

    for(int i = 0 ; i < self.itemCount; i ++)
    {
        NSString *title = [dataSource horizMenu:self titleForItemAtIndex:i];
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton setTitle:title forState:UIControlStateNormal];
        [customButton setTitleColor:[ConstantMethods colorWithHexString:@"bf343a"] forState:UIControlStateNormal];
        [customButton setTitleColor:[ConstantMethods colorWithHexString:@"bf343a"] forState:UIControlStateSelected];
        customButton.titleLabel.font = buttonFont;
        
        [customButton setBackgroundImage:self.selectedImage forState:UIControlStateSelected];
        
        customButton.tag = tag++;
        [customButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        int buttonWidth = [title sizeWithFont:customButton.titleLabel.font
                            constrainedToSize:CGSizeMake(150, 28) 
                                lineBreakMode:UILineBreakModeClip].width;
        
        customButton.frame = CGRectMake(xPos, 7, buttonWidth + buttonPadding, 28);
        xPos += buttonWidth;
        xPos += buttonPadding;
        [self addSubview:customButton];        
    }
    
    // bretdabaker: added right padding to contentSize
    xPos += kLeftOffset;
    
    self.contentSize = CGSizeMake(xPos, 41);
    [self layoutSubviews];  
}


-(void) setSelectedIndex:(int) index animated:(BOOL) animated
{
    [line removeFromSuperview];
    UIButton *thisButton = (UIButton*) [self viewWithTag:index + kButtonBaseTag];
    [line setFrame:CGRectMake(thisButton.frame.origin.x, self.frame.size.height - 2, thisButton.frame.size.width, 2)];
    
    [self addSubview:line];
    [self unselectAll];
    thisButton.selected = YES;
    [self setContentOffset:CGPointMake(thisButton.frame.origin.x - (kLeftOffset * 1.2), 0) animated:animated];
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:index];
}

- (void) unselectAll {
    for (int x =0; x < self.itemCount; x++) {
        UIButton *thisButton = (UIButton*) [self viewWithTag:x + kButtonBaseTag];
        thisButton.selected = NO;
    }
}

-(void) buttonTapped:(id) sender
{
    UIButton *button = (UIButton*) sender;
    [line removeFromSuperview];
    
    for(int i = 0; i < self.itemCount; i++)
    {
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        if(i + kButtonBaseTag == button.tag) {
            thisButton.selected = YES;
            [line setFrame:CGRectMake(thisButton.frame.origin.x, self.frame.size.height - 2, thisButton.frame.size.width, 2)];
            [self addSubview:line];
            [self setContentOffset:CGPointMake(thisButton.frame.origin.x - (kLeftOffset * 1.2), 0) animated:YES];
        }
        else {
            thisButton.selected = NO;
        }
    }
    
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
}

- (void) setTitleColors:(UIColor *)titleColor {
    
    int tag = kButtonBaseTag;
    for(int i = 0 ; i < self.itemCount; i ++)
    {
        UIButton *btn = (UIButton *)[self viewWithTag:tag++];
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setTitleColor:titleColor forState:UIControlStateSelected];
    }
}

- (void) setLineColor:(UIColor *)color {
    [line setBackgroundColor:color];
}

- (void)dealloc
{
    [_selectedImage release];
    _selectedImage = nil;
    [_titles release];
    _titles = nil;
    
    [super dealloc];
}

@end
