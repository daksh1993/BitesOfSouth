import React, { useEffect, useState } from "react";
import "./Menu.css";
import { getDocs, collection, getFirestore } from "firebase/firestore";
import { initializeApp } from "firebase/app";
import { useNavigate } from "react-router-dom"; // For navigation

const firebaseConfig = {
  apiKey: "AIzaSyCnSJVHioItNsc2kedyZTxJ7PvfX2hQC7Q",
  authDomain: "bitesofsouth-a38f4.firebaseapp.com",
  databaseURL: "https://bitesofsouth-a38f4-default-rtdb.firebaseio.com",
  projectId: "bitesofsouth-a38f4",
  storageBucket: "bitesofsouth-a38f4.appspot.com",
  messagingSenderId: "65231955877",
  appId: "1:65231955877:web:aab053b6882e9894bdaa4c",
  measurementId: "G-R9WE265DPN",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

function Menu() {
  const [cart, setCart] = useState([]);
  const [showCartPopup, setShowCartPopup] = useState(false);
  const navigate = useNavigate(); // For redirection

  useEffect(() => {
    fetchMenu();
    loadCart();
  }, []);

  // Fetch menu from Firebase
  const fetchMenu = async () => {
    const menuContainer = document.querySelector(".DishItems");
    const querySnapshot = await getDocs(collection(db, "menu"));

    menuContainer.innerHTML = ""; // Clear previous content

    if (querySnapshot.empty) {
      menuContainer.innerHTML = "<p>No menu items available.</p>";
      return;
    }

    querySnapshot.forEach((doc) => {
      const data = doc.data();
      const foodItemHTML = `
          <div class="DishItmesPlacement">
              <div class="LSidePlacement">
                  <div class="ItemType">
                      <img src="/images/veg-icon.jpeg" alt="veg">
                  </div>
                  <div class="itemTitle">
                      <h3>${data.title}</h3>
                  </div>
                  <div class="itemPrice">
                      <h4>₹${data.price}</h4>
                  </div>
                  <div class="itemRatings">
                      <img src="/images/Stars.png" alt="">  <p>${data.rating}</p>
                  </div>
                  <div class="itemDescription">
                      <h5>${data.description}</h5>
                  </div>
              </div>
              <div class="RSidePlacement">
                  <div class="ItemsImgs">
                      <img src="${data.image}" alt="DosaImg" height="144px" width="156px">
                  </div>   
                  <div class="AddToCart">
                      <button onclick="window.addToCart('${data.title}', ${data.price})">Add</button>
                  </div>
              </div>
          </div>
      `;
      menuContainer.innerHTML += foodItemHTML;
    });
  };

  // Add item to cart (localStorage)
  window.addToCart = (title, price) => {
    let cart = JSON.parse(localStorage.getItem("cart")) || [];
    let itemIndex = cart.findIndex((item) => item.title === title);

    if (itemIndex !== -1) {
      cart[itemIndex].quantity += 1;
    } else {
      cart.push({ title, price, quantity: 1 });
    }

    localStorage.setItem("cart", JSON.stringify(cart));
    setCart(cart);
    setShowCartPopup(true); // Show popup when item is added
  };

  // Load cart from localStorage
  const loadCart = () => {
    const storedCart = JSON.parse(localStorage.getItem("cart")) || [];
    setCart(storedCart);
    if (storedCart.length > 0) {
      setShowCartPopup(true);
    }
  };

  // Redirect to cart if items are available
  const goToCart = () => {
    if (cart.length > 0) {
      navigate("/Cart");
    }
  };

  return (
    <div>
      <div className="MTitle">
        <div className="LArt"></div>
        <div className="MHead">
          <h2>Menu</h2>
          {/* <button onClick={goToCart} className="cartButton">
            <i className="fa-solid fa-cart-shopping"></i>
          </button> */}
        </div>
        <div className="RArt"></div>
      </div>

      <div className="SearchBtn">
        <input type="text" placeholder="Search for dishes" />
        <i className="fa-solid fa-magnifying-glass"></i>
      </div>

      <div className="line"></div>

      <div className="DishItems">
        {/* Content will be inserted here dynamically */}
      </div>

      {/* Floating cart notification */}
      {showCartPopup && cart.length > 0 && (
        <div className="cartPopup" onClick={goToCart}>
          <p> 🛒 {cart.length} items in cart. Go to Cart ➡️</p>
        </div>
      )}
    </div>
  );
}

export default Menu;
