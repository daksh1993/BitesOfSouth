// src/App.js
import './App.css';
import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Home from "./Home"; // Import Home Component
import Menu from "./Menu" // menu import 
import Cart from './Cart';
import UserProfileModal from './UserProfileModal';
// import About from "./About"; 

const App = () => {
  return (
    <Router>
      {/* Define routes */}
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path='/menu' element={<Menu />} />
        <Route path='/cart' element={<Cart />} />
        <Route path='/UserProfileModal' element={<UserProfileModal />} />
        {/* <Route path="/about" element={<About />} /> */}
      </Routes>
    </Router>
  );
};

export default App;
