import { useState, useEffect } from 'react'

export default function App() {
  const [nodeData, setNodeData] = useState(null)
  const [flaskData, setFlaskData] = useState(null)

  useEffect(() => {
    fetch('http://node-api.INGRESS_HOST')
      .then(r => r.json())
      .then(setNodeData)
      .catch(() => setNodeData({ status: 'unreachable' }))

    fetch('http://flask-api.INGRESS_HOST')
      .then(r => r.json())
      .then(setFlaskData)
      .catch(() => setFlaskData({ status: 'unreachable' }))
  }, [])

  return (
    <div style={{ fontFamily: 'sans-serif', background: '#0f172a', color: '#e2e8f0', minHeight: '100vh', padding: '2rem' }}>
      <div style={{ maxWidth: 800, margin: '0 auto' }}>
        <h1 style={{ color: '#6366f1', fontSize: '2rem' }}>⚡ Cloud Forge</h1>
        <p style={{ color: '#94a3b8' }}>React App — deployée sur EKS via GitHub Actions</p>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginTop: '2rem' }}>
          <div style={{ background: '#1e293b', padding: '1.5rem', borderRadius: 12, borderTop: '3px solid #6366f1' }}>
            <h2 style={{ margin: 0, marginBottom: '0.5rem' }}>Node API</h2>
            {nodeData ? (
              <pre style={{ color: '#94a3b8', fontSize: '0.85rem', overflow: 'auto' }}>
                {JSON.stringify(nodeData, null, 2)}
              </pre>
            ) : (
              <p style={{ color: '#64748b' }}>Chargement...</p>
            )}
          </div>

          <div style={{ background: '#1e293b', padding: '1.5rem', borderRadius: 12, borderTop: '3px solid #10b981' }}>
            <h2 style={{ margin: 0, marginBottom: '0.5rem' }}>Flask API</h2>
            {flaskData ? (
              <pre style={{ color: '#94a3b8', fontSize: '0.85rem', overflow: 'auto' }}>
                {JSON.stringify(flaskData, null, 2)}
              </pre>
            ) : (
              <p style={{ color: '#64748b' }}>Chargement...</p>
            )}
          </div>
        </div>

        <div style={{ background: '#1e293b', padding: '1.5rem', borderRadius: 12, marginTop: '1rem', borderTop: '3px solid #f59e0b' }}>
          <h2 style={{ margin: 0, marginBottom: '1rem' }}>Stack technique</h2>
          <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
            {['AWS EKS', 'Terraform', 'GitHub Actions', 'Prometheus', 'Grafana', 'NGINX Ingress', 'React', 'Node.js', 'Flask'].map(tag => (
              <span key={tag} style={{ background: '#334155', padding: '0.3rem 0.8rem', borderRadius: 20, fontSize: '0.85rem' }}>
                {tag}
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
