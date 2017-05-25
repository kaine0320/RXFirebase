//
//  FIRDatabaseQuery+Rx.swift
//  TreeCave
//
//  Created by Alex Hung on 21/4/2017.
//  Copyright © 2017 Alex Hung. All rights reserved.
//

import Firebase
import FirebaseStorage
import RxSwift

//MARK: Completion Block

fileprivate func handleWith(observer : AnyObserver<FIRDataSnapshot?>) -> (FIRDataSnapshot)-> Void {
    return { snapshot in
        observer.onNext(snapshot)
    }
}

fileprivate func handleWith(observer : AnyObserver<FIRDatabaseReference>) -> (Error?, FIRDatabaseReference)-> Void {
    return { (error , databaseReference) in
        
        if error != nil {
            observer.onError(error!)
            return;
        } else {
            observer.onNext(databaseReference)
            observer.onCompleted()
        }
    }
}

fileprivate func handleWith(observer: AnyObserver<FIRUser?>) -> (FIRUser? , Error?) -> Void {
    return { (user, error) in
        if error != nil {
            observer.onError(error!)
        } else {
            observer.onNext(user!)
            observer.onCompleted()
        }
    }
}

fileprivate func handleWith(observer: AnyObserver<URL?>) -> (FIRStorageMetadata?, Error?) -> Void {
    return { (metadata , error) in
        if error != nil {
            observer.onError(error!)
        } else {
            observer.onNext(metadata?.downloadURL())
            observer.onCompleted()
        }
    }
}

public extension FIRAuth {
    
    func rx_createUserWith(email: String, password: String) -> Observable<FIRUser?> {
        
        return Observable.create { observer in
            self.createUser(withEmail: email, password: password, completion: handleWith(observer: observer))
            
            return Disposables.create()
        }
    }
    
    func rx_signInWith(email: String, password: String) -> Observable<FIRUser?> {
        return Observable.create { observer in
            self.signIn(withEmail: email, password: password, completion: handleWith(observer: observer))
            
            return Disposables.create()
        }
    }
}

public extension FIRDatabaseQuery {
    
    func rx_observe(eventType: FIRDataEventType) -> Observable<(FIRDataSnapshot?)> {
        return Observable.create{ observer in
            let handle = self.observe(eventType, with:handleWith(observer: observer))
            
            return Disposables.create {
                self.removeObserver(withHandle: handle)
            }
        }
    }
    
    func rx_observeSingleEvent(eventType: FIRDataEventType) -> Observable<(FIRDataSnapshot?)> {
        return Observable.create{ observer in
            self.observeSingleEvent(of: eventType, with:handleWith(observer: observer))
            
            return Disposables.create()
        }
    }
}

public extension FIRDatabaseReference {
    
    func rx_updateChildValues(_ values: [String : AnyObject]) -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.updateChildValues(values, withCompletionBlock:handleWith(observer: observer))
            
            return Disposables.create()
        }
    }
    
    func rx_setValue(_ value: Any?, priority: AnyObject? = nil) -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            
            let completion = handleWith(observer: observer)
            
            if priority == nil {
                self.setValue(value, withCompletionBlock: completion)
            } else {
                self.setValue(value, andPriority: priority, withCompletionBlock: completion)
            }
            
            return Disposables.create()
        }
    }
}

public extension FIRStorageReference {
    
    func rx_put(data: Data, metadata: FIRStorageMetadata? = nil) -> Observable<URL?> {
        return Observable.create { observer in
            self.put(data, metadata: metadata, completion: handleWith(observer:observer))
            
            return Disposables.create()
        }
        
    }
}
