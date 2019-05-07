//
//  MJKRecord+Condition.m
//  Database
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord+Condition.h"

//SQLCondition start
@interface MJKSQLCondition : NSObject

@property(nonatomic, copy) NSString *field;
@property(nonatomic, copy) NSString *where;
@property(nonatomic, copy) NSString *having;
@property(nonatomic, copy) NSString *groupBy;
@property(nonatomic, copy) NSString *orderBy;
@property(nonatomic, copy) NSString *limit;
@property(nonatomic, copy) NSString *updateField;

@end

@implementation MJKSQLCondition

- (instancetype)init {
    self = [super init];
    if (self) {
        _field = [@" *" copy];
        _limit = [@"" copy];
        _orderBy = [@"" copy];
        _groupBy = [@"" copy];
        _where = [@" WHERE 1" copy];
        _having= [@"" copy];
        _updateField = [@"" copy];
    }
    
    return self;
}

+ (MJKSQLCondition *)defaultCondition {
    static MJKSQLCondition *sqlCondition = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlCondition = [[MJKSQLCondition alloc] init];
    });
    
    return sqlCondition;
}

@end
//SQLCondition end


//MJKSQLConditionManager start
@interface MJKSQLConditionManager : NSObject

/**
 map = @{tableName : MJKSQLCondition, ...}
 */
@property (nonatomic, retain)  NSMutableDictionary *map;

+ (instancetype)shareInstance;

- (void)setSQLCondition:(MJKSQLCondition *)sqlCondition key:(NSString *)key;
- (MJKSQLCondition *)sqlConditionForKey:(NSString *)key;

@end

@implementation MJKSQLConditionManager

+ (instancetype)shareInstance {
    static MJKSQLConditionManager *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _map = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)setSQLCondition:(MJKSQLCondition *)sqlCondition key:(NSString *)key {
    [self.map setObject:sqlCondition forKey:key];
}

- (MJKSQLCondition *)sqlConditionForKey:(NSString *)key {
    MJKSQLCondition *sqlCondition = [self.map objectForKey:key];
    if (!sqlCondition) {
        sqlCondition = [MJKSQLCondition defaultCondition];
        [self.map setObject:sqlCondition forKey:key];
    }
    
    return sqlCondition;
}

@end
//MJKSQLConditionManager end


@implementation MJKRecord (Condition)

- (void)resetAll {
    MJKSQLCondition *sqlCondition = [MJKSQLCondition defaultCondition];
    [[MJKSQLConditionManager shareInstance] setSQLCondition:sqlCondition key:[self tableName]];
}

- (void)setField:(id)field {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    if ([field isKindOfClass:[NSString class]]) {
        sqlCondition.field = field;
    } else if([field isKindOfClass:[NSArray class]]) {
        sqlCondition.field = [(NSArray*)field componentsJoinedByString:@","];
    } else {
        sqlCondition.field = @" *";
    }
}

- (NSString *)field {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    return sqlCondition.field;
}

- (void)setWhere:(id)where {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    
    if ([where isKindOfClass:[NSString class]]) {
        sqlCondition.where= [NSMutableString stringWithFormat:@" where %@", where];  //where name = 'Ansel' AND ...
    } else if ([where isKindOfClass:[NSDictionary class]]) {
        NSMutableString *sqlWhere = [NSMutableString stringWithString:@" where 1"];
        [where enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
            [sqlWhere appendFormat:@" and %@ = '%@'", key, value];   //where name = 'Ansel' AND ...
        }];
        
        sqlCondition.where = sqlWhere;
    } else {
        sqlCondition.where = @" where 1";
    }
}

- (NSString *)where {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    return  sqlCondition.where;
}

- (void)setOrderBy:(id)orderBy {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    
    if ([orderBy isKindOfClass:[NSString class]]){
        sqlCondition.orderBy = [NSString stringWithFormat:@" order by %@", orderBy];
    } else if([orderBy isKindOfClass:[NSArray class]]){
        sqlCondition.orderBy = [NSString stringWithFormat:@" order by %@", [orderBy  componentsJoinedByString:@", "]];
    } else if([orderBy isKindOfClass:[NSDictionary class]]){
        if ([[orderBy allKeys] count] <= 0) {
            return;
        }
        
        NSMutableString *tmpOrderBy = [[NSMutableString alloc] initWithString:@" order by"];
        for (NSString *sortMethod in orderBy) {
            [tmpOrderBy appendFormat:@" %@ %@,", [orderBy[sortMethod] componentsJoinedByString:@", "], sortMethod];
        }
        
        sqlCondition.orderBy = [tmpOrderBy substringToIndex:[tmpOrderBy length] - 1];
    } else{
        sqlCondition.orderBy = @"";
    }
}

- (NSString *)orderBy {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    return sqlCondition.orderBy;
}

- (void)setGroupBy:(id)groupBy {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    
    if ([groupBy isKindOfClass:[NSString class]]) {
        sqlCondition.groupBy = [NSString stringWithFormat:@" group by %@", groupBy];
    } else if([groupBy isKindOfClass:[NSArray class]]) {
        sqlCondition.groupBy = [NSString stringWithFormat:@" group by %@", [groupBy componentsJoinedByString:@", "]];
    } else {
        sqlCondition.groupBy = @"";
    }
}

- (NSString *)groupBy {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    return sqlCondition.groupBy;
}

- (void)setHaving:(id)having {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    
    if ([having isKindOfClass:[NSString class]]) {
        sqlCondition.having = [NSMutableString stringWithFormat:@" having %@", having];  //HAVING SUM(age) = 1000 AND ...
    } else if ([having isKindOfClass:[NSDictionary class]]) {
        if ([[having allKeys] count] <= 0) {
            return;
        }
        
        NSMutableString *havingCondition = [NSMutableString string];
        NSMutableArray *havingConditionValues = [[NSMutableArray alloc] init];
        [havingCondition appendString:@" having 1"];
        [having enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
            [havingCondition appendFormat:@" and `%@` = ?", key];    //HAVING SUM(age) = ? AND ...
            [havingConditionValues addObject:value];                //@[@(1000), ....]
        }];
        
        sqlCondition.having = havingCondition;
    } else {
        sqlCondition.having = @"";
    }
    
}

- (NSString *)having {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    return sqlCondition.having;
}

- (void)setLimitWithStart:(NSUInteger)start size:(NSUInteger)size {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    sqlCondition.limit = [NSString stringWithFormat:@" limit %lu, %lu",(unsigned long)start,(unsigned long)size];
}

- (NSString *)limit {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    return sqlCondition.limit;
}

- (void)setUpdateField:(NSDictionary *)updateField {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    
    NSMutableString *tmpUpdateField= [NSMutableString string];
    [updateField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [tmpUpdateField appendFormat:@"%@ = '%@'", key, obj];
    }];
    
    sqlCondition.updateField = tmpUpdateField;
}

- (NSString *)updateField {
    MJKSQLCondition *sqlCondition = [[MJKSQLConditionManager shareInstance] sqlConditionForKey:[self tableName]];
    return sqlCondition.updateField;
}

@end
