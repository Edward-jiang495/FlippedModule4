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

class ResetInception(BaseHandler):
    def post(self):
        print("Resetting Inception")

        #clear user images
        clear_image_dir(image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2])

        #clear user model
        clear_model_dir(model_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2])

        self.write_json({"status":"ok"})
        #train base model

class ResetXception(BaseHandler):
    def post(self):
        print("Resetting Xception")

        #clear user images
        clear_image_dir(image_dirs[ModelType.USER][PretrainType.XCEPTION])

        #clear user model
        clear_model_dir(model_dirs[ModelType.USER][PretrainType.XCEPTION])

        
        self.write_json({"status":"ok"})

class PredictInception(BaseHandler):
    def post(self):
        print("Predicting Inception")

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

        prediction = prediction.replace("_"," ").title()

        print(prediction)

        # Return Prediction
        self.write_json({"prediction":prediction})


class PredictXception(BaseHandler):
    def post(self):
        print("Predicting Xception")

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
        
        prediction = prediction.replace("_"," ").title()

        print(prediction)

        # Return Prediction
        self.write_json({"prediction":prediction})


class TrainInception(BaseHandler):
    def post(self):
        # load body
        data = json.loads(self.request.body.decode("utf-8"))
        epochs = data['epochs']

        # Load Model
        model = get_model(ModelType.USER, PretrainType.INCEPTION_RESNET_V2)

        # Train model
        history = train_user_model(model,PretrainType.INCEPTION_RESNET_V2,
                        image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2],epochs)

        # clear directory
        clear_image_dir(image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2])

        if history is None:
            self.write_json({"status":"Error","Message":"Uploading data before training"})
        else:
            self.write_json({"status":"ok","val_acc":history[1].history['val_binary_accuracy'][-1]})
        

class TrainXception(BaseHandler):
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

        if history is None:
            self.write_json({"status":"Error","Message":"Uploading data before training"})
        else:
            self.write_json({"status":"ok","val_acc":history[1].history['val_binary_accuracy'][-1]})

        

class UploadInceptionData(BaseHandler):
    def post(self):
        print("Uploading Inception Data")

        # load body
        data = json.loads(self.request.body.decode("utf-8"))
        target = data['target']
        image = data['image']
        
        #save image
        save_example_image(image,image_dirs[ModelType.USER][PretrainType.INCEPTION_RESNET_V2], target)

        self.write_json({"status":"ok"})
        

class UploadXceptionData(BaseHandler):
    def post(self):
        print("Uploading Xception data")

        # load body
        data = json.loads(self.request.body.decode("utf-8"))
        image = data['image']
        target = data['target']

        # save image
        save_example_image(image,image_dirs[ModelType.USER][PretrainType.XCEPTION],target)
        
        self.write_json({"status":"ok"})
        