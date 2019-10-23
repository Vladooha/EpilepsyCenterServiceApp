# Frontend of Epilepsy Center app 

Multiplatform app for Android/iOS/Web created with Flutter (Dart lang)

## Getting Started with Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Functionality
This application represents default REST-client app based on MVVM-like architecture
('...View' classes is View + ViewModel part of MVVM because of some Flutter features)

Planned features:
- Chat for Doctor and his Patients
- Ketone calculator remotely controlled by Doctor 
- Remote medical appointment and similar features

## Class naming
- ...View - Android activity or Web page analog
- ...ViewPart - custom widget on view
- ...ShadowView - invisible View with some logic that should be outside visible part