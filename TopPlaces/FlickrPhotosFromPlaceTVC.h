//
//  FlickrPhotosFromPlaceTVC.h
//  TopPlaces
//
//  Created by jijuncai on 5/13/15.
//  Copyright (c) 2015 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotosFromPlaceTVC : UITableViewController

@property (nonatomic, strong) NSDictionary *placeOfPhotos; // of Flickr photo NSDictionary
@property (nonatomic) NSArray *photos;
@property (nonatomic, readonly) NSString *placeID;

@end
