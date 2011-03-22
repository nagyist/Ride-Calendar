//
//  RideCalendarAppDelegate.h
//  RideCalendar
//
//  Created by Jerome Thomere on 10/18/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Ride, RootViewController;

@interface RideCalendarAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	RootViewController *rootViewController;

	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;	

	NSURLConnection *feedConnection;
	NSMutableData *rideData;
	
	Ride *currentRideObject;
	Ride *nextRide;
	NSMutableArray *currentParseBatch;
	NSUInteger parsedRideCounter;
	//NSMutableString *currentParsedCharacterData;
	BOOL accumulatingParsedCharacterData;
	BOOL didAbortParsing;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSURLConnection *feedConnection;
@property (nonatomic, retain) NSMutableData *rideData;
@property (nonatomic, retain) Ride *nextRide;

@property (nonatomic, retain) Ride *currentRideObject;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
//@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;


- (NSString *)applicationDocumentsDirectory;

//- (BOOL)isRegularItemInsideElement:(NSString *)elementName;
//- (void)parseRideData:(NSData *)data;
- (void)reloadTableView;
//- (void)addRidesToList:(NSArray *)rides;
- (void)handleError:(NSError *)error;
-(void) checkObject:(Ride *)ride;
-(NSArray *) ridesWithRideId:(NSString *)rideId;
-(void)checkNextRide;
-(void)checkAllRides;

- (void)saveObjectContext;

@end

