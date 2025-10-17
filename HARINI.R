const express = require('express');
const session = require('express-session');
const app = express();
const PORT = 3000;
// Setup session middleware
app.use(session({
  secret: 'secret-key',
  resave: false,
  saveUninitialized: true,
}));
// Middleware to parse POST body
app.use(express.urlencoded({ extended: true }));
// Set view engine to EJS
app.set('view engine', 'ejs');
// Sample product list
const products = [
  { id: 1, name: 'Phone', price: 300 },
  { id: 2, name: 'Laptop', price: 1200 },
  { id: 3, name: 'Headphones', price: 150 },
];
// Home page - display products
app.get('/', (req, res) => {
  res.render('index', { products });
});
// View Cart
app.get('/cart', (req, res) => {
  const cart = req.session.cart || [];
 
 const total = cart.reduce((sum, item) => sum + item.price * item.qty, 0);
  res.render('cart', { cart, total });
});
// Add to cart
app.post('/add-to-cart', (req, res) => {
  const productId = parseInt(req.body.productId);
  const product = products.find(p => p.id === productId);
  if (!product) return res.send('Product not found');

  if (!req.session.cart) req.session.cart = [];

  const cartItem = req.session.cart.find(item => item.id === productId);
  if (cartItem) {
    cartItem.qty += 1;
  } else {
    req.session.cart.push({ ...product, qty: 1 });
  }

  res.redirect('/cart');
});

// Remove from cart
app.post('/remove-from-cart', (req, res) => {
  const productId = parseInt(req.body.productId);
  req.session.cart = (req.session.cart || []).filter(item => item.id !== productId);
  res.redirect('/cart');
});

// Update quantity
app.post('/update-qty', (req, res) => {
  const { productId, qty } = req.body;
  const cart = req.session.cart || [];
  const item = cart.find(i => i.id === parseInt(productId));
  if (item) item.qty = parseInt(qty);
  res.redirect('/cart');
});

// Start server
app.listen(PORT, () => console.log(`Server running at http://localhost:${PORT}`));

views/index.ejs – Product List Page

<!DOCTYPE html>
<html>
<head><title>Product List</title></head>
<body>
  <h1>Products</h1>
  <ul>
    <% products.forEach(p => { %>
      <li>
        <%= p.name %> - $<%= p.price %>
        <form action="/add-to-cart" method="POST" style="display:inline">
          <input type="hidden" name="productId" value="<%= p.id %>">
          <button type="submit">Add to Cart</button>
        </form>
      </li>
    <% }); %>
  </ul>
  <a href="/cart">View Cart</a>
</body>
</html>

views/cart.ejs – Cart Page

<!DOCTYPE html>
<html>
<head><title>Your Cart</title></head>
<body>
  <h1>Shopping Cart</h1>
  <% if (cart.length === 0) { %>
    <p>Your cart is empty.</p>
  <% } else { %>
    <ul>
      <% cart.forEach(item => { %>
        <li>
          <%= item.name %> - $<%= item.price %> x 
          <form action="/update-qty" method="POST" style="display:inline">
          
  <input type="number" name="qty" value="<%= item.qty %>" min="1" style="width:50px">
           
 <input type="hidden" name="productId" value="<%= item.id %>">
            <button type="submit">Update</button>
          </form>
          = $<%= item.price * item.qty %>
          <form action="/remove-from-cart" method="POST" style="display:inline">
            <input type="hidden" name="productId" value="<%= item.id %>">
            <button type="submit">Remove</button>
          </form>
        </li>
      <% }); %>
    </ul>
    <h3>Total: $<%= total %></h3>
  <% } %>
  <a href="/">Back to Products</a>
</body>
</html>







