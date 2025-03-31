#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>

%hook SKPaymentTransaction
- (SKPaymentTransactionState)transactionState {
    NSLog(@"[ExitLagBypassFinal] Interceptado transactionState - respondendo como 'purchased'");
    return SKPaymentTransactionStatePurchased;
}
%end

%hook SKReceiptRefreshRequest
- (void)start {
    NSLog(@"[ExitLagBypassFinal] Interceptado start de SKReceiptRefreshRequest.");
}
%end

%hook SKPaymentQueue
- (void)addPayment:(SKPayment *)payment {
    NSLog(@"[ExitLagBypassFinal] Interceptando addPayment para: %@", payment.productIdentifier);
    SKPaymentTransaction *fakeTransaction = [[NSClassFromString(@"SKPaymentTransaction") alloc] init];
    [fakeTransaction setValue:@(SKPaymentTransactionStatePurchased) forKey:@"transactionState"];
    NSArray *transactions = @[fakeTransaction];
    if ([self respondsToSelector:@selector(paymentQueue:updatedTransactions:)]) {
        [self performSelector:@selector(paymentQueue:updatedTransactions:) withObject:self withObject:transactions];
        NSLog(@"[ExitLagBypassFinal] Transação fake enviada com sucesso.");
    } else {
        NSLog(@"[ExitLagBypassFinal] Falha ao enviar transação fake.");
    }
}
%end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"[ExitLagBypassFinal] Aplicando hooks com atraso...");
            %init();
        });
    }];
}
