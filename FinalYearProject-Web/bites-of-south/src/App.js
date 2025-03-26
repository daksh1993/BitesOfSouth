// src/App.js
import './App.css';
import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Orders from './orders';
import Home from './Home';
import Menu from './Menu';
import Cart from './Cart';
import OrderDetails from './OrderDetails';
import UserProfileModal from './UserProfileModal';
import OrderProcessing from './OrderProcessing';
import Reward from './reward';
import LoginModal from './LoginModal';
import BottomNav from './bottomnav';
import { auth } from './firebase';
import { useAuthState } from 'react-firebase-hooks/auth';

const ProtectedRoute = ({ children }) => {
  const [user, loading] = useAuthState(auth);

  if (loading) {
    return (
      <div className="loading-container">
        <img src="/images/loading.gif" alt="Loading..." className="loading-gif" />
      </div>
    );
  }

  return user ? children : <Navigate to="/" />;
};

const App = () => {
  const [user, loading] = useAuthState(auth);
  const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);
  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false);

  if (loading) {
    return (
      <div className="loading-container">
        <img src="/images/loading.gif" alt="Loading..." className="loading-gif" />
      </div>
    );
  }

  const handleLogout = () => {
    auth.signOut()
      .then(() => {
        setIsProfileModalOpen(false);
        setIsLoginModalOpen(false);
      })
      .catch((error) => {
        console.error("Logout error:", error);
      });
  };

  const handleMenuNavigation = (category = null) => {
    if (user) {
      const path = category ? `/menu?filter=${category.toLowerCase()}` : '/menu';
      window.location.href = path;
    } else {
      setIsLoginModalOpen(true);
    }
  };

  console.log("App render - isLoginModalOpen:", isLoginModalOpen); // Debug state

  return (
    <Router>
      <div className="app-container">
        <Routes>
          <Route
            path="/"
            element={
              <Home
                user={user}
                onOpenLogin={() => {
                  console.log("Opening login modal"); // Debug click
                  setIsLoginModalOpen(true);
                }}
                onOpenProfile={() => setIsProfileModalOpen(true)}
                onMenuNavigation={handleMenuNavigation}
              />
            }
          />
          <Route
            path="/menu"
            element={
              <ProtectedRoute>
                <Menu />
              </ProtectedRoute>
            }
          />
          <Route
            path="/cart"
            element={
              <ProtectedRoute>
                <Cart />
              </ProtectedRoute>
            }
          />
          <Route
            path="/reward"
            element={
              <ProtectedRoute>
                <Reward />
              </ProtectedRoute>
            }
          />
          <Route
            path="/order-processing"
            element={
              <ProtectedRoute>
                <OrderProcessing />
              </ProtectedRoute>
            }
          />
          <Route
            path="/order-details"
            element={
              <ProtectedRoute>
                <OrderDetails />
              </ProtectedRoute>
            }
          />
          <Route
            path="/orders"
            element={
              <ProtectedRoute>
                <Orders />
              </ProtectedRoute>
            }
          />
        </Routes>

        <LoginModal
          isOpen={isLoginModalOpen}
          onClose={() => setIsLoginModalOpen(false)}
        />
        {user && (
          <UserProfileModal
            isOpen={isProfileModalOpen}
            onClose={() => setIsProfileModalOpen(false)}
            user={user}
            onLogout={handleLogout}
          />
        )}

        <BottomNav
          user={user}
          onOpenLogin={() => setIsLoginModalOpen(true)}
          onOpenProfile={() => setIsProfileModalOpen(true)}
        />
      </div>
    </Router>
  );
};

export default App;