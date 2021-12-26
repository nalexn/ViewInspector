@import Foundation;
@import AuthenticationServices;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@interface VIASAuthorization: ASAuthorization

+ (VIASAuthorization *)appleID;
- (void)setProvider:(id<ASAuthorizationProvider> _Nonnull)provider;
- (void)setCredential:(id<ASAuthorizationCredential> _Nonnull)credential;

+ (void)pass: (ASAuthorizationAppleIDRequest *)request block:(void (^_Nonnull)(ASAuthorizationAppleIDRequest *))block;

@end

AS_EXTERN API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@interface ASAuthorizationAppleIDCredential (Init)
+ (ASAuthorizationAppleIDCredential *)appleIDCredentialWithUser:(NSString *)user;
@end

NS_ASSUME_NONNULL_END
