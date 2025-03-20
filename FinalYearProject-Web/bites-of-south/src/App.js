// src/App.js
import './App.css';
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import Home from './Home';
import Menu from './Menu';
import Cart from './Cart';
import UserProfileModal from './UserProfileModal';
import OrderProcessing from './OrderProcessing';
import BottomNav from './bottomnav'; // Import the new component
import { auth } from './firebase';
import { useAuthState } from 'react-firebase-hooks/auth';

// ProtectedRoute component to check authentication
const ProtectedRoute = ({ children }) => {
  const [user, loading] = useAuthState(auth);

  if (loading) {
    return <div>Loading...</div>; // Show a loading state while checking auth
  }

  return user ? children : <Navigate to="/" />; // Redirect to home if not logged in
};

const App = () => {
  const [user, loading] = useAuthState(auth); // Get user state for the app

  if (loading) {
    return <div>Loading...</div>; // Show loading while auth state is initializing
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
          <Route path="/UserProfileModal" element={<UserProfileModal />} />
          <Route path="/order-processing" element={<OrderProcessing />} />
        </Routes>
        <BottomNav user={user} /> {/* Pass user to BottomNav */}
      </div>
    </Router>
  );
};

export default App;