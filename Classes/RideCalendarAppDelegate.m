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

#import "XmlParser.h"
#import "XmlRideFactory.h"

#import <CFNetwork/CFNetwork.h>



@implementation RideCalendarAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize feedConnection;
@synthesize rideData;
@synthesize lastUpdatedDate;
@synthesize nextRide,currentRideObject,currentParseBatch; //currentParsedCharacterData

static NSString * const kCalendarURLString = @"http://dssf.org/dssf_html/calendar/rides-xml.php";


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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	self.feedConnection = nil;
	NSLog(@"New parsing of data");
	XmlParser *rideParser = [[XmlParser alloc] init];
	rideParser.xmlData = rideData;
	[rideParser execute];
	XmlRideFactory* factory = [[XmlRideFactory alloc] init];
	XmlElement* messageElement = [rideParser.parsedElement getElementByTagName:@"message"];
    NSLog(@"There are %d elements in the message", [messageElement.children count]);
	for (XmlElement* elt in messageElement.children) {
		[self checkObject:[factory rideFromXml:elt]];
	}
	[self saveObjectContext];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self reloadTableView];
}

/*
- (void)parseRideData:(NSData *)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.currentParseBatch = [NSMutableArray array];
	self.currentParsedCharacterData = [NSMutableString string];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	[parser parse];
	int count = [self.currentParseBatch count];
	NSLog(@"Count: %d", count);
	[self reloadTableView];
	self.currentParseBatch = nil;
	self.currentParsedCharacterData = nil;
	[parser release];
	[pool release];
}
*/


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

/*
#pragma mark Parser constants

static const const NSUInteger kMaximumNumberOfRidesToParse = 50;
static NSUInteger const KSizeOfRideBatch = 5;

static NSString * const kEntryElementName = @"item";
static NSString * const kLinkElementName = @"link";
static NSString * const kTitleElementName = @"title";
static NSString * const kRideIdElementName = @"id";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kDateElementName = @"pubDate";
static NSString * const kPaceElementName = @"pace";
static NSString * const kTerrainElementName = @"terrain";
static NSString * const kDistanceElementName = @"distance";
static NSString * const kLeaderElementName = @"leader";
static NSString * const kEmailElementName = @"email";
static NSString * const kPhoneElementName = @"phone";
static NSString * const kStartElementName = @"start";
static NSString * const kStartLatElementName = @"lat";
static NSString * const kStartLonElementName = @"lon";

static NSUInteger kPaceA = (NSUInteger)(unichar)'A';

#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
									namespaceURI:(NSString *)namespaceURI
									qualifiedName:(NSString *)qname 
									attributes:(NSDictionary *)attributeDict {
	if (parsedRideCounter >= kMaximumNumberOfRidesToParse) {
		didAbortParsing = YES;
		[parser abortParsing];
	}
	//NSLog(@"element: %@", elementName);
	if ([elementName isEqualToString:kEntryElementName]) {
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:[self managedObjectContext]];
		Ride *ride = [[Ride alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
		self.currentRideObject = ride;
		self.currentRideObject.terrainPaceCode = @"";
		[ride release];
	} else if ([self isRegularItemInsideElement:elementName]) {
        accumulatingParsedCharacterData = YES;
		//NSLog(@"started element %@", elementName);
		[currentParsedCharacterData setString:@""];
	}
}

-(BOOL)isRegularItemInsideElement:(NSString *)elementName {
	return (
			[elementName isEqualToString:kLinkElementName]
			|| [elementName isEqualToString:kRideIdElementName]
			|| [elementName isEqualToString:kTitleElementName]
			|| [elementName isEqualToString:kDescriptionElementName]
			|| [elementName isEqualToString:kDateElementName]
			|| [elementName isEqualToString:kPaceElementName]
			|| [elementName isEqualToString:kTerrainElementName]
			|| [elementName isEqualToString:kDistanceElementName]
			|| [elementName isEqualToString:kStartElementName]
			|| [elementName isEqualToString:kStartLatElementName]
			|| [elementName isEqualToString:kStartLonElementName]
			|| [elementName isEqualToString:kLeaderElementName]
			|| [elementName isEqualToString:kEmailElementName]
			|| [elementName isEqualToString:kPhoneElementName]
	);
}
*/

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
/*
 -(void)checkNextRide:(Ride *)ride  {
 if (self.nextRide == nil) {
 NSLog(@"self.nextRide = %@", ride);
 self.nextRide = ride;
 return;
 }
 NSDate *testDate = ride.date;
 NSDate *today = [NSDate date];
 NSLog(@"checkNextRide today=%@ testDate=%@ nextRide.date=%@", today, testDate, self.nextRide.date);
 NSLog(@"today compare:testDate=%d", [today compare:testDate]);
 NSLog(@"[testDate compare:self.nextRide.date]=%d", [testDate compare:self.nextRide.date]);
 if (([today compare:testDate] == NSOrderedAscending) //ride is in the future
 && ([testDate compare:self.nextRide.date] == NSOrderedAscending)) // but it is before what we thought was the next ride
 {
 NSLog(@"self.nextRide = %@", ride);
 self.nextRide = ride;
 }
 
 }
 */

