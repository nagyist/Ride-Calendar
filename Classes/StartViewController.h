//
//  StartViewController.h
//  RideCalendar
//
//  Created by Jerome Thomere on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface StartViewController : UIViewController <MKAnnotation> {
    IBOutlet MKMapView *mapView;
	IBOutlet UITextView *description;
	NSString *text;
	MKCoordinateRegion region;
}

@property (nonatomic) MKCoordinateRegion region;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) MKMapView *mapView;

-(NSString *)extractAddress: (NSString *)txtString;
-(IBAction) goToGoogle: (id)sender;
@end
