# Developer Log - Product Management Module

All notable changes to this project will be documented in this file.

## [2026-04-13] - UI/UX & Validation Fixes

### 🛠 Fixes & Improvements
- **Resolved Overflow Issues**: Wrapped the `ProductFormScreen` in a `SingleChildScrollView` to prevent "Bottom Overflow" errors when the keyboard is active.
- **Enhanced URL Validation**: Added a helper function to validate Image URLs before attempting to render them, preventing app crashes on invalid input.
- **Improved List Layout**: Refactored `ProductListScreen` to use `Row` and `Expanded` widgets, fixing a bug where text was compressed vertically.
- **Cleaned up Actions**: Moved Edit and Delete functions from the main list into the `ProductFormScreen` for a cleaner interface.
- **Added Safety Nets**: Implemented a `_confirmDelete` dialog to prevent accidental data loss.

### 📸 Screenshots
|                     Before Fix (Overflow/Layout)                     |           After Fix (Clean & Scrollable)            |
|:--------------------------------------------------------------------:|:---------------------------------------------------:|
| ![Before](docs/invalid_image_display&vertical_rendering_of_text.png) |      ![After](docs/fixed_error_image_link.png)      |
|                          ![Squashed List]()                          | ![Clean List](docs/cleaner_product_list_screen.png) |
|                      ![Product Screen Before](docs/productFormScreenBefore.png)                      |             ![Cleaner Product Screen](docs/cleanerProductFormScreen.png)             |

## [2026-04-13] - Architecture Refactor & UI Polish

### 🏗️ Software Architecture
- **Layered Folder Structure**: Migrated from a monolithic file structure to a professional modular system (`models/`, `providers/`, `screens/`, `widgets/`, `utils/`).
- **State Management**: Optimized `ProductProvider` to manage asynchronous API lifecycle states (loading, success, error) for the Spring Boot backend.
- **Centralized Business Logic**: Implemented `AppValidators` utility to provide a single source of truth for URL, numeric, and required field validation.
- **Service Layer**: Decoupled API calls into a dedicated `ApiService` class using the `http` package.

### ✨ UI/UX & Component Design
- **Reusable Input Components**: Created `ProductInputField` widget to standardize form design and reduce code duplication.
- **Global Theming**: Centralized UI constants (border radius, input decorations) in `AppTheme` for application-wide consistency.
- **Responsive Layout**: Wrapped forms in `SingleChildScrollView` to resolve bottom-overflow issues during keyboard interaction.
- **Real-time Image Preview**: Implemented a dynamic preview window in the product form with graceful error handling for invalid URLs.

### 🛠️ Fixes & Small Tweaks
- **Keyboard Optimization**: Set `isNumber: true` for price and stock fields to automatically trigger the numeric keypad.
- **Safety Dialogs**: Added an asynchronous confirmation dialog for the "Delete Product" action.
- **Search Logic**: Integrated a local search filter in `ProductListScreen` using a `TextEditingController` listener.

## [2026-04-14] - Full-Stack Image Upload & Local Storage

### 🏗️ Backend & Database (Spring Boot / SQL Server)
- **Local File Storage**: Configured ProductController to save binary images to a dedicated user-photos/ directory on the server instead of relying on external URLs.
- **Static Resource Mapping**: Implemented WebConfig to map the web path /uploads/** to the physical storage folder, allowing the Flutter app to retrieve files via HTTP.
- **Repository Optimization**: Fixed Java Generics type error by migrating ProductRepository from primitive int to the Integer wrapper class.
- **Database Strategy**: Shifted storage logic to save relative file paths in SQL Server, significantly improving query performance and data portability.

### 📱 Frontend & Mobile (Flutter)
- ** Native Image Selection**: Integrated the image_picker plugin to allow selecting product photos from the Android gallery.
- **Multipart Data Handling**: Refactored ProductProvider and ApiService to use http.MultipartRequest, enabling simultaneous upload of product metadata and binary image files.
- **Dynamic Image Hosting**: Implemented a "Hybrid URL" logic in _buildImagePreview and ProductCard to gracefully handle both legacy web links (http://...) and new local server paths.
- **Native Configuration**: Configured AndroidManifest.xml with READ_EXTERNAL_STORAGE and READ_MEDIA_IMAGES permissions to support modern Android API levels.

### 🛠️ Fixes & Native Troubleshooting
- **Build Synchronization**: Resolved MissingPluginException by performing a full native "Cold Boot" (clean/rebuild) to register plugin channels.
- **Model Flexibility**: Updated the Product model to make imageUrl optional, preventing validation errors during the "Create" phase of new products.
- **Emulator Connectivity**: Configured the Flutter app to use the specialized 10.0.2.2 IP address to communicate with the Spring Boot server running on the host machine.

|                 Dynamic Image Storing                  |
|:------------------------------------------------------:|
| ![Dynamic image storing](docs/dynamicImageStoring.png) |