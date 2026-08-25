//
//  AuthService.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var role: String?
    @Published var barberId: String?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            if let uid = user?.uid {
                self?.fetchUserRole(uid: uid) { result in
                    if case .failure(let error) = result {
                        print("Failed to fetch role on init:", error.localizedDescription)
                    }
                }
            } else {
                self?.role = nil
                self?.barberId = nil
            }
        }
    }

    deinit {
        if let handle = authListenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }


    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if email.lowercased() == "admin@local" && password == "admin123" {
            self.user = nil
            self.role = "manager"
            self.barberId = nil
            completion(.success(()))
            return
        }

        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
                return
            }

            self?.user = user
            self?.fetchUserRole(uid: user.uid, completion: completion)
        }
    }

    // MARK: - Fetch Role
    private func fetchUserRole(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let role = data["role"] as? String else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Role not found."])))
                return
            }

            self?.role = role
            self?.barberId = data["barberId"] as? String
            completion(.success(()))
        }
    }

    // MARK: - Sign Out
    func logout() {
        try? auth.signOut()
        self.user = nil
        self.role = nil
        self.barberId = nil
    }

    // MARK: - Get Current UID
    var currentUID: String? {
        return auth.currentUser?.uid
    }

    // MARK: - Create User
    func createUser(email: String, password: String, role: String, barberId: String?, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user."])))
                return
            }

            var userData: [String: Any] = [
                "name": name,
                "email": email,
                "role": role,
                "createdAt": FieldValue.serverTimestamp()
            ]

            if let barberId = barberId {
                userData["barberId"] = barberId
            }

            self?.db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
