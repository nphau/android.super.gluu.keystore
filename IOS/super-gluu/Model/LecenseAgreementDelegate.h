//
//  LecenseAgreementDelegate.h
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/3/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

@protocol LicenseAgreementDelegate

-(void)approveRequest;
-(void)denyRequest;

@end
