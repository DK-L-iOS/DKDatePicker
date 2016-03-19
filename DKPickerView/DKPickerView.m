//
//  DKPickerView.m
//  DKPickView
//
//  Created by 李登科 on 16/3/18.
//  Copyright © 2016年 DK-Li. All rights reserved.
//

#import "DKPickerView.h"
#import "AreaModel.h"
#import <MapKit/MapKit.h>

@interface DKPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate>
{
    NSMutableArray *dataArr;
    NSMutableArray *stateArr;   // 省
    NSInteger oldStateRow;
    NSMutableArray *cityArr;    // 市
    NSMutableArray *countryArr; // 县
    NSString *choseState;
    NSString *choseCity;
    NSString *choseCountry;
}

@property(nonatomic, weak) UIPickerView *pickerView;
@property(nonatomic, weak) UILabel *showSeleLab;

@property(nonatomic, strong) CLLocationManager *locMgr;
@property(nonatomic, strong) CLGeocoder *geocoder;

@end


@implementation DKPickerView

static DKPickerView *DKPW = nil;
+ (DKPickerView *)shareWith:(CGRect)frame
{
    if (!DKPW) {
        DKPW = [[self alloc] initWithFrame:frame];
       
    }
    
    return DKPW;
}


+ (void)showDKPickerViewWith:(CGRect)frame result:(ResultBlock)result
{

    DKPW = [DKPickerView shareWith:frame];
    DKPW.result = result;
    DKPW.isUseDefault = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:DKPW];
}

+ (void)showDKPickerViewWith:(CGRect)frame isUseDefault:(BOOL)isUse result:(ResultBlock)result
{
    DKPW = [DKPickerView shareWith:frame];
    DKPW.result = result;
    DKPW.isUseDefault = isUse;
    [DKPW useDefaultLocation];

    [[UIApplication sharedApplication].keyWindow addSubview:DKPW];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        dataArr = [NSMutableArray array];
        stateArr = [NSMutableArray array];
        cityArr = [NSMutableArray array];
        countryArr = [NSMutableArray array];
        [self loadAreaPlist];
        [self createPickerViewWith:frame];
        
    }
    return self;
}

- (CLLocationManager *)locMgr
{
    if (!_locMgr) {
        _locMgr = [[CLLocationManager alloc] init];
        _locMgr.delegate = self;
        [_locMgr requestAlwaysAuthorization];
    }
    return _locMgr;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}


- (void)loadAreaPlist
{
    // 加载plist文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"];
    NSDictionary *areaDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *allKeys = [areaDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSString *str1 = obj1;
        NSString *str2 = obj2;
        str1 = str1.length == 1? [NSString stringWithFormat:@"0%@",str1] : str1;
        str2 = str2.length == 1? [NSString stringWithFormat:@"0%@",str2] : str2;
        return [str1 compare:str2];
    }];
    
    
    // 解析省级
    for (NSString *key in allKeys) {
        NSDictionary *midelDict = areaDict[key];
        
        StateModel *stateModel = [[StateModel alloc] init];
        stateModel.stateNum = key;
        stateModel.state = midelDict.allKeys.firstObject;
        
        NSDictionary *nextDict = midelDict[stateModel.state];
        
        NSArray *cityAllKeys = [nextDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            NSString *str1 = obj1;
            NSString *str2 = obj2;
            str1 = str1.length == 1? [NSString stringWithFormat:@"0%@",str1] : str1;
            str2 = str2.length == 1? [NSString stringWithFormat:@"0%@",str2] : str2;
            return [str1 compare:str2];
        }];
        
        // 解析市级
        for (NSString *citysNum in cityAllKeys) {
            
            NSDictionary *cityDict = nextDict[citysNum];
            
            CityModel *cityModel = [[CityModel alloc] init];
            cityModel.cityNum = citysNum;
            cityModel.city = cityDict.allKeys.firstObject;
            
            // 解析县级
            for (NSString *countryName in cityDict[cityModel.city]) {
                
                CountryModel *countryModel = [[CountryModel alloc] init];
                countryModel.country = countryName;
                
                [cityModel.countryArr addObject:countryModel];
                
            }
            [stateModel.citiesArr addObject:cityModel];
        }
        
        [dataArr addObject:stateModel];
    }
    
    
    // 默认显示北京市
    for (CityModel *citymodel in [dataArr[0] citiesArr]) {
        [cityArr addObject:citymodel.city];
    }
    
    for (CountryModel *countrymodel in [[dataArr[0] citiesArr][0] countryArr]) {
        [countryArr addObject:countrymodel.country];
    }
    
}

