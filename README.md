# Secure Credentials Manager
A Flutter-based password/credentials manager focused on security and user privacy.

## Overview
Secure Credentials Manager is designed to provide a safe and offline password storage solution. The app leverages the Flutter framework to create a user-friendly interface while ensuring that all sensitive information is securely stored and only accessible by the user.

## Key Features
* **Offline Storage**: All data is stored locally using SharedPreferences, eliminating the need for internet access and enhancing security.
* **Password Hashing**: Utilizes hashing to securely store passwords, ensuring that they remain protected.
* **Import/Export Functionality**: Allows users to import and export the SharedPreferences file, ensuring data portability. The exported file contains hashed passwords that can only be accessed within the app.
* **User Privacy**: Designed with a strong focus on user privacy, ensuring no malicious intent and no external access to your data.
* **Motto**: "Own your passwords, and don't trust someone else to take care of them for you."

## Installation and Setup
Follow these steps to get the app running on your local machine:

* Clone the repository:
```
git clone https://github.com/iabhi4/Password-Manager-App.git
cd password-manager-app
```
* Install dependencies:
```
flutter pub get
```
* Run the app:
```
flutter run
```

## Contributions
Contributions are welcome! Please submit a pull request or open an issue to discuss improvements or bugs.

## License
This project is licensed under the MIT License.

