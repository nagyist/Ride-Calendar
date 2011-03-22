//
//  DescriptionViewController.h
//  RideCalendar
//
//  Created by Jerome Thomere on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DescriptionViewController : UIViewController {

	UITextView * description;
	NSString *text;

}

@property (nonatomic, retain) IBOutlet UITextView *description;
@property (nonatomic, retain) NSString *text;

@end
