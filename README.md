# QuickTask Pro

A powerful and efficient Quick Task management application built with Flutter, Dart, and Back4App (Parse Server).

## 🚀 Features

-   **Cross-Platform:** Runs seamlessly on Android, iOS, Web, and Desktop.
-   **Task Management:** Create, read, update, and delete tasks easily.
-   **Real-time Synchronization:** Powered by Back4App (Parse Server) for real-time data sync.
-   **User-Friendly Interface:** Clean and intuitive UI designed for productivity.

## 🌟 Key Functionalities

### 1. User Authentication
*   **Sign Up:** Secure registration requiring a unique Username, Email, and Password.
*   **Login:** quick access using credentials.
*   **Session Management:** Keeps the user logged in until they explicitly sign out.

### 2. Task Management
*   **Create Tasks:** Easily add new tasks with a title and a mandatory **Due Date**.
*   **Smart Sorting:** intelligently organizes tasks:
    *   **Priority:** Incomplete tasks are always shown at the top.
    *   **Chronological:** Tasks are further sorted by their due dates.
*   **Real-time Updates:** Mark tasks as "Done" or "Undone" with immediate status updates synced to the cloud.
*   **Delete:** Remove unwanted tasks permanently.

### 3. Visual & Interactive UI
*   **Dynamic Backgrounds:** Beautiful gradient themes for authentication screens.
*   **Date Formatting:** Tasks display due dates in a readable `dd-MMM-yyyy` format.
*   **Validation:** Input fields validation ensures data integrity (e.g., non-empty titles, valid credentials).
*   **Feedback:** Toast messages and Error Dialogs provide immediate user feedback.

## 📂 Project Structure

-   `lib/main.dart`: The entry point. Handles the App logic, Home Screen, and Task Management features.
-   `lib/login.dart`: Handles User Login UI and logic.
-   `lib/signup.dart`: Handles new User Registration.
-   `lib/creds.dart`: (Sensitive) Contains configuration keys for Back4App/Parse Server.

## 🛠️ Tech Stack

-   **Frontend:** Flutter & Dart
-   **Backend:** Back4App (Parse Server)
-   **IDE:** Android Studio / VS Code

## 📦 Dependencies

This project relies on the following key packages:
-   [`parse_server_sdk_flutter`](https://pub.dev/packages/parse_server_sdk_flutter): For backend integration.
-   [`intl`](https://pub.dev/packages/intl): For date and time formatting.

## 🏁 Getting Started

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
-   An IDE (Android Studio or VS Code) with Flutter plugins.
-   A Back4App account and a created App to get Application ID and Client Key.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yo-sayantan/QuickTask_app.git
    cd QuickTask_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

## ⚙️ Configuration

Ensure you have configured your Back4App credentials in the project (typically in `lib/main.dart` or a dedicated configuration file) to connect to your database instance.

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
