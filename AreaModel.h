//
//  AreaModel.h
//  DKPickView
//
//  Created by 李登科 on 16/3/17.
//  Copyright © 2016年 DK-Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryModel : NSObject
@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *countryNum;
@end

@interface CityModel : NSObject
@property(nonatomic, strong) NSString *city;
@property(nonatomic, strong) NSString *cityNum;
@property(nonatomic, strong) NSMutableArray *countryArr;
@end


@interface StateModel : NSObject
@property(nonatomic, strong) NSString *state;
@property(nonatomic, strong) NSString *stateNum;
@property(nonatomic, strong) NSMutableArray *citiesArr;
@end


@interface AreaModel : NSObject
@property(nonatomic, strong) NSMutableArray *areasArr;
@end












