import os
import base64
from datetime import datetime

def clear_image_dir(dir):
    # clear hotdog images
    hot_dog_dir = dir + "/hot_dog"
    for f in os.listdir(hot_dog_dir):
        os.remove(os.path.join(hot_dog_dir, f))

    # clear not hotdog images
    not_hot_dog_dir = dir + "/not_hot_dog"
    for f in os.listdir(not_hot_dog_dir):
        os.remove(os.path.join(not_hot_dog_dir, f))

def clear_model_dir(dir):
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))

def save_example_image(img_str,dir,hot_dog):
    imgdata = base64.b64decode(img_str)

    hot_dog_path = "hot_dog"
    if not hot_dog:
        hot_dog_path = "not_hot_dog"

    filename = datetime.now().strftime('%m_%d_%Y-%H:%M:%S') + '.jpg'
    path = f'{dir}/{hot_dog_path}/{filename}'
    
    with open(path, 'wb') as f:
            f.write(imgdata)

    return path

def temp_save_image(img_str):
    imgdata = base64.b64decode(img_str)
    filename = datetime.now().strftime('%m_%d_%Y-%H:%M:%S') + '.jpg'
    with open(filename, 'wb') as f:
            f.write(imgdata)

    return filename


def delete_image(path):
    os.remove(path)