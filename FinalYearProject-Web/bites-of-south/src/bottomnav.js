// src/BottomNav.js
import React from 'react';
import { useNavigate } from 'react-router-dom';
import './bottomnav.css'; // Add styling here

const BottomNav = ({ user }) => {
  const navigate = useNavigate();
  const isLoggedIn = !!user; // Convert user to boolean

  const handleMenuNavigation = (e) => {
    e.preventDefault();
    if (isLoggedIn) {
      navigate('/menu');
    } else {
      navigate('/'); // Redirect to home if not logged in
    }
  };

  return (
    <nav className="bottom-nav">
      <a href="/" className="nav-item">
        <i className="fa-solid fa-house"></i>
      </a>
      <a href="#" className="nav-item">
        <i className="fa-solid fa-gift"></i>
      </a>
      <a href="/menu" onClick={handleMenuNavigation} className="nav-item">
        <i className="fa-solid fa-search"></i>
      </a>
      <a href="/cart" className="nav-item">
        <i className="fa-solid fa-cart-shopping"></i>
      </a>
    </nav>
  );
};

export default BottomNav;