import React, { useEffect, useState } from 'react';
import './Cart.css';
import { useNavigate } from "react-router-dom";

const Cart = () => {
  const [cartItems, setCartItems] = useState([]);
  const [totalPrice, setTotalPrice] = useState(0);
  const [itemTotal, setItemTotal] = useState(0);
  const [gst, setGst] = useState(0);
  const [serviceCharge, setServiceCharge] = useState(0);
  const [isTakeIn, setIsTakeIn] = useState(false);
  const [tableNumber, setTableNumber] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const storedCart = JSON.parse(localStorage.getItem("cart")) || [];
    const sanitizedCart = storedCart.map(item => ({
      title: item.title || "Unknown",
      price: item.price || 0,
      quantity: item.quantity || 1,
      image: item.image || ""
    }));
    setCartItems(sanitizedCart);
  }, []);

  useEffect(() => {
    if (cartItems.length === 0) {
      setItemTotal(0);
      setGst(0);
      setServiceCharge(0);
      setTotalPrice(0);
      return;
    }

    let validItems = cartItems.filter(item => item.price && item.quantity);
    let itemTotal = validItems.reduce((acc, item) => acc + (item.price * item.quantity), 0);
    let gst = itemTotal * 0.10;
    let serviceCharge = itemTotal * 0.05;
    let total = itemTotal + gst + serviceCharge;

    setItemTotal(itemTotal || 0);
    setGst(gst || 0);
    setServiceCharge(serviceCharge || 0);
    setTotalPrice(total || 0);
  }, [cartItems]);

  const updateQuantity = (title, change) => {
    setCartItems((prevCart) => {
      const updatedCart = prevCart
        .map(item => {
          if (item.title === title) {
            let newQuantity = item.quantity + change;
            return newQuantity > 0 ? { ...item, quantity: newQuantity } : null;
          }
          return item;
        })
        .filter(item => item !== null);

      localStorage.setItem("cart", JSON.stringify(updatedCart));
      return updatedCart;
    });
  };

  const handlePayment = () => {
    if (isTakeIn && !tableNumber) {
      alert("Please enter a table number for in-store dining.");
      return;
    }

    const options = {
      key: "rzp_test_CkutVrejMBd1qG",
      amount: totalPrice * 100,
      currency: "INR",
      name: "BitesOfSouth",
      description: "Order Payment",
      image: "https://firebasestorage.googleapis.com/v0/b/bitesofsouth-a38f4.firebasestorage.app/o/round_logo.png?alt=media&token=57af3ab9-1836-46a9-a1c9-130275ef1bec",
      handler: function (response) {
        alert("Payment Successful! Payment ID: " + response.razorpay_payment_id);
        localStorage.removeItem("cart");
        setCartItems([]);
        navigate("/order-processing", { state: { cartItems, tableNumber } });
      },
      prefill: {
        name: "Customer Name",
        email: "customer@example.com",
        contact: "9999999999",
      },
      theme: {
        color: "#1ba672",
      },
    };

    const rzp = new window.Razorpay(options);
    rzp.open();
  };

  const handleBack = () => {
    navigate(-1); // Go back to the previous page
  };

  return (
    <section className="Cart">
      <div className="cart-container">
        <div className="cart-header">
          <button className="back-btn" onClick={handleBack}>
            <i className="fa-solid fa-arrow-left"></i>
          </button>
          <h1 className="cart-title">Your Cart</h1>
        </div>
        <div className="cart-items">
          {cartItems.length === 0 ? (
            <p className="empty-cart">Your cart is empty.</p>
          ) : (
            cartItems.map(item => (
              <div className="cart-item" key={item.title}>
                <div className="item-image">
                  {item.image && <img src={item.image} alt={item.title} />}
                </div>
                <div className="item-details">
                  <p className="item-name">{item.title}</p>
                  <p className="item-price">₹{(item.price * item.quantity).toFixed(2)}</p>
                </div>
                <div className="item-quantity">
                  <button onClick={() => updateQuantity(item.title, -1)}>-</button>
                  <span>{item.quantity}</span>
                  <button onClick={() => updateQuantity(item.title, 1)}>+</button>
                </div>
              </div>
            ))
          )}
        </div>

        <div className="cart-options">
          <div className="instructions">
            <i className="fa-regular fa-clipboard"></i>
            <input
              type="text"
              placeholder="Add instructions for your order..."
            />
          </div>
          <div className="dine-in-option">
            <label>
              <input
                type="checkbox"
                checked={isTakeIn}
                onChange={(e) => setIsTakeIn(e.target.checked)}
              />
              Dine In
            </label>
            {isTakeIn && (
              <div className="table-number">
                <input
                  type="text"
                  placeholder="Table Number (Required)"
                  value={tableNumber}
                  onChange={(e) => setTableNumber(e.target.value)}
                  required
                />
              </div>
            )}
          </div>
        </div>

        <div className="cart-summary">
          <h2>Bill Details</h2>
          <div className="summary-item">
            <span>Item Total</span>
            <span>₹{itemTotal.toFixed(2)}</span>
          </div>
          <div className="summary-item">
            <span>GST (10%)</span>
            <span>₹{gst.toFixed(2)}</span>
          </div>
          <div className="summary-item">
            <span>Service Charge (5%)</span>
            <span>₹{serviceCharge.toFixed(2)}</span>
          </div>
          <div className="summary-total">
            <span>Total</span>
            <span>₹{totalPrice.toFixed(2)}</span>
          </div>
        </div>

        <div className="checkout">
          <button className="pay-now-btn" onClick={handlePayment}>
            Pay Now ₹{totalPrice.toFixed(2)}
          </button>
        </div>
      </div>
    </section>
  );
};

export default Cart;