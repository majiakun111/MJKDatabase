//
//  BankCard.h
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "MJKRecord.h"

@interface BankCard : MJKRecord

@property (nonatomic, strong) NSString *cardId;
@property (nonatomic, copy) NSString *money;

@end
