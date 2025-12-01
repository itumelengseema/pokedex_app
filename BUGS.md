# 🐛 Pokedex App - Known Bugs & Issues

Last Updated: December 1, 2025

## 🔴 Critical Bugs (Must Fix)

### 1. Favorites Not Persisted
**Severity:** Critical  
**Status:** 🔴 Open  
**File:** `lib/controllers/favorites_controller.dart`

**Issue:**
- Favorites are stored in memory only
- All favorites are lost when app closes/restarts
- User experience is broken - false expectation of persistence

**Impact:** High - Core feature doesn't work as expected

**Solution:**
- Implement SharedPreferences for local persistence
- OR use Firebase Firestore for cloud sync

**Code Location:**
```dart
// Line 3-5
class FavoritesController extends ChangeNotifier {
  final Set<int> _favoriteIds = {}; // ❌ Lost on restart
}
```

---

### 2. No User-Specific Favorites
**Severity:** Critical  
**Status:** 🔴 Open  
**File:** `lib/controllers/favorites_controller.dart`

**Issue:**
- All users share the same favorites list
- User A's favorites show for User B
- No user ID association with favorites

**Impact:** High - Multi-user authentication is useless for favorites

**Solution:**
- Store favorites in Firestore under user UID
- Structure: `/users/{userId}/favorites/{pokemonId}`

**Expected Behavior:**
- Each user should have their own favorites
- Favorites should sync across devices

---

### 3. Memory Leak - ScrollController Not Cleaned Up
**Severity:** Critical  
**Status:** 🔴 Open  
**File:** `lib/views/screens/home_screen.dart`

**Issue:**
- ScrollController listener added but never removed
- Causes memory leak over time
- Multiple listeners accumulate on hot reload

**Impact:** Medium - Performance degrades over time

**Code Location:**
```dart
// Line ~78
@override
void dispose() {
  // ❌ Missing: _scrollController.removeListener(_onScroll);
  _scrollController.dispose();
  super.dispose();
}
```

**Fix:**
```dart
@override
void dispose() {
  _scrollController.removeListener(_onScroll); // ✅ Add this
  _scrollController.dispose();
  super.dispose();
}
```

---

## ⚠️ High Priority Bugs

### 4. API Calls Have No Timeout
**Severity:** High  
**Status:** ⚠️ Open  
**File:** `lib/services/api_services.dart`

**Issue:**
- HTTP requests have no timeout limit
- App can hang indefinitely on slow/failed connections
- Poor user experience with no feedback

**Impact:** Medium - App appears frozen

**Solution:**
```dart
final response = await http.get(Uri.parse(url))
    .timeout(Duration(seconds: 10)); // ✅ Add timeout
```

---

### 5. Google Sign-In Commented Out But Documented
**Severity:** High  
**Status:** ⚠️ Open  
**File:** `lib/views/screens/login_screen.dart`

**Issue:**
- Lines 337-362: Google Sign-In button is commented out
- README.md claims Google Sign-In is a feature
- Documentation doesn't match implementation

**Impact:** Medium - False advertising, user confusion

**Decision Needed:**
- [ ] Remove Google Sign-In from README
- [ ] Uncomment and fix Google Sign-In implementation

---

### 6. No Favorites Screen/View
**Severity:** High  
**Status:** ⚠️ Open  
**File:** Missing file

**Issue:**
- Users can favorite Pokemon but can't view favorites list
- Profile shows favorite count but no way to access them
- No navigation to favorites

**Impact:** High - Feature is incomplete

**Required:**
- Create `lib/views/screens/favorites_screen.dart`
- Add navigation from profile screen
- Show grid/list of favorited Pokemon
- Allow unfavorite from this screen

---

### 7. Race Condition in Favorite Toggle
**Severity:** High  
**Status:** ⚠️ Open  
**File:** `lib/controllers/favorites_controller.dart`

**Issue:**
- Rapid tapping can cause state inconsistencies
- No debouncing or async handling
- Multiple toggles before `notifyListeners()` completes

**Solution:**
```dart
bool _isToggling = false;

Future<void> toggleFavorite(int pokemonId) async {
  if (_isToggling) return; // ✅ Prevent rapid taps
  _isToggling = true;
  
  // ... toggle logic ...
  
  _isToggling = false;
}
```

---

## 🟡 Medium Priority Bugs

