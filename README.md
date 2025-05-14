# Mess Management App

A Flutter application for managing mess operations including attendance, payments, expenses, and user profiles.

## Features

- **Authentication**
  - Secure token-based authentication
  - Persistent login state
  - Automatic token refresh
  - Secure storage of sensitive data

- **Profile Management**
  - View and edit user profile
  - Update personal information
  - Secure logout functionality

- **Attendance Tracking**
  - Mark attendance for breakfast, lunch, and dinner
  - Real-time updates
  - Visual feedback for attendance status

- **History Management**
  - View payment and expense history
  - Search functionality
  - Filter by time periods
  - Color-coded transactions

## Technical Implementation

### Architecture
- **MVC Pattern**
  - Model: Data management and business logic
  - View: UI components and presentation
  - Controller: Handles user interactions and API calls

### State Management
- Provider package for state management
- ChangeNotifier for reactive updates
- Hive for local storage
- Flutter Secure Storage for sensitive data

### API Integration
- Dio for HTTP requests
- Interceptors for token management
- Error handling and retry logic
- Offline support with local storage

### Security
- Secure token storage
- Automatic token refresh
- Session management
- Data encryption for sensitive information

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  dio: ^5.4.0
  provider: ^6.1.1
  connectivity_plus: ^5.0.2
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

## Project Structure

```
lib/
├── controllers/
│   ├── base_controller.dart
│   └── ...
├── models/
│   ├── base_model.dart
│   └── ...
├── services/
│   └── storage_service.dart
├── utilities/
│   ├── api_urls.dart
│   └── dio_client.dart
├── views/
│   ├── attendance/
│   ├── history/
│   └── profile/
└── main.dart
```

## Storage Implementation

### Token Management
- Tokens stored securely using `flutter_secure_storage`
- Automatic token refresh on expiration
- Secure token deletion on logout

### User Data Storage
- User data stored in Hive boxes
- Efficient local storage
- Offline data access
- Automatic data synchronization

## API Integration

### Dio Client Configuration
- Base URL configuration
- Timeout settings
- Error handling
- Token management
- Request/Response interceptors

### Error Handling
- Connection timeout handling
- Server error responses
- Unauthorized access handling
- Network connectivity checks

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Environment Setup

1. Ensure Flutter SDK is installed
2. Set up Android Studio/VS Code
3. Configure API endpoints in `api_urls.dart`
4. Set up secure storage keys

## Security Considerations

- Tokens stored securely using platform-specific secure storage
- Sensitive data encrypted at rest
- Automatic session cleanup on logout
- Network security configurations

## Known Issues and Solutions

### 1. Dio Client Singleton Implementation
**Issue**: The current Dio client implementation has a singleton pattern issue where the storage service is not properly initialized.
```dart
factory DioClient({
  required StorageService storage,
}) {
  return _instance;  // This ignores the storage parameter
}
```

**Solution**: Update the Dio client to properly handle the storage service:
```dart
factory DioClient({
  required StorageService storage,
}) {
  _instance._storage = storage;
  return _instance;
}
```

### 2. Hive Box Initialization
**Issue**: Hive boxes are not properly registered with adapters, which can cause type errors when storing complex objects.

**Solution**: Register Hive adapters for custom types:
```dart
// In main.dart
await Hive.initFlutter();
Hive.registerAdapter(UserAdapter());
await Hive.openBox<User>('userBox');
```

### 3. Token Refresh Logic
**Issue**: The current implementation lacks token refresh logic when the token expires.

**Solution**: Implement token refresh mechanism:
```dart
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    try {
      final newToken = await refreshToken();
      await _storage.saveToken(newToken);
      return handler.resolve(await _retry(error.requestOptions));
    } catch (e) {
      await _storage.clearAll();
      // Navigate to login
    }
  }
  return handler.next(error);
}
```

### 4. Error Handling in Controllers
**Issue**: Error messages are not properly propagated to the UI layer.

**Solution**: Implement proper error handling in controllers:
```dart
Future<void> loadUserData() async {
  try {
    await handleApiCall(
      () async {
        final response = await dioClient.get(ApiUrls.profile);
        model.updateUserData(response.data);
      },
      onError: (error) {
        model.setError('Failed to load user data: $error');
        // Show error in UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  } catch (e) {
    // Handle unexpected errors
  }
}
```

### 5. State Management
**Issue**: Provider usage in views can lead to unnecessary rebuilds.

**Solution**: Optimize provider usage:
```dart
// Use Consumer with specific parts of the UI
Consumer<ProfileModel>(
  builder: (context, model, child) {
    return Column(
      children: [
        // Static widgets that don't need rebuild
        child!,
        // Dynamic content
        if (model.isLoading) LoadingIndicator(),
      ],
    );
  },
  child: StaticWidget(), // Won't rebuild
)
```

### 6. Form Validation
**Issue**: Form validation is not properly implemented in the profile view.

**Solution**: Add proper form validation:
```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (field == 'email' && !isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    if (field == 'phone' && !isValidPhone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  },
)
```

### 7. Network Connectivity
**Issue**: The app doesn't handle offline scenarios properly.

**Solution**: Implement proper offline handling:
```dart
// In Dio client
Future<Response> get(String path) async {
  if (!await checkInternetConnection()) {
    // Return cached data if available
    final cachedData = await _storage.getCachedData(path);
    if (cachedData != null) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: cachedData,
      );
    }
    throw 'No internet connection';
  }
  // Proceed with network request
}
```

### 8. Security
**Issue**: Sensitive data might be exposed in logs or error messages.

**Solution**: Implement proper security measures:
```dart
// Remove sensitive data from logs
void logError(String error) {
  final sanitizedError = error.replaceAll(RegExp(r'token=[^&]+'), 'token=***');
  debugPrint(sanitizedError);
}
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
