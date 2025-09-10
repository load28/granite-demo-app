//
//  GraniteCoreModule.m
//  ios
//
//  Objective-C bridge for GraniteCoreModule Swift implementation
//  Handles event system and lazy loading functionality
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(GraniteCoreModule, NSObject)

// Event System Methods
RCT_EXTERN_METHOD(addListener:(NSString *)eventName)

RCT_EXTERN_METHOD(removeListeners:(nonnull NSNumber *)count)

// Lazy Loading Method
RCT_EXTERN_METHOD(importLazy:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

@end