'use strict';

let currentFilter = '';

// ── boot ──────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', async () => {
  const params = new URLSearchParams(location.search);
  if (params.get('confirmed') === '1') {
    showNotice('ok', 'Email confirmed — you can now sign in.');
  }

  const res = await fetch('/api/auth/me');
  if (res.ok) {
    const me = await res.json();
    showApp(me);
  } else {
    showAuth();
  }
});

// ── auth ──────────────────────────────────────────────────────

function showAuth() {
  document.getElementById('auth').style.display = 'flex';
  document.getElementById('app').style.display = 'none';
}

function showApp(me) {
  document.getElementById('auth').style.display = 'none';
  document.getElementById('app').style.display = 'block';
  document.getElementById('topbar-info').textContent = `${me.email} · ${me.ip}`;
  loadBooks();
}

function switchTab(tab) {
  const tabs = document.querySelectorAll('.tab');
  tabs.forEach((t, i) => t.classList.toggle('active', (tab === 'login') === (i === 0)));
  document.getElementById('tab-login').style.display = tab === 'login' ? 'block' : 'none';
  document.getElementById('tab-register').style.display = tab === 'register' ? 'block' : 'none';
  hideNotice();
}

async function login() {
  const email = document.getElementById('l-email').value.trim();
  const password = document.getElementById('l-pass').value;
  if (!email || !password) return;

  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  const data = await res.json();
  if (!res.ok) { showNotice('err', data.error); return; }

  const me = await (await fetch('/api/auth/me')).json();
  showApp(me);
}

async function register() {
  const email = document.getElementById('r-email').value.trim();
  const password = document.getElementById('r-pass').value;
  if (!email || !password) return;

  const res = await fetch('/api/auth/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  const data = await res.json();
  if (!res.ok) { showNotice('err', data.error); return; }
  showNotice('ok', data.message);
}

async function logout() {
  await fetch('/api/auth/logout', { method: 'POST' });
  showAuth();
}

// ── books ─────────────────────────────────────────────────────

async function loadBooks() {
  const url = currentFilter ? `/api/books?status=${currentFilter}` : '/api/books';
  const res = await fetch(url);
  if (!res.ok) return;
  const books = await res.json();
  renderBooks(books);
}

function renderBooks(books) {
  const el = document.getElementById('books');
  if (!books.length) {
    el.innerHTML = '<div class="empty">Nothing here yet.</div>';
    return;
  }
  el.innerHTML = books.map(b => `
    <div class="book-card">
      <div class="book-title">${esc(b.title)}</div>
      ${b.author ? `<div class="book-author">${esc(b.author)}</div>` : ''}
      <div class="book-meta">
        ${b.genre ? `<span>${esc(b.genre)}</span>` : ''}
        ${b.year  ? `<span>${b.year}</span>` : ''}
      </div>
      ${b.rating ? `<div class="stars">${stars(b.rating)}</div>` : ''}
      <span class="book-status status-${b.status}">${statusLabel(b.status)}</span>
      ${b.notes ? `<div class="book-meta" style="margin-top:4px;font-style:italic">${esc(b.notes)}</div>` : ''}
      <div class="book-actions">
        <button class="act-btn" onclick="editBook(${b.id})">Edit</button>
        <button class="act-btn del" onclick="deleteBook(${b.id})">Delete</button>
      </div>
    </div>
  `).join('');
}

function setFilter(status, btn) {
  currentFilter = status;
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  loadBooks();
}

async function deleteBook(id) {
  if (!confirm('Delete this book?')) return;
  await fetch(`/api/books/${id}`, { method: 'DELETE' });
  loadBooks();
}

// ── modal ─────────────────────────────────────────────────────

function openModal(book = null) {
  document.getElementById('modal-title').textContent = book ? 'Edit book' : 'Add book';
  document.getElementById('book-id').value     = book ? book.id : '';
  document.getElementById('book-title').value  = book ? book.title : '';
  document.getElementById('book-author').value = book ? book.author : '';
  document.getElementById('book-genre').value  = book ? book.genre : '';
  document.getElementById('book-year').value   = book ? (book.year || '') : '';
  document.getElementById('book-status').value = book ? book.status : 'want';
  document.getElementById('book-rating').value = book ? (book.rating || '') : '';
  document.getElementById('book-notes').value  = book ? book.notes : '';
  document.getElementById('overlay').classList.add('open');
  document.getElementById('book-title').focus();
}

function closeModal() {
  document.getElementById('overlay').classList.remove('open');
}

function closeModalOutside(e) {
  if (e.target === document.getElementById('overlay')) closeModal();
}

async function editBook(id) {
  const res = await fetch('/api/books');
  const books = await res.json();
  const book = books.find(b => b.id === id);
  if (book) openModal(book);
}

async function saveBook() {
  const id = document.getElementById('book-id').value;
  const body = {
    title:  document.getElementById('book-title').value.trim(),
    author: document.getElementById('book-author').value.trim(),
    genre:  document.getElementById('book-genre').value.trim(),
    year:   parseInt(document.getElementById('book-year').value) || null,
    status: document.getElementById('book-status').value,
    rating: parseInt(document.getElementById('book-rating').value) || null,
    notes:  document.getElementById('book-notes').value.trim(),
  };
  if (!body.title) { document.getElementById('book-title').focus(); return; }

  const method = id ? 'PUT' : 'POST';
  const url = id ? `/api/books/${id}` : '/api/books';
  await fetch(url, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  closeModal();
  loadBooks();
}

// ── utils ─────────────────────────────────────────────────────

function esc(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function stars(n) {
  return '★'.repeat(n) + '☆'.repeat(5 - n);
}

function statusLabel(s) {
  return { want: 'Want to read', reading: 'Reading', read: 'Read' }[s] || s;
}

function showNotice(type, msg) {
  const el = document.getElementById('auth-notice');
  el.className = `notice ${type}`;
  el.textContent = msg;
  el.style.display = 'block';
}

function hideNotice() {
  document.getElementById('auth-notice').style.display = 'none';
}
