import React, { useEffect, useState } from "react";
import "./Menu.css";
import { getDocs, collection, getFirestore } from "firebase/firestore";
import { initializeApp } from "firebase/app";
import { useNavigate } from "react-router-dom";

// Firebase Configuration
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
  const [menuItems, setMenuItems] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortOption, setSortOption] = useState("");
  const [category, setCategory] = useState("All");
  const [categories, setCategories] = useState([]);
  const navigate = useNavigate();

  // Fetch menu and load cart on component mount
  useEffect(() => {
    fetchMenu();
    loadCart();
  }, []);

  // Fetch menu from Firebase
  const fetchMenu = async () => {
    const querySnapshot = await getDocs(collection(db, "menu"));
    const menuData = querySnapshot.docs.map((doc) => doc.data());
    setMenuItems(menuData);

    // Extract unique categories
    const uniqueCategories = [...new Set(menuData.map((item) => item.category))];
    setCategories(uniqueCategories);
  };

  // Load cart from local storage
  const loadCart = () => {
    const storedCart = JSON.parse(localStorage.getItem("cart")) || [];
    setCart(storedCart);
    if (storedCart.length > 0) {
      setShowCartPopup(true);
    }
  };

  // Add item to cart and save to local storage
  const addToCart = (item) => {
    setCart((prevCart) => {
      const existingItem = prevCart.find((cartItem) => cartItem.title === item.title);

      let updatedCart;
      if (existingItem) {
        updatedCart = prevCart.map((cartItem) =>
          cartItem.title === item.title
            ? { ...cartItem, quantity: cartItem.quantity + 1 }
            : cartItem
        );
      } else {
        updatedCart = [...prevCart, { ...item, quantity: 1 }];
      }

      localStorage.setItem("cart", JSON.stringify(updatedCart)); // Update local storage
      return updatedCart;
    });

    setShowCartPopup(true);
  };

  // Navigate to cart page
  const goToCart = () => {
    if (cart.length > 0) {
      navigate("/Cart");
    }
  };

  // Filter items based on search and category
  const filteredMenu = menuItems.filter((item) => {
    return (
      item.title.toLowerCase().includes(searchQuery.toLowerCase()) &&
      (category === "All" || item.category === category)
    );
  });

  // Sort items based on selected option
  const sortedMenu = [...filteredMenu].sort((a, b) => {
    if (sortOption === "priceLowHigh") return a.price - b.price;
    if (sortOption === "priceHighLow") return b.price - a.price;
    if (sortOption === "ratingHighLow") return b.rating - a.rating;
    if (sortOption === "ratingLowHigh") return a.rating - b.rating;
    return 0;
  });

  return (
    <div>
      <div className="MTitle">
        <div className="MHead">
          <h2>Menu</h2>
        </div>
      </div>

      {/* Search Input */}
      <div className="SearchBtn">
        <input
          type="text"
          placeholder="Search for dishes"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        <i className="fa-solid fa-magnifying-glass"></i>
      </div>

      {/* Filter and Sort Options */}
      <div className="FilterSortContainer">
        {/* Sort Dropdown */}
        <select className="Sorting" value={sortOption} onChange={(e) => setSortOption(e.target.value)}>
          <option value="">Sort By</option>
          <option value="priceLowHigh">Price: Low to High</option>
          <option value="priceHighLow">Price: High to Low</option>
          <option value="ratingHighLow">Rating: High to Low</option>
          <option value="ratingLowHigh">Rating: Low to High</option>
        </select>

        {/* Category Filter */}
        <select value={category} onChange={(e) => setCategory(e.target.value)}>
          <option value="All">All Categories</option>
          {categories.map((cat, index) => (
            <option key={index} value={cat}>
              {cat}
            </option>
          ))}
        </select>
      </div>

      <div className="line"></div>

      {/* Display Sorted and Filtered Menu Items */}
      <div className="DishItems">
        {sortedMenu.length > 0 ? (
          sortedMenu.map((data, index) => (
            <div className="DishItmesPlacement" key={index}>
              <div className="LSidePlacement">
                <div className="ItemType">
                  <img src="/images/veg-icon.jpeg" alt="veg" />
                </div>
                <div className="itemTitle">
                  <h3>{data.title}</h3>
                </div>
                <div className="itemPrice">
                  <h4>₹{data.price}</h4>
                </div>
                <div className="itemRatings">
                  <img src="/images/Stars.png" alt="rating" />
                  <p>{data.rating}</p>
                </div>
                <div className="itemDescription">
                  <h5>{data.description}</h5>
                </div>
              </div>
              <div className="RSidePlacement">
                <div className="ItemsImgs">
                  <img src={data.image} alt="DishImg" />
                </div>
                <div className="AddToCart">
                  <button onClick={() => addToCart(data)}>Add</button>
                </div>
              </div>
            </div>
          ))
        ) : (
          <p>No menu items available.</p>
        )}
      </div>

      {/* Floating Cart Notification */}
      {showCartPopup && cart.length > 0 && (
        <div className="cartPopup" onClick={goToCart}>
          <p> 🛒 {cart.length} items in cart. Go to Cart ➡️</p>
        </div>
      )}
    </div>
  );
}

export default Menu;
