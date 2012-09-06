//
//  JSRideFactory.m
//  RideCalendar
//
//  Created by Jerome Thomere on 9/2/12.
//
//

#import "JSRideFactory.h"
#import "RideCalendarAppDelegate.h"

@implementation JSRideFactory

static NSString * const kEntryElementName = @"item";
static NSString * const kLinkElementName = @"link";
static NSString * const kTitleElementName = @"title";
static NSString * const kRideIdElementName = @"rideid";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kDateElementName = @"date";
static NSString * const kTimeElementName = @"time";
static NSString * const kPaceElementName = @"pace";
static NSString * const kTerrainElementName = @"terrain";
static NSString * const kDistanceElementName = @"distance";
static NSString * const kLeaderElementName = @"leader";
static NSString * const kEmailElementName = @"email";
static NSString * const kPhoneElementName = @"phone";
static NSString * const kStartElementName = @"start";
static NSString * const kStartLatElementName = @"lat";
static NSString * const kStartLonElementName = @"lng";

static NSUInteger kPaceA = (NSUInteger)(unichar)'A';

- (void) updateRidesWithArray:(NSArray *)rideDictArrays {
    for (NSDictionary *rideDict in rideDictArrays) {
        [self rideFromJson:rideDict];
    }
	RideCalendarAppDelegate *delegate = (RideCalendarAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate reloadTableView];
}


- (Ride *)rideFromJson:(NSDictionary *)rideDict {
	RideCalendarAppDelegate *delegate = (RideCalendarAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.context = [delegate managedObjectContext];
    if (rideDict) {
        NSString *rideId = [rideDict objectForKey:kRideIdElementName];
		NSArray* ridesFound = [delegate ridesWithRideId:rideId];
		NSLog(@"RootViewController rideFromJson ridesWithRideId %@: %d elements", rideId, [ridesFound count]);
		if ([ridesFound count] > 0) {
			self.ride = [ridesFound objectAtIndex:0];
		} else {
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:self.context];
			self.ride = [[Ride alloc] initWithEntity:entity insertIntoManagedObjectContext:self.context];
		}
		[self fillUpRidefromElement:rideDict];
		NSLog(@"RootViewController rideFromJson Ride=%@ %@  %@ %@", self.ride.rideId, self.ride.title,  self.ride.month, self.ride.date);
		return self.ride;
    }
	return nil;
}

-(void) fillUpRidefromElement:(NSDictionary *)rideDict {
    self.ride.rideId = [rideDict objectForKey:kRideIdElementName];
    self.ride.terrainPaceCode = @"";
    self.ride.title = [rideDict objectForKey:kTitleElementName];
    self.ride.descString = [rideDict objectForKey:kDescriptionElementName];
    if ([rideDict objectForKey:kDateElementName]) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.ride.date = [dateFormatter dateFromString:
                          [NSString stringWithFormat:@"%@T%@", [rideDict objectForKey:kDateElementName],
                           [rideDict objectForKey:kTimeElementName]]];
        [dateFormatter setDateFormat:@"yyyy-MM"];
        self.ride.month = [dateFormatter stringFromDate:self.ride.date];
        NSLog(@"JSRideFactory.h fillUpRidefromElement stringfromdate=%@ to %@", self.ride.date, self.ride.month);
    }
    self.ride.pace = [NSNumber numberWithInt:[[rideDict objectForKey:kPaceElementName] characterAtIndex:0] - kPaceA];
    self.ride.terrainPaceCode = [[rideDict objectForKey:kPaceElementName] stringByAppendingString:self.ride.terrainPaceCode];
    self.ride.terrain = [NSNumber numberWithInt:[[rideDict objectForKey:kTerrainElementName] integerValue] - 1];
    self.ride.terrainPaceCode = [self.ride.terrainPaceCode stringByAppendingString:[rideDict objectForKey:kTerrainElementName]];
    if ([[rideDict objectForKey:kDistanceElementName] length] == 0) {
        self.ride.distance = [NSDecimalNumber zero];
    }else {
        self.ride.distance = [NSDecimalNumber decimalNumberWithString:[rideDict objectForKey:kDistanceElementName]];
    }
    self.ride.leader = [rideDict objectForKey:kLeaderElementName];
    self.ride.email = [rideDict objectForKey:kEmailElementName];
    self.ride.phone = [rideDict objectForKey:kPhoneElementName];
    self.ride.start = [rideDict objectForKey:kStartElementName];
    self.ride.startLat = [NSDecimalNumber decimalNumberWithString:[rideDict objectForKey:kStartLatElementName]];
    self.ride.startLon = [NSDecimalNumber decimalNumberWithString:[rideDict objectForKey:kStartLonElementName]];
}
    


@end
