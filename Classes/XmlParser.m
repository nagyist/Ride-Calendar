//
//  RideParser.m
//  RideCalendar
//
//  Created by Jerome Thomere on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XmlParser.h"
#import "XmlElement.h"

@implementation XmlParser

@synthesize xmlData, inElement, currentParsedCharacterData, nonTerminalElements, parsedElement;

-(void) dealloc {
	[super dealloc];
	[xmlData release];
	[inElement release];
	[currentParsedCharacterData release];
	[nonTerminalElements release];
	[parsedElement release];
}

-(void)execute {
	self.currentParsedCharacterData = [NSMutableString string];
	
	//NSLog(@"currentParsedCharacterData: %@", self.currentParsedCharacterData);
	NSLog(@"data length: %d", [xmlData length]);
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:self];
	XmlElement *root = [[XmlElement alloc] init];
	root.children = [[NSMutableArray alloc] init];
	self.inElement = [[NSMutableArray alloc] init];
	[self.inElement addObject:root];
	[parser parse];
	//NSLog(@"New parsed result: %@", root);
	//[root xmlLog];
	self.parsedElement = root;
	
}

#pragma mark NSXMLParser delegate methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qname 
   attributes:(NSDictionary *)attributeDict {
	//NSLog(@"element: %@", elementName);
	XmlElement *previousElement = [self.inElement lastObject];
	previousElement.content = [previousElement.content stringByAppendingString:self.currentParsedCharacterData];
	[currentParsedCharacterData setString:@""];
	XmlElement * currentElement = [[XmlElement alloc] init];
	currentElement.tag = elementName;
	currentElement.children = [[NSMutableArray alloc] init];
	[self.inElement addObject:currentElement];
	//NSLog(@"inElement: %@", self.inElement);
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qname {
	XmlElement *currentElement = [self.inElement lastObject];
	currentElement.content = [NSString stringWithString:self.currentParsedCharacterData];
    if ([elementName isEqualToString:@"title"]) {
        NSLog(@"title=%@", currentElement.content);
    }
    if ([elementName isEqualToString:@"id"]) {
        NSLog(@"id=%@", currentElement.content);
    }
	[currentParsedCharacterData setString:@""];
	[self.inElement removeLastObject];
	XmlElement *previousElement = [self.inElement lastObject];
	[previousElement.children addObject:currentElement];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.currentParsedCharacterData appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[self handleError:parseError];
}

- (void)handleError:(NSError *)error {
	NSString *errorMessage = [error localizedDescription];
	NSString *suggestion = [error localizedRecoverySuggestion];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorMessage
														message:suggestion 
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


@end
