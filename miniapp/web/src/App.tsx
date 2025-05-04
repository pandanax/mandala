import { useState, useEffect } from 'react'
import WebApp from '@twa-dev/sdk'

import './App.css'

function App() {
  const [count, setCount] = useState(0)
  useEffect(() => {
      WebApp.ready();
  }, []);
  const user = WebApp.initDataUnsafe.user;

    return (
      <>
          <h2>Моя Мандала</h2>
          <div className="card">
              <button onClick={() => setCount((count) => count + 1)}>
                  прожито жизней = {count}
              </button>
          </div>
          {
              user && (
                  <div>
                      <p>Привет, {user.first_name}!</p>
                      <p>ID: {user.id}</p>
                  </div>
              )
          }
          <button onClick={() => WebApp.close()}>Close App</button>

      </>
  )
}

export default App
