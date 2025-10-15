# 🍴 Bites of South  
### A Full-Stack Food Ordering & Management Solution  
#### *"Unleashing a Seamless Culinary Experience"*

---

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Full%20Stack-brightgreen?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Frontend-React.js%20%7C%20Flutter-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Backend-Firebase-orange?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Status-Completed-success?style=for-the-badge"/>
</p>

---

## 🌟 Project Overview

**Bites of South** is a dual-platform system developed as a final-year diploma project.  
It streamlines food ordering and business management for modern restaurants —  
from **customers placing real-time orders** to **admins managing complete operations** in one ecosystem.

The project embodies both **customer convenience** and **business efficiency**, built on a robust, scalable infrastructure.

---

## 🏗️ System Architecture

This solution consists of **two major applications**, both powered by **Firebase** at their backend.

### 🍽️ Customer Web Application
A dynamic interface for customers to browse, order, and track.

**Built with:** `React.js`, `react-router-dom`

#### Key Features:
- 🔐 **Firebase Authentication** – Secure user sign-up/sign-in  
- 🛒 **Dynamic Menu & Cart** – Real-time item listing and order customization  
- ⏳ **Order Status** – Live updates from kitchen to delivery  
- 🎁 **Rewards System** – Integrated loyalty points system  

---

### 🧑‍💼 Admin Panel Mobile Application
A Flutter-based mobile dashboard for business administrators.

**Built with:** `Flutter`, `Dart`

#### Key Features:
- 🧾 **Menu Management** – Add, edit, or delete menu items easily  
- 🚀 **Order Processing** – Real-time management of orders and updates  
- 📊 **Analytics Dashboard** – Visual insights with PDF reporting  
- ☁️ **Sync with Firestore** – Live data sync across all devices  

---

## ⚙️ Shared Backend — Firebase Stack

| Service | Function |
|----------|-----------|
| 🔥 **Firebase Firestore** | Manages real-time database for orders, users & menus |
| 🔐 **Firebase Authentication** | Handles secure logins for users & admins |
| 📦 **Firebase Storage** | Stores images and media assets efficiently |
| ⚙️ **Firebase Hosting** | Hosts the web interface for smooth deployment |

---

## 🧰 Technologies Used

| Layer | Technology/Tool |
|-------|-----------------|
| **Frontend (Web)** | React.js, React Router, HTML5, CSS3 |
| **Frontend (Mobile)** | Flutter, Dart |
| **Backend & Hosting** | Firebase (Firestore, Auth, Storage) |
| **Design & Collaboration** | Figma |
| **Version Control** | Git & GitHub |

---

## ⚡ Getting Started

### 🗒 Prerequisites

Ensure you have the following installed:

- Node.js & npm (or yarn)  
- Flutter SDK  
- Firebase Project (with Firestore, Auth, and Storage enabled)  
- Google config files:  
  - `google-services.json` for Android  
  - `GoogleService-Info.plist` for iOS  
  - Firebase config for React Web  

---

### 🔧 Setup Instructions

#### 🛍 Web Application (Customer Interface)

Clone the repo
git clone https://github.com/daksh1993/bitesofsouth.git
cd bitesofsouth

Navigate to web app
cd FinalYearProject-Web/bites-of-south

Install dependencies and run
npm install
npm start


🖥 Access: [http://localhost:3000](http://localhost:3000)

---

#### 📱 Admin Panel (Flutter App)

Navigate to admin panel project directory
cd ../../Admin Panel App/bites_of_south

Install dependencies and run
flutter pub get
flutter run


📲 Launch on connected device or emulator.

---

## 👥 Collaborators

| Name | Role | GitHub |
|------|------|--------|
| **Daksh Rathod** | Flutter & Firebase Developer | [@daksh1993](https://github.com/daksh1993) |
| **Jeel Savaliya** | Web Developer |  |
| **Nikshay Mehta** | UI/UX Design & QA |  |

---

## 🧠 Core Highlights

- Real-time order management  
- Dual-app system (React web + Flutter mobile)  
- Integrated analytics & reporting system  
- Secure authentication for users & admins  
- Efficient image management via Firebase Storage  

---

## 📸 Screenshots / Demo

<p align="center">
  <img src="https://dummyimage.com/600x350/000/fff.png&text=Customer+Web+App+Interface" width="45%"/>
  <img src="https://dummyimage.com/600x350/555/fff.png&text=Admin+Panel+Mobile+Dashboard" width="45%"/>
</p>

*(Replace placeholders with actual screenshots showing UI workflow.)*

---



## 🧾 License

This project is distributed under the **MIT License** — free for learning and collaboration.

---

## 💡 Future Enhancements

- Delivery Partner tracking via real-time GeoLocation  
- Integration with payment gateways (Stripe, Razorpay)  
- Adaptive UI for tablet devices  
- Role-based user analytics for admins  

---

## ❤️ Acknowledgements

Developed as part of a **Final Year Diploma Project** under guidance from faculty mentors,  
with gratitude to the open-source community for tools and templates that made this possible.

---

<p align="center">
  🌮 *"Technology meets Taste — with Bites of South!"* 🍛
</p>
