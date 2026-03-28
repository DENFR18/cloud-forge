import { useState, useEffect } from 'react'

const apps = [
  { name: 'WordPress', path: '/wordpress', desc: 'CMS client Alpha', color: '#3b82f6', icon: '📝' },
  { name: 'Ghost', path: '/ghost', desc: 'Blog client Beta', color: '#8b5cf6', icon: '👻' },
  { name: 'Gitea', path: '/gitea', desc: 'Git self-hosted client Gamma', color: '#f97316', icon: '🔧' },
  { name: 'Grafana', path: '/grafana', desc: 'Dashboards monitoring', color: '#f59e0b', icon: '📊' },
  { name: 'Prometheus', path: '/prometheus', desc: 'Metriques cluster', color: '#ef4444', icon: '🔥' },
]

const stack = [
  'Scaleway Kapsule', 'Terraform', 'GitHub Actions', 'Prometheus',
  'Grafana', 'NGINX Ingress', 'React', 'Node.js', 'Flask',
  'WordPress', 'Ghost', 'Gitea', 'Docker', 'Cilium CNI'
]

export default function App() {
  const [nodeData, setNodeData] = useState(null)
  const [flaskData, setFlaskData] = useState(null)
  const host = window.location.hostname

  useEffect(() => {
    fetch('/api')
      .then(r => r.json())
      .then(setNodeData)
      .catch(() => setNodeData({ status: 'unreachable' }))

    fetch('/flask')
      .then(r => r.json())
      .then(setFlaskData)
      .catch(() => setFlaskData({ status: 'unreachable' }))
  }, [])

  const getAppUrl = (app) => app.path

  return (
    <div style={{ fontFamily: "'Segoe UI', sans-serif", background: '#0f172a', color: '#e2e8f0', minHeight: '100vh', padding: '2rem' }}>
      <div style={{ maxWidth: 1000, margin: '0 auto' }}>

        <header style={{ textAlign: 'center', marginBottom: '3rem' }}>
          <h1 style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>
            <span style={{ color: '#6366f1' }}>Cloud</span> <span style={{ color: '#10b981' }}>Forge</span>
          </h1>
          <p style={{ color: '#94a3b8', fontSize: '1.1rem' }}>
            Plateforme multi-tenant ESN — Scaleway Kapsule
          </p>
          <p style={{ color: '#64748b', fontSize: '0.9rem', marginTop: '0.3rem' }}>
            SUP DE VINCI — Mastere DevOps 2025-2026
          </p>
        </header>

        <h2 style={{ color: '#94a3b8', fontSize: '1rem', textTransform: 'uppercase', letterSpacing: 2, marginBottom: '1rem' }}>
          Applications clients
        </h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: '1rem', marginBottom: '2rem' }}>
          {apps.map(app => (
            <a key={app.name} href={getAppUrl(app)}
              style={{
                background: '#1e293b', padding: '1.2rem', borderRadius: 12,
                borderLeft: `4px solid ${app.color}`, textDecoration: 'none', color: '#e2e8f0',
                transition: 'transform 0.2s', cursor: 'pointer'
              }}
              onMouseEnter={e => e.currentTarget.style.transform = 'translateY(-2px)'}
              onMouseLeave={e => e.currentTarget.style.transform = 'translateY(0)'}
            >
              <div style={{ fontSize: '1.5rem', marginBottom: '0.5rem' }}>{app.icon}</div>
              <div style={{ fontWeight: 600 }}>{app.name}</div>
              <div style={{ color: '#64748b', fontSize: '0.8rem', marginTop: '0.3rem' }}>{app.desc}</div>
            </a>
          ))}
        </div>

        <h2 style={{ color: '#94a3b8', fontSize: '1rem', textTransform: 'uppercase', letterSpacing: 2, marginBottom: '1rem' }}>
          APIs internes
        </h2>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '2rem' }}>
          <div style={{ background: '#1e293b', padding: '1.5rem', borderRadius: 12, borderTop: '3px solid #6366f1' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
              <h3 style={{ margin: 0 }}>Node API</h3>
              <span style={{
                background: nodeData?.status === 'unreachable' ? '#ef4444' : '#10b981',
                padding: '0.2rem 0.6rem', borderRadius: 20, fontSize: '0.75rem'
              }}>
                {nodeData?.status === 'unreachable' ? 'offline' : 'online'}
              </span>
            </div>
            <pre style={{ color: '#94a3b8', fontSize: '0.8rem', overflow: 'auto', margin: 0 }}>
              {nodeData ? JSON.stringify(nodeData, null, 2) : 'Chargement...'}
            </pre>
          </div>

          <div style={{ background: '#1e293b', padding: '1.5rem', borderRadius: 12, borderTop: '3px solid #10b981' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
              <h3 style={{ margin: 0 }}>Flask API</h3>
              <span style={{
                background: flaskData?.status === 'unreachable' ? '#ef4444' : '#10b981',
                padding: '0.2rem 0.6rem', borderRadius: 20, fontSize: '0.75rem'
              }}>
                {flaskData?.status === 'unreachable' ? 'offline' : 'online'}
              </span>
            </div>
            <pre style={{ color: '#94a3b8', fontSize: '0.8rem', overflow: 'auto', margin: 0 }}>
              {flaskData ? JSON.stringify(flaskData, null, 2) : 'Chargement...'}
            </pre>
          </div>
        </div>

        <h2 style={{ color: '#94a3b8', fontSize: '1rem', textTransform: 'uppercase', letterSpacing: 2, marginBottom: '1rem' }}>
          Stack technique
        </h2>
        <div style={{ background: '#1e293b', padding: '1.5rem', borderRadius: 12 }}>
          <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
            {stack.map(tag => (
              <span key={tag} style={{
                background: '#334155', padding: '0.4rem 0.9rem',
                borderRadius: 20, fontSize: '0.85rem', color: '#cbd5e1'
              }}>
                {tag}
              </span>
            ))}
          </div>
        </div>

        <footer style={{ textAlign: 'center', marginTop: '2rem', color: '#475569', fontSize: '0.8rem' }}>
          Cloud Forge v2.0 — Deploye via GitHub Actions sur Scaleway Kapsule
        </footer>
      </div>
    </div>
  )
}
