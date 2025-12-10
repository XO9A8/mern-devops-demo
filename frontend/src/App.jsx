import { useState, useEffect } from 'react'
import './App.css'

function App() {
    const [message, setMessage] = useState('Loading...')
    const [health, setHealth] = useState(null)

    useEffect(() => {
        // Fetch API message
        fetch('/api')
            .then(res => res.json())
            .then(data => setMessage(data.message))
            .catch(() => setMessage('Failed to connect to API'))

        // Fetch health status
        fetch('/health')
            .then(res => res.json())
            .then(data => setHealth(data))
            .catch(() => setHealth({ status: 'unhealthy' }))
    }, [])

    return (
        <div className="app">
            <header>
                <h1>🚀 MERN DevOps</h1>
                <p className="subtitle">Full-stack application with industry-level DevOps</p>
            </header>

            <main>
                <section className="card">
                    <h2>API Response</h2>
                    <p>{message}</p>
                </section>

                <section className="card">
                    <h2>Health Status</h2>
                    {health && (
                        <div className={`status ${health.status}`}>
                            <span className="indicator"></span>
                            {health.status}
                        </div>
                    )}
                </section>

                <section className="card">
                    <h2>DevOps Features</h2>
                    <ul>
                        <li>✅ Docker (dev/prod)</li>
                        <li>✅ GitHub Actions CI/CD</li>
                        <li>✅ Kubernetes deployment</li>
                        <li>✅ Prometheus monitoring</li>
                        <li>✅ Structured logging</li>
                    </ul>
                </section>
            </main>

            <footer>
                <p>Built for DevOps demonstration</p>
            </footer>
        </div>
    )
}

export default App
