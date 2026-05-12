from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics
import random

app = Flask(__name__)
metrics = PrometheusMetrics(app) 

facts = [
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum imperdiet diam purus, eu varius velit porttitor non. Vestibulum ornare blandit ex, ut convallis velit interdum ut. Fusce augue justo, dignissim non mi ut, fermentum maximus dolor. Phasellus purus orci, fermentum eu tincidunt eget, eleifend nec dolor. Nam lobortis mauris tortor, in accumsan neque porta auctor. Integer elementum ornare eros, in consequat velit interdum vel. Duis euismod augue molestie ex dictum, in facilisis tortor pellentesque. Nam sagittis eu dui eget eleifend. Morbi tempus leo lacus, eu molestie magna semper sed. Interdum et malesuada fames ac ante ipsum primis in faucibus.  Sed nec elit ligula. Pellentesque pretium urna eu posuere sollicitudin. Vestibulum id maximus diam. Curabitur mollis nisl metus, in vestibulum dui volutpat vitae. Cras     consectetur laoreet semper. Nam eget eleifend diam, non aliquet purus. Quisque enim risus, faucibus ut nisi ac, fermentum vehicula est. Integer vitae tristique felis. Integer elementum ac risus eu dapibus. Fusce dignissim ex leo, eu gravida metus auctor sed."
]

@app.route("/")
def home():
    return jsonify({"status": "ok", "message": "DevOps Portfolio App"})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/fact")
def fact():
    return jsonify({"fact": random.choice(facts)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)