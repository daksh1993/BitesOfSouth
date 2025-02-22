import React, { useEffect, useState } from 'react';
import { getDocs, collection, updateDoc, doc, deleteDoc, getDoc } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";
import './Cart.css'; // Import your CSS file for styling
// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCnSJVHioItNsc2kedyZTxJ7PvfX2hQC7Q",
  authDomain: "bitesofsouth-a38f4.firebaseapp.com",
  databaseURL: "https://bitesofsouth-a38f4-default-rtdb.firebaseio.com",
  projectId: "bitesofsouth-a38f4",
  storageBucket: "bitesofsouth-a38f4.firebasestorage.app",
  messagingSenderId: "65231955877",
  appId: "1:65231955877:web:aab053b6882e9894bdaa4c",
  measurementId: "G-R9WE265DPN",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const Cart = () => {
  const [cartItems, setCartItems] = useState([]);
  const [totalPrice, setTotalPrice] = useState(0);
  const [itemTotal, setItemTotal] = useState(0);
  const [gst, setGst] = useState(0);
  const [serviceCharge, setServiceCharge] = useState(0);

  // Function to update total price, GST, and service charge dynamically
  useEffect(() => {
    let itemTotal = cartItems.reduce((acc, item) => acc + item.price * item.quantity, 0);
    let gst = itemTotal * 0.10; // 10% GST
    let serviceCharge = itemTotal * 0.05; // 5% Service Charge
    let total = itemTotal + gst + serviceCharge;

    setItemTotal(itemTotal);
    setGst(gst);
    setServiceCharge(serviceCharge);
    setTotalPrice(total);
  }, [cartItems]);

  // Function to load cart items
  const loadCart = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, "cart"));
      const items = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        totalPrice: doc.data().price * doc.data().quantity
      }));

      setCartItems(items);
    } catch (error) {
      console.error("❌ Error loading cart:", error);
    }
  };

  // Function to update the quantity of items
  const updateQuantity = async (itemId, change) => {
    try {
      const itemRef = doc(db, "cart", itemId);
      const itemSnap = await getDoc(itemRef);

      if (itemSnap.exists()) {
        let newQuantity = itemSnap.data().quantity + change;

        if (newQuantity < 1) {
          removeItem(itemId);
          return;
        }

        await updateDoc(itemRef, { quantity: newQuantity });

        setCartItems(prevItems =>
          prevItems.map(item =>
            item.id === itemId ? { ...item, quantity: newQuantity, totalPrice: newQuantity * item.price } : item
          )
        );
      }
    } catch (error) {
      console.error("❌ Error updating quantity:", error);
    }
  };

  // Function to remove item from cart
  const removeItem = async (itemId) => {
    try {
      await deleteDoc(doc(db, "cart", itemId));
      setCartItems(prevItems => prevItems.filter(item => item.id !== itemId));
    } catch (error) {
      console.error("❌ Error removing item:", error);
    }
  };

  useEffect(() => {
    loadCart();
  }, []);

  return (
    <section className="Cart">
      <div className="headc">
        <h1>Cart</h1>
      </div>
      <div className="itemshow">
        {cartItems.length === 0 ? (
          <p>Your cart is empty.</p>
        ) : (
          cartItems.map(item => (
            <div className="ItemsCart" key={item.id}>
              <div className="Itemname">
                <p>{item.title}</p>
              </div>
              <div className="AddRemov">
                <button className="DecreaseQuant" onClick={() => updateQuantity(item.id, -1)}>-</button>
                <div className="CurrQuan">
                  <button className="CurrentQuant">{item.quantity}</button>
                </div>
                <button className="AddQuant" onClick={() => updateQuantity(item.id, 1)}>+</button>
              </div>
              <div className="ItemPrice">
                <p>₹{item.totalPrice}</p>
              </div>
            </div>
          ))
        )}
      </div>
        
      <div className="line"></div>
      <div className="WriteInstruction">
        <i className="fa-regular fa-clipboard" style={{ color: "#b0b0b0" }}></i>
        <input className="inpcal" type="text" placeholder="Write Instruction for your order..." />
      </div>
      <div className="seprator"></div>
      <div className="TakeIntakeAway">
        <div className="HaveInCheckBox">
          <input type="checkbox" name="TakeIn" checked />
        </div>
        <div className="DescBox">
          <div className="HeadDesc">
            <h4>Choose Your Preferred Order Option</h4>
          </div>
          <div className="BodyDesc">
            <p>If you'd prefer to enjoy your order in-store, please select the option. This will help us prepare everything for you to enjoy on-site</p>
          </div>
        </div>
      </div>
      <div className="line"></div>
      <div className="ApplyCoupon">
        <button>
          <div className="Couponlogo">
            <i className="fa-solid fa-percent" style={{ color: "#919191" }}></i>
          </div>
          <div className="Redirectpage">
            <h4>Apply coupon</h4>
          </div>
        </button>
      </div>
      <div className="line"></div>

      <div className="OrderSummary">
        <h2>Bill details</h2>
        <div className="SummaryItem">
          <div className="SummaryLabel"><p>Item Total:</p></div>
          <div className="SummaryValue"><p>₹{itemTotal.toFixed(2)}</p></div>
        </div>
        <div className="SummaryItem">
          <div className="SummaryLabel"><p>GST:</p></div>
          <div className="SummaryValue"><p>₹{gst.toFixed(2)}</p></div>
        </div>
        <div className="SummaryItem">
          <div className="SummaryLabel"><p>Service Charge:</p></div>
          <div className="SummaryValue"><p>₹{serviceCharge.toFixed(2)}</p></div>
        </div>
        <div className="SummaryItem Total">
          <div className="SummaryLabel"><p><strong>To Pay:</strong></p></div>
          <div className="SummaryValue"><div className="TotalPrice">₹{totalPrice.toFixed(2)}</div></div>
        </div>
      </div>

      <div className="line" id="lastone"></div>

      <div className="CheckoutFixed">
        <div className="AlmostThere"><p>Almost there! Complete your order by pay now.</p></div>
        <div className="PayNow">
          <button className="PayNowButton">Pay Now</button>
        </div>
      </div>
    </section>
  );
};

export default Cart;
