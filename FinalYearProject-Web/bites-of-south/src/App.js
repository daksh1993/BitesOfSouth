// src/App.js
import './App.css';
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Orders from './orders';
import Home from './Home';
import Menu from './Menu';
import Cart from './Cart';
import OrderDetails from './OrderDetails';
import UserProfileModal from './UserProfileModal';
import OrderProcessing from './OrderProcessing';
import Reward from './reward';

import BottomNav from './bottomnav';
import { auth } from './firebase';
import { useAuthState } from 'react-firebase-hooks/auth';

// ProtectedRoute component to check authentication
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

  if (loading) {
    return (
      <div className="loading-container">
        <img src="/images/loading.gif" alt="Loading..." className="loading-gif" />
      </div>
    );
  }

  return (
    <Router>
      <div className="app-container">
        <Routes>
          <Route path="/" element={<Home />} />
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
            path="/UserProfileModal"
            element={
              <ProtectedRoute>
                <UserProfileModal />
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
        <BottomNav user={user} />
      </div>
    </Router>
  );
};

export default App;