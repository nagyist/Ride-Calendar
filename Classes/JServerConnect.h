//
//  JsonTest.h
//  RideCalendar
//
//  Created by Jerome Thomere on 8/31/12.
//
//

#import <Foundation/Foundation.h>

@interface JServerConnect : NSObject {
    
	NSMutableData *data;
    NSString *requestUrlString;

}

- (void) asyncFetchRides;

@end
