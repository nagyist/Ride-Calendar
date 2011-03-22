//
//  XmlRideReader.h
//  RideCalendar
//
//  Created by Jerome Thomere on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlElement.h"
#import "Ride.h"


@interface XmlRideFactory : NSObject {

	NSManagedObjectContext *context;
	XmlElement* source;
	Ride* ride;
}

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) XmlElement* source;
@property (nonatomic, retain) Ride* ride;

-(Ride *)rideFromXml:(XmlElement *)element;
-(void) fillUpRidefromElement:(XmlElement *)geneElement;

@end
