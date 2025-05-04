import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <h1>Мандала</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
           прожито жизней = {count}
        </button>
      </div>
    </>
  )
}

export default App
