
#import "MidtransModule.h"
#import <React/RCTLog.h>

@implementation MidtransModule

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(checkOut:(NSDictionary*) optionConect
                  : (NSDictionary*) transRequest
                  : (NSArray*) items
                  : (NSDictionary*) creditCardOptions
                  : (NSDictionary*) mapUserDetail
                  : (NSDictionary*) optionColorTheme
                  : (NSDictionary*) optionFont
                  : (NSDictionary*) paymentMethod
                  : (RCTResponseSenderBlock)callback){

    [CONFIG setClientKey:[optionConect valueForKey:@"clientKey"]
             environment:[optionConect valueForKey:@"sandbox"] ? MidtransServerEnvironmentSandbox : MidtransServerEnvironmentProduction
       merchantServerURL:[optionConect valueForKey:@"urlMerchant"]];

    NSMutableArray *itemitems = [[NSMutableArray alloc] init];
    for (NSDictionary *ele in items) {
        MidtransItemDetail *tmp =
        [[MidtransItemDetail alloc] initWithItemID:[ele valueForKey:@"id"]
                                              name:[ele valueForKey:@"name"]
                                             price:[ele valueForKey:@"price"]
                                          quantity:[ele valueForKey:@"qty"]];
        [itemitems addObject:tmp];
    }

    MidtransAddress *shippingAddress = [MidtransAddress addressWithFirstName:[mapUserDetail valueForKey:@"fullName"]
                                                                    lastName:@""
                                                                       phone:[mapUserDetail valueForKey:@"phoneNumber"]
                                                                     address:[mapUserDetail valueForKey:@"address"]
                                                                        city:[mapUserDetail valueForKey:@"city"]
                                                                  postalCode:[mapUserDetail valueForKey:@"zipcode"]
                                                                 countryCode:[mapUserDetail valueForKey:@"country"]];
    MidtransAddress *billingAddress = [MidtransAddress addressWithFirstName:[mapUserDetail valueForKey:@"fullName"]
                                                                    lastName:@""
                                                                       phone:[mapUserDetail valueForKey:@"phoneNumber"]
                                                                     address:[mapUserDetail valueForKey:@"address"]
                                                                        city:[mapUserDetail valueForKey:@"city"]
                                                                  postalCode:[mapUserDetail valueForKey:@"zipcode"]
                                                                 countryCode:[mapUserDetail valueForKey:@"country"]];

    MidtransCustomerDetails *customerDetail =
    [[MidtransCustomerDetails alloc] initWithFirstName:[mapUserDetail valueForKey:@"fullName"]
                                              lastName:@"lastname"
                                                 email:[mapUserDetail valueForKey:@"email"]
                                                 phone:[mapUserDetail valueForKey:@"phoneNumber"]
                                       shippingAddress:shippingAddress
                                        billingAddress:billingAddress];

    NSNumber *totalAmount = [NSNumber numberWithInt:[[transRequest valueForKey:@"totalAmount"] intValue]];
    MidtransTransactionDetails *transactionDetail =
    [[MidtransTransactionDetails alloc] initWithOrderID:[transRequest valueForKey:@"transactionId"]
                                         andGrossAmount:totalAmount];

    MidtransPaymentFeature *paymentMethodFeature = [[MidtransPaymentFeature]paymentMethod valueForKey:@"method"];
    [[MidtransMerchantClient shared]
     requestTransactionTokenWithTransactionDetails:transactionDetail
     itemDetails:itemitems
     customerDetails:customerDetail
     completion:^(MidtransTransactionTokenResponse * _Nullable token, NSError *_Nullable error) {
         if (token) {
             UIViewController *ctrl = [[[[UIApplication sharedApplication] delegate] window] rootViewController];

             MidtransUIPaymentViewController *vc = [[MidtransUIPaymentViewController alloc] initWithToken:token
                                                                                        andPaymentFeature:paymentMethodFeature];

             [ctrl presentViewController:vc animated:NO completion:nil];
             //set the delegate
             vc.paymentDelegate = self;

             callback(@[@"init", [NSNull null]]);
         }
         else {
             callback(@[error.localizedDescription, [NSNull null]]);
         }
     }];
};

@property (nonatomic) MidtransPaymentFeature type;

+ (NSDictionary *)typePaymentFeatures
{
    return @{@(MidtransPaymentFeatureCreditCard) : @"CREDIT_CARD",
             @(MidtransPaymentFeatureBankTransfer) : @"BANK_TRANSFER",
             @(MidtransPaymentFeatureBankTransferBCAVA) : @"BANK_TRANSFER_BCA",
             @(MidtransPaymentFeatureBankTransferMandiriVA) : @"BANK_TRANSFER_MANDIRI",
             @(MidtransPaymentFeatureBankTransferBNIVA) : @"BANK_TRANSFER_BNI",
             @(MidtransPaymentFeatureBankTransferPermataVA) : @"BANK_TRANSFER_PERMATA",
             @(MidtransPaymentFeatureBankTransferOtherVA) : @"BANK_TRANSFER_OTHER",
             @(MidtransPaymentFeatureKlikBCA) : @"KLIK_BCA",
             @(MidtransPaymentFeatureIndomaret) : @"INDOMARET",
             @(MidtransPaymentFeatureCIMBClicks) : @"CIMB_CLICKS",
             @(MidtransPaymentFeatureCStore) : @"STORE",
             @(midtranspaymentfeatureBCAKlikPay) : @"BCA_KLIK_PAY",
             @(MidtransPaymentFeatureMandiriEcash) : @"MANDIRI_ECASH",
             @(MidtransPaymentFeatureEchannel) : @"ECHANNEL",
             @(MidtransPaymentFeaturePermataVA) : @"PERMATA_VA",
             @(MidtransPaymentFeatureBRIEpay) : @"BRI_E_PAY",
             @(MidtransPaymentFeatureAkulaku) : @"AKULAKU",
             @(MidtransPaymentFeatureTelkomselEcash) : @"TELKOMSEL_E_CASH",
             @(MidtransPyamentFeatureDanamonOnline) : @"DANAMON_ONLINE",
             @(MidtransPaymentFeatureIndosatDompetku) : @"INDOSAT_DOMPETKU",
             @(MidtransPaymentFeatureXLTunai) : @"XL_TUNAI",
             @(MidtransPaymentFeatureMandiriClickPay) : @"MANDIRI_CLICK_PAY",
             @(MidtransPaymentFeatureKiosON) : @"KIOS_ON",
             @(MidtransPaymentFeatureGCI) : @"GCI",
             @(MidtransPaymentFeatureGOPAY) : @"GO_PAY",
             @(MidtransPaymentCreditCardForm) : @"CREDIT_CARD_FORM"
}

- (NSString *)typePaymentFeature
{
    return [[self class] typePaymentFeatures][@(self.type)];
}

#pragma mark - MidtransUIPaymentViewControllerDelegate

- (void)paymentViewController:(MidtransUIPaymentViewController *)viewController paymentSuccess:(MidtransTransactionResult *)result{
    RCTLogInfo(@"%@", result);
}

- (void)paymentViewController:(MidtransUIPaymentViewController *)viewController paymentFailed:(NSError *)error {
    RCTLogInfo(@"%@", error);
}

- (void)paymentViewController:(MidtransUIPaymentViewController *)viewController paymentPending:(MidtransTransactionResult *)result {
    RCTLogInfo(@"%@", result);
}

- (void)paymentViewController_paymentCanceled:(MidtransUIPaymentViewController *)viewController {
    RCTLogInfo(@"Cancel Transaction");
}
@end
