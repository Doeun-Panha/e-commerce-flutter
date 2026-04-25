# 📱 E-Commerce Mobile Client (Flutter)

This is the cross-platform mobile frontend for the **E-Commerce**, built with Flutter. It provides a high-performance shopping experience for users and a robust management dashboard for administrators, consuming the [Spring Boot REST API](https://github.com/Doeun-Panha/e-commerce-spring).

---

## 🛠️ Tech Stack & Architecture
* **Framework:** Flutter (Material 3)
* **State Management:** Provider (`ChangeNotifier`)
* **Security:** JWT Authentication with **Flutter Secure Storage**
* **Networking:** Http with Multipart Request support
* **Media:** Image Picker for product uploads

### **Clean Architecture**
The project is structured into feature-based modules to ensure clean code and scalability:
1. **Presentation Layer:** UI Screens (Admin Dashboard, Storefront) and reusable Widgets.
2. **Logic Layer (Providers):** Handles state management, cart calculations, and product filtering.
3. **Data Layer:** API Services and Data Models for JSON serialization.
4. **Core Layer:** Global themes, input validators, and shared utility classes.

---

## ✨ Key Technical Implementations

### **🔒 Role-Based Routing (RBAC)**
* **Dynamic View Switching:** The app uses an `AuthProvider` to decode JWT claims. Upon login, the system automatically routes users to either the **Admin Dashboard** or the **User Storefront** based on their assigned role.
* **Persistent Sessions:** Uses secure storage to keep users logged in across app restarts, with automatic 403 (Forbidden) handling to clear expired tokens.

### **🛒 State & Cart Management**
* **Provider Pattern:** Centralized logic for the Shopping Cart, allowing for real-time quantity updates and price calculations across different screens.
* **Complex Filtering:** Implemented a multi-criteria filtering system that handles A-Z sorting, price ordering, and dynamic category filtering simultaneously.

### **🎥 Cinematic UI & UX**
* **Hero Animations:** Utilizes Flutter Hero tags to provide smooth image transitions from the product list to the details view.
* **Inventory Alerts:** Dynamic UI badges that change color and text (e.g., "OUT OF STOCK" or "LOW STOCK") based on real-time inventory thresholds.
* **Form Handling:** Robust product management forms with image selection, category creation dialogs, and real-time validation.

---

## 🚀 Key Modules & Flows

| Module | Feature | Logic | Description |
| :--- | :--- | :--- | :--- |
| **Auth** | Login/Logout | JWT/SecureStorage | Manages user session and role detection |
| **Admin** | Inventory CRUD | ProductProvider | Full management of products and images |
| **Store** | Shopping Cart | CartProvider | Local cart logic with total amount calculation |
| **Catalog** | Category Filter | CategoryProvider | Dynamic product filtering by backend categories |

---

## ⚙️ How to Run

1. **Clone the repo:**
   ```bash
   git clone [https://github.com/Doeun-Panha/e-commerce-flutter.git](https://github.com/Doeun-Panha/e-commerce-flutter.git)
