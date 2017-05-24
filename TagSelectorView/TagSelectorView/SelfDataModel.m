//
//  SelfDataModel.m
//  TagSelectorView
//
//  Created by 樊少华 on 09/03/2017.
//  Copyright © 2017 camoufleur. All rights reserved.
//

#import "SelfDataModel.h"

@implementation SelfDataModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"child": @"TagSelectorModel"};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"title" : @"name",
             @"child" : @[@"rows", @"item"]};
}


@end
