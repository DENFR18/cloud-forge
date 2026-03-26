const express = require('express')
const app = express()
const PORT = process.env.PORT || 3000

app.use(express.json())

app.get('/', (req, res) => {
  res.json({
    service: 'Cloud Forge — Node API',
    version: '1.0.0',
    status: 'running',
    timestamp: new Date().toISOString()
  })
})

app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})

app.get('/info', (req, res) => {
  res.json({
    runtime: 'Node.js ' + process.version,
    platform: process.platform,
    uptime: process.uptime(),
    memory: process.memoryUsage()
  })
})

app.listen(PORT, () => {
  console.log(`Node API running on port ${PORT}`)
})
