//
//  SecondLevelViewController.h
//  RideCalendar
//
//  Created by Jerome Thomere on 10/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Ride.h"

#define kDescriptionRow 0
#define kLeaderRow 1
#define kStartRow 2

@interface RideViewController : UITableViewController <MKAnnotation>{
	
	UISegmentedControl *paceValue;
	UISegmentedControl *terrain;
	UILabel * date;
	UILabel * distance;
	MKMapView *start;
	
	MKPlacemark *startPlacemark;
	CLLocationCoordinate2D startLocation;
	NSDateFormatter * dateFormatter;
	UILabel *nonRidingLabel;
	UIView *rideKey;
	UIImage *rowImage;
	Ride *ride;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *paceValue;
@property (nonatomic, retain) IBOutlet UISegmentedControl *terrain;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UILabel *distance;
@property (nonatomic, retain) IBOutlet MKMapView *start;
@property (nonatomic, retain) IBOutlet UILabel *nonRidingLabel;
@property (nonatomic, retain) IBOutlet UIView *rideKey;
@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;

@property (nonatomic, retain) Ride *ride;

-(MKCoordinateRegion)startRegionFromLocation:(CLLocation *)location;

@end
