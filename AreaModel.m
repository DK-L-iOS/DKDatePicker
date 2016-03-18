//
//  AreaModel.m
//  DKPickView
//
//  Created by 李登科 on 16/3/17.
//  Copyright © 2016年 DK-Li. All rights reserved.
//

#import "AreaModel.h"

@implementation AreaModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.areasArr = [NSMutableArray array];
    }
    return self;
}
@end


@implementation CityModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.countryArr = [NSMutableArray array];
    }
    return self;
}
@end


@implementation StateModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.citiesArr = [NSMutableArray array];
    }
    return self;
}
@end


@implementation CountryModel
@end



