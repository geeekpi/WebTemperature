from bottle import route, run, template, response
import random
import commands

@route('/data')
def index():
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token'
    temp = commands.getoutput('./ntc')
    return temp

run(host='localhost', port=9000)