- (void)createPickerViewWith:(CGRect)frame
{
    
    CGFloat choseBar_h = 40;
    
    UIView *choseBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, choseBar_h)];
    choseBar.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:choseBar];
    
    NSArray *name = @[@"取消",@"确定"];
    UIButton *btn;
    for (int i =0; i<2; i++) {
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:name[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:1000 + i];
        
        CGFloat btn_x = i==0? 0 : frame.size.width - 60;
        
        btn.frame = CGRectMake(btn_x, 0, 60, 40);
        
        [choseBar addSubview:btn];
        
    }
    
    UILabel *showSelectLab = [[UILabel alloc] initWithFrame:CGRectMake(65, 0,frame.size.width - 65*2, 40)];
    [choseBar addSubview:showSelectLab];
    showSelectLab.textAlignment = 1;
    showSelectLab.adjustsFontSizeToFitWidth = YES;
    self.showSeleLab = showSelectLab;
    
    
    CGFloat picker_w = CGRectGetWidth(choseBar.frame);
    CGFloat picker_h = frame.size.height - choseBar_h;
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, choseBar_h, picker_w, picker_h)];
    
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    pickerView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:pickerView];
    
    self.pickerView = pickerView;
    
}

- (void)useDefaultLocation
{
    if (self.isUseDefault) {
        
        [self.locMgr startUpdatingLocation];
    }
}

- (void)btnClick:(UIButton *)btn
{
    if (btn.tag == 1000) {
        [self removeFromSuperview];
        DKPW = nil;
    }
    else
    {

        
        
        DKPW.result(self.showSeleLab.text.length == 0? @"北京市-北京市-东城区":self.showSeleLab.text);
        
        [self removeFromSuperview];
        DKPW = nil;
        
    }
}

- (void)showSelect
{
    NSInteger stateRow = [self.pickerView selectedRowInComponent:0];
    NSInteger cityRow = [self.pickerView selectedRowInComponent:1];
    NSInteger countryRow = [self.pickerView selectedRowInComponent:2];
    
    StateModel *model =dataArr[stateRow];
    choseState = model.state;
    choseCity = cityArr[cityRow];
    choseCountry = countryArr[countryRow];
    
    NSString *result = [NSString stringWithFormat:@"%@-%@-%@",choseState,choseCity,choseCountry];
    
    self.showSeleLab.text = result;

}

#pragma mark ---- UIPickerView代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        
        return dataArr.count;
    }
    else if (component == 1)
    {
        return cityArr.count;
    }
    
    return countryArr.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *title = [UILabel new];
    title.backgroundColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:19];
    title.adjustsFontSizeToFitWidth = YES;
    
    title.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    
    //在该代理方法里添加以下两行代码删掉上下的黑线
//    [[pickerView.subviews objectAtIndex:1] setHidden:YES];
//    [[pickerView.subviews objectAtIndex:2] setHidden:YES];
    
    return title;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        
        StateModel *model = dataArr[row];
        
        return model.state;
    }
    else if (component == 1)
    {
        
        return cityArr[row];
    }
    
    return countryArr[row];
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return (self.frame.size.width - 30)/3.0;
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

    
    if (component == 2) {
        [self showSelect];
        return;
    }
    
    [cityArr removeAllObjects];
    [countryArr removeAllObjects];
    if (component == 0) {
        
        oldStateRow = row;
        
        StateModel *model = dataArr[row];
        
        for (CityModel *model1 in model.citiesArr) {
            
            [cityArr addObject:model1.city];
            
        }
        
        for (CountryModel *model2 in [model.citiesArr[0] countryArr]) {
            
            [countryArr addObject:model2.country];
        }
        
        [pickerView reloadAllComponents];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }
    else if (component == 1)
    {
        StateModel *model = dataArr[oldStateRow];
        
        for (CityModel *model1 in model.citiesArr) {
            
            [cityArr addObject:model1.city];
            
        }
        
        for (CountryModel *model2 in [model.citiesArr[row] countryArr]) {
            
            [countryArr addObject:model2.country];
        }
        [pickerView reloadAllComponents];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    [self showSelect];
}

#pragma mark ---- 定位

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations.firstObject;
    
    NSLog(@"%f---%f",location.coordinate.latitude,location.coordinate.longitude);
    
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        
        
        NSString *state = placemark.addressDictionary[@"State"];
        NSString *city = placemark.addressDictionary[@"City"];
        NSString *SubLocality = placemark.addressDictionary[@"SubLocality"];
        
        
        NSInteger mark1 = 0;
        NSInteger mark2 = 0;
        NSInteger mark3 = 0;
        
        for (StateModel *stateModel in dataArr) {
            if ([stateModel.state isEqualToString:state]) {
                break;
            }
            mark1 ++;
        }
        
        [self.pickerView reloadComponent:0];
        [self.pickerView selectRow:mark1 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:mark1 inComponent:0];
        
        
        for (NSString *cityName in cityArr) {
            
            if ([cityName isEqualToString:city]) {
                break ;
            }
            mark2 ++;
        }
        
        [self.pickerView reloadComponent:1];
        [self.pickerView selectRow:mark2 inComponent:1 animated:YES];
        [self pickerView:self.pickerView didSelectRow:mark2 inComponent:1];
        
        
        
        for (NSString *country in countryArr) {
            
            if ([SubLocality isEqualToString:country]) {
                break;
            }
            mark3 ++;
        }
        
        [self.pickerView reloadComponent:2];
        [self.pickerView selectRow:mark3 inComponent:2 animated:YES];
        
        [self.locMgr stopUpdatingLocation];
    }];
    
}

@end












