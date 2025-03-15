import React, { useEffect, useState } from 'react';
import './Cart.css'; // Import your CSS file for styling
import { useNavigate } from "react-router-dom";

const Cart = () => {
  const [cartItems, setCartItems] = useState([]);
  const [totalPrice, setTotalPrice] = useState(0);
  const [itemTotal, setItemTotal] = useState(0);
  const [gst, setGst] = useState(0);
  const [serviceCharge, setServiceCharge] = useState(0);
  const navigate = useNavigate(); // Move useNavigate inside the component


  // Load cart items from local storage
  useEffect(() => {
    const storedCart = JSON.parse(localStorage.getItem("cart")) || [];

    // Ensure all items have a valid price and quantity
    const sanitizedCart = storedCart.map(item => ({
      title: item.title || "Unknown",
      price: item.price || 0,
      quantity: item.quantity || 1
    }));

    setCartItems(sanitizedCart);
  }, []);

  // Function to update total price, GST, and service charge dynamically
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
    let gst = itemTotal * 0.10; // 10% GST
    let serviceCharge = itemTotal * 0.05; // 5% Service Charge
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
        .filter(item => item !== null); // Remove null items

      localStorage.setItem("cart", JSON.stringify(updatedCart)); // Update local storage
      return updatedCart;
    });
  };
  const handlePayment = () => {
    const options = {
      key: "rzp_test_CkutVrejMBd1qG", // Replace with your Razorpay Test/Live Key
      amount: totalPrice * 100, // Convert to paisa
      currency: "INR",
      name: "BitesOfSouth",
      description: "Order Payment",
      image: "https://firebasestorage.googleapis.com/v0/b/bitesofsouth-a38f4.firebasestorage.app/o/round_logo.png?alt=media&token=57af3ab9-1836-46a9-a1c9-130275ef1bec", // Optional: Add your brand logo
      handler: function (response) {
        alert("Payment Successful! Payment ID: " + response.razorpay_payment_id);
        localStorage.removeItem("cart"); // Clear cart after successful payment
        setCartItems([]);
        navigate("/order-processing.js", { state: { cartItems } });

      },
      prefill: {
        name: "Customer Name",
        email: "customer@example.com",
        contact: "9999999999",
      },
      theme: {
        color: "#F37254",
      },
      
    };

    const rzp = new window.Razorpay(options);
    rzp.open();
  };

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
            <div className="ItemsCart" key={item.title}>
              <div className="Itemname">
                <p>{item.title}</p>
              </div>
              <div className="AddRemov">
                <button className="DecreaseQuant" onClick={() => updateQuantity(item.title, -1)}>-</button>
                <div className="CurrQuan">
                  <button className="CurrentQuant">{item.quantity}</button>
                </div>
                <button className="AddQuant" onClick={() => updateQuantity(item.title, 1)}>+</button>
              </div>
              <div className="ItemPrice">
                <p>₹{(item.price * item.quantity || 0).toFixed(2)}</p>
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
          {/* <button className="PayNowButton">Pay Now</button> */}
          <button className="PayNowButton" onClick={handlePayment}>Pay Now</button>
        </div>
      </div>
    </section>
  );
};

export default Cart;
