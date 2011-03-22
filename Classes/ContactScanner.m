//
//  ContactScanner.m
//  RideCalendar
//
//  Created by Jerome Thomere on 2/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContactScanner.h"


@implementation ContactScanner

@synthesize scanner, separators;

-(void) dealloc {
	[super dealloc];
	[separators release];
	[scanner release];
}

+ (ContactScanner *)contactScannerWithString: (NSString *)string {
	ContactScanner *contactScanner = [[ContactScanner alloc] init];
	contactScanner.scanner = [NSScanner scannerWithString:string];
	NSMutableCharacterSet *set = [NSMutableCharacterSet newlineCharacterSet];
	[set addCharactersInString:@","];
	contactScanner.separators = set;
	return [contactScanner autorelease];
}

- (BOOL) hasMore {
	return ![self.scanner isAtEnd];
}
- (NSString *)next {
	NSString * ignore = nil;
	[self.scanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&ignore];
	//NSLog(@"ignore = [%@]", ignore);
	NSString *next = nil;
	[self.scanner scanUpToCharactersFromSet:self.separators intoString:&next];
	//NSLog(@"next = [%@]", next);
	return [NSString stringWithString:next];
}


@end