### 8. Auth Error Not Propagated to UI
**Severity:** Medium  
**Status:** 🟡 Open  
**File:** `lib/controllers/auth_controller.dart`

**Issue:**
```dart
Future<void> signOut() async {
  try {
    // ... sign out logic ...
  } catch (e) {
    print('Sign out error: $e'); // ❌ Only prints, doesn't notify UI
  }
}
```

**Fix:** Add `rethrow;` or return error state

---

### 9. Case-Sensitive Search
**Severity:** Medium  
**Status:** 🟡 Open  
**File:** `lib/views/screens/home_screen.dart`

**Issue:**
- Search only works with exact case match
- "pikachu" won't find "Pikachu"

**Fix:**
```dart
pokemon.name.toLowerCase().contains(query.toLowerCase()); // ✅ Already done
```
*Note: Check if this is actually implemented correctly*

---

### 10. Missing Error State in Details Screen
**Severity:** Medium  
**Status:** 🟡 Open  
**File:** `lib/views/screens/details_screen.dart`

**Issue:**
- Only shows loading or content
- No error UI if API fails
- User sees blank screen on error

**Required:**
- Add error state widget
- Show retry button
- Display error message

---

### 11. No Null Check Before Adding Pokemon
**Severity:** Medium  
**Status:** 🟡 Open  
**File:** `lib/controllers/pokemon_controller.dart`

**Issue:**
```dart
final pokemonData = await ApiService.fetchPokemon(offset, limit);
_pokemons.addAll(pokemonData); // ❌ No null/empty check
```

**Fix:**
```dart
if (pokemonData != null && pokemonData.isNotEmpty) {
  _pokemons.addAll(pokemonData);
}
```

---

### 12. Firebase Already Initialized Error
**Severity:** Medium  
**Status:** 🟡 Open  
**File:** `lib/main.dart`

**Issue:**
- No check if Firebase is already initialized
- Causes errors on hot reload during development

**Fix:**
```dart
try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
} catch (e) {
  // Firebase already initialized
}
```

---

## 🟢 Low Priority Bugs

### 13. No Loading State for Favorite Toggle
**Severity:** Low  
**Status:** 🟢 Open  
**File:** `lib/views/widgets/pokemon_card.dart`

**Issue:**
- No loading indicator when toggling favorite
- If Firebase sync added, no feedback during save

**Enhancement:** Add loading spinner during async operations

---

### 14. No Undo for Unfavorite
**Severity:** Low  
**Status:** 🟢 Open  
**File:** `lib/controllers/favorites_controller.dart`

**Issue:**
- Accidental tap removes favorite permanently
- No confirmation dialog
- No undo option

**Enhancement:** Add SnackBar with undo action

---

### 15. No Filter for "Show Only Favorites"
**Severity:** Low  
**Status:** 🟢 Open  
**File:** `lib/views/screens/home_screen.dart`

**Issue:**
- Search doesn't have "favorites only" filter
- Users can't easily find favorited Pokemon

**Enhancement:** Add toggle button to filter favorites

---

### 16. Profile Screen - No Null User Handling
**Severity:** Low  
**Status:** 🟢 Open  
**File:** `lib/views/screens/profile_screen.dart`

**Issue:**
```dart
Text(_authService.currentUser?.email ?? 'No email')
```
- Shows "No email" instead of redirecting to login
- Should never show this if AuthWrapper works correctly

**Enhancement:** Add null check and redirect

---

## 📊 Bug Statistics

- **Total Bugs:** 16
- **Critical:** 3 🔴
- **High Priority:** 4 ⚠️
- **Medium Priority:** 6 🟡
- **Low Priority:** 3 🟢

## 🎯 Recommended Fix Order

1. ✅ **Favorites Persistence** (Bug #1) - Core feature broken
2. ✅ **User-Specific Favorites** (Bug #2) - Multi-user broken
3. ✅ **Memory Leak** (Bug #3) - Performance issue
4. ✅ **API Timeout** (Bug #4) - App hangs
5. ✅ **Create Favorites Screen** (Bug #6) - Complete the feature
6. ✅ **Race Condition** (Bug #7) - Data integrity
7. ⏳ **Google Sign-In Decision** (Bug #5) - Documentation fix
8. ⏳ **Error States** (Bugs #8, #10) - Better UX
9. ⏳ **Null Checks** (Bug #11) - Crash prevention
10. ⏳ **Everything else** - Nice-to-haves

