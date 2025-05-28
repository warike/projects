//
//  Amazon.swift
//  scoodit
//
//  Created by Sergio Esteban on 2/25/17.
//  Copyright © 2017 Sergio Cardenas. All rights reserved.
//

import Foundation
import AWSCore


let S3BucketName: String = "scoodit-images"
let regionType = AWSRegionType.EUCentral1
let pool_id = "us-west-2:74233803-1225-42b0-adee-44582630b79c"


protocol AmazonHelper {
    func getConfiguration(from region: AWSRegionType, pool_id: String) -> AWSServiceConfiguration
}

extension AmazonHelper {
    func getConfiguration(from region: AWSRegionType, pool_id: String) -> AWSServiceConfiguration{
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: region, identityPoolId: pool_id)
        let configuration = AWSServiceConfiguration(region:regionType, credentialsProvider: credentialsProvider)
        return configuration!
    }
}
