from os import makedirs, path
from os.path import dirname, abspath
from enum import Enum


class PretrainType(Enum):
    INCEPTION_RESNET_V2 = 0
    XCEPTION = 1


class ModelType(Enum):
    BASE = 0
    USER = 1


parent = dirname(dirname(abspath(__file__)))

model_dirs = {
    ModelType.BASE: {
        PretrainType.INCEPTION_RESNET_V2: path.join(parent, 'models', 'base', 'inception_resnetv2'),
        PretrainType.XCEPTION: path.join(parent, 'models', 'base', 'xception')
    },
    ModelType.USER: {
        PretrainType.INCEPTION_RESNET_V2: path.join(parent, 'models', 'user', 'inception_resnetv2'),
        PretrainType.XCEPTION: path.join(parent, 'models', 'user', 'xception')
    },
}

image_dirs = {
    ModelType.BASE: {
        'train': path.join(parent, 'images', 'base', 'train'),
        'test': path.join(parent, 'images', 'base', 'test'),
    },
    ModelType.USER: {
        PretrainType.INCEPTION_RESNET_V2: path.join(parent, 'images', 'user', 'inception_resnetv2', 'train'),
        PretrainType.XCEPTION: path.join(parent, 'images', 'user', 'xception', 'train'),
    },
}

for _, directory in image_dirs.items():
    for _, sub_directory in directory.items():
        makedirs(sub_directory, exist_ok=True)

for _, directory in model_dirs.items():
    for _, sub_directory in directory.items():
        makedirs(sub_directory, exist_ok=True)
