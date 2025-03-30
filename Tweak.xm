#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"SKPaymentQueue")) {
            NSLog(@"[ExitLagBypassFinal] StoreKit detectado. Hooks serão aplicados.");
            %init();
        } else {
            NSLog(@"[ExitLagBypassFinal] StoreKit NÃO encontrado. Nenhum hook será aplicado.");
        }
    });
}

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
        [self performSelector:@selector(paymentQueue:updatedTransactions:)
                   withObject:self
                   withObject:transactions];
        NSLog(@"[ExitLagBypassFinal] Transação fake enviada com sucesso.");
    } else {
        NSLog(@"[ExitLagBypassFinal] Falha ao enviar transação fake.");
    }
}

%end
