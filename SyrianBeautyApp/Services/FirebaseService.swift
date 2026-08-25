//
//  FirebaseService.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private init() {}
    
    private let db = Firestore.firestore()
    func fetchCollection<T: Decodable>(
        collection: String,
        as type: T.Type,
        filters: [(field: String, op: String, value: Any)] = [],
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var query: Query = db.collection(collection)

        for filter in filters {
            query = query.whereField(filter.field, isEqualTo: filter.value)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                do {
                    let result = try documents.compactMap {
                        try $0.data(as: T.self)
                    }
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    // MARK: - Generic Fetch
    func fetchDocument<T: Decodable>(collection: String, documentId: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collection).document(documentId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                if let document = snapshot, document.exists {
                    let data = try document.data(as: T.self)
                    completion(.success(data))
                } else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist."])
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Generic Write
    func writeDocument<T: Encodable>(collection: String, documentId: String, data: T, completion: ((Error?) -> Void)? = nil) {
        do {
            try db.collection(collection).document(documentId).setData(from: data, completion: completion)
        } catch {
            completion?(error)
        }
    }

    // MARK: - Add to Collection with Auto ID
    func addDocument<T: Encodable>(collection: String, data: T, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let ref = try db.collection(collection).addDocument(from: data)
            completion(.success(ref.documentID))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Query Documents
    func queryDocuments<T: Decodable>(collection: String, field: String, isEqualTo value: Any, as type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collection).whereField(field, isEqualTo: value).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                let items = try snapshot?.documents.compactMap {
                    try $0.data(as: T.self)
                } ?? []
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    // MARK: - Update Specific Fields in Document
    func updateDocument(collection: String, documentId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(collection)
            .document(documentId)
            .updateData(data, completion: completion)
    }
}

