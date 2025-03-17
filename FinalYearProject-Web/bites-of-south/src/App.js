// src/App.js
import './App.css';
import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Home from "./Home"; // Import Home Component
import Menu from "./Menu" // menu import 
import Cart from './Cart';
<<<<<<< HEAD
import UserProfileModal from './UserProfileModal';
=======
import OrderProcessing from './OrderProcessing';
>>>>>>> 1e868f4baf3bb39934d4da41aff50bce252cb240
// import About from "./About"; 

const App = () => {
  return (
    <Router>
      {/* Define routes */}
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path='/menu' element={<Menu />} />
        <Route path='/cart' element={<Cart />} />
<<<<<<< HEAD
        <Route path='/UserProfileModal' element={<UserProfileModal />} />
=======
        <Route path='/order-processing' element={<OrderProcessing />} />
>>>>>>> 1e868f4baf3bb39934d4da41aff50bce252cb240
        {/* <Route path="/about" element={<About />} /> */}
      </Routes>
    </Router>
  );
};

export default App;
