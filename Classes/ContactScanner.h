//
//  ContactScanner.h
//  RideCalendar
//
//  Created by Jerome Thomere on 2/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContactScanner : NSObject {
	NSScanner *scanner;
	NSCharacterSet *separators;

}

@property (nonatomic, retain) NSScanner *scanner;
@property (nonatomic, retain) NSCharacterSet *separators;

+ (ContactScanner *)contactScannerWithString: (NSString *)string;
- (BOOL) hasMore;
- (NSString *)next;

@end
