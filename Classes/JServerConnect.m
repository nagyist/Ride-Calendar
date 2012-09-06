//
//  JsonTest.m
//  RideCalendar
//
//  Created by Jerome Thomere on 8/31/12.
//
//

#import "JServerConnect.h"
#import "SBJson.h"
#import "JSRideFactory.h"

@implementation JServerConnect

static NSString * const kCalendarURLString = @"http://dssf.org/dssf_html/calendar/rides-json.php5";

+ (NSURLRequest *) getRidesRequest {
	//NSLog(@"getPostsRequest URL=%@",utf8url);
	NSString* updatedURLString = [NSString stringWithFormat:@"%@?updatedafter=2011-04-23", kCalendarURLString];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:updatedURLString]];
	return request;
}

#pragma mark - Asynchronous Fetching data

-(void) asyncFetchRequest: (NSURLRequest *) request {
	if (request == nil) {
		NSLog(@"Error: the request is nil");
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    requestUrlString = [NSString stringWithFormat:@"%@?%@", [[request URL] path], [[request URL] query]];
    [requestUrlString retain];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	//NSLog(@"ServerAccess asyncFetchRequest:%@ theConnection=%@", request, theConnection);
	if (theConnection) {
        //NSLog(@"ServerAccess asyncFetchRequest:%@", request);
        //NSLog(@"ServerAccess asyncFetchRequest connection=%@", theConnection);
		data = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
		NSLog(@"asyncFetchRequest: The request %@ failed", request);
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	// It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	//NSLog(@"ServerAccess connection: %@ didReceiveResponse:%@",connection, response);
    //NSLog(@"Url %@ established a connection in %5.3f ms", requestUrlString, 1000.0f * [[NSDate date] timeIntervalSinceDate:requestSentDate]);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger httpStatus = [httpResponse statusCode];
    NSError *error;
    if (httpStatus < 400) {
        [data setLength:0];
        return;
    }
    //There was a problem...
    [connection cancel];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString* localizedStringForStatusCode = [NSString stringWithFormat:@"HTTP error: %@", [NSHTTPURLResponse localizedStringForStatusCode:httpStatus]];
    switch (httpStatus) {
        default:
            error = [NSError errorWithDomain:@"JildyErrorDomain" code:httpStatus userInfo:
                     [NSDictionary dictionaryWithObject:localizedStringForStatusCode forKey:NSLocalizedDescriptionKey] ];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSLog(@"will show alert requestUrl=%@", requestUrlString);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:requestUrlString
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
            [alert release];
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData {
    
	//NSLog(@"ServerAccess connection:%@ didReceiveData: %d bytes",connection, [newData length]);;
    [data appendData:newData];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"ServerAccess connection: didReceiveAuthenticationChallenge:%@", challenge);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *failingURLString = [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey];
    NSLog(@"ServerAccess connection: %@ didFailWithError %@ %@",connection, [error localizedDescription], failingURLString);
    NSLog(@"[error userInfo]=%@ error=%@",[error userInfo], error);
    [connection release];
    [data release];
    [requestUrlString release];
    //NSURL * failingURL = [NSURL URLWithString:failingURLString];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection error"
                                                    message:[error localizedDescription]
                          //message:[NSString stringWithFormat:@"%@?%@", [failingURL path], [failingURL query]]
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    //NSLog(@"ServerAccess connection: %@ connectionDidFinishLoading",connection);;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//NSLog(@"json=%@", [ServerAccess dictWithJSONData:data]);
    
    if ([data length] <= 0) {
        NSLog(@"0 bytes response from request %@", requestUrlString);
    }
	[self didLoadData];
    [connection release];
    [data release];
    [requestUrlString autorelease];
}

#pragma mark - Loding data

- (void) didLoadData {
    NSArray* array = [JServerConnect arrayWithJSONData:data];
    NSLog(@"JsonTest didLoadData array length: %d", [array count]);
    JSRideFactory *factory = [[JSRideFactory alloc] init];
    [factory updateRidesWithArray:array];
    [factory release];
}

#pragma mark - Parsing data

+ (NSDictionary *) dictWithJSONData: (NSData *) response  {
	// Get JSON as a NSString from NSData response
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    if ([json_string length] <= 0) {
        NSLog(@"PARSING PROBLEM: got an empty string with response=%@", [response description]);
    }
	//NSLog(@"json_string=|%@|", json_string);
	NSLog(@"dictWithJSONData json_string length=%d", [json_string length] );
	SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSError *error = nil;
	NSDictionary *dict = [parser objectWithString:json_string error:&error];
    if (error && ([response length] > 0)) {
        NSLog(@"JSON data length = %d", [response length]);
        NSLog(@"JSON string = \"%@\"",json_string);
    }
	[parser release];
	[json_string release];
	return dict;
}

+ (NSArray *) arrayWithJSONData: (NSData *) response  {
	// Get JSON as a NSString from NSData response
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    if ([json_string length] <= 0) {
        NSLog(@"PARSING PROBLEM: got an empty string with response=%@", [response description]);
    }
	//NSLog(@"json_string=|%@|", json_string);
	//NSLog(@"dictWithJSONData json_string length=%d", [json_string length] );
	SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSError *error = nil;
	NSArray *array = [parser objectWithString:json_string error:&error];
    if (error && ([response length] > 0)) {
        NSLog(@"JSON data length = %d", [response length]);
        NSLog(@"JSON string = \"%@\"",json_string);
    }
	[parser release];
	[json_string release];
	return array;
}

#pragma mark - Main functions

- (void) asyncFetchRides {
    [self asyncFetchRequest:[JServerConnect getRidesRequest]];
}

@end
