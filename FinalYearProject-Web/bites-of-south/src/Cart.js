import React, { useEffect, useState } from 'react';
import { useNavigate } from "react-router-dom";
import { db, auth } from './firebase';
import { collection, addDoc, getDocs } from 'firebase/firestore';
import './Cart.css';

const Cart = () => {
  const [cartItems, setCartItems] = useState([]);
  const [totalPrice, setTotalPrice] = useState(0);
  const [itemTotal, setItemTotal] = useState(0);
  const [gst, setGst] = useState(0);
  const [serviceCharge, setServiceCharge] = useState(0);
  const [isTakeIn, setIsTakeIn] = useState(false);
  const [tableNumber, setTableNumber] = useState("");
  const [instructions, setInstructions] = useState("");
  const [couponCode, setCouponCode] = useState("");
  const [discount, setDiscount] = useState(0);
  const [couponMessage, setCouponMessage] = useState("");
  const [availableCoupons, setAvailableCoupons] = useState([]);
  const navigate = useNavigate();

  // Fetch cart items from localStorage
  useEffect(() => {
    const storedCart = JSON.parse(localStorage.getItem("cart")) || [];
    const sanitizedCart = storedCart.map(item => ({
      uid: item.uid || "unknown",
      title: item.title || "Unknown",
      price: item.price || 0,
      quantity: item.quantity || 1,
      image: item.image || "",
      makingTime: item.makingTime || 15
    }));
    setCartItems(sanitizedCart);
  }, []);

  // Fetch available coupons from Firestore
  useEffect(() => {
    const fetchCoupons = async () => {
      try {
        const couponsRef = collection(db, "coupons");
        const snapshot = await getDocs(couponsRef);
        const currentTime = Date.now();
        const couponsData = snapshot.docs
          .map(doc => ({ id: doc.id, ...doc.data() }))
          .filter(coupon => {
            const expiryDate = coupon.expiryDate?.toDate().getTime() || Infinity;
            const isNotExpired = expiryDate > currentTime;
            const usesLeft = coupon.usesTillValid > coupon.uses;
            return isNotExpired && usesLeft;
          });
        console.log("Fetched coupons:", couponsData); // Debug log
        setAvailableCoupons(couponsData);
      } catch (error) {
        console.error("Error fetching coupons:", error);
        setCouponMessage("Failed to load coupons. Please try again later.");
      }
    };
    fetchCoupons();
  }, []);

  // Calculate totals
  useEffect(() => {
    if (cartItems.length === 0) {
      setItemTotal(0);
      setGst(0);
      setServiceCharge(0);
      setDiscount(0);
      setTotalPrice(0);
      return;
    }

    const validItems = cartItems.filter(item => item.price > 0 && item.quantity > 0);
    const calculatedItemTotal = validItems.reduce((acc, item) => {
      return acc + (item.price * item.quantity);
    }, 0);

    const calculatedGst = calculatedItemTotal * 0.10;
    const calculatedServiceCharge = calculatedItemTotal * 0.05;
    const calculatedTotalPrice = calculatedItemTotal + calculatedGst + calculatedServiceCharge - discount;

    setItemTotal(calculatedItemTotal);
    setGst(calculatedGst);
    setServiceCharge(calculatedServiceCharge);
    setTotalPrice(calculatedTotalPrice > 0 ? calculatedTotalPrice : 0);
  }, [cartItems, discount]);

  const updateQuantity = (uid, change) => {
    setCartItems((prevCart) => {
      const updatedCart = prevCart
        .map(item => {
          if (item.uid === uid) {
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

  const applyCoupon = () => {
    if (!couponCode) {
      setCouponMessage("Please enter a coupon code.");
      setDiscount(0);
      return;
    }

    const coupon = availableCoupons.find(c => c.id.toUpperCase() === couponCode.toUpperCase());
    if (!coupon) {
      setCouponMessage("Invalid or expired coupon code.");
      setDiscount(0);
      return;
    }

    let newDiscount = 0;
    if (coupon.discountType === "percentage") {
      newDiscount = (itemTotal * coupon.value) / 100;
    } else if (coupon.discountType === "flat") {
      newDiscount = coupon.value;
    }

    if (newDiscount >= itemTotal) {
      setCouponMessage("Discount cannot exceed subtotal.");
      setDiscount(itemTotal - 0.01);
    } else {
      setDiscount(newDiscount);
      setCouponMessage(`Coupon "${coupon.id}" applied! Saved ₹${newDiscount.toFixed(2)}`);
    }
  };

  const selectCoupon = (code) => {
    setCouponCode(code);
    setCouponMessage("");
    applyCoupon();
  };

  const saveOrderToFirestore = async (cartItems, paymentResponse) => {
    try {
      const userId = auth.currentUser?.uid || "guest";
      const totalQuantity = cartItems.reduce((sum, item) => sum + item.quantity, 0);

      if (!totalQuantity) {
        throw new Error("No items in cart to save.");
      }

      const orderData = {
        userId: userId,
        items: cartItems.map(item => ({
          itemId: item.uid,
          name: item.title,
          quantity: item.quantity,
          price: item.price,
          makingTime: Math.round((item.makingTime || 15) / totalQuantity)
        })),
        totalAmount: totalPrice,
        orderStatus: "Pending",
        pendingStatus: "25",
        paymentStatus: "Paid",
        timestamp: Date.now(),
        makingTime: Math.max(...cartItems.map(item => Math.round((item.makingTime || 15) / totalQuantity))),
        dineIn: isTakeIn,
        tableNo: isTakeIn ? tableNumber : null,
        instructions: instructions || "No instructions provided",
        couponCode: couponCode || null,
        discount: discount || 0,
        paymentDetails: {
          razorpayPaymentId: paymentResponse.razorpay_payment_id,
          razorpayOrderId: paymentResponse.razorpay_order_id || "order_8B44YVu180hVun",
          amount: totalPrice * 100,
          currency: "INR",
          status: "captured",
          amountRefunded: 0,
          refundStatus: null,
          captured: true,
          paymentTimestamp: Date.now(),
          testMode: true
        }
      };

      const docRef = await addDoc(collection(db, "orders"), orderData);
      console.log("Order saved with ID:", docRef.id);
      return docRef.id;
    } catch (error) {
      console.error("Error saving order:", error.message);
      return null;
    }
  };

  const handlePayment = async () => {
    if (totalPrice <= 0) {
      alert("Your cart is empty. Please add items before checking out.");
      return;
    }
    if (isTakeIn && !tableNumber) {
      alert("Please enter a table number for in-store dining.");
      return;
    }

    if (!window.Razorpay) {
      console.error("Razorpay SDK not loaded.");
      alert("Payment service is unavailable. Please try again later.");
      return;
    }

    const options = {
      key: "rzp_test_CkutVrejMBd1qG",
      amount: totalPrice * 100,
      currency: "INR",
      name: "BitesOfSouth",
      description: "Order Payment",
      image: "https://firebasestorage.googleapis.com/v0/b/bitesofsouth-a38f4.firebasestorage.app/o/round_logo.png?alt=media&token=57af3ab9-1836-46a9-a1c9-130275ef1bec",
      handler: async function (response) {
        const orderId = await saveOrderToFirestore(cartItems, response);
        if (orderId) {
          localStorage.removeItem("cart");
          setCartItems([]);
          navigate("/order-details", {
            state: {
              orderId,
              cartItems,
              tableNumber,
              totalAmount: totalPrice,
              couponCode,
              discount
            }
          });
        } else {
          alert("Failed to save order. Please try again.");
        }
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
    navigate(-1);
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
              <div className="cart-item" key={item.uid}>
                <div className="item-image">
                  {item.image && <img src={item.image} alt={item.title} />}
                </div>
                <div className="item-details">
                  <p className="item-name">{item.title}</p>
                  <p className="item-price">₹{item.price} x {item.quantity} = ₹{(item.price * item.quantity).toFixed(2)}</p>
                </div>
                <div className="item-quantity">
                  <button onClick={() => updateQuantity(item.uid, -1)}>-</button>
                  <span>{item.quantity}</span>
                  <button onClick={() => updateQuantity(item.uid, 1)}>+</button>
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
              value={instructions}
              onChange={(e) => setInstructions(e.target.value)}
            />
          </div>

          {/* Coupon Section */}
          <div className="coupon-section">
            <input
              type="text"
              placeholder="Enter coupon code"
              value={couponCode}
              onChange={(e) => setCouponCode(e.target.value)}
              className="coupon-input"
            />
            <button onClick={applyCoupon} className="apply-coupon-btn">Apply</button>
          </div>
          {couponMessage && <p className={discount > 0 ? "coupon-success" : "coupon-error"}>{couponMessage}</p>}

          {/* Available Coupons */}
          <div className="available-coupons">
            <h3>Available Offers</h3>
            {availableCoupons.length > 0 ? (
              <div className="coupon-list">
                {availableCoupons.map(coupon => (
                  <div key={coupon.id} className="coupon-item" onClick={() => selectCoupon(coupon.id)}>
                    <div className="coupon-code">{coupon.id}</div>
                    <div className="coupon-details">
                      <p>
                        {coupon.discountType === "percentage" 
                          ? `${coupon.value}% off` 
                          : `₹${coupon.value} off`}
                        {coupon.expiryDate && ` (Valid till ${coupon.expiryDate.toDate().toLocaleDateString()})`}
                      </p>
                      <span className="apply-link">Click to apply</span>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="no-coupons">No coupons available at the moment.</p>
            )}
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
          <div className="summary-breakdown">
            <div className="summary-item">
              <span>Subtotal (Items)</span>
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
            {discount > 0 && (
              <div className="summary-item discount">
                <span>Discount ({couponCode})</span>
                <span>-₹{discount.toFixed(2)}</span>
              </div>
            )}
            <div className="summary-total">
              <span>Grand Total</span>
              <span>₹{totalPrice.toFixed(2)}</span>
            </div>
          </div>
        </div>

        <div className="checkout">
          <button
            className="pay-now-btn"
            onClick={handlePayment}
            disabled={totalPrice <= 0}
          >
            Pay Now ₹{totalPrice.toFixed(2)}
          </button>
        </div>
      </div>
    </section>
  );
};

export default Cart;