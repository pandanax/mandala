import { useState, useEffect } from 'react'
import WebApp from '@twa-dev/sdk'

import './App.css'

function App() {
  const [count, setCount] = useState(0)
  const [apiStatus, setApiStatus] = useState<any>(null)

    useEffect(() => {
      WebApp.ready();
  }, []);
  const user = WebApp.initDataUnsafe.user;

    const fetchApiStatus = async () => {
        try {
            const apiUrl = window.location.hostname.includes('mandala-app')
                ? '//api.' + window.location.hostname
                : 'http://localhost:3000';
            const response = await fetch(`${apiUrl}/status`)
            const data = await response.json()
            setApiStatus(data)
        } catch (error) {
            console.error('Ошибка при запросе к API:', error)
            setApiStatus({ error: 'Не удалось получить данные' })
        }
    }

    return (
      <>
          <h2>Моя Мандала2</h2>
          <div className="card">
              <button onClick={() => setCount((count) => count + 1)}>
                  прожито жизней = {count}
              </button>
              <button onClick={fetchApiStatus} style={{marginTop: '10px'}}>
                  Сходить в API
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
          {apiStatus && (
              <div style={{ marginTop: '20px' }}>
                  <h3>Ответ API:</h3>
                  <pre>{JSON.stringify(apiStatus, null, 2)}</pre>
              </div>
          )}
          <button onClick={() => WebApp.close()}>Close App</button>

      </>
  )
}

export default App
