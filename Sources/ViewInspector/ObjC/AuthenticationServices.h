@import Foundation;

#if __has_include(<AuthenticationServices/ASAuthorization.h>)
@import AuthenticationServices;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@interface VIASAuthorization: ASAuthorization

+ (VIASAuthorization *)authorization;
- (void)setProvider:(id<ASAuthorizationProvider> _Nonnull)provider;
- (void)setCredential:(id<ASAuthorizationCredential> _Nonnull)credential;

@end

API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@interface ASAuthorizationAppleIDCredential (Init)
+ (instancetype)credentialWithUser:(NSString *)user
                             email:(NSString * _Nullable)email
                          fullName:(NSPersonNameComponents * _Nullable)fullName
                             state:(NSString * _Nullable)state
                  authorizedScopes:(NSArray<ASAuthorizationScope> *)authorizedScopes
                 authorizationCode:(NSData * _Nullable)authorizationCode
                     identityToken:(NSData * _Nullable)identityToken
                    realUserStatus:(ASUserDetectionStatus)realUserStatus;
@end

NS_ASSUME_NONNULL_END

#endif
