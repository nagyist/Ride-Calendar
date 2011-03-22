//
//  RootViewController.h
//  RideCalendar
//
//  Created by Jerome Thomere on 10/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Ride.h"

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	
	NSFetchedResultsController *resultsController;
	NSDateFormatter * dateFormatter;
}

@property (nonatomic, retain) NSFetchedResultsController *resultsController;
@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;

@end
