import traceback
from flask import Flask, jsonify, request

from .remove_node_pool import removeNodePool
from .create_node_pool import createNodePool

app = Flask(__name__)

@app.route('/', methods=['POST', 'DELETE'])
def index():
    try:
        if request.method == 'POST':
            createNodePool()
        else:
            removeNodePool()
        return '', 200
    except Exception as err:
        print(err)
        traceback.print_exc()
        raise err

@app.errorhandler(Exception)
def handle_all_error(error):
    error_code = getattr(error, 'code', 500)
    error_message = getattr(error, 'name', 'InternalServerError')
    return jsonify({'message': error_message}), error_code
