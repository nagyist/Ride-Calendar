//
//  XmlElement.m
//  RideCalendar
//
//  Created by Jerome Thomere on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XmlElement.h"


@implementation XmlElement

@synthesize tag, children, content;

-(void) dealloc {
	[super dealloc];
	[tag release];
	[children release];
	[content release];
}

-(void) xmlLog {
	if ([children count] <= 0) {
		NSLog(@"<%@>%@</%@>", tag, content, tag);
		
	} else {
		NSLog(@"<%@>%@", tag, content);
		for (int i=0; i < [children count]; i++) {
			XmlElement* elt = [children objectAtIndex:i];
			[elt xmlLog];
		}
		NSLog(@"</%@>", tag);
	}
}
-(XmlElement *)getElementByTagName: (NSString*)tagName {
	//NSLog(@"Looking into element %@", tag);
	if ([tag isEqualToString:tagName]) {
		return self;
	} else {
		for (int i=0; i < [children count]; i++) {
			XmlElement* elt = [children objectAtIndex:i];
			XmlElement* found = [elt getElementByTagName:tagName];
			if (found != nil) {
				return found;
			}
		}
		
	}
	return nil;
	
}

@end
