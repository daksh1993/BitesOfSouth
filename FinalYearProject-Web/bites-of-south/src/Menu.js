import React, { useEffect } from "react";
import "./Menu.css";
import { getDocs, collection, addDoc, getFirestore } from "firebase/firestore";
import {  updateDoc, query, where, doc } from "firebase/firestore";
import { initializeApp } from "firebase/app";

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

function App() {
  useEffect(() => {
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
                        <button onclick="addToCart('${doc.id}', '${data.title}', ${data.price})">Add</button>
                    </div>
                </div>
            </div>
        `;
        menuContainer.innerHTML += foodItemHTML;
      });
    };

    fetchMenu();
  }, []);

  window.addToCart = async (id, title, price) => {
    try {
      const cartRef = collection(db, "cart");
  
      // Check if the item already exists in the cart
      const q = query(cartRef, where("title", "==", title));
      const querySnapshot = await getDocs(q);
  
      if (!querySnapshot.empty) {
        // Item exists, update its quantity
        const cartItem = querySnapshot.docs[0]; // First matching item
        const cartItemRef = doc(db, "cart", cartItem.id);
        const newQuantity = cartItem.data().quantity + 1;
  
        await updateDoc(cartItemRef, { quantity: newQuantity });
  
        alert(`✅ Updated quantity to ${newQuantity}!`);
      } else {
        // Item does not exist, add it to the cart
        await addDoc(cartRef, {
          title: title,
          price: price,
          quantity: 1,
        });
  
        alert("✅ Item added to cart successfully!");
      }
    } catch (error) {
      console.error("❌ Error adding item to cart:", error);
    }
  };

  return (
    <div>
      <div className="MTitle">
        <div className="LArt"></div>
        <div className="MHead">
          <div>
            <h2> Menu </h2>
          </div>
          <div>
            <a href="/Cart">
              <i className="fa-solid fa-cart-shopping"></i>
            </a>
          </div>
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
    </div>
  );
}

export default App;
