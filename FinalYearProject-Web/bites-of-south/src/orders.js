// src/Orders.js
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth, db } from './firebase';
import { collection, query, where, onSnapshot } from 'firebase/firestore';
import './orders.css';

const Orders = () => {
  const [user, setUser] = useState(null);
  const [pastOrders, setPastOrders] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    const unsubscribeAuth = auth.onAuthStateChanged((currentUser) => {
      console.log("Current User UID:", currentUser?.uid); // Debug log
      setUser(currentUser);
    });
    return () => unsubscribeAuth();
  }, []);

  useEffect(() => {
    if (!user) return;

    const q = query(collection(db, "orders"), where("userId", "==", user.uid));
    const unsubscribeOrders = onSnapshot(q, (snapshot) => {
      const orders = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      console.log("Fetched Orders:", orders); // Debug log
      setPastOrders(orders.sort((a, b) => b.timestamp - a.timestamp));
    }, (error) => {
      console.error("Error fetching orders:", error.message);
    });

    // Set up a live timer for all orders
    const timer = setInterval(() => {
      setPastOrders((prevOrders) =>
        prevOrders.map((order) => {
          const { isInProgress, timeRemaining, progress } = getOrderStatus(order);
          return { ...order, isInProgress, timeRemaining, progress };
        })
      );
    }, 1000);

    return () => {
      unsubscribeOrders();
      clearInterval(timer); // Cleanup timer
    };
  }, [user]);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const getOrderStatus = (order) => {
    const totalQuantity = order.items.reduce((sum, item) => sum + item.quantity, 0);
    const adjustedMakingTime = order.makingTime + ((totalQuantity - 1) * 5);
    const totalTime = adjustedMakingTime * 60;
    const timeElapsed = (Date.now() - order.timestamp) / 1000;
    const remaining = Math.max(0, totalTime - timeElapsed);

    if (remaining > 0) {
      const progress = Math.min(100, ((totalTime - remaining) / totalTime) * 100);
      return {
        isInProgress: true,
        timeRemaining: Math.floor(remaining),
        progress,
        message: order.dineIn ? "Cooking in Progress" : "Packing Your Order"
      };
    }
    return {
      isInProgress: false,
      timeRemaining: 0,
      progress: 100,
      message: order.dineIn ? "Delivered to Table" : "Order Delivered"
    };
  };

  if (!user) {
    return null; // ProtectedRoute handles redirection
  }

  return (
    <div className="orders-page">
      <header className="orders-header">
        <button className="back-btn" onClick={() => navigate('/')}>
          <i className="fa-solid fa-arrow-left"></i>
        </button>
        <h1>Your Orders</h1>
      </header>
      <section className="orders-list">
        {pastOrders.length === 0 ? (
          <p className="no-orders">No orders found. Start ordering now! (UID: {user.uid})</p>
        ) : (
          pastOrders.map((order) => {
            const { isInProgress, timeRemaining, progress, message } = getOrderStatus(order);
            const itemTotal = order.items.reduce((acc, item) => acc + (item.price * item.quantity), 0);
            const gst = itemTotal * 0.10;
            const serviceCharge = itemTotal * 0.05;
            const grandTotal = itemTotal + gst + serviceCharge;

            return (
              <div key={order.id} className={`order-card ${!isInProgress ? 'order-delivered' : ''}`}>
                <div className="order-summary">
                  <div className="order-info">
                    <h2>Order #{order.id.slice(0, 8)}</h2>
                    <p className="order-date">{new Date(order.timestamp).toLocaleString()}</p>
                    <p className="order-status">{message}</p>
                    <p className="order-total">₹{grandTotal.toFixed(2)}</p>
                  </div>
                  {isInProgress && (
                    <div className="order-progress">
                      <div className="progress-bar">
                        <div className="progress-fill" style={{ width: `${progress}%` }}></div>
                      </div>
                      <div className="progress-details">
                        <span>{formatTime(timeRemaining)}</span>
                        <span>Est. Time: {order.makingTime} min</span>
                      </div>
                    </div>
                  )}
                </div>
                <div className="order-details">
                  <h3>Items</h3>
                  {order.items.map((item, index) => (
                    <div className="item" key={index}>
                      <span className="item-name">{item.name}</span>
                      <span className="item-qty">x{item.quantity}</span>
                      <span className="item-price">₹{(item.price * item.quantity).toFixed(2)}</span>
                    </div>
                  ))}
                  <div className="bill-breakdown">
                    <div className="bill-item">
                      <span>Subtotal</span>
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
                      <span>Total</span>
                      <span>₹{grandTotal.toFixed(2)}</span>
                    </div>
                  </div>
                  {order.dineIn && order.tableNo && (
                    <p className="extra-info">Table No: {order.tableNo}</p>
                  )}
                  {order.instructions !== "No instructions provided" && (
                    <p className="extra-info">Instructions: {order.instructions}</p>
                  )}
                </div>
              </div>
            );
          })
        )}
      </section>
    </div>
  );
};

export default Orders;