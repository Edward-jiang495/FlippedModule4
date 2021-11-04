# FlippedModule4

## [1 points] Part One: Run the Server

1. Run MongoDB from your mac and then run `tornado_turi_create.py` or `tornado_scikit_learn.py`
2. Look up the name or IP address of your mac (for example, using
`ifconfig | grep inet`)
3. Connect the iPhone to your server and navigate to “`(your IP):8000/Handlers`” using safari in iOS
    - If you can’t connect, create a WiFi network from your mac and try again
4. Take a screenshot from the phone and save it for uploading with the project.

## [1.5 points] Part Two: Update the App

5. In the iOS `HTTPSwiftExample`
App, change the name of the URL to point to your server
6. Update the User Interface and code so that the DSID can be selected by the user (you can use any UI element you want). That is, the code should now use the user selected DSID, rather than the default DSID.
7. Run `HTTPSwiftExample` on the iPhone and perform the calibration procedure a few times in
order to get some example data into the database, then train a model.
8. Take a quick video of the example working with a predicted feature vector. The classifier does not need to be very good.

## [2 points] Part Three: Change the Loading of the Classifier 

All of the following changes should be made in the files `turihandlers.py` (or `sklearnhandlers.py`) and, possibly, in `tornado_turi_create/scikit_learn.py` (depending on your implementation choices):

9. Setup the `.clf` property to be a dictionary. In the dictionary the key should be the DSID and the value is the turi or sklearn model. That is, when training a model, update the code to save the DSID and classifier as a key/object pair in the `.clf` dictionary. In this way, all models will be loaded into the `.clf` dictionary (not just one model). As new models are trained, they will be added to the dictionary.

10. Update the code in `PredictOneFromDatasetId` to:
    1. Change the loading of the classifier: Check if the requested DSID from the post request exists in the `.clf` dictionary. If it does not, then load the requested classifier and save it in the dictionary property as a new key/object pair. Account for any errors that might occur in loading and saving the model.
    2. Update the prediction to use the `.clf` dictionary property for predicting a label from the uploaded feature vector

## [0.5 points] For Thought

11. Is the current method of saving the classifier blocking to the tornado IOLoop? Justify your response.

12. Would the models saved on one server be useable by another server if we migrated the saved documents in MongoDB? Justify your response.

What to turn in:
- Team member names, zipped Xcode project, zipped python code, screenshots/videos, and answers to “for thought” questions (written out in complete sentences with valid justification for answers).