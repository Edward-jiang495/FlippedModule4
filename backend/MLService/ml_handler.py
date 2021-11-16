# import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.layers import Dense, Flatten, Conv2D, MaxPooling2D, Rescaling
from enum import Enum

# model parameters
batch_size = 32
img_height = 224
img_width = 224
optimizer = keras.optimizers.Adam(learning_rate=0.0001)
num_classes = 2
images_dir = "../../images/"


class ModelType(Enum):
    CNN = 0
    MLP = 1


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
                                                                batch_size=batch_size, shuffle=True)

    test_ds = keras.preprocessing.image_dataset_from_directory(dataset_directory + "test", label_mode="binary",
                                                               image_size=(img_height, img_width),
                                                               batch_size=batch_size, shuffle=True)

    return train_ds, test_ds


def make_cnn_model() -> keras.Model:
    """
    Generates a CNN model with the following architecture:
        Input: img_height × img_width × 3
        Conv1: 16 filters, kernel size 3 × 3, stride 1, padding same
        Conv2: 32 filters, kernel size 3 × 3, stride 1, padding same
        Conv3: 64 filters, kernel size 3 × 3, stride 1, padding same
        Dense1: 128 units
        Dense2: num_classes units

    Returns:
        model: A tf.keras.Model object
    """
    model = keras.Sequential([
        Rescaling(1. / 255, input_shape=(img_height, img_width, 3)),  # normalize & rescale
        Conv2D(16, 3, padding='same', activation='relu'),
        MaxPooling2D(),
        Conv2D(32, 3, padding='same', activation='relu'),
        MaxPooling2D(),
        Conv2D(64, 3, padding='same', activation='relu'),
        MaxPooling2D(),
        Flatten(),
        Dense(128, activation='relu'),
        Dense(num_classes),
    ])

    model.compile(optimizer=optimizer, loss=keras.losses.Binarycrossentropy(from_logits=True), metrics=['accuracy'])
    return model


def make_mlp_model() -> keras.Model:
    """
    Generates a MLP model with the following architecture:
        Input: img_height × img_width × 3
        Dense1: 128 units
        Dense2: num_classes units

    Returns:
        model: A tf.keras.Model object
    """
    model = keras.Sequential([
        Rescaling(1. / 255, input_shape=(img_height, img_width, 3)),  # normalize
        Flatten(),
        Dense(128, activation='relu'),
        Dense(num_classes),
    ])

    model.compile(optimizer=optimizer, loss=keras.losses.Binarycrossentropy(from_logits=True), metrics=['accuracy'])
    return model


def train_base_model(model_type: ModelType, epochs: int = 10, dataset_directory: str = images_dir):
    model = None

    if model_type == ModelType.CNN:
        model = make_cnn_model()

    elif model_type == ModelType.MLP:
        model = make_mlp_model()

    train_ds, test_ds = get_dataset(dataset_directory)

    history = model.fit(train_ds, validation_data=test_ds, epochs=epochs)

    return model, history


def train_model():
    pass


def save_model():
    pass


def load_model():
    pass


def get_prediction():
    pass


def __main__():
    from matplotlib import pyplot as plt

    epochs = 10

    cnn_model, cnn_history = train_base_model(ModelType.CNN, epochs=epochs)

    acc = cnn_history.history['accuracy']
    val_acc = cnn_history.history['val_accuracy']

    loss = cnn_history.history['loss']
    val_loss = cnn_history.history['val_loss']

    epochs_range = range(epochs)

    plt.figure(figsize=(8, 8))
    plt.subplot(1, 2, 1)
    plt.plot(epochs_range, acc, label='Training Accuracy')
    plt.plot(epochs_range, val_acc, label='Validation Accuracy')
    plt.legend(loc='lower right')
    plt.title('Training and Validation Accuracy')

    plt.subplot(1, 2, 2)
    plt.plot(epochs_range, loss, label='Training Loss')
    plt.plot(epochs_range, val_loss, label='Validation Loss')
    plt.legend(loc='upper right')
    plt.title('Training and Validation Loss')
    plt.show()

    mlp_model, mlp_history = train_base_model(ModelType.MLP, epochs=epochs)

    acc = mlp_history.history['accuracy']
    val_acc = mlp_history.history['val_accuracy']

    loss = mlp_history.history['loss']
    val_loss = mlp_history.history['val_loss']

    epochs_range = range(epochs)

    plt.figure(figsize=(8, 8))
    plt.subplot(1, 2, 1)
    plt.plot(epochs_range, acc, label='Training Accuracy')
    plt.plot(epochs_range, val_acc, label='Validation Accuracy')
    plt.legend(loc='lower right')
    plt.title('Training and Validation Accuracy')

    plt.subplot(1, 2, 2)
    plt.plot(epochs_range, loss, label='Training Loss')
    plt.plot(epochs_range, val_loss, label='Validation Loss')
    plt.legend(loc='upper right')
    plt.title('Training and Validation Loss')
    plt.show()
