//
//  DescriptionViewController.m
//  RideCalendar
//
//  Created by Jerome Thomere on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DescriptionViewController.h"
#import "JServerConnect.h"

@implementation DescriptionViewController
@synthesize text;
@synthesize description;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.description.text = text;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
