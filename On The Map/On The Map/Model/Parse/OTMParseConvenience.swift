//
//  OTMParseConvenience.swift
//  On The Map
//
//  Created by Bdoor on 26/04/1440 AH.
//  Copyright © 1440 badriah. All rights reserved.
//

import UIKit
import Foundation



extension OTMParseClient {
    
    
    func getAllDataFormUsers(_ completionHandlerForUserID: @escaping (_ success: Bool,_ usersData: [Any]?, _ errorString: String?) -> Void) {
        
        let parameters =  [OTMParseClient.ParameterKeys.Limit:OTMParseClient.ParameterValues.Limit,OTMParseClient.ParameterKeys.Order:OTMParseClient.ParameterValues.Order]
        
        
        _ = taskForGETMethod( OTMParseClient.Methods.StudentLocation, parameters: parameters as [String : AnyObject] , decode: StudentLocations.self) { (result, error) in
            
            
            if let error = error {
                
                completionHandlerForUserID(false ,nil ,"\(error.localizedDescription)")
            }else {
                let newResult = result as! StudentLocations
                if let usersData = newResult.results  {
                    completionHandlerForUserID(true ,usersData,nil)
                    
                }else {
                    completionHandlerForUserID(false ,nil ,"\( error!.localizedDescription)")
                    
                }
                
                
            }
        }
        
    }
    
    
    func getuserDataByUniqueKey(_ completionHandlerForUserID: @escaping (_ success: Bool,_ objectId:String?, _ errorString: String?) -> Void) {
        
        
        let method: String = Methods.StudentLocation
        
        let newParameterValues = substituteKeyInMethod(OTMParseClient.ParameterValues.Where, key: OTMParseClient.URLKeys.UserID, value: OTMUdacityClient.sharedInstance().userID!)!
        
        
        let parameters =  [OTMParseClient.ParameterKeys.Where:newParameterValues]
        
        
        _ = taskForGETMethod(method, parameters: parameters as [String : AnyObject], decode: StudentLocations.self) { (result, error) in
            
            
            if let error = error {
                
                completionHandlerForUserID(false ,nil ,"\(error.localizedDescription)")
            }else {
                let newResult = result as! StudentLocations
                
                if !((newResult.results?.isEmpty)!){
                    if let usersData = newResult.results  {
                      
                        if let objectId = usersData[0].objectId    {
                            OTMParseClient.sharedInstance().objectId = objectId
                            
                            
                        }
                        
                        completionHandlerForUserID(true ,self.objectId,nil)
                    }else {
                        completionHandlerForUserID(false ,nil ,"\( error!.localizedDescription)")
                        
                    }
                    
                }else {
                    completionHandlerForUserID(true ,self.objectId ,nil)
                    
                }
                
                
            }
        }
        
    }
    
    func postUserLocation<E: Encodable>( jsonBody:E ,completionHandlerForSession: @escaping (_ success: Bool , _ errorString: String?) -> Void) {
        
       
        _ = taskForPOSTMethod(Methods.StudentLocation, decode: StudentLocationsResponse.self, jsonBody: jsonBody) { (result, error) in
            
            if let error = error {
                completionHandlerForSession(false ,"\(error.localizedDescription) ")
            }else {
                if result != nil{
                    completionHandlerForSession(true ,nil)
                    
                }else {
                    completionHandlerForSession(false ," \(error!.localizedDescription)")
                    
                }
                
                
            }
        }
        
    }
    
    func putUserLocation<E: Encodable>( jsonBody:E ,completionHandlerForSession: @escaping (_ success: Bool , _ errorString: String?) -> Void) {
        
        
        var mutableMethod: String = Methods.StudentLocationUpdate
        mutableMethod = substituteKeyInMethod(mutableMethod, key: URLKeys.ObjectId, value: String(self.objectId!))!
        
        _ = taskForPUTMethod(mutableMethod, decode: StudentLocationsUpdateResponse.self, jsonBody: jsonBody) { (result, error) in
            
            if let error = error {
                completionHandlerForSession(false ,"\(error.localizedDescription) ")
            }else {
                if result != nil {
                    completionHandlerForSession(true  ,nil)
                    
                }else {
                    completionHandlerForSession(false ," \(error!.localizedDescription)")
                    
                }
                
                
            }
        }
        
    }
    
    
    
}


