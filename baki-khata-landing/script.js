const screens = [
  {image:'assets/customers.webp', title:'সব কাস্টমারের হিসাব একসাথে', desc:'কার কাছে কত টাকা বাকি আছে, তা দ্রুত দেখুন। নাম বা ফোন নম্বর দিয়ে কাস্টমার খুঁজুন।', alt:'কাস্টমার তালিকা'},
  {image:'assets/account.webp', title:'প্রতিটি কাস্টমারের পুরো হিসাব', desc:'আগের বিক্রি, জমা, মোট বকেয়া এবং লেনদেনের ইতিহাস এক স্ক্রিনে দেখুন।', alt:'কাস্টমারের বিস্তারিত হিসাব'},
  {image:'assets/sale.webp', title:'বিক্রির হিসাব লিখুন সহজে', desc:'পণ্য, পরিমাণ, ছাড় ও জমার টাকা যোগ করে বাকির হিসাব রাখুন।', alt:'নতুন বিক্রির ফর্ম'},
  {image:'assets/expenses.webp', title:'প্রতিটি খরচ থাকুক গুছিয়ে', desc:'বিভিন্ন খাতে দোকানের খরচ লিখুন এবং মাসিক বা দৈনিক সারাংশ দেখুন।', alt:'দোকানের খরচ'},
  {image:'assets/products.webp', title:'পণ্যের মূল্যতালিকা হাতের কাছে', desc:'বিক্রির সময় দ্রুত বেছে নিতে নিয়মিত পণ্য ও দাম সংরক্ষণ করুন।', alt:'পণ্য তালিকা'}
];
let active = 0;
const image = document.getElementById('active-screen');
const tabs = [...document.querySelectorAll('.screen-tab')];
function showScreen(index) {
 active = (index + screens.length) % screens.length;
 const s = screens[active];
 image.style.opacity = '0.35';
 const preload = new Image(); preload.src = s.image;
 preload.onload = () => {image.src = s.image; image.alt = s.alt; image.style.opacity = '1';};
 document.getElementById('screen-index').textContent = String(active+1).padStart(2,'0') + ' / 05';
 document.getElementById('screen-title').textContent = s.title;
 document.getElementById('screen-desc').textContent = s.desc;
 tabs.forEach((tab,i) => {tab.classList.toggle('active',i===active); tab.setAttribute('aria-selected',String(i===active));});
}
tabs.forEach((tab,i) => tab.addEventListener('click',()=>showScreen(i)));
document.getElementById('prev-screen').addEventListener('click',()=>showScreen(active-1));
document.getElementById('next-screen').addEventListener('click',()=>showScreen(active+1));
const toggle = document.querySelector('.mobile-menu-toggle');
const menu = document.querySelector('.mobile-nav');
toggle.addEventListener('click',()=>{const isOpen=menu.classList.toggle('open'); toggle.setAttribute('aria-expanded',String(isOpen));toggle.textContent=isOpen?'×':'☰';});
menu.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{menu.classList.remove('open');toggle.setAttribute('aria-expanded','false');toggle.textContent='☰';}));
document.getElementById('year').textContent = new Date().getFullYear();
