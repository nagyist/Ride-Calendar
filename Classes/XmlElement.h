//
//  XmlElement.h
//  RideCalendar
//
//  Created by Jerome Thomere on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlElement.h"


@interface XmlElement : NSObject {
	NSString *tag;
	NSMutableArray *children;
	NSString *content;

}

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain) NSString *content;

-(void) xmlLog;
-(XmlElement *)getElementByTagName: (NSString*)xid;

@end
