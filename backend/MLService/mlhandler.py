# import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers  # import Dense, Flatten, Conv2D, MaxPooling2D, Rescaling, RandomFlip
from enum import Enum

# model parameters
batch_size = 32
img_height = 75
img_width = 75
optimizer = keras.optimizers.Adam(learning_rate=0.0001)
num_classes = 2
base_image_directory = "../images/truth/"
user_image_directory = "../images/user/"


class ModelType(Enum):
    INCEPTION_RESNET_V2 = 0
    XCEPTION = 1


def get_dataset(dataset_directory: str) -> tuple:
    """
    Returns a tuple of (train_dataset, test_dataset)

    Args:
        dataset_directory: The directory containing train/ and test/

    Returns:
        train_dataset: A tf.data.Dataset object containing the training data
        test_dataset: A tf.data.Dataset object containing the test data

    """
    if dataset_directory[-1] != '/':
        dataset_directory += '/'

    train_ds = keras.preprocessing.image_dataset_from_directory(dataset_directory + "train", label_mode="binary",
                                                                image_size=(img_height, img_width),
                                                                batch_size=batch_size, shuffle=True,
                                                                crop_to_ascpect_ratio=True)

    test_ds = keras.preprocessing.image_dataset_from_directory(dataset_directory + "test", label_mode="binary",
                                                               image_size=(img_height, img_width),
                                                               batch_size=batch_size, shuffle=True,
                                                               crop_to_ascpect_ratio=True)

    return train_ds, test_ds


def make_pretrainable_model(model_type: ModelType) -> keras.Model:
    """
    Generates a transfer learning model from a pretrained model

    Args:
        model_type: base model to use for transfer learning

    Returns:
        model: A tf.keras.Model object
    """

    pretrained_models = {
        ModelType.INCEPTION_RESNET_V2: keras.applications.inception_resnet_v2.InceptionResNetV2,
        ModelType.XCEPTION: keras.applications.xception.Xception
    }

    pretrained_model = pretrained_models[model_type](input_shape=(img_height, img_width, 3), include_top=False)
    pretrained_model.trainable = False

    model = keras.Sequential([
        # data augmentation
        layers.RandomFlip("horizontal", input_shape=(img_height, img_width, 3)),
        layers.RandomRotation(0.1),
        layers.RandomZoom(0.1),

        # normalization
        layers.Rescaling(1. / 255, input_shape=(img_height, img_width, 3)),

        # transfer learning
        pretrained_model,
        layers.Flatten(),
        layers.Dense(1),
    ])

    model.compile(optimizer=optimizer, loss=keras.losses.BinaryCrossentropy(from_logits=True),
                  metrics=[keras.metrics.BinaryAccuracy()])
    return model


def train_base_model(model_type: ModelType, epochs: int = 10):
    model = make_pretrainable_model(model_type)
    train_ds, test_ds = get_dataset(dataset_directory)
    history = model.fit(train_ds, validation_data=test_ds, epochs=epochs)

    return model, history


def train_model(model: keras.Model, epochs: int = 10):
    train_ds, _ = get_dataset(user_image_directory)
    _, test_ds = get_dataset(base_image_directory)
    history = model.fit(train_ds, validation_data=test_ds, epochs=epochs)

    return model, history


def save_model():
    pass


def load_model():
    pass


def get_prediction():
    pass


def __main__():
    from matplotlib import pyplot as plt

    epochs = 5

    cnn_model, cnn_history = train_base_model(ModelType.XCEPTION, epochs=epochs)
    mlp_model, mlp_history = train_base_model(ModelType.INCEPTION_RESNET_V2, epochs=epochs)

    acc = mlp_history.history['binary_accuracy']
    val_acc = mlp_history.history['val_binary_accuracy']

    loss = mlp_history.history['loss']
    val_loss = mlp_history.history['val_loss']


if __name__ == '__main__':
    __main__()
