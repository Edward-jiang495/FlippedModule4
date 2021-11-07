# FlippedModule4

## Part 1

![](images/Part1.png)

## Part 2

-- insert video --

## Questions for Thought

> 1. Is the current method of saving the classifier blocking to the tornado IOLoop? Justify your response.

Yes, because `model.save('../models/turi_model_dsid%d'%(dsid))` is getting called from the `get()` function, so tornado must wait for the model to be saved before completing the call in IOLoop (IOLoop will wait until the get() call is complete before handling the next request).

> 2. Would the models saved on one server be useable by another server if we migrated the saved documents in MongoDB? Justify your response.

Yes, provided the server is using the same version of turicreate and can run `turicreate.load_model('path/to/model')`