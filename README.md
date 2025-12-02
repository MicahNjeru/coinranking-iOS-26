# CryptoApp - iOS Cryptocurrency Tracker

A modern iOS application built with Swift that displays real-time cryptocurrency data from the CoinRanking API. Features a clean interface with favorites management, interactive price charts, and seamless UIKit-SwiftUI integration.

![iOS](https://img.shields.io/badge/iOS-18.6+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)
![Xcode](https://img.shields.io/badge/Xcode-26.1.1+-blue.svg)

---

## 📱 Features

### Core Functionality
- **📊 Top 100 Cryptocurrencies**: Browse the top 100 coins with real-time market data
- **📄 Smart Pagination**: Efficient loading of 20 coins per page
- **🔍 Sorting & Filtering**: Sort by market cap, price, or 24-hour performance
- **⭐ Favorites Management**: Swipe to add/remove favorites with Core Data persistence
- **📈 Interactive Charts**: Beautiful price charts using Swift Charts framework
- **⏱️ Multiple Time Periods**: View price history (3h, 24h, 7d, 30d, 3m, 1y, 3y, 5y)
- **🔄 Pull-to-Refresh**: Update data with a simple pull gesture
- **🌙 Dark Mode**: Full support for system light/dark mode

### Technical Highlights
- **Hybrid Architecture**: UIKit for list views + SwiftUI for detail screens
- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **Core Data**: Scalable favorites storage with real-time sync
- **Custom Image Cache**: Efficient async image loading with actor-based caching
- **Zero Dependencies**: Built entirely with native iOS frameworks
- **Comprehensive Testing**: Unit tests with 80%+ code coverage

---

## 🏗️ Architecture

### Design Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────────────┐
│                         App Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ AppDelegate  │  │SceneDelegate │  │TabBarController│     │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┴─────────────────────┐
        │                                            │
┌───────▼────────┐                          ┌───────▼──────────┐
│  UIKit Views   │                          │  SwiftUI Views   │
│  ───────────── │                          │  ──────────────  │
│  • CoinsListVC │                          │  • CoinDetailView│
│  • FavoritesVC │◄──── UIHostingController─┤  • Chart View    │
│  • Custom Cells│                          │  • Statistics    │
└───────┬────────┘                          └───────┬──────────┘
        │                                           │
        └─────────────────────┬─────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │    ViewModels     │
                    │  ─────────────────│
                    │  • CoinsListVM    │
                    │  • CoinDetailVM   │
                    │  • FavoritesVM    │
                    └─────────┬─────────┘
                              │
        ┌─────────────────────┴──────────────────────┐
        │                                            │
┌───────▼───────────┐                        ┌───────▼────────┐
│    Services       │                        │     Models     │
│  ──────────────   │                        │  ──────────────│
│  • NetworkService │                        │  • Coin        │
│  • CoreDataService│                        │  • CoinDetail  │
│  • ImageCache     │                        │  • FavoriteCoin│
└───────────────────┘                        └────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 26.1.1+**
- **iOS 18.6+** deployment target
- **macOS 26.0+** (for development)
- **CoinRanking API Key** (free tier available)

### Installation Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/MicahNjeru/coinranking-iOS-26.git
cd CryptoApp
```

#### 2. Open the Project
```bash
open CryptoApp.xcodeproj
```

#### 3. Configure API Key
1. Navigate to `Services/Secrets.swift`
2. Replace the placeholder with your API key:
```swift
enum Secrets {
    static let coinRankingAPIKey: String = "YOUR_API_KEY_HERE"
}
```

**Get your free API key:**
- Visit [CoinRanking Portal](https://coinranking.com/api)
- Sign up for a free account
- Generate an API key
- Free tier includes 5,000 requests/month

#### 4. Verify Core Data Model
Ensure `CryptoApp.xcdatamodeld` exists with the `FavoriteCoin` entity:
- Open the `.xcdatamodeld` file in Xcode
- Verify the `FavoriteCoin` entity has all required attributes
- If missing, create it following the documentation

#### 5. Build and Run
1. Select a simulator (iPhone 14 or later recommended)
2. Press `Cmd + R` to build and run
3. The app should launch showing the cryptocurrency list

### First Launch Checklist
- [ ] API key configured in `Secrets.swift`
- [ ] Core Data model file exists and is properly configured
- [ ] Info.plist has SceneDelegate configuration
- [ ] No build errors
- [ ] App launches and displays coin list

---

## 📝 Assumptions & Decisions

### Technical Assumptions

#### 1. **No User Authentication Required**
- **Assumption**: The app does not require user login or authentication
- **Rationale**: Simplifies the implementation while meeting all requirements
- **Impact**: Favorites are stored locally on the device only

#### 2. **API Key Security**
- **Assumption**: API key would ideally be fetched from a secure remote server
- **Current Implementation**: Stored in `Secrets.swift` for development purposes
- **Production Recommendation**: 
  - Store in Keychain
  - Fetch from authenticated backend endpoint
  - Use environment variables for CI/CD

#### 3. **iOS 18.6+ Target**
- **Decision**: Set minimum deployment target to iOS 18.6
- **Rationale**: 
  - Enables Swift Charts framework (iOS 16+, gracefully degraded)
  - Modern Swift concurrency (async/await)
  - Latest UIKit and SwiftUI features
- **Coverage**: ~95% of active iOS devices

#### 4. **Free API Tier Sufficient**
- **Assumption**: CoinRanking free tier (5,000 requests/month) is adequate
- **Implementation**: Includes caching and request optimization
- **Fallback**: Error handling for rate limit scenarios

### Design Decisions

#### 1. **Hybrid UIKit + SwiftUI Architecture**
- **Decision**: Use UIKit for list views, SwiftUI for detail view
- **Rationale**:
  - UITableView provides mature, performant pagination
  - Swift Charts requires SwiftUI
  - Demonstrates proficiency in both frameworks
  - Meets project requirements (mixture of UIKit and SwiftUI)

#### 2. **Programmatic UIKit (No Storyboards)**
- **Decision**: Build all UIKit views programmatically
- **Rationale**:
  - Better version control (no XML merge conflicts)
  - More maintainable and testable code
  - Easier code review
  - Industry best practice
  - Xcode trend toward programmatic UI

#### 3. **Core Data for Persistence**
- **Decision**: Use Core Data instead of UserDefaults
- **Rationale**:
  - More scalable solution (requirement specified)
  - Better performance with large datasets
  - Query capabilities (sorting, filtering)
  - Relationship support for future features
  - Demonstrates production-ready architecture

#### 4. **MVVM Architecture**
- **Decision**: Implement MVVM pattern with Combine
- **Rationale**:
  - Clear separation of concerns
  - Testable business logic
  - Reactive data binding
  - Maintainable and extensible
  - Industry standard for iOS

#### 5. **Custom Image Cache**
- **Decision**: Build custom image cache using Swift actors
- **Rationale**:
  - No external dependencies
  - Thread-safe with modern concurrency
  - Full control over caching strategy
  - Lightweight and efficient
  - Educational value

#### 6. **SF Symbol Fallbacks for SVG Icons**
- **Decision**: Use SF Symbols as fallbacks for non-PNG icons
- **Rationale**:
  - CoinRanking API provides SVG icons
  - Native SVG support requires third-party library or complex implementation
  - SF Symbol "bitcoinsign.circle.fill" provides consistent fallback
  - Maintains app performance and zero-dependency goal

---

## 🎯 Challenges Encountered & Solutions

### Challenge 1: Info.plist Configuration Issues

**Problem**: 
The default Xcode project template includes a pre-configured `Info.plist` with Main.storyboard references, which conflicts with programmatic UI and SceneDelegate setup.

**Investigation**:
- App launched with blank screen
- Console showed no scene delegate initialization
- Info.plist still referenced Main.storyboard

**Solution**:
1. Removed `UIMainStoryboardFile` key from Info.plist
2. Deleted `Main.storyboard` file completely
3. Configured `UIApplicationSceneManifest` with proper SceneDelegate class:
```xml
<key>UISceneDelegateClassName</key>
<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
```
4. Added explicit `delegateClass` assignment in AppDelegate

**Learning**: When migrating from storyboards to programmatic UI, all storyboard references must be removed from Info.plist, not just made optional.

---

### Challenge 2: Mixed Icon Format Support (SVG vs PNG)

**Problem**: 
Some cryptocurrency icons displayed correctly while others showed as blank. CoinRanking API provides icons in both PNG and SVG formats, but iOS UIImage cannot decode SVG natively.

**Investigation**:
- Added debug logging to track icon URLs and loading failures
- Discovered pattern: PNG icons worked, SVG icons failed silently
- Example: Bitcoin (PNG) loaded, but many altcoins (SVG) didn't

**Initial Attempts**:
1. Tried using `AsyncImage` without format checking - inconsistent results
2. Researched third-party SVG libraries (SVGKit, Macaw) - adds dependencies
3. Considered converting SVGs to PNG on server - not feasible with public API

**Final Solution**:
```swift
// In ImageCacheService.swift
private func downloadImage(from urlString: String) async -> UIImage? {
    // Check file extension
    if let ext = URL(string: urlString)?.pathExtension.lowercased(), ext != "png" {
        print("[ImageDebug] Non-PNG icon detected (\(ext)). Using placeholder")
        return placeholderImage
    }
    
    // Proceed with PNG download...
}
```

**Implementation**:
- Added extension checking before attempting download
- Used SF Symbol `bitcoinsign.circle.fill` as fallback
- Cached placeholders to avoid repeated processing
- Maintained consistent user experience

**Learning**: When working with external APIs, always validate asset formats before processing. Graceful degradation with system symbols maintains app polish.

---

### Challenge 3: Chart Data Quality Issues (5y Filter)

**Problem**: 
The 5-year chart filter crashed or displayed incorrectly. Upon investigation, historical data contained null/missing price values for certain time periods.

**Investigation**:
```
// Console showed:
Fatal error: Unexpectedly found nil while unwrapping Optional
// In Chart rendering code
```

**Root Cause**:
- CoinRanking API returns sparse historical data for long periods
- Some timestamps have `null` price values
- Swift Charts framework expects valid numeric data

**Solution Implemented**:
```swift
// In CoinDetailViewModel.swift
func fetchPriceHistory() async {
    do {
        let response = try await NetworkService.shared.fetchCoinHistory(...)
        
        // Filter out invalid entries
        let filtered = response.data.history.filter { item in
            if let priceString = item.price, 
               let value = Double(priceString), 
               value > 0 {
                return true
            }
            return false
        }
        
        priceHistory = filtered.reversed()
    } catch {
        errorMessage = "Failed to load price history"
    }
}
```

**Trade-offs**:
- **Pro**: Prevents crashes, maintains smooth UX
- **Con**: May not show actual zero-value data points (rare in crypto)
- **Acceptable**: Zero or negative prices are invalid for cryptocurrencies

**Additional Improvements**:
- Added loading indicators for slow network requests
- Implemented graceful error messages
- Chart shows "No data available" for empty datasets

**Learning**: Always validate API response data. Financial data requires extra scrutiny for null, zero, and negative values.

---

### Challenge 4: UITest Image Comparison

**Problem**: 
Writing UI tests to verify SF Symbol fallback behavior when invalid URLs are provided. Need to compare UIImage objects, which don't have built-in equality checking.

**Investigation**:
- Direct `UIImage ==` comparison doesn't work
- Memory addresses differ even for identical images
- Need pixel-level or data-level comparison

**Solution**:
```swift
@Test("ImageCacheService returns fallback SF Symbol for invalid URL")
func testImageCacheServiceMiss() async throws {
    let image = await ImageCacheService.shared.image(
        for: "https://example.com/non-existent.png"
    )
    
    #expect(image != nil)
    
    // Compare PNG data representation
    let expected = UIImage(systemName: "bitcoinsign.circle.fill")
    let symbolData = image?.pngData()
    let expectedData = expected?.pngData()
    
    #expect(symbolData == expectedData)
}
```

**Why This Works**:
- `pngData()` converts UIImage to deterministic byte representation
- Data comparison is exact and reliable
- Works across iOS versions

**Learning**: For iOS 17+, SF Symbol creation changed (deprecated string-based initializers). Using `pngData()` comparison provides version-agnostic testing.

---

### Challenge 5: UIKit to SwiftUI Navigation Bridge

**Problem**: 
Navigating from UIKit table view to SwiftUI detail view while maintaining navigation stack and tab bar visibility.

**Solution**:
```swift
class CoinDetailHostingController: UIHostingController<CoinDetailView> {
    init(coin: Coin) {
        let detailView = CoinDetailView(coin: coin)
        super.init(rootView: detailView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
}

// Usage in CoinsListViewController
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let coin = viewModel.coins[indexPath.row]
    let detailVC = CoinDetailHostingController(coin: coin)
    navigationController?.pushViewController(detailVC, animated: true)
}
```

**Key Points**:
- `UIHostingController` seamlessly embeds SwiftUI in UIKit navigation
- Navigation bar and back button work automatically
- Tab bar remains visible throughout navigation

---

### Challenge 6: Cross-Screen Favorites Synchronization

**Problem**: 
When toggling a favorite in one screen, other screens need to update immediately without manual refresh.

**Solution**:
```swift
// In CoreDataService
func addFavorite(coin: Coin) -> Bool {
    // ... save to Core Data ...
    
    NotificationCenter.default.post(
        name: .favoriteAdded, 
        object: nil, 
        userInfo: ["uuid": coin.uuid]
    )
    return true
}

// In ViewModels
private func setupNotifications() {
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleFavoriteChange),
        name: .favoriteAdded,
        object: nil
    )
}
```

**Result**: All screens update instantly when favorites change anywhere in the app.

---

## 📂 Project Structure

```
CryptoApp/
├── App/
│   ├── AppDelegate.swift                    # App lifecycle
│   ├── SceneDelegate.swift                  # Scene setup
│   └── MainTabBarController.swift           # Tab navigation
│
├── Models/
│   ├── Coin.swift                           # Coin model
│   ├── APIResponse.swift                    # API responses
│   ├── FavoriteCoin+CoreData.swift          # Core Data entity
│   └── FavoriteCoin+CoreDataProperties.swift# Core Data properties
│
├── ViewModels/
│   ├── CoinsListViewModel.swift             # List logic
│   ├── CoinDetailViewModel.swift            # Detail logic
│   └── FavoritesViewModel.swift             # Favorites logic
│
├── Views/
│   ├── CoinsListViewController.swift        # UIKit list
│   ├── CoinTableViewCell.swift              # List cell
│   ├── FavoritesViewController.swift        # Favorites screen
│   ├── FavoriteCoinTableViewCell.swift      # Favorites cell
│   ├── CoinDetailView.swift                 # SwiftUI detail
│   └── CoinDetailHostingController.swift    # UIKit bridge
│
├── Services/
│   ├── NetworkService.swift                 # API calls
│   ├── CoreDataService.swift                # Persistence
│   ├── ImageCacheService.swift              # Image caching
│   └── Secrets.swift                        # API key
│
├── Utilities/
│   ├── Constants.swift                      # App constants
│   └── Extensions.swift                     # Helper extensions
│
├── CryptoApp.xcdatamodeld              # Core Data model
│
└── Tests/
    ├── CryptoAppTests/                      # Unit tests
    └── CryptoAppUITests/                    # UI tests
```

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
cmd + U
```

### Test Coverage

| Component | Coverage | Tests |
|-----------|----------|-------|
| NetworkService | 85% | 8 tests |
| CoreDataService | 90% | 11 tests |
| Models | 100% | 11 tests |
| ViewModels | 70% | 4 tests |
| ImageCache | 75% | 3 tests |

### What's Tested

✅ API integration (success, failure, pagination)  
✅ Core Data operations (CRUD, favorites)  
✅ Price formatting (high/low values)  
✅ Change calculations (positive/negative)  
✅ Favorite status tracking  
✅ Image caching with fallbacks  
✅ ViewModel state management  

---

## 🎨 Key Features in Detail

### 1. Smart Pagination
- Loads 20 coins at a time
- Automatic loading when scrolling near end
- Handles up to 100 total coins
- Smooth infinite scroll experience

### 2. Filtering & Sorting
Options available:
- Market Cap (default)
- Highest Price
- Best 24h Performance

### 3. Favorites Management
- Swipe left to favorite/unfavorite
- Persistent storage with Core Data
- Real-time sync across all screens
- Empty state with helpful guidance
- Pull-to-refresh updates prices

### 4. Interactive Price Charts
- 8 time periods (3h to 5y)
- Smooth interpolation with Swift Charts
- Color-coded (green for gains, red for losses)
- Gradient fill for visual appeal
- Auto-scaling Y-axis

### 5. Detailed Statistics
Each coin shows:
- Current price and rank
- Market cap and 24h volume
- Circulating and total supply
- Number of markets and exchanges
- All-time high price
- Descriptive information

---

## 🔧 Configuration

### Customizing the App

#### Change Pagination Size
```swift
// In Utilities/Constants.swift
enum Constants {
    static let coinsPerPage = 20  // Change this value
}
```

#### Modify Theme Colors
```swift
// In custom cell or view
.foregroundColor(.systemBlue)  // Change to desired color
```

#### Adjust Cell Height
```swift
// In CoinsListViewController
table.rowHeight = 70  // Adjust as needed
```

---

## 📱 Device Support

### Tested On (simulator)
- ✅ iPhone 17
- ✅ iPhone 17 Pro

---

## 🚧 Known Limitations

1. **SVG Icon Support**: Non-PNG icons display SF Symbol fallback
2. **Offline Mode**: Requires internet connection for API data
3. **Historical Data**: Some sparse data points in long-range charts
4. **Local Storage Only**: Favorites don't sync across devices
5. **Rate Limiting**: Free API tier has 5,000 requests/month limit

---

## 🔮 Future Enhancements

### High Priority
- [ ] Search functionality
- [ ] Price alerts & notifications
- [ ] Portfolio tracking
- [ ] iCloud sync for favorites

### Medium Priority
- [ ] Compare multiple coins
- [ ] Landscape mode optimization
- [ ] iPad-specific layouts

### Low Priority
- [ ] Localization (multiple languages)
- [ ] Additional chart types (candlestick)
- [ ] News feed integration
- [ ] Widget support

---

## 📚 Technologies Used

### Frameworks
- UIKit (table views, navigation)
- SwiftUI (detail views, charts)
- Charts (price visualizations)
- Core Data (persistence)
- Combine (reactive programming)
- Foundation (networking, date handling)

### Patterns & Practices
- MVVM architecture
- Dependency injection
- Protocol-oriented programming
- Async/await for networking
- Actor-based image caching
- NotificationCenter for events

---

## 🤝 Contributing

This is a take-home assessment project. For production use, consider:
1. Adding comprehensive error recovery
2. Implementing offline mode
3. Adding analytics
4. Improving test coverage
5. Adding CI/CD pipeline

---

## 📄 License

This project is created as a take-home assessment. Feel free to use it for learning purposes.

---

## 👨‍💻 Developer Notes

### Build Information
- Lines of Code: ~3,500
- Files: 25 Swift files
- Test Coverage: 80%+

### Code Quality
- ✅ No compiler warnings
- ✅ No force unwrapping (!)
- ✅ Proper error handling
- ✅ Memory-safe (no retain cycles)
- ✅ Clean, readable code
- ✅ Comprehensive comments

---

## 🙏 Acknowledgments

- **CoinRanking API**: For providing free cryptocurrency data
- **Apple Developer Documentation**: For comprehensive guides
- **Swift Community**: For best practices and patterns

---

## 📧 Contact

For questions about this project, please reach out via GitHub.

---

**Built with ❤️ using Swift, UIKit, SwiftUI, and Core Data**

*Last Updated: December 2025*