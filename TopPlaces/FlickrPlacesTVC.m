//
//  FlickrPlacesTVC.m
//  TopPlaces
//
//  Created by jijuncai on 5/12/15.
//  Copyright (c) 2015 CS193p. All rights reserved.
//

#import "FlickrPlacesTVC.h"
#import "FlickrFetcher.h"
#import "JustPostedFlickrPhotosTVC.h"
#import "PhotosOfPlaceViewController.h"

@interface FlickrPlacesTVC ()

@property (nonatomic) NSMutableDictionary *countriesOfPlaces; // local NSMutableDictionary
@property (nonatomic) NSArray *sortedCountryOfPlaces;

@end

@implementation FlickrPlacesTVC

#pragma mark - Getter and Setter

// must have this when override both getter and setter
@synthesize sortedCountryOfPlaces = _sortedCountryOfPlaces;

- (void)setPlaces:(NSArray *)places{ // setter for places
    if (!_places) _places = places;
    [self updateCountryOfPlacesWithPlaces:self.places];
    [self.tableView reloadData];
}

- (NSMutableDictionary *)countriesOfPlaces { // getter for countriesOfPlaces
    if(!_countriesOfPlaces) _countriesOfPlaces = [[NSMutableDictionary alloc] init];
    return _countriesOfPlaces;
}

- (NSArray *)sortedCountryOfPlaces { // getter for sortedCountryOfPlaces
    if(!_sortedCountryOfPlaces) {
        _sortedCountryOfPlaces = [[self.countriesOfPlaces allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *) obj1 compare:obj2];
        }];
    }
    return _sortedCountryOfPlaces;
}

- (void)setSortedCountryOfPlaces:(NSArray *)sortedCountryToPlaces { // setter
    _sortedCountryOfPlaces = sortedCountryToPlaces;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.countriesOfPlaces.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *countryName =  self.sortedCountryOfPlaces[section];
    NSArray *placesInCountry = self.countriesOfPlaces[countryName];
    return placesInCountry.count;
}
- (NSString *)countryNameForSection:(NSInteger)section {
    // return country name for section
    return self.sortedCountryOfPlaces[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // return country title for section
    return [self countryNameForSection:section];
}

// update the cell info
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flickr places cell" forIndexPath:indexPath];
    
    NSString *country = [self countryNameForSection:indexPath.section];
    NSDictionary *topPhotoPlace = (self.countriesOfPlaces[country])[indexPath.row];
    
    cell.textLabel.text = [self extractCityNameFromPlaceInformation:topPhotoPlace];
    cell.detailTextLabel.text = [self extractLocationNameFromPlaceInformation:topPhotoPlace];
    
    return cell;
}

#pragma mark - helper methods for class

- (void) updateCountryOfPlacesWithPlaces: (NSArray *)places { // create local from places
    [self.countriesOfPlaces removeAllObjects];
    for (NSDictionary *place in places) [self addPlace:place];
}

- (void)addPlace:(NSDictionary *)place { // add place method
    NSString *country = [self extractCountryNameFromPlaceInformation:place];
    NSMutableArray *existingPlaceListForCountry = [self.countriesOfPlaces objectForKey:country];
    if(!existingPlaceListForCountry) {
        existingPlaceListForCountry = [[NSMutableArray alloc] init];
        [self.countriesOfPlaces setObject:existingPlaceListForCountry forKey:country];
    }
    [existingPlaceListForCountry addObject:place];
}

- (void)sortPlacesInEachCountry { //Sort the places within each country
    for (NSMutableArray *countryToPlaces in self.countriesOfPlaces.allValues) {
        [countryToPlaces sortUsingComparator:^NSComparisonResult(NSDictionary * place1, NSDictionary * place2) {
            NSString *place1Name = [place1 valueForKeyPath:FLICKR_PLACE_NAME];
            NSString *place2Name = [place2 valueForKeyPath:FLICKR_PLACE_NAME];
            return [place1Name compare:place2Name];
        }];
    }
}

- (NSArray *)extractNameByArrayFromPlaceInformation:(NSDictionary *)place{ // extract name by array
    NSString *content = [place valueForKey:FLICKR_PLACE_NAME];
    NSArray *contentComponents = [content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    return contentComponents;
}

- (NSString *)extractCountryNameFromPlaceInformation:(NSDictionary *)place{ // extract country name
    return [self extractNameByArrayFromPlaceInformation:place].lastObject;
}

- (NSString *)extractLocationNameFromPlaceInformation:(NSDictionary *)place{ // extract location name
    return [self extractNameByArrayFromPlaceInformation:place].firstObject;
}

- (NSString *)extractCityNameFromPlaceInformation:(NSDictionary *)place{ // extract city name
    return [self extractNameByArrayFromPlaceInformation:place][1];
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"diplay photos"]) {
                // yes ... is the destination an ImageViewController?
                if ([segue.destinationViewController isKindOfClass:[UITableViewController class]]) {
                    // yes ... then we know how to prepare for that segue!
                    PhotosOfPlaceViewController * destViewController = segue.destinationViewController;
                    NSString *country = [self countryNameForSection:indexPath.section];
                    NSDictionary *topPhotoPlace = self.countriesOfPlaces[country][indexPath.row];
                    
                    destViewController.placeOfPhotos = topPhotoPlace;
                }
            }
        }
    }

}

@end
