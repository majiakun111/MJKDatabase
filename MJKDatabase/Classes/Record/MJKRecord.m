//
//  MJKRecord.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord.h"
#import "MJKRecord+DDL.h"
#import "MJKRecord+Condition.h"
#import <objc/runtime.h>

@implementation MJKRecord

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createTable];
        [self resetAll];
    }
    
    return self;
}

- (NSString *)tableName {
    return [[self class] tableName];
}

+ (NSString *)tableName {
    return NSStringFromClass([self class]);
}

#pragma mark - May Override

+ (NSDictionary<NSString*, NSString*> *)constraints {
    return nil;
}

+ (NSDictionary<NSString*, NSDictionary*> *)indexes {
    return nil;
}

@end
