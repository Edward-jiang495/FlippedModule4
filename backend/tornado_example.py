#!/usr/bin/python
'''Starts and runs the tornado with BaseHandler '''

# database imports
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError

# tornado imports
import tornado.web
from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from MLService.mlhandler import get_model
from MLService import *

# custom imports
from basehandler import BaseHandler
import examplehandlers as eh

# Setup information for tornado class
define("port", default=8000,
       help="run on the given port", type=int)


class Application(tornado.web.Application):
    """
    Utility to be used when creating the Tornado server
    Contains the handlers and the database connection
    """

    def __init__(self):
        """
        Store necessary handlers,
        connect to database
        """

        handlers = [(r"/[/]?", BaseHandler),  # raise 404
                    (r"/Inception/reset[/]?", eh.ResetInception),  # needs nginx running to work
                    (r"/Xception/reset[/]?", eh.ResetXception),  # needs nginx running to work
                    (r"/Inception/train[/]?", eh.TrainInception),  # needs nginx running to work
                    (r"/Xception/train[/]?", eh.TrainXception),  # needs nginx running to work
                    (r"/Inception/predict[/]?", eh.PredictInception),  # needs nginx running to work
                    (r"/Xception/predict[/]?", eh.PredictXception),  # needs nginx running to work
                    (r"/Inception/UploadImage[/]?", eh.UploadInceptionData),  # needs nginx running to work
                    (r"/Xception/UploadImage[/]?", eh.UploadXceptionData),  # needs nginx running to work
                    ]

        try:
            self.client = MongoClient(serverSelectionTimeoutMS=5)  # local host, default port
            print(
                self.client.server_info())  # force pymongo to look for possible running servers, error if none running
            # if we get here, at least one instance of pymongo is running
            self.db = self.client.exampledatabase  # database with labeledinstances, models
            # handlers.append((r"/SaveToDatabase[/]?",eh.LogToDatabaseHandler)) # add new handler for database

        except ServerSelectionTimeoutError as inst:
            print('\033[1m' + 'Could not initialize database connection, skipping, Error Details:' + '\033[0m')
            print(inst)
            print('=================================')

        settings = {'debug': True}
        tornado.web.Application.__init__(self, handlers, **settings)

    def __exit__(self):
        self.client.close()


def main():
    """
    Create server, begin IOLoop
    """

    tornado.options.parse_command_line()
    http_server = HTTPServer(Application(), xheaders=True)
    http_server.listen(options.port)
    get_model(ModelType.USER, PretrainType.XCEPTION)
    get_model(ModelType.USER, PretrainType.INCEPTION_RESNET_V2)
    IOLoop.instance().start()


if __name__ == "__main__":
    main()
