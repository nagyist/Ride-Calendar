//
//  Ride.h
//  RideCalendar
//
//  Created by Jerome Thomere on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ride.h"


@interface OldRide : NSObject {
	NSString *link;
	NSString *rideId;
	NSString *title;
	NSString *descString;
	NSDate *date;
	NSString *leader;
	NSString *phone;
	NSString *email;
	NSUInteger pace;
	NSUInteger terrain;
	NSString *terrainPaceCode;
	NSDecimalNumber *distance;
	NSString *start;
	NSDecimalNumber * startLat;
	NSDecimalNumber * startLon;

}

@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *rideId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *descString;
@property (nonatomic, retain) NSString *leader;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) NSUInteger pace;
@property (nonatomic, assign) NSUInteger terrain;
@property (nonatomic, retain) NSString *terrainPaceCode;
@property (nonatomic, retain) NSDecimalNumber *distance;
@property (nonatomic, retain) NSString *start;
@property (nonatomic, retain) NSDecimalNumber * startLat;
@property (nonatomic, retain) NSDecimalNumber * startLon;

-(void)outputToLog;
-(NSDateComponents *)dateComponents;
-(BOOL)isRideInMonth: (NSUInteger)month;
-(void) updateToRide:(NSManagedObject *)rideObject;

	
@end
