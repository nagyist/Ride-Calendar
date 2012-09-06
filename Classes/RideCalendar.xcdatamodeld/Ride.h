//
//  Ride.h
//  RideCalendar
//
//  Created by Jerome Thomere on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Ride :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * terrainPaceCode;
@property (nonatomic, retain) NSString * start;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * leader;
@property (nonatomic, retain) NSNumber * terrain;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * rideId;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * startLon;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * descString;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * startLat;
@property (nonatomic, retain) NSString * month;
@property (nonatomic, retain) NSDecimalNumber * distance;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * pace;

@end



