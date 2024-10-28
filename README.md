
# Enigma
This application provides a seamless chat experience with support for voice and video calls, making communication easier and more interactive.

![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Android Studio](https://img.shields.io/badge/android%20studio-346ac1?style=for-the-badge&logo=android%20studio&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-a08021?style=for-the-badge&logo=firebase&logoColor=ffcd34)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)


## Features

* User Authentication: Sign up and log in securely.
* Chat Request: Decide who want to communicate by sending and recieving chat requests.
* Barcode Scanning: Easily send chat requests by scanning the barcode of your friends QR code.
* Real-time Chat: Send and receive messages, audio messages, images instantly.
* Voice Calls: Connect with friends, family, or colleagues via voice calls.
* Video Calls: Enable face-to-face communication using video calls.
* Call and Chat Notifications: Receive real-time notifications for calls and chats across foreground, background, and terminated app states, ensuring no missed updates.
* Stories: Share your day with uploading stories.
* Profile Management: Manage user profiles.
* Theme Mode: Switch between Dark and Light mode.

## Technology
1. Dart as the source language
2. Flutter for cross-platform application
3. Firebase for Backend
4. Agora SDK for Real-Time-Communication
5. Python and FastAPI for Backend Services

## Highlights
* Codebase follows **MVVM** and **Clean Architecture**
* Routing management using **GoRouter**
* Local Databases used (**Sembast**, **Shared Preferences**)
* **Barcode scanner** for sending chat requests
* **Deeplink** implemented for chats and calls in Foreground, Background and Terminated state to automatically navigate to a specific screen.
* Real-Time-Communication:
    * Implemented the **Agora RTC** for voice calls and video calls.
    * Built a backend service using **FastAPI** to generate unique token for voice and video call.
    * Utilized the hardware's call module by using **Flutter Callkit Incoming** to send and recieve call notifications.

## Demo
Coming soon...


## Installation
Clone the repository:
```bash
  git clone https://github.com/Sifat-16/enigma.git
  cd enigma
```
Install dependencies: Make sure you have Flutter installed, then run:
```bash
  flutter pub get
``` 

Run the App:
```bash
  flutter run
```


