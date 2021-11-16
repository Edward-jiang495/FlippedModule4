#!/usr/bin/python

import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from MLService.mlhandler import ModelType, get_model, get_prediction, train_user_model

from basehandler import BaseHandler
import base64
import time
import json
import pdb
from datetime import datetime
import os
from MLService.filehandler import *
from MLService import *

# class MSLC(BaseHandler):
#     def get(self):
#         self.write('''
#             <!DOCTYPE html>
#             <html>
#             <head>
#             <link href="data:image/x-icon;base64,AAABAAEAEBAAAAEACABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAc7XOAJzGzgB7tdYAISkxAHO1xgB7tc4AhLXWAPf3/wAhKSkASnuUAHu1xgCEtc4AWq3WAIS1xgCMtc4AY63WABAYEABrrb0AY63OABghOQDW7+8Aa63OADFzpQBrrcYAUpy9AHOtzgBKnM4A5+/3ADlzpQBCc5QASqXWALXe5wBKnMYAc63GAFqcvQAYISEAvd7nAHutxgBSnMYAnNbeACEhIQBSpc4AQkpSAKXW3gBSpcYAY6W9AFqlzgCc1ucAWqXGAMbn5wBClL0Aa6W9ANbn9wApOTkAa5ytAGultQA5lMYASpS9AHOlvQApOUoAa3NzAEqUtQBrpcYAe5ytAIScnABSlLUAlM7eAIzO7wAxQkoAWpS1AJzO3gBzvd4AnM7WAHu93gA5jL0Apc7eAHu91gCczucApc7WAIS93gApMTkAMVprAIS91gD3//8Arc7WAEKMtQCUpaUAhL3OAIy91gD///8AOVqEAHOUpQCMxt4AjL3OAEqMrQBjtdYAa7XeAITG5wCUvc4AMXu1AEpjcwBrtdYAlMbWAJS9xgBrtc4AlMbOAJzG1gBztdYAlMbnADGEtQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATihYFkJCRgsOJgVYWWMGAAhdAWkaGC4uLiIiMTEBBgBaXVkBIiI0DF4mNC1kJxMAWkdZJhIYIiImYyYnM24hAAgsZUUJPDciD14MBjMzLwAVSVErXDg7DgsLDAwZOlAAJVUkKVdoagJPa14mPzE1AFQgJBFBQ1NdXk9MZ1MNWgBaMkpKUEgKK0BnAwYqKloAWjBHNmFsRj1SMS8TS2BaAFptRARNM1lTJy8QG2QIWgBaWmJhXRMjNCMtVhQ+WloAWlocEEoTOSoQbh1bW1RaAFpaWlofZDVUWloxXx5UWgBaWlpaZgdaWlpaWhYXWloAWlpaWmFaWlpaWlpaHFpaAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAA=" rel="icon" type="image/x-icon" />
#             </head>
#             <body>

#             <h1>Database Queries</h1>


#             ''')
#         # now we can display the queries
#         # as HTML
#         for f in self.db.queries.find():
#             f['time'] = datetime.fromtimestamp(f['time']).strftime('%c')
#             if f['arg'] not in ['sleep','death']:
#                 self.write('<p style="color:blue">'+str(f)+'</p>')

#         self.write('''
#             </body>
#             </html>
#             ''')

# class TestHandler(BaseHandler):
#     def get(self):
#         '''Write out to screen
#         '''
#         self.write("Test of Hello World")

# class PostHandlerAsGetArguments(BaseHandler):
#     def post(self):
#         ''' If a post request at the specified URL
#         Respond with arg1 and arg1*4
#         '''
#         arg1 = self.get_float_arg("arg1",default=1.0)
#         self.write_json({"arg1":arg1,"arg2":4*arg1})

#     def get(self):
#         '''respond with arg1*2
#         '''
#         arg1 = self.get_float_arg("arg1",default=3.0);
#         # self.write("Get from Post Handler? " + str(arg1*2));
#         self.write("Hope Coronavirus is over! "+str(arg1)+"\n")
#         self.write_json({"arg1":arg1,"arg2":2*arg1})