-(void)checkAllRides {
	/*	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:managedObjectContext];
	 [request setEntity:entity];
	 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	 NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	 [request setSortDescriptors:sortDescriptors];
	 NSError *error;
	 [managedObjectContext executeFetchRequest:request error:&error]
	 */
	NSEnumerator* rideEnumerator = [[self.managedObjectContext registeredObjects] objectEnumerator];
	Ride *ride;
	while (ride = [rideEnumerator nextObject]) {
		[self checkNextRide];
	}
}

/*
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
									namespaceURI:(NSString *)namespaceURI
									qualifiedName:(NSString *)qname {
	if ([elementName isEqualToString:kEntryElementName]) {
        [self.currentParseBatch addObject:self.currentRideObject];
		[self checkObject:self.currentRideObject];
		parsedRideCounter++;
		//[self.currentRideObject outputToLog];
	}else if ([elementName isEqualToString:kRideIdElementName]) {
		self.currentRideObject.rideId = [self.currentParsedCharacterData copy];
	}else if ([elementName isEqualToString:kLinkElementName]) {
		self.currentRideObject.link = [self.currentParsedCharacterData copy];
	}else if ([elementName isEqualToString:kLeaderElementName]) {
		self.currentRideObject.leader = [self.currentParsedCharacterData copy];
	}else if ([elementName isEqualToString:kPhoneElementName]) {
		self.currentRideObject.phone = [self.currentParsedCharacterData copy];
	}else if ([elementName isEqualToString:kEmailElementName]) {
		self.currentRideObject.email = [self.currentParsedCharacterData copy];
	}else if ([elementName isEqualToString:kTitleElementName]) {
		self.currentRideObject.title = [NSString stringWithString:self.currentParsedCharacterData];
	}else if ([elementName isEqualToString:kDescriptionElementName]) {
		self.currentRideObject.descString = [self.currentParsedCharacterData copy];
	} else if ([elementName isEqualToString:kDateElementName]) {
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
		self.currentRideObject.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
		[dateFormatter setDateFormat:@"LLLL YYYY"];
		self.currentRideObject.month = [dateFormatter stringFromDate:self.currentRideObject.date];
	} else if ([elementName isEqualToString:kPaceElementName]) {
		self.currentRideObject.pace = [NSNumber numberWithInt:[self.currentParsedCharacterData characterAtIndex:0] - kPaceA];
		self.currentRideObject.terrainPaceCode = [self.currentParsedCharacterData stringByAppendingString:self.currentRideObject.terrainPaceCode];
	} else if ([elementName isEqualToString:kTerrainElementName]) {
		self.currentRideObject.terrain = [NSNumber numberWithInt:[self.currentParsedCharacterData integerValue] - 1];
		self.currentRideObject.terrainPaceCode = [self.currentRideObject.terrainPaceCode stringByAppendingString:self.currentParsedCharacterData];
	} else if ([elementName isEqualToString:kDistanceElementName]) {
		if ([self.currentParsedCharacterData length] == 0) {
			self.currentRideObject.distance = [NSDecimalNumber zero];
		}else {
			self.currentRideObject.distance = [NSDecimalNumber decimalNumberWithString:self.currentParsedCharacterData];
		}
	} else if ([elementName isEqualToString:kStartElementName]) {
		self.currentRideObject.start = [NSString stringWithString:self.currentParsedCharacterData];
	} else if ([elementName isEqualToString:kStartLatElementName]) {
		self.currentRideObject.startLat = [NSDecimalNumber decimalNumberWithString:self.currentParsedCharacterData];
	} else if ([elementName isEqualToString:kStartLonElementName]) {
		self.currentRideObject.startLon = [NSDecimalNumber decimalNumberWithString:self.currentParsedCharacterData];
	}
	accumulatingParsedCharacterData = NO;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // If the number of ride records received is greater than kMaximumNumberOfEarthquakesToParse, we abort parsing.
    // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
    // how we distinguish real errors encountered by the parser.
	if (didAbortParsing = YES) {
		NSLog(@"didAbortParsing: YES");
	}
	else {
		NSLog(@"didAbortParsing: NO");
	}
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        //[self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
		[self handleError:parseError];
    }
}
*/
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

