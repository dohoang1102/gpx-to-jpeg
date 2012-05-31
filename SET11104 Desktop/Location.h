//
//  Location.h
//  SET11104 Desktop
//
//  Created by Jules Coynel on 09/11/2011.
//  Copyright (c) 2011 Jules Coynel. All rights reserved.
//

@interface Location : NSObject
{
	double latitude;
	double longitude;
	NSDate *timestamp;
}

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, retain) NSDate* timestamp;

- (id)initWithLatitude:(double)lat longitude:(double)lon;
- (id)initWithLatitude:(double)lat longitude:(double)lon timestamp:(NSDate *)t;

@end
