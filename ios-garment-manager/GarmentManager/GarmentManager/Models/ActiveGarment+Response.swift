//
//  ActiveGarment+Response.swift
//  nadix
//
//  Created by james on 3/4/17.
//  Copyright © 2017 Snepo. All rights reserved.
//

import Foundation
import FocusMotion

let dataIndexResponse = 0

enum ResponseType : Int {
    case version = 1
    case battery = 2
    case sensor = 3
    case endCalib = 4
}

extension ActiveGarment {
    
    func didReceive(_ data:Data) {
        guard let cmd = ResponseType(rawValue: Int(data[dataIndexResponse])) else {
            print("unrecognised response: \(data)")
            return
        }
        
        switch cmd {
        case .sensor:
            readSensor(data)
        default:
            readResponse(cmd, withData:data)
        }
    }
    
    //Read x, y, z values of each sensor in order of index
    fileprivate func readSensor(_ data:Data) {
        let sensorErrorValue : Int16 = -1
        let index : Int8 = Int8(data[1]);
        
        let xValue = (Int16(data[2]) << 8 + Int16(data[3])) >> 2
        let yValue = (Int16(data[4]) << 8 + Int16(data[5])) >> 2
        let zValue = (Int16(data[6]) << 8 + Int16(data[7])) >> 2
        
        if (xValue != sensorErrorValue) && (xValue != sensors[index]?.x) && // valid non-repeated value
            (maxActiveIndex == nil || index >= maxActiveIndex! ) {
            (maxActiveIndex, maxIndexUpdate) = (index, Date())
        }

        var dataDict = Dictionary<String, Int>()
        dataDict["index"] = Int(index)
        dataDict["x"] = Int(xValue)
        dataDict["y"] = Int(yValue)
        dataDict["z"] = Int(zValue)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedData"), object:nil, userInfo:dataDict)
        
        let data = (index, xValue, yValue, zValue)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKey.activeGarmentResponseData), object: nil, userInfo: ["responseData":data])
        sensors.updateValue(AccelerometerReading(x: xValue, y: yValue, z: zValue), forKey: index)
        
        if garmentType != .unknown {
            let sensorData: FMSensorData = fmDeviceOutput.getSensorData(.accelerometer, index: Int(index))
            sensorData.samplingRate = 9.5 //maybe do dynamically?
            sensorData.appendSample([Float(xValue)*ActiveGarment.gScale, Float(yValue)*ActiveGarment.gScale, Float(zValue)*ActiveGarment.gScale, Float(-startDate.timeIntervalSinceNow)])
        }
    }
    
    static let gScale : Float = 9.80665 / 2048.0
    
    fileprivate func readResponse(_ response:ResponseType, withData data:Data) {
        switch response {
        case .version:
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVersion"), object:nil)
            break
        case .battery:
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBattery"), object:nil)
            break
        case .endCalib:
            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endCalibration"), object:nil, userInfo:nil)
            break
        default:
            print("Unexpected Reponse: \(data)")
            //        } else if characteristic.uuid == CBUUID.init(string: OTAConstants.dfuControlPointCharacteristicUUIDString) {
            //            receivedNotification(data: characteristic.value!)
        }
        
    }
}
