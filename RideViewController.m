//
//  SecondLevelViewController.m
//  RideCalendar
//
//  Created by Jerome Thomere on 10/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RideViewController.h"
#import "CoreLocation/CLLocation.h"
#import "DescriptionViewController.h"
#import "StartViewController.h"
#import "ContactScanner.h"


@implementation RideViewController

@synthesize ride;

@synthesize paceValue;
@synthesize terrain;
@synthesize date;
@synthesize distance;
@synthesize start;
@synthesize nonRidingLabel, rideKey;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)dealloc {
	[ride release];
	[paceValue release];
	[nonRidingLabel release];
	[rideKey release];
	[dateFormatter release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSDateFormatter *)dateFormatter {
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE, MMM dd     hh:mm aaa"];
	}
	return dateFormatter;
}



- (void)viewWillAppear:(BOOL)animated { 
	//[ride outputToLog];
	self.title = [self.ride.title copy];
	//[self.paceValue setEnabled:YES forSegmentAtIndex:[ride.pace intValue]];
	self.date.text = [self.dateFormatter stringFromDate:ride.date];
	self.distance.text = [NSString stringWithFormat:@"%@", ride.distance];
	self.paceValue.selectedSegmentIndex = [ride.pace intValue];
	self.terrain.selectedSegmentIndex = [ride.terrain intValue];
	if (self.ride.distance == [NSDecimalNumber zero]) {
		self.nonRidingLabel.text = @"Non riding event";
		[self.rideKey bringSubviewToFront:self.nonRidingLabel];
	} 
	//NSLog(@"startLon=%@", ride.startLon);
	if (ride.startLon != 0) {
		CLLocation *location = [[CLLocation alloc] 
								initWithLatitude:[ride.startLat doubleValue]
								longitude:[ride.startLon doubleValue]];
		startLocation = location.coordinate;
		self.start.region = [self startRegionFromLocation:location];
		[start addAnnotation:self];
		[location release];
	} else {
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 190, 30)];
		dateLabel.font = [UIFont systemFontOfSize:19];
		dateLabel.textAlignment = UITextAlignmentCenter;
		[self.start addSubview:dateLabel];
		dateLabel.text = @"Location not found";
		[dateLabel release];
	}
}

-(MKCoordinateRegion)startRegionFromLocation:(CLLocation *)location {
	MKCoordinateRegion region;
	region.center = location.coordinate;
	//Set Zoom level using Span
	MKCoordinateSpan span;
	span.latitudeDelta=.020;
	span.longitudeDelta=.010;
	region.span=span;
	return region;
}

-(CLLocationCoordinate2D)coordinate {
	return start.region.center;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.paceValue = nil;
	self.ride = nil;
}

#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	//UILabel *label = [[UILabel alloc] initWithFrame:  CGRectMake(10, 10, 260, 30)];
	//label.textAlignment = UITextAlignmentRight;
	//[cell.contentView addSubview:label];
	UILabel *label = cell.textLabel;
	label.font = [UIFont systemFontOfSize:15];
	NSUInteger row = [indexPath row];
	switch (row) {
		case kDescriptionRow:
			label.numberOfLines = 2;
			label.text = [NSString stringWithString:ride.descString];
			break;
		case kLeaderRow:
			label.numberOfLines = 2;
			label.text = [NSString stringWithString:ride.leader];
			cell.imageView.image = [UIImage imageNamed:@"rsvp.png"];
			break;
		case kStartRow:
			label.numberOfLines = 2;
			label.text = [NSString stringWithString:ride.start];
			cell.imageView.image = [UIImage imageNamed:@"map.png"];
			break;
			
		default:
			break;
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	switch (row) {
		case kDescriptionRow:{
			DescriptionViewController *controller = [[DescriptionViewController alloc] initWithNibName:@"DescriptionViewController" bundle:nil];
			controller.title = @"Description";
			controller.text = self.ride.descString;
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
		}
			break;
		case kLeaderRow:{
			DescriptionViewController *controller = [[DescriptionViewController alloc] initWithNibName:@"DescriptionViewController" bundle:nil];
			controller.title = @"Leader(s)";
			NSMutableArray *strArray = [NSMutableArray arrayWithCapacity:12];
			for (ContactScanner * leaderScan = [ContactScanner contactScannerWithString:self.ride.leader]; [leaderScan hasMore]; ) {
				[strArray addObject:[NSMutableString stringWithString:[leaderScan next]]];
			}
			//NSLog(@"Array=%@", strArray);
			int i = 0;
			for (ContactScanner * mailScan = [ContactScanner contactScannerWithString:self.ride.email]; [mailScan hasMore]; i++) {
				if (i >= [strArray count]) {
					[strArray addObject:[NSMutableString stringWithString:@""]];
				}
				[[strArray objectAtIndex:i] appendString:@"\n"];
				[[strArray objectAtIndex:i] appendString:[mailScan next]];
			}
			//NSLog(@"Array=%@", strArray);
			i = 0;
			for (ContactScanner * phoneScan = [ContactScanner contactScannerWithString:self.ride.phone]; [phoneScan hasMore]; i++) {
				if (i >= [strArray count]) {
					[strArray addObject:[NSMutableString stringWithString:@""]];
				}
				[[strArray objectAtIndex:i] appendString:@"\ntel://"];
				[[strArray objectAtIndex:i] appendString:[phoneScan next]];
			}
			//NSLog(@"Array=%@", strArray);
			NSMutableString *leaderStr = [NSMutableString stringWithString:@"Leader(s):\n\n"];
			for (NSString *line in strArray) {
				[leaderStr appendString:line];
				[leaderStr appendString:@"\n\n"];
			}
			[leaderStr appendString:@"\n\nTo RSVP, just click on one of the links (email or phone) above."];
			//NSLog(@"leaderstr=[%@]", leaderStr); 
			controller.text = leaderStr;
			
			//controller.text = [NSString stringWithFormat:@"Leaders:\n%@\n%@\n%@", self.ride.leader, self.ride.email, self.ride.phone];
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
		}
			break;

		case kStartRow:{
			StartViewController *controller = [[StartViewController alloc] initWithNibName:@"StartViewController" bundle:nil];
			controller.text = self.ride.start;
			controller.title = @"Start";
			//NSLog(@"start.region=%d", start.region.span.latitudeDelta);
			controller.region = start.region;
			//NSLog(@"controller.mapView.region=%d", controller.mapView.region.span.latitudeDelta);
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
		}
			break;
			
		default:
			break;
	}
}


@end

