import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import MenuPage from './menu/menupage';  
import Login from './login/loginpage';  
import PaymentPage from "./payment/paymentpage"; // Ensure this file exists in src/payment/

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<MenuPage />} />
        <Route path="/login" element={<Login />} />
        <Route path="/payment" element={<PaymentPage />} /> {/* Added PaymentPage route */}
      </Routes>
    </Router>
  );
}

export default App;
