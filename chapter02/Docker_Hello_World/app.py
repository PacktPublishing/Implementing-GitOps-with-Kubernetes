from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!\n'

@app.route('/name/<name>')
def hello_name(name):
    return 'Hello, {}\n'.format(name)

@app.route('/datetime')
def datetime():
    import datetime
    now = datetime.datetime.now()
    return now.strftime("%Y-%m-%d %H:%M:%S\n")

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)

