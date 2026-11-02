/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          dark: '#0b1120',
          card: '#1e293b',
          border: '#334155',
          primary: '#38bdf8',
          accent: '#818cf8',
          success: '#34d399',
          warning: '#fbbf24',
          danger: '#f87171'
        }
      }
    },
  },
  plugins: [],
}
