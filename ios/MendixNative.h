
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNMendixNativeSpec.h"

@interface MendixNative : NSObject <NativeMendixNativeSpec>
#else
#import <React/RCTBridgeModule.h>

@interface MendixNative : NSObject <RCTBridgeModule>
#endif

@end
