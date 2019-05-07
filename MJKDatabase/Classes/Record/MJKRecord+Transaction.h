//
//  MJKRecord+Transaction.h
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord.h"

@interface MJKRecord (Transaction)

- (BOOL)beginDeferredTransaction;

- (BOOL)beginImmediateTransaction;

- (BOOL)beginExclusiveTransaction;

- (BOOL)startSavePointWithName:(NSString*)name;

- (BOOL)releaseSavePointWithName:(NSString*)name;

- (BOOL)rollbackToSavePointWithName:(NSString*)name;

- (BOOL)rollback;

- (BOOL)commit;

@end
