//
//  ADSubsriber.m
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 6/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import "ADSubsriber.h"
#import "IAPShare.h"

#define MONTHLY_SUBSCRIBTION @"com.gluu.org.monthly.ad.free"
#define SHARED_SECRET_KEY @"44b38fbde32249fe9bf43e30c760ed94"

@implementation ADSubsriber

+ (instancetype) sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)restorePurchase{
    if(![IAPShare sharedHelper].iap) {
        NSSet* dataSet = [[NSSet alloc] initWithObjects:MONTHLY_SUBSCRIBTION, nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    [[IAPShare sharedHelper].iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        
        //check with SKPaymentQueue
        
        // number of restore count
//        NSInteger numberOfTransactions = payment.transactions.count;
        
        for (SKPaymentTransaction *transaction in payment.transactions)
        {
            NSString *purchased = transaction.payment.productIdentifier;
            if([purchased isEqualToString:MONTHLY_SUBSCRIBTION])
            {
                //enable the prodcut here
                NSLog(@"%@", [NSString stringWithFormat:@"%@ - Purchase restored", purchased]);
            }
        }
        
    }];
}

-(void)tryToSubsribe{
//    NSString* purchaceID = @"com.gluu.org.monthly.ad.free.ble";
    if (/* DISABLES CODE */ (YES)){
        if(![IAPShare sharedHelper].iap) {
            NSSet* dataSet = [[NSSet alloc] initWithObjects:MONTHLY_SUBSCRIBTION, nil];
            
            [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
        }
        
        [IAPShare sharedHelper].iap.production = YES;
        
        [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
         {
             if(response > 0 && [IAPShare sharedHelper].iap.products.count > 0) {
                 SKProduct* product =[[IAPShare sharedHelper].iap.products objectAtIndex:0];
                 
                 NSLog(@"Price: %@",[[IAPShare sharedHelper].iap getLocalePrice:product]);
                 NSLog(@"Title: %@",product.localizedTitle);
                 
                 [[IAPShare sharedHelper].iap buyProduct:product
                                            onCompletion:^(SKPaymentTransaction* trans){
                                                
                                                if(trans.error)
                                                {
                                                    NSLog(@"Fail %@",[trans.error localizedDescription]);
                                                }
                                                else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                                                    
                                                    [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:SHARED_SECRET_KEY onCompletion:^(NSString *response, NSError *error) {
                                                        
                                                        if (response != nil) {
                                                            //Convert JSON String to NSDictionary
                                                            NSDictionary* rec = [IAPShare toJSON:response];
                                                            
                                                            if([rec[@"status"] integerValue]==0)
                                                            {
                                                                
                                                                [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                                                                NSLog(@"SUCCESS %@",response);
                                                                NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                                            
                                                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_FREE object:nil];
                                                                _isSubscribed = YES;
                                                            }
                                                            else {
                                                                NSLog(@"Fail");
                                                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_NOT_FREE object:nil];
                                                                _isSubscribed = NO;
                                                            }
                                                        }
                                                    }];
                                                }
                                                else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                                    NSLog(@"Fail");
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_NOT_FREE object:nil];
                                                    _isSubscribed = NO;
                                                }
                                            }];//end of buy product
             }
         }];
    } else {
        NSLog(@"You've successfully subscribed");
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_FREE object:nil];
        _isSubscribed = YES;
    }
}

-(void)isSubscriptionExpired{
//    NSString* purchaceID = @"com.gluu.org.monthly.ad.free.ble";
    
    if(![IAPShare sharedHelper].iap) {
        NSSet* dataSet = [[NSSet alloc] initWithObjects:MONTHLY_SUBSCRIBTION, nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    
    [IAPShare sharedHelper].iap.production = YES;
    
    //Get receipt with info about subscription
    [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:SHARED_SECRET_KEY onCompletion:^(NSString *response, NSError *error) {
        
        if (response == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_NOT_FREE object:nil];
            _isSubscribed = NO;
            return;
        }
        //Convert JSON String to NSDictionary
        NSDictionary* rec = [IAPShare toJSON:response];
        
        if([rec[@"status"] integerValue]==0)
        {
            NSArray* latest_receipt_info_ar = rec[@"latest_receipt_info"];
            NSDictionary* latest_receipt_info_dic = latest_receipt_info_ar.lastObject;
            NSString* expires_date = latest_receipt_info_dic[@"expires_date"];
            NSDate* expiredDate = [self extractDate:expires_date];
            NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            if ([IAPShare sharedHelper].iap.production){
                NSDateComponents *dateComponent = [calender components:NSCalendarUnitDay fromDate:[NSDate date] toDate:expiredDate options:0];
                NSInteger days = [dateComponent day];
                if (days >= 0){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_FREE object:nil];
                    _isSubscribed = YES;
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_NOT_FREE object:nil];
                    _isSubscribed = NO;
                }
                NSLog(@"Days - %ld", (long)days);
            } else {
                NSDateComponents *dateComponent = [calender components:NSCalendarUnitMinute fromDate:[NSDate date] toDate:expiredDate options:0];
                NSInteger mins = [dateComponent minute];
                if (mins >= 0){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_FREE object:nil];
                    _isSubscribed = YES;
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_NOT_FREE object:nil];
                    _isSubscribed = NO;
                }
                NSLog(@"Minutes - %ld", (long)mins);
            }
        }
        else {
            NSLog(@"Fail");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AD_NOT_FREE object:nil];
            _isSubscribed = NO;
        }
    }];
}

-(NSDate*)extractDate:(NSString*)date{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss VV"];
    NSDate* newDate = [formatter dateFromString:date];
    return newDate;
}


@end