# class JSONPostHandler(BaseHandler):
#     def post(self):
#         '''Respond with arg1 and arg1*4
#         '''
#         #print(self.request.body.decode("utf-8"))
#         data = json.loads(self.request.body.decode("utf-8"))
#         print(data)
#         self.write_json({"arg1":data['arg'][0]*2,
#             "arg2":data['arg'],
#             "arg3":[32,4.5,"Eric Rocks!"]})


# class LogToDatabaseHandler(BaseHandler):
#     def get(self):
#         '''log query to database
#         '''
#         #pdb.set_trace() # to stop here and inspect
        
#         vals = self.get_argument("arg")
#         t = time.time()
#         ip = self.request.remote_ip
#         dbid = self.db.queries.insert(
#             {"arg":vals,"time":t,"remote_ip":ip}
#             )
#         self.write_json({"id":str(dbid)})


class ResetCNN(BaseHandler):
    def post(self):
        print("Resetting CNN")

        #clear user images
        clear_image_dir(image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2])

        #clear user model
        clear_model_dir(model_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2])

        self.write_json({"status":"ok"})
        #train base model

class ResetMLP(BaseHandler):
    def post(self):
        print("Resetting MLP")

        #clear user images
        clear_image_dir(image_dirs[ModelType.USER][PretrainType.XCEPTION])

        #clear user model
        clear_model_dir(model_dirs[ModelType.USER][PretrainType.XCEPTION])

        
        self.write_json({"status":"ok"})

class PredictCNN(BaseHandler):
    def post(self):
        print("Predicting CNN")

        # Load body
        data = json.loads(self.request.body.decode("utf-8"))
        image = data['image']

        # Temp Save Image
        temp_image_path = temp_save_image(image)

        # Load Model
        model = get_model(ModelType.USER, PretrainType.INCEPTION_RESNET_V2)

        # Predict
        prediction = get_prediction(model, temp_image_path)


        # Delete Image
        delete_image(temp_image_path)

        # Return Prediction
        self.write_json({"prediction":prediction})


class PredictMLP(BaseHandler):
    def post(self):
        print("Predicting MLP")

        # Load body
        data = json.loads(self.request.body.decode("utf-8"))
        image = data['image']

        # Temp Save Image
        temp_image_path = temp_save_image(image)

        # Load Model
        model = get_model(ModelType.USER, PretrainType.XCEPTION)

        # Predict
        prediction = get_prediction(model, temp_image_path)

        # Delete Image
        delete_image(temp_image_path)
        
        # Return Prediction
        self.write_json({"prediction":prediction})


class TrainCNN(BaseHandler):
    def post(self):
        # load body
        data = json.loads(self.request.body.decode("utf-8"))
        epochs = data['epochs']

        # Load Model
        model = get_model(ModelType.USER, PretrainType.INCEPTION_RESNET_V2)

        self.write_json({"status":"ok"})

        # Train model
        history = train_user_model(model,PretrainType.INCEPTION_RESNET_V2,
                        image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2],epochs)

        # clear directory
        clear_image_dir(image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2])

        self.write_json({"status":"ok","val_acc":history.history['val_acc'][-1]})
        

class TrainMLP(BaseHandler):
    def post(self):
        # load body
        data = json.loads(self.request.body.decode("utf-8"))
        epochs = data['epochs']

        # Load Model
        model = get_model(ModelType.USER, PretrainType.XCEPTION)

        # Train model
        history = train_user_model(model,PretrainType.XCEPTION,
                        image_dirs[ModelType.USER][PretrainType.XCEPTION],epochs)

        # clear directory
        clear_image_dir(image_dirs[ModelType.USER][PretrainType.XCEPTION])

        self.write_json({"status":"ok","val_acc":history.history['val_acc'][-1]})

        

class UploadCNNData(BaseHandler):
    def post(self):
        print("Uploading CNN Data")

        # load body
        data = json.loads(self.request.body.decode("utf-8"))
        target = data['target']
        image = data['image']
        
        #save image
        save_example_image(image,image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2], target)

        self.write_json({"status":"ok"})
        

class UploadMLPData(BaseHandler):
    def post(self):
        print("Uploading MLP data")

        # load body
        data = json.loads(self.request.body.decode("utf-8"))
        image = data['image']
        target = data['target']

        # save image
        save_example_image(image,image_dirs[ModelType.USER][PretrainType.XCEPTION],target)
        
        self.write_json({"status":"ok"})
        