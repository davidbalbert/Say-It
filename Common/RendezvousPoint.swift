//
//  RendezvousPoint.swift
//  Say It
//
//  Created by David Albert on 3/29/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Foundation

@objc protocol RendezvousPoint {
    func registerApp(endpoint: NSXPCListenerEndpoint)
    func registerServiceProvider(withReply reply: @escaping (NSXPCListenerEndpoint) -> Void)
}
