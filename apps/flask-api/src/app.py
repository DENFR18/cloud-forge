from flask import Flask, jsonify
import platform
import time

app = Flask(__name__)
START_TIME = time.time()

@app.route('/')
def index():
    return jsonify({
        'service': 'Cloud Forge — Flask API',
        'version': '1.0.0',
        'status': 'running'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'ok'})

@app.route('/info')
def info():
    return jsonify({
        'runtime': f'Python {platform.python_version()}',
        'platform': platform.system(),
        'uptime_seconds': round(time.time() - START_TIME, 2)
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
