
//
//  RideParser.h
//  RideCalendar
//
//  Created by Jerome Thomere on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlElement.h"

@interface XmlParser : NSObject<NSXMLParserDelegate> {
	NSData *xmlData;
	NSMutableArray *inElement;
	NSMutableSet *nonTerminalElements;
	NSMutableString *currentParsedCharacterData;
	BOOL accumulatingParsedCharacterData;
	BOOL didAbortParsing;
	XmlElement *parsedElement;
}

@property (nonatomic, retain) NSData *xmlData;
@property (nonatomic, retain) NSMutableArray *inElement;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) NSMutableSet *nonTerminalElements;
@property (nonatomic, retain) XmlElement *parsedElement;

-(void)execute;
- (void)handleError:(NSError *)error;

@end
