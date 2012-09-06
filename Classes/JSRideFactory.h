//
//  JSRideFactory.h
//  RideCalendar
//
//  Created by Jerome Thomere on 9/2/12.
//
//

#import <Foundation/Foundation.h>
#import "Ride.h"

@interface JSRideFactory : NSObject
@property (nonatomic, retain) Ride* ride;
@property (nonatomic, retain) NSManagedObjectContext *context;

- (void) updateRidesWithArray:(NSArray *)rideDictArrays;

@end
