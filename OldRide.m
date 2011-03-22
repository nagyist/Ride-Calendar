//
//  Ride.m
//  RideCalendar
//
//  Created by Jerome Thomere on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OldRide.h"


@implementation OldRide

@synthesize link;
@synthesize rideId;
@synthesize title;
@synthesize descString;
@synthesize leader;
@synthesize email;
@synthesize phone;
@synthesize date;
@synthesize pace;
@synthesize terrain;
@synthesize terrainPaceCode;
@synthesize distance;
@synthesize start;
@synthesize startLat;
@synthesize startLon;

-(void)dealloc {
	[link release];
	[rideId release];
	[title release];
	[descString release];
	[date release];
	[leader release];
	[email release];
	[phone release];
	[start release];
	[terrainPaceCode release];
	[startLat release];
	[startLon release];
	[distance release];
	[super dealloc];
}

-(id)init
{
    if (self = [super init])
    {
		self.link = @"";
		self.rideId = @"";
		self.title = @"";
		self.descString = @"";
		self.leader = @"";
		self.email = @"";
		self.phone = @"";
		self.start = @"";
		self.terrainPaceCode = @"";
    }
    return self;
}

-(void)outputToLog {
	NSLog(@"Begin Ride");
	NSLog(@"   title: %@", title);
	NSLog(@"    date: %@", date);
	NSLog(@"    link: %@", link);
	NSLog(@"    leader: %@ (#@) #@", leader, email, phone);
	NSLog(@"    link: %@", link);
	NSLog(@"    pace: %d", pace);
	NSLog(@" terrain: %d", terrain);
	NSLog(@"    code: %@", terrainPaceCode);
	NSLog(@"End Ride");
}

-(NSDateComponents *)dateComponents {
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	return [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
}

-(BOOL)isRideInMonth: (NSUInteger)month {
	return ([[self dateComponents] month] == month);
}

-(void) updateToRide:(NSManagedObject *)rideObject {
	Ride* ride = (Ride *)rideObject;
	OldRide *oldRide = self;
	ride.rideId = [NSString stringWithString:oldRide.rideId];
	ride.start = [NSString stringWithString:oldRide.start];
	ride.phone = [NSString stringWithString:oldRide.phone];
	ride.leader = [NSString stringWithString:oldRide.leader];
	ride.link =[NSString stringWithString:oldRide.link];
	ride.title = [NSString stringWithString:oldRide.title];
	ride.descString = [NSString stringWithString:oldRide.descString];
	ride.email = [NSString stringWithString:oldRide.email];
	ride.terrainPaceCode = [NSString stringWithString:oldRide.terrainPaceCode];
	ride.terrain = [NSNumber numberWithInteger:oldRide.terrain];
	ride.pace = [NSNumber numberWithInteger:oldRide.pace];
	ride.distance = [oldRide.distance copy];
	ride.startLat = [oldRide.startLat copy];
	ride.startLon = [oldRide.startLon copy];
	ride.date = [oldRide.date copy];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"LLLL YYYY"];
	ride.month = [dateFormatter stringFromDate:oldRide.date];
	NSLog(@"month [%@]->[%@]", oldRide.date, ride.month);
}

@end
