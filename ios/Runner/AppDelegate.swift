import Flutter
import UIKit
import DeviceCheck
import CryptoKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "rahpeyman/device_attestation",
      binaryMessenger: engineBridge.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getDeviceId":
        result(UIDevice.current.identifierForVendor?.uuidString)
      case "isAppAttestSupported":
        result(DCAppAttestService.shared.isSupported)
      case "generateAppAttestKey":
        self.generateAppAttestKey(result: result)
      case "attestAppKey":
        guard
          let args = call.arguments as? [String: Any],
          let challenge = args["challenge"] as? String
        else {
          result(FlutterError(code: "INVALID_CHALLENGE", message: "Challenge is required", details: nil))
          return
        }
        self.attestAppKey(challenge: challenge, result: result)
      case "generateAppAttestAssertion":
        guard
          let args = call.arguments as? [String: Any],
          let challenge = args["challenge"] as? String
        else {
          result(FlutterError(code: "INVALID_CHALLENGE", message: "Challenge is required", details: nil))
          return
        }
        self.generateAssertion(challenge: challenge, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func generateAppAttestKey(result: @escaping FlutterResult) {
    DCAppAttestService.shared.generateKey { keyId, error in
      if let error {
        result(FlutterError(code: "APP_ATTEST_KEY_FAILED", message: error.localizedDescription, details: nil))
        return
      }
      guard let keyId else {
        result(FlutterError(code: "APP_ATTEST_KEY_FAILED", message: "No key id returned", details: nil))
        return
      }
      UserDefaults.standard.set(keyId, forKey: "rahpeyman.app_attest_key_id")
      result(keyId)
    }
  }

  private func clientDataHash(for challenge: String) -> Data? {
    guard let challengeData = Data(base64Encoded: challenge) else {
      return nil
    }
    return Data(SHA256.hash(data: challengeData))
  }

  private func attestAppKey(challenge: String, result: @escaping FlutterResult) {
    guard let keyId = UserDefaults.standard.string(forKey: "rahpeyman.app_attest_key_id"),
          let clientDataHash = clientDataHash(for: challenge) else {
      result(FlutterError(code: "APP_ATTEST_NOT_READY", message: "Generate a key and provide a valid challenge", details: nil))
      return
    }

    DCAppAttestService.shared.attestKey(keyId, clientDataHash: clientDataHash) { attestation, error in
      if let error {
        result(FlutterError(code: "APP_ATTEST_FAILED", message: error.localizedDescription, details: nil))
        return
      }
      result([
        "keyId": keyId,
        "attestation": attestation?.base64EncodedString() ?? "",
      ])
    }
  }

  private func generateAssertion(challenge: String, result: @escaping FlutterResult) {
    guard let keyId = UserDefaults.standard.string(forKey: "rahpeyman.app_attest_key_id"),
          let clientDataHash = clientDataHash(for: challenge) else {
      result(FlutterError(code: "APP_ATTEST_NOT_READY", message: "App Attest key is not available", details: nil))
      return
    }

    DCAppAttestService.shared.generateAssertion(keyId, clientDataHash: clientDataHash) { assertion, error in
      if let error {
        result(FlutterError(code: "APP_ATTEST_ASSERTION_FAILED", message: error.localizedDescription, details: nil))
        return
      }
      result(assertion?.base64EncodedString() ?? "")
    }
  }
}
