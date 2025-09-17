#import "MendixNative.h"
#import "MendixNative-Swift.h"

@implementation MendixNative
RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeMendixNativeSpecJSI>(params);
}

- (void)cookieClearAll {
  [[[NativeCookieModule alloc] init] clearAll];
}

- (void)splashScreenHide {
  [[[MendixSplashScreen alloc] init] hide];
}

- (void)splashScreenShow {
  [[[MendixSplashScreen alloc] init] show];
}

- (void)encryptedStorageClear {
  [[[EncryptedStorage alloc] init] clear];
}

- (void)encryptedStorageGetItem:(nonnull NSString *)key resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  [[[EncryptedStorage alloc] init] getItemWithKey:key resolve:resolve reject:reject];
}

- (nonnull NSNumber *)encryptedStorageIsEncrypted { 
  return [NSNumber numberWithBool: [EncryptedStorage isEncrypted]];
}

- (void)encryptedStorageRemoveItem:(nonnull NSString *)key resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  [[[EncryptedStorage alloc] init] removeItemWithKey:key resolve:resolve reject:reject];
}

- (void)encryptedStorageSetItem:(nonnull NSString *)key value:(nonnull NSString *)value resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  [[[EncryptedStorage alloc] init] setItemWithKey:key value:value resolve:resolve reject:reject];
}

- (void)reloadHandlerExitApp { 
  [[[ReloadHandler alloc] init] exitApp];
}

- (void)reloadHandlerReload { 
  [[[ReloadHandler alloc] init] reload];
}

- (void)reloadHandlerReloadClientWithState { 
  [self sendEventWithName:[ReloadHandler reloadWithStateEventName] body:nil];
}

- (nonnull NSString *)reloadHandlerReloadWithStateEventName { 
  return [ReloadHandler reloadWithStateEventName];
}

- (nonnull NSArray<NSString *> *)reloadHandlerSupportedEvents { 
  return [ReloadHandler supportedEvents];
}

- (void)downloadHandlerDownload:(nonnull NSString *)url downloadPath:(nonnull NSString *)downloadPath mimeType:(nonnull NSString *)mimeType connectionTimeout:(double)connectionTimeout resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  [[[NativeDownloadModule alloc] init] download:url downloadPath:downloadPath config:@{@"mimeType": mimeType, @"connectionTimeout": [NSNumber numberWithDouble:connectionTimeout] } resolver:resolve rejecter:reject];
}

- (nonnull NSArray<NSString *> *)downloadHandlerSupportedEvents { 
  return [[[NativeDownloadModule alloc] init] supportedEvents];
}

- (NSArray<NSString *> *)supportedEvents {
  
  NSArray<NSString *> *downloadEvents = [self downloadHandlerSupportedEvents];
  NSArray<NSString *> *reloadEvents = [self reloadHandlerSupportedEvents];
  
  NSMutableArray<NSString *> *allEvents = [[NSMutableArray alloc] init];
  
  for (int i = 0; i < downloadEvents.count ; i++) {
    [allEvents addObject:downloadEvents[i]];
  }
  
  for (int i = 0; i < reloadEvents.count ; i++) {
    [allEvents addObject:reloadEvents[i]];
  }
  return allEvents;
}

@end
