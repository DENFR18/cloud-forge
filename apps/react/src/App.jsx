import { useState, useEffect } from 'react'
import './index.css'

const clientApps = [
  { name: 'WordPress', sub: 'wordpress', desc: 'CMS — Client Alpha', tag: 'CMS', accent: '#3b82f6', iconBg: 'rgba(59,130,246,0.12)', icon: 'W' },
  { name: 'Ghost', sub: 'ghost', desc: 'Blog — Client Beta', tag: 'Blog', accent: '#8b5cf6', iconBg: 'rgba(139,92,246,0.12)', icon: 'G' },
  { name: 'Gitea', sub: 'gitea', desc: 'Git — Client Gamma', tag: 'SCM', accent: '#f97316', iconBg: 'rgba(249,115,22,0.12)', icon: '<>' },
]

const monitoringApps = [
  { name: 'Grafana', sub: 'grafana', desc: 'Dashboards & alerting', tag: 'Monitoring', accent: '#f59e0b', iconBg: 'rgba(245,158,11,0.12)', icon: '◈' },
  { name: 'Prometheus', sub: 'prometheus', desc: 'Metriques cluster', tag: 'Metrics', accent: '#ef4444', iconBg: 'rgba(239,68,68,0.12)', icon: '◉' },
]

const stack = [
  'Scaleway Kapsule', 'Terraform', 'GitHub Actions', 'Docker',
  'Prometheus', 'Grafana', 'NGINX Ingress', 'Cilium CNI',
  'React', 'Node.js', 'Flask', 'WordPress', 'Ghost', 'Gitea',
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

  const baseHost = host.endsWith('.nip.io') ? host : `${host}.nip.io`
  const getAppUrl = (app) => `http://${app.sub}.${baseHost}`

  const AppCard = ({ app }) => (
    <a
      className="app-card"
      href={getAppUrl(app)}
      target="_blank"
      rel="noopener noreferrer"
      style={{ '--card-accent': app.accent, '--icon-bg': app.iconBg }}
    >
      <div className="app-icon" style={{ color: app.accent }}>{app.icon}</div>
      <div className="app-name">{app.name}</div>
      <div className="app-desc">{app.desc}</div>
      <span className="app-tag">{app.tag}</span>
    </a>
  )

  const ApiCard = ({ name, lang, data, accent }) => {
    const online = data && data.status !== 'unreachable'
    return (
      <div className="api-card">
        <div className="api-header">
          <div className="api-name">
            {name}
            <span className="api-lang">{lang}</span>
          </div>
          <span className={`status-badge ${online ? 'online' : 'offline'}`}>
            <span className="status-dot" />
            {online ? 'Online' : 'Offline'}
          </span>
        </div>
        <div className="api-response">
          {data ? JSON.stringify(data, null, 2) : 'Connecting...'}
        </div>
      </div>
    )
  }

  return (
    <div className="portal">
      <header className="header">
        <h1 className="logo">
          <span className="logo-cloud">Cloud</span>{' '}
          <span className="logo-forge">Forge</span>
        </h1>
        <p className="subtitle">Plateforme multi-tenant ESN — Infrastructure as Code</p>
        <p className="school">SUP DE VINCI — Mastere DevOps 2025-2026</p>
      </header>

      <main className="main">
        <section className="section">
          <h2 className="section-title">Applications Clients</h2>
          <div className="app-grid">
            {clientApps.map(app => <AppCard key={app.name} app={app} />)}
          </div>
        </section>

        <section className="section">
          <h2 className="section-title">Monitoring</h2>
          <div className="app-grid">
            {monitoringApps.map(app => <AppCard key={app.name} app={app} />)}
          </div>
        </section>

        <section className="section">
          <h2 className="section-title">APIs Internes</h2>
          <div className="api-grid">
            <ApiCard name="Node API" lang="Express.js" data={nodeData} accent="#818cf8" />
            <ApiCard name="Flask API" lang="Python" data={flaskData} accent="#34d399" />
          </div>
        </section>

        <section className="section">
          <h2 className="section-title">Infrastructure</h2>
          <div className="infra-bar">
            <div className="infra-item">
              <div className="infra-value">2</div>
              <div className="infra-label">Nodes</div>
            </div>
            <div className="infra-item">
              <div className="infra-value">7</div>
              <div className="infra-label">Namespaces</div>
            </div>
            <div className="infra-item">
              <div className="infra-value">11</div>
              <div className="infra-label">Services</div>
            </div>
            <div className="infra-item">
              <div className="infra-value">8 GB</div>
              <div className="infra-label">RAM Total</div>
            </div>
            <div className="infra-item">
              <div className="infra-value">K8s 1.34</div>
              <div className="infra-label">Version</div>
            </div>
          </div>
        </section>

        <section className="section">
          <h2 className="section-title">Stack Technique</h2>
          <div className="stack-grid">
            {stack.map(tag => (
              <span key={tag} className="stack-tag">{tag}</span>
            ))}
          </div>
        </section>
      </main>

      <footer className="footer">
        Cloud Forge v2.0 — Deploye via GitHub Actions sur Scaleway Kapsule
        <div className="footer-tech">Terraform &middot; Kubernetes &middot; CI/CD</div>
      </footer>
    </div>
  )
}
