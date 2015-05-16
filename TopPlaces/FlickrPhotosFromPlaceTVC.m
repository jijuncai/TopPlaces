//
//  FlickrPhotosFromPlaceTVC.m
//  TopPlaces
//
//  Created by jijuncai on 5/13/15.
//  Copyright (c) 2015 CS193p. All rights reserved.
//

#import "FlickrPhotosFromPlaceTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
#import "RecentPlaces.h"

@interface FlickrPhotosFromPlaceTVC ()

@property (nonatomic, readonly) RecentPlaces *recents;

@end

@implementation FlickrPhotosFromPlaceTVC

- (void)setPlaceOfPhotos:(NSDictionary *)placeOfPhotos{
    _placeOfPhotos = placeOfPhotos;
    [self.tableView reloadData];
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.tableView reloadData];
}

- (NSString *)placeID {
    return self.placeOfPhotos[FLICKR_PLACE_ID];
}

#pragma mark - recent photos

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.placeOfPhotos) {
        [self setTitle:@"50 Tops"];
    } else {
        [self setTitle:@"Recents"];
    }
    [self setPhotosToRecent];
}

- (RecentPlaces *)recents{
    
    return [RecentPlaces sharedInstance];
}

- (void)setPhotosToRecent {
    self.photos = [[RecentPlaces sharedInstance] recents];
}

- (void)recentsChangedToEntities: (NSArray *)entities {
    self.photos = entities;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.photos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photos Cell" forIndexPath:indexPath];
    
    NSDictionary *placeOfPhoto = self.photos[indexPath.row];
    NSString *title = [placeOfPhoto valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSString *description = [placeOfPhoto valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    cell.textLabel.text = ([title length] == 0 ? (([description length] == 0) ? @"Unknown" : description) : title);
    cell.detailTextLabel.text = ([description length] == 0 ? @"Unknown" : description);
 
    return cell;
}


#pragma mark - UITableViewDelegate

// when a row is selected and we are in a UISplitViewController,
//   this updates the Detail ImageViewController (instead of segueing to it)
// knows how to find an ImageViewController inside a UINavigationController in the Detail too
// otherwise, this does nothing (because detail will be nil and not "isKindOfClass:" anything)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the Detail view controller in our UISplitViewController (nil if not in one)
    id detail = self.splitViewController.viewControllers[1];
    // if Detail is a UINavigationController, look at its root view controller to find it
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    // is the Detail is an ImageViewController?
    if ([detail isKindOfClass:[ImageViewController class]]) {
        // yes ... we know how to update that!
        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
    }
}

#pragma mark - Navigation

// prepares the given ImageViewController to show the given photo
// used either when segueing to an ImageViewController
//   or when our UISplitViewController's Detail view controller is an ImageViewController

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
}

// In a story board-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                // yes ... is the destination an ImageViewController?
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    // yes ... then we know how to prepare for that segue!
                    [self prepareImageViewController:segue.destinationViewController
                                      toDisplayPhoto:self.photos[indexPath.row]];
                    
                    ImageViewController * destViewController = segue.destinationViewController;
                    NSDictionary *selectedPhoto = self.photos[indexPath.row];
                    
                    destViewController.photoMetaData = selectedPhoto;
                    if(self.placeOfPhotos) {
                        [self.recents addRecent:selectedPhoto];
                    }

                }
            }
        }
    }
}

@end
