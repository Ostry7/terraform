from flask import Flask, jsonify
import random

app = Flask(__name__)

facts = [
    "Totally new app code ;>"
    "ONLY ONE FACT!",
    #"NEW FACT!!",
    #"Kubernetes means 'helmsman' in Greek.",
    #"Docker was released in 2013.",
    #"Terraform is written in Go.",
    #"Azure has over 60 regions worldwide.",
    #"The first Linux kernel was released in 1991.",
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