//
//  MailView.swift
//  ToDue
//
//  Created by Niklas Kuder on 25.08.22.
//

import SwiftUI
import UIKit
import MessageUI

// Credit for this struct goes to https://swiftuirecipes.com/blog/send-mail-in-swiftui
typealias MailViewCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

struct MailView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  @Binding var supportEmail: ContactEmail
  let callback: MailViewCallback

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    @Binding var presentation: PresentationMode
    @Binding var data: ContactEmail
    let callback: MailViewCallback

    init(presentation: Binding<PresentationMode>,
         data: Binding<ContactEmail>,
         callback: MailViewCallback) {
      _presentation = presentation
      _data = data
      self.callback = callback
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
      if let error = error {
        callback?(.failure(error))
      } else {
        callback?(.success(result))
      }
      $presentation.wrappedValue.dismiss()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(presentation: presentation, data: $supportEmail, callback: callback)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let mvc = MFMailComposeViewController()
    mvc.mailComposeDelegate = context.coordinator
    mvc.setSubject(supportEmail.subject)
    mvc.setToRecipients([supportEmail.toAddress])
    mvc.setMessageBody(supportEmail.body, isHTML: false)
      if let data = supportEmail.data {
          mvc.addAttachmentData(data, mimeType: "text/plain", fileName: "\(Bundle.main.displayName).json")
      }
    mvc.accessibilityElementDidLoseFocus()
    return mvc
  }

  func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
  }

  static var canSendMail: Bool {
    MFMailComposeViewController.canSendMail()
  }
}
