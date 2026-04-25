# Flutter E-Commerce Client 🚀

A cross-platform mobile application built with **Flutter** and **Spring Boot**. This project implements a dual-interface system for Administrators and Users, managed through role-based logic and the Provider state management pattern.

---

## 📱 Features

### **Authentication & Role-Based Routing**
* **Dynamic Home Logic:** Uses `AuthProvider` to check authentication status and user roles (Admin vs. User) to automatically route to the correct dashboard.
* **Logout System:** Secure sign-out functionality integrated into both Admin and User interfaces.
* **JWT Integration:** Handles token-based security for API communication, including automatic logout on 403 (Forbidden) errors.

### **Admin Inventory Management**
* **Dashboard Summary:** Real-time metrics for total products and low-stock items.
* **Product CRUD:** Full capability to add, edit, and delete products, including image selection via the `image_picker`.
* **Category Management:** Dynamic category selection with an inline "Create New Category" feature directly within the product form.
* **Inventory Filtering:** Filter products by name (Search), Category, Price, A-Z, or Low Stock status.

### **User Storefront**
* **Product Catalog:** A grid-based storefront with specialized badges for "Out of Stock" or "Limited" stock items.
* **Advanced Filtering:** Users can filter the shop by Category, Price, or alphabetical order.
* **Shopping Cart:** - Add items to cart with automatic quantity incrementing.
  - Cart summary with total amount calculation.
  - Management UI to remove items or clear the entire cart.
* **Product Details:** Detailed view including Hero animations, stock warnings, and "Buy Now" logic.

---

## 🛠 Tech Stack

* **Frontend:** Flutter
* **State Management:** Provider (`MultiProvider`, `ChangeNotifier`)
* **API Communication:** Http package with Multipart request support for images.
* **Image Handling:** `image_picker` for local files and `Image.network` with error placeholders.
* **Dev Tools:** Custom `HttpOverrides` to handle bad certificates during development.

---

## 🏗 Project Architecture

The code is organized into feature-based modules:

```text
lib/
├── core/               # App theme and validation logic
├── features/
│   ├── auth/           # Login logic and AuthProvider
│   ├── categories/     # Category models and logic
│   └── products/
│       ├── data/       # Product models and API services
│       ├── logic/      # CartProvider and ProductProvider
│       └── presentation/
│           ├── admin/  # Inventory Dashboard and Product Form
│           ├── user/   # Storefront, Details, and Cart UI
│           └── widgets/# Admin/User Product Cards
└── main.dart           # App entry and Provider initialization
