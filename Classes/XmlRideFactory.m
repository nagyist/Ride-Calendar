//
//  XmlRideReader.m
//  RideCalendar
//
//  Created by Jerome Thomere on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XmlRideFactory.h"
#import "RideCalendarAppDelegate.h"


@implementation XmlRideFactory
@synthesize source, ride, context;

#pragma mark Parser constants

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



-(Ride *)rideFromXml:(XmlElement *)element {
	self.source = element;
	RideCalendarAppDelegate *delegate = (RideCalendarAppDelegate *)[[UIApplication sharedApplication] delegate];
	context = [delegate managedObjectContext];
	XmlElement * foundXml = [element getElementByTagName:kEntryElementName];
	if (foundXml !=  nil) {
		XmlElement* xmlRideId = [element getElementByTagName:kRideIdElementName];
		NSString *rideId = xmlRideId.content;
		NSArray* ridesFound = [delegate ridesWithRideId:rideId];
		//NSLog(@"ridesWithRideId %@: %d elements", rideId, [ridesFound count]);
		if ([ridesFound count] > 0) {
			self.ride = [ridesFound objectAtIndex:0];
		} else {
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ride" inManagedObjectContext:context];
			self.ride = [[Ride alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
			//[foundXml xmlLog];
		}
		[self fillUpRidefromElement:foundXml];
		NSLog(@"Ride=%@ %@  %@ %@", self.ride.rideId, self.ride.title,  self.ride.month, self.ride.date);
		return self.ride;
	}
	return nil;
}

-(void) fillUpRidefromElement:(XmlElement *)rideElement {
	ride.terrainPaceCode = @"";
	for (XmlElement *elt in rideElement.children) {
		if ([elt.tag isEqualToString:kRideIdElementName]) {
			ride.rideId = elt.content;
		} else if ([elt.tag isEqualToString:kTitleElementName]) {
			ride.title = elt.content;
		} else if ([elt.tag isEqualToString:kDescriptionElementName]) {
			ride.descString = elt.content;
		} else if ([elt.tag isEqualToString:kDateElementName]) {
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
			ride.date = [dateFormatter dateFromString:elt.content];
			[dateFormatter setDateFormat:@"LLLL yyyy"];
            NSLog(@"stringfromdate=%@ to %@", ride.date, [dateFormatter stringFromDate:ride.date]);
			ride.month = [dateFormatter stringFromDate:ride.date];
		} else if ([elt.tag isEqualToString:kPaceElementName]) {
			ride.pace = [NSNumber numberWithInt:[elt.content characterAtIndex:0] - kPaceA];
			ride.terrainPaceCode = [elt.content stringByAppendingString:ride.terrainPaceCode];
		} else if ([elt.tag isEqualToString:kTerrainElementName]) {
			ride.terrain = [NSNumber numberWithInt:[elt.content integerValue] - 1];
			ride.terrainPaceCode = [ride.terrainPaceCode stringByAppendingString:elt.content];
		} else if ([elt.tag isEqualToString:kDistanceElementName]) {
			if ([elt.content length] == 0) {
				ride.distance = [NSDecimalNumber zero];
			}else {
				ride.distance = [NSDecimalNumber decimalNumberWithString:elt.content];
			}
		} else if ([elt.tag isEqualToString:kLeaderElementName]) {
			ride.leader = elt.content;
		} else if ([elt.tag isEqualToString:kEmailElementName]) {
			ride.email = elt.content;
		} else if ([elt.tag isEqualToString:kPhoneElementName]) {
			ride.phone = elt.content;
		} else if ([elt.tag isEqualToString:kLeaderElementName]) {
			ride.leader = elt.content;
		} else if ([elt.tag isEqualToString:kStartElementName]) {
			ride.start = elt.content;
		} else if ([elt.tag isEqualToString:kStartLatElementName]) {
			ride.startLat = [NSDecimalNumber decimalNumberWithString:elt.content];
		} else if ([elt.tag isEqualToString:kStartLonElementName]) {
			ride.startLon = [NSDecimalNumber decimalNumberWithString:elt.content];
		} else {
			NSLog(@"fillUpRidefromElement Tag %@ not handled", elt.tag);
		}
		
	}
}

-(void) dealloc {
	[super dealloc];
	[source release];
	[context release];
	[ride release];
}


@end
