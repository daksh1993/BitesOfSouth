Bites of South: A Full-Stack Food Ordering & Management Solution
Unleashing a Seamless Culinary Experience

This project, "Bites of South," represents a comprehensive solution to modern food ordering and business management. Developed as a final year diploma project, it's a dual-platform system designed to streamline the entire process, from a customer placing an order to a business owner managing operations.

The theoretical foundation of this project centers on creating an end-to-end, real-time system that addresses the common challenges faced by small to medium-sized food businesses. By separating the customer and admin experiences into distinct applications, we aimed to optimize user flow, enhance business efficiency, and provide a robust, scalable platform.

Technical Architecture

The project is structured into two main components, each built with a specific technology stack to suit its function.

1. Customer-Facing Web Application

This web application provides a clean and intuitive interface for customers to browse the menu, place orders, and track their status.

Frontend Technology: Built with React.js, this application was bootstrapped using Create React App and utilizes react-router-dom for navigation.

Key Features:

User Authentication: Secure login and user profile management using Firebase Authentication.

Menu & Cart: A dynamic menu interface and a cart system for adding and managing orders.

Order Status: Real-time order processing and status tracking for the user.

Rewards System: An integrated feature to reward loyal customers.

2. Admin Panel Mobile Application

This application empowers business administrators with the tools to manage their operations efficiently from a mobile device.

Frontend Technology: Built with Flutter, a UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.

Key Features:

Menu Management: Administrators can easily add, update, and remove menu items.

Order Processing: A centralized panel to view and process incoming orders in real-time.

Data & Analytics: The app features comprehensive analytics, including the ability to generate and view PDF reports of business performance.

Shared Backend

Firebase: Both applications are powered by Google's Firebase backend-as-a-service (BaaS).

Firestore: Serves as the real-time, NoSQL database for managing all application data, including menus, orders, and user information.

Firebase Authentication: Handles all user and administrator authentication processes.

Firebase Storage: Manages the storage of images for menu items, ensuring media content is efficiently handled.

Getting Started

Prerequisites

To run these applications, you'll need to have the following installed:

Node.js & npm (or yarn)

Flutter SDK

A Firebase Project with Firestore, Authentication, and Storage enabled.

Your Firebase configuration files (google-services.json for Android and GoogleService-Info.plist for iOS) for the Flutter app and the Firebase configuration for the React app.

Step-by-Step Instructions

Clone the repository:

Bash
git clone https://github.com/daksh1993/bitesofsouth.git
cd bitesofsouth
Web Application Setup (FinalYearProject-Web/bites-of-south):

Bash
cd FinalYearProject-Web/bites-of-south
npm install
npm start
This will launch the web application in development mode at http://localhost:3000.

Admin Panel Setup (Admin Panel App/bites_of_south):

Bash
cd ../../Admin Panel App/bites_of_south
flutter pub get
flutter run
This will start the Flutter application on your connected device or emulator. The app is a new Flutter project.

Collaborators

Daksh

Jeel Savaliya

Nikshay Mehta

