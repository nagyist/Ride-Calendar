//
//  StartViewController.m
//  RideCalendar
//
//  Created by Jerome Thomere on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StartViewController.h"


@implementation StartViewController
@synthesize text, mapView, region;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *goToGoogleButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"View in Maps" style:UIBarButtonItemStyleBordered target:self action:@selector(goToGoogle:)];
    [self.navigationItem setRightBarButtonItem:goToGoogleButtonItem];
    [goToGoogleButtonItem release];
}


-(void)viewWillAppear:(BOOL)animated {
	description.text = text;
	[mapView addAnnotation:self];
	mapView.region = region;
}
-(CLLocationCoordinate2D)coordinate {
	return region.center;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(IBAction) goToGoogle: (id)sender {
	static NSString * const kMapsBaseURL = @"http://maps.google.com/maps?";
	NSString *mapsQuery = [NSString stringWithFormat:@"oi=map&q=%@", [self extractAddress:text]];
	mapsQuery = [mapsQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *mapsURLString = [kMapsBaseURL stringByAppendingString:mapsQuery];
	//NSLog(@"mapsURLString=%@", mapsURLString);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURLString]];
}

-(NSString *)extractAddress: (NSString *)txtString {
	NSRange range = [txtString rangeOfString:@"("];
	if (range.location != NSNotFound) {
		return [txtString substringWithRange:NSMakeRange(0, range.location)];
	}
	return txtString;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[text release];
    [super dealloc];
}


@end
