//
//  RideCalendarAppDelegate.m
//  RideCalendar
//
//  Created by Jerome Thomere on 10/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RideCalendarAppDelegate.h"
#import "RootViewController.h"
#import "Ride.h"
#import "JServerConnect.h"

#import <CFNetwork/CFNetwork.h>



@implementation RideCalendarAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize feedConnection;
@synthesize rideData;
@synthesize lastUpdatedDate;
@synthesize nextRide,currentRideObject,currentParseBatch; //currentParsedCharacterData

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	[window addSubview:[navigationController view]];
	[self reloadTableView];
    JServerConnect *connect = [[JServerConnect alloc] init];
    [connect asyncFetchRides];
    /*
	NSString* updatedURLString = [NSString stringWithFormat:@"%@?updatedafter=2010-03-23", kCalendarURLString];
	NSLog(@"updatedURLString=%@", updatedURLString);
	NSURLRequest *rideRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:updatedURLString]];
	self.feedConnection = [[[NSURLConnection alloc] initWithRequest:rideRequest delegate:self] autorelease];
	
	NSAssert(self.feedConnection != nil, @"Failure to create URL Connection.");

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     */
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	[self saveObjectContext];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[self saveObjectContext];
}

- (void)saveObjectContext {
    NSLog(@"RideCalendarAppDelegate.h saveObjectContext");
	NSError *error = nil;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
			NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
			if(detailedErrors != nil && [detailedErrors count] > 0) {
				for(NSError* detailedError in detailedErrors) {
					NSLog(@"  DetailedError: %@", [detailedError userInfo]);
				}
			}
			else {
				NSLog(@"  %@", [error userInfo]);
			}
			abort();
			
		}
	}
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.rideData = [NSMutableData data];
	//NSLog(@"@%@",self.rideData);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[rideData appendData:data];
	//NSLog(@"@%@",self.rideData);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if ([error code] == kCFURLErrorNotConnectedToInternet) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  NSLocalizedString(@"You are not connected to the internet",
								  @"Error message displayed when not connected to the Internet."),
								  NSLocalizedDescriptionKey,
								  NSLocalizedString(@"Using the ride calendar in memory",
													@"Error message displayed when not connected to the Internet."),
								  NSLocalizedRecoverySuggestionErrorKey,
								  nil];
		NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain 
														 code:kCFURLErrorNotConnectedToInternet 
													 userInfo:userInfo];
		[self handleError:noConnectionError];
	} else {
		[self handleError:error];
	}
	self.feedConnection = nil;

}

- (void)handleError:(NSError *)error {
	NSString *errorMessage = [error localizedDescription];
	NSString *suggestion = [error localizedRecoverySuggestion];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorMessage
													message:suggestion 
													delegate:nil
													cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)reloadTableView {
	[rootViewController.tableView reloadData];
	[self checkNextRide];
	if (self.nextRide != nil) {
		NSLog(@"RideCalendarAppDelegate reloadTableView nextRide.date=%@", self.nextRide.date);
		//NSLog(@"nextRide=%@", self.nextRide);
		NSIndexPath *nextRideIndexPath = [rootViewController.resultsController indexPathForObject:self.nextRide];
		NSLog(@"RideCalendarAppDelegate reloadTableView nextRideIndexPath=%@", nextRideIndexPath);
		[rootViewController.tableView scrollToRowAtIndexPath:nextRideIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}

}

-(void) checkObject:(Ride *)ride {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:self.managedObjectContext];	
	[request setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rideId == %@", ride.rideId];
	[request setPredicate:predicate];
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	[request release];
	if (mutableFetchResults == nil) {
		// Handle the error
	}
	//NSUInteger count = [mutableFetchResults count];
	//NSLog(@"There are %d results", count);
	//NSLog(@"ridesWithRideId %@: %@", ride.rideId, [self ridesWithRideId:ride.rideId]);
	for (Ride *r in mutableFetchResults) {
		//NSLog(@"r==ride -> [%d]", (r == ride));
		if (r != ride) {
			NSLog(@"Deleting %@", r.date);
			if (nextRide == r) {
				self.nextRide = ride;
			}
			[managedObjectContext deleteObject:r];
		}
	}
	[mutableFetchResults release];
	[self checkNextRide];
}

-(NSArray *) ridesWithRideId:(NSString *)rideId {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:self.managedObjectContext];	
	[request setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rideId == %@", rideId];
	[request setPredicate:predicate];
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	[request release];
	return mutableFetchResults;
}

-(void)checkNextRide {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	NSPredicate *future = [NSPredicate predicateWithFormat:@"date >= %@", [NSDate date]];
	[request setSortDescriptors:sortDescriptors];
	[request setPredicate:future];
	NSError *error;
	NSMutableArray *mutableResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableResults == nil) {
		NSLog(@"Fetch error = %@", error);
	}
	//NSLog(@"%d objects after today", [mutableResults count]);
	if ([mutableResults count] >= 1) {
		self.nextRide = (Ride *)[mutableResults objectAtIndex:0];
	} else {
		self.nextRide = nil;
	}

} 

-(void)checkAllRides {
	NSEnumerator* rideEnumerator = [[self.managedObjectContext registeredObjects] objectEnumerator];
	Ride *ride;
	while (ride = [rideEnumerator nextObject]) {
		[self checkNextRide];
	}
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"rideCalendar.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        //erase the store when the schema is invalid
        NSLog(@"addPersistentStoreWithType error %@, trying to delete the store at %@", [error userInfo], storeUrl);
		[[NSFileManager defaultManager] removeItemAtURL:storeUrl error:nil];
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
            
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible
             * The schema for the persistent store is incompatible with current managed object model
             Check the error message to determine what the actual problem was.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
	
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[feedConnection release];
	[nextRide release];
    [lastUpdatedDate release];
	[rideData release];
	[navigationController release];
	[rootViewController release];
	[window release];
	//[currentParsedCharacterData release];
	//[currentParseBatch release];
	[managedObjectModel release];
	[managedObjectContext release];
	[super dealloc];
}


@end

