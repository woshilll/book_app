//
//  WoshilllPlugin.swift
//  Runner
//
//  Created by 李洋 on 2022/10/23.
//

import Flutter
import UIKit

public class WoshilllPlugin {
    static var channel: FlutterMethodChannel?
    static func register(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "woshill/plugin", binaryMessenger: messenger)
    }
    
    static func seedBookPath(path: [String: String]) {
        channel?.invokeMethod("bookPath", arguments: path)
    }
}
