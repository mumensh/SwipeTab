//
//  ViewController.m
//  SwipeTab
//
//  Created by Mumen Shabaro on 4/1/14.
//  Copyright (c) 2014 Mumen Shabaro. All rights reserved.
//

#import "ViewController.h"
#import "SwipeControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    SwipeControl *control = [[SwipeControl alloc] initWithMenu:[NSArray arrayWithObjects:@"Item 1", @"Item 2", @"Item 3", @"Item 4", nil]];
    
    for (int x = 0; x < [[control items] count]; x++) {
        UIView *cViews = [[UIView alloc] init];
        
        [cViews setBackgroundColor:[ConstantMethods randomColor]];
        
        cViews.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
        
        [control addNewViewController:cViews];
    }
    
        //example of changing the color of the items
    [control changeTitleColor:[UIColor blueColor]];
    
        //example of changing the color of the line
    [control changeLineColor:[UIColor blackColor]];
    
    [self.view addSubview:control];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
