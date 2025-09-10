//
//  GraniteModule.m
//  ios
//
//  Objective-C bridge for GraniteModule Swift implementation
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(GraniteModule, NSObject)

RCT_EXTERN_METHOD(closeView)

RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(schemeUri)

RCT_EXTERN_METHOD(setScheme:(NSString *)scheme)

RCT_EXTERN_METHOD(configureBridge:(RCTBridge *)bridge)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

@end