// src/OrderDetails.js
import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { db } from './firebase';
import { doc, onSnapshot } from 'firebase/firestore';
import './OrderDetails.css';

const OrderDetails = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { orderId, cartItems: initialItems, tableNumber, totalAmount } = location.state || {};
  const [orderData, setOrderData] = useState(null);
  const [timeRemaining, setTimeRemaining] = useState(0);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    if (!orderId) {
      navigate('/cart');
      return;
    }

    const unsubscribe = onSnapshot(doc(db, "orders", orderId), (docSnap) => {
      if (docSnap.exists()) {
        const data = docSnap.data();
        setOrderData(data);

        const totalQuantity = data.items.reduce((sum, item) => sum + item.quantity, 0);
        const adjustedMakingTime = data.makingTime + ((totalQuantity - 1) * 5);
        const totalTime = adjustedMakingTime * 60;

        const updateTimer = () => {
          const timeElapsed = (Date.now() - data.timestamp) / 1000;
          const remaining = Math.max(0, totalTime - timeElapsed);
          const progressPercent = Math.min(100, ((totalTime - remaining) / totalTime) * 100);

          setTimeRemaining(Math.floor(remaining));
          setProgress(progressPercent);
        };

        updateTimer();
        const timer = setInterval(updateTimer, 1000);
        return () => clearInterval(timer);
      } else {
        console.error("Order not found");
        navigate('/cart');
      }
    }, (error) => {
      console.error("Firestore error:", error);
      navigate('/cart');
    });

    return () => unsubscribe();
  }, [orderId, navigate]);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const getStatusMessage = () => {
    if (!orderData) return "Preparing...";
    return orderData.dineIn 
      ? (progress < 100 ? "Cooking in Progress" : "Ready to Serve")
      : (progress < 100 ? "Packing Your Order" : "Order Packed");
  };

  const handleBackToMenu = () => {
    navigate('/');
  };

  if (!orderData) {
    return <div className="loading">Loading your order...</div>;
  }

  const itemTotal = orderData.items.reduce((acc, item) => acc + (item.price * item.quantity), 0);
  const gst = itemTotal * 0.10;
  const serviceCharge = itemTotal * 0.05;
  const grandTotal = itemTotal + gst + serviceCharge;

  return (
    <section className={`order-details ${progress === 100 ? 'order-delivered' : ''}`}>
      <div className="order-header">
        <h1>Order #{orderId.slice(0, 8)}</h1>
        <p className="status">{getStatusMessage()}</p>
      </div>

      <div className="order-progress">
        <div className="gif-placeholder">
          <div className="gif-box">
            {progress < 100 ? (
              <img src="./images/cooking.gif" alt="Cooking in progress" className="status-gif" />
            ) : (
              <img src="./images/ready.gif" alt="Order ready" className="status-gif" />
            )}
          </div>
        </div>
        <div className="progress-container">
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${progress}%` }}
            ></div>
          </div>
          <div className="time-info">
            <span>{formatTime(timeRemaining)}</span>
            <span>Est. Time: {orderData.makingTime + ((orderData.items.reduce((sum, item) => sum + item.quantity, 0) - 1) * 5)} min</span>
          </div>
        </div>
      </div>

      <div className="order-summary">
        <h2>Order Summary</h2>
        <div className="items-list">
          {orderData.items.map((item, index) => (
            <div className="item" key={index}>
              <span className="item-name">{item.name}</span>
              <span className="item-qty">x{item.quantity}</span>
              <span className="item-price">₹{item.price} x {item.quantity} = ₹{(item.price * item.quantity).toFixed(2)}</span>
            </div>
          ))}
        </div>
        <div className="bill-breakdown">
          <div className="bill-item">
            <span>Subtotal (Items)</span>
            <span>₹{itemTotal.toFixed(2)}</span>
          </div>
          <div className="bill-item">
            <span>GST (10%)</span>
            <span>₹{gst.toFixed(2)}</span>
          </div>
          <div className="bill-item">
            <span>Service Charge (5%)</span>
            <span>₹{serviceCharge.toFixed(2)}</span>
          </div>
          <div className="bill-total">
            <span>Grand Total</span>
            <span>₹{grandTotal.toFixed(2)}</span>
          </div>
        </div>
      </div>

      <div className="order-info">
        {orderData.dineIn && orderData.tableNo && (
          <p>Table No: {orderData.tableNo}</p>
        )}
        {orderData.instructions !== "No instructions provided" && (
          <p>Instructions: {orderData.instructions}</p>
        )}
      </div>

      <button className="menu-btn" onClick={handleBackToMenu}>
        Back to Menu
      </button>
    </section>
  );
};

export default OrderDetails;