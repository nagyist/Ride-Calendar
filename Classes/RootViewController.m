//
//  RootViewController.m
//  RideCalendar
//
//  Created by Jerome Thomere on 10/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "RideViewController.h"
#import "Ride.h"
#import "RideCalendarAppDelegate.h"


@implementation RootViewController

@synthesize resultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(goToToday:)];
	self.tableView.rowHeight = 50;
	self.title = @"Rides";
	NSError *error;
	if (![[self resultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	RideCalendarAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate checkAllRides];
	NSLog(@"nextRide.date=%@", appDelegate.nextRide.date);
}

- (void) goToToday:(id)target {
	RideCalendarAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if (appDelegate.nextRide != nil) {
		NSLog(@"RideCalendarAppDelegate goToToday nextRide.date=%@", appDelegate.nextRide.date);
		//NSLog(@"nextRide=%@", self.nextRide);
		NSIndexPath *nextRideIndexPath = [self.resultsController indexPathForObject:appDelegate.nextRide];
		NSLog(@"RideCalendarAppDelegate goToToday nextRideIndexPath=%@", nextRideIndexPath);
		[self.tableView scrollToRowAtIndexPath:nextRideIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

- (NSDateFormatter *)dateFormatter {
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE dd  'at'   hh:mm aaa"];
	}
	return dateFormatter;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table view methods with fetchedResultsController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	[self.tableView reloadData];
}

- (NSFetchedResultsController *)resultsController {
	if (resultsController != nil) {
		return resultsController;
	}
	RideCalendarAppDelegate *appDelegate = (RideCalendarAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	// Create and configure a fetch request with the Ride entity.
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"month" cacheName:nil];
	[request release];
	self.resultsController = fetchedResultsController;
	[fetchedResultsController release];
	resultsController.delegate = self;
	return resultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//NSLog(@"numberOfSectionsInTableView=%d",  [[self.resultsController sections] count]);
	return [[self.resultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.resultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDateFormatter *monthFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [monthFormatter setDateFormat:@"yyyy-MM"];
    NSString *monthName = [[[self.resultsController sections] objectAtIndex:section] name];
    NSDate* month = [monthFormatter dateFromString:monthName];
    [monthFormatter setDateFormat:@"LLLL yyyy"];
    monthName = [monthFormatter stringFromDate:month];
    return monthName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Ride *ride = [self.resultsController objectAtIndexPath:indexPath];
	static NSUInteger const kDateTag = 3;
	static NSUInteger const kTitleTag = 4;
	UILabel *dateLabel = nil;
    UILabel *titleLabel = nil;
	NSString *CellIdentifier;
    if ([ride.date compare:[NSDate date]] < 1) {
        CellIdentifier = @"RideCellID";
	} else {
        CellIdentifier = @"PastRideCellID";
	}

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 3, 190, 14)];
		dateLabel.tag = kDateTag;
		dateLabel.font = [UIFont systemFontOfSize:13];
        if ([ride.date compare:[NSDate date]] < 1) {
            dateLabel.textColor = [UIColor blackColor];
        } else {
            cell.backgroundColor =[UIColor lightGrayColor];
        }
		dateLabel.textAlignment = UITextAlignmentRight;
		[cell.contentView addSubview:dateLabel];
		[dateLabel release];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 28, 230, 20)];
		titleLabel.tag = kTitleTag;
		titleLabel.font = [UIFont boldSystemFontOfSize:14];
		[cell.contentView addSubview:titleLabel];
		[titleLabel release];
		
    } else {
		dateLabel = (UILabel *)[cell.contentView viewWithTag:kDateTag];
		titleLabel = (UILabel *)[cell.contentView viewWithTag:kTitleTag];
	}
	//[self tableView:tableView numberOfRowsInSection:[indexPath section]];
	//NSLog(@"Section %d row %d", [indexPath section], [indexPath row]);
	if ([ride.distance floatValue] > 0) {
		NSString *codePng = [[NSString stringWithFormat:@"%@.png", ride.terrainPaceCode] lowercaseString];
		UIImage *rideImage = [UIImage imageNamed:codePng];
		cell.imageView.image = rideImage;		
	}
	dateLabel.text = [self.dateFormatter stringFromDate:ride.date];
	if ([ride.date compare:[NSDate date]] < 1) {
		dateLabel.textColor = [UIColor blackColor];
	} else {
		dateLabel.textColor = [UIColor blueColor];
	}

	titleLabel.text = ride.title;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RideViewController *controller = [[RideViewController alloc] initWithNibName:@"RideLevelViewController" bundle:nil];
	Ride *ride = (Ride *)[self.resultsController objectAtIndexPath:indexPath];
	controller.ride = ride;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)dealloc {
    [super dealloc];
	[resultsController release];
	[dateFormatter release];
}

@end

