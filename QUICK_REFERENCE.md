# Quick Reference Guide - My Sauda Auth Module

## 🚀 Quick Start

### Run the App

```bash
cd /Users/jitarth/Documents/my_sauda
flutter pub get
flutter run
```

### Test the Authentication Flows

**Register Flow**:

1. App opens to Login screen
2. Click "Register" link at bottom
3. Fill in all fields:
   - Name: "John Doe"
   - Company: "Farmer's Coop"
   - Phone: "9876543210"
   - Email: "john@example.com"
   - Password: "password123"
4. Click "Register" button
5. See success message → navigates to Login

**Login Flow**:

1. Enter: "john@example.com" / "password123"
2. Click "Login" button
3. See success message

---

## 📁 Quick File Reference

| File                     | What to Find                              |
| ------------------------ | ----------------------------------------- |
| `main.dart`              | App setup, Riverpod scope, routing        |
| `app_theme.dart`         | Colors, fonts, input styling              |
| `router.dart`            | Navigation routes (`/login`, `/register`) |
| `login_screen.dart`      | Login UI, form handling                   |
| `register_screen.dart`   | Registration UI, 5 fields                 |
| `auth_view_model.dart`   | State management, validation logic        |
| `custom_text_field.dart` | Reusable input component                  |

---

## 🎨 Theme Colors

```dart
AppTheme.primaryColor    // #2E7D32 (Green)
AppTheme.accentColor     // #6D4C41 (Brown)
AppTheme.backgroundColor // #F5F5F0 (Light Beige)
AppTheme.textColor       // #333333 (Dark Grey)
AppTheme.white           // #FFFFFF
```

---

## 🔑 Key Code Snippets

### Using Auth ViewModel

```dart
// Watch auth state in UI
final authState = ref.watch(authViewModelProvider);

// Call register
final authViewModel = ref.read(authViewModelProvider.notifier);
bool success = await authViewModel.register(
  name: 'John',
  companyName: 'Coop',
  phone: '1234567890',
  email: 'john@example.com',
  password: 'password123',
);

// Call login
bool success = await authViewModel.login(
  email: 'john@example.com',
  password: 'password123',
);

// Handle errors
if (authState.error != null) {
  print(authState.error);
}

// Check if loading
if (authState.isLoading) {
  // Show spinner
}
```

### Using CustomTextField

```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  isPassword: false,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Required';
    return null;
  },
)
```

### Navigation

```dart
// Go to login
context.go('/login');

// Go to register
context.go('/register');
```

---

## ✅ Validation Rules

### Registration Fields

```
Name:        Min 2 characters
Company:     Required (any length)
Phone:       Min 10 digits
Email:       Must be valid email (name@domain.com)
Password:    Min 6 characters
```

### Login Fields

```
Email:       Must be valid email
Password:    Required (any length)
```

---

## 🔄 State Transitions

```
Initial → Loading → Success/Error
                        ↓
                    User Redirected/Error Shown
```

### AuthState Structure

```dart
class AuthState {
  bool isLoading;           // True during API calls
  String? error;            // Error message (null if no error)
  bool isAuthenticated;     // True if user is logged in
}
```

---

## 🐛 Common Issues & Solutions

### Issue: "No issues found" but app won't run

**Solution**: Make sure you have:

```bash
flutter pub get
flutter clean
flutter pub get
flutter run
```

### Issue: "Provider not found" error

**Solution**: Make sure `ProviderScope` wraps `MyApp()` in `main.dart`

### Issue: Navigation not working

**Solution**: Check that routes are correct:

- `/login` → LoginScreen
- `/register` → RegisterScreen

### Issue: Validation not showing

**Solution**: Ensure `_formKey.currentState!.validate()` is called before submission

---

## 📝 Customization Guide

### Change Theme Colors

Edit `lib/core/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF2E7D32); // Change this
static const Color accentColor = Color(0xFF6D4C41);  // Or this
```

### Change Button Text

Edit screen files (`login_screen.dart`, `register_screen.dart`):

```dart
ElevatedButton(
  onPressed: _handleLogin,
  child: const Text('Login'),  // Change text here
)
```

### Change Validation Messages

Edit `auth_view_model.dart` or screen validators:

```dart
if (value == null || value.isEmpty) {
  return 'Email is required';  // Customize this
}
```

### Add New Fields

1. Add field to screen form
2. Add validation in validator function
3. Add parameter to ViewModel method
4. Update copyWith() in AuthState if storing data

---

## 🔗 API Integration (TODO)

In `auth_view_model.dart`, replace:

```dart
// Current (simulated):
await Future.delayed(const Duration(milliseconds: 800));

// With actual Supabase call:
final response = await Supabase.instance.client.auth.signUp(
  email: email,
  password: password,
);
```

---

## 📦 Dependencies Versions

```yaml
riverpod: ^2.6.0 # State management core
flutter_riverpod: ^2.6.0 # Flutter integration
go_router: ^14.0.0 # Navigation
supabase_flutter: ^2.12.4 # Backend (ready to use)
flutter: SDK 3.2.6+ # Flutter version
```

---

## 🎯 Testing Checklist

- [ ] Register with all fields
- [ ] See validation errors for empty fields
- [ ] See validation error for invalid email
- [ ] See validation error for short password
- [ ] Register successfully → redirected to login
- [ ] Login with registered credentials
- [ ] See error for invalid email format
- [ ] See error for empty fields
- [ ] See loading spinner during "authentication"
- [ ] Navigate between login/register links
- [ ] Theme colors applied correctly
- [ ] Inputs have rounded corners
- [ ] All text is readable
- [ ] Works on different screen sizes

---

## 📚 Documentation Files

- **AUTH_MODULE_DOCUMENTATION.md** - Complete detailed guide
- **IMPLEMENTATION_SUMMARY.md** - Implementation details
- **QUICK_REFERENCE.md** - This file

---

## 💡 Pro Tips

1. **Form Validation**: Use `_formKey.currentState!.validate()` to trigger all validators at once
2. **Error Handling**: Always check `authState.error` after async operations
3. **Loading States**: Show spinners while `authState.isLoading` is true
4. **Reusability**: Use `CustomTextField` for all text inputs
5. **Theme**: Always use `AppTheme.colors` instead of hardcoding colors
6. **Navigation**: Use `context.go()` for named routes
7. **State**: Use `ref.watch()` for UI updates, `ref.read()` for methods

---

## 🚀 Next Steps

1. Test the current implementation
2. Run on device/emulator
3. Test all validation rules
4. Test navigation flows
5. Connect to Supabase backend
6. Add home screen after login
7. Store authentication token
8. Add password recovery

---

## ❓ Quick Q&A

**Q: How do I add a new field to registration?**
A: Add it to RegisterScreen, add validation, add to register() method parameters

**Q: How do I change colors?**
A: Edit `lib/core/theme/app_theme.dart` constants at the top

**Q: How do I connect to Supabase?**
A: Replace `Future.delayed()` in `auth_view_model.dart` with Supabase API calls

**Q: How do I persist login?**
A: Store token in secure storage, check it on app startup in main.dart

**Q: Can I customize input styles?**
A: Yes, edit `InputDecorationTheme` in `app_theme.dart`

---

## ✨ You're All Set!

The authentication module is ready to use. Start with `flutter run` and test the flows!
