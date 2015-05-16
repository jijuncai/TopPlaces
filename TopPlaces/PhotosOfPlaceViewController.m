//
//  PhotosOfPlaceViewController.m
//  TopPlaces
//
//  Created by jijuncai on 5/13/15.
//  Copyright (c) 2015 CS193p. All rights reserved.
//

#import "PhotosOfPlaceViewController.h"
#import "FlickrFetcher.h"

@interface PhotosOfPlaceViewController ()

@end

@implementation PhotosOfPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchPhotosOfPlace];
}

- (IBAction)fetchPhotosOfPlace{
    self.photos = nil;
    
    [self.refreshControl beginRefreshing]; // start the spinner
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:self.placeID maxResults:50];
    //NSLog(@"%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
        // this handler is not executing on the main queue, so we can't do UI directly here
            if (!error) {
                NSData *jsonData = [NSData dataWithContentsOfURL:localfile options:0 error:&error];
                //NSLog(@"%@", jsonData);
                NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                    options:0
                                                                                      error:&error];
                NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing]; // stop the spinner
                    self.photos = photos;
                });
            }
    }];
    [task resume];

}

@end
