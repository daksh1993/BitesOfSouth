/**
 * @fileoverview Entry point for the React application.
 * This file initializes the React application by rendering the root component (`App`)
 * into the DOM element with the ID 'root'. It also imports global styles and sets up
 * performance reporting using `reportWebVitals`.
 *
 * @module index
 */
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

reportWebVitals();
