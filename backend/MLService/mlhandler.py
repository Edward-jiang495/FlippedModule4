import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

from backend.MLService import *

# model parameters
batch_size = 32
img_height = 128
img_width = 128
optimizer = keras.optimizers.Adam(learning_rate=0.0001)
num_classes = 2
compile_options = {
    "optimizer": optimizer,
    "loss": keras.losses.BinaryCrossentropy(from_logits=True),
    "metrics": [keras.metrics.BinaryAccuracy()],
}
class_names = None


def get_dataset_from_dir(images_dir: path) -> tf.data.Dataset:
    ds = keras.preprocessing.image_dataset_from_directory(images_dir,
                                                          label_mode="binary",
                                                          image_size=(img_height, img_width),
                                                          batch_size=batch_size,
                                                          shuffle=True,
                                                          crop_to_aspect_ratio=False)

    if class_names is None:
        class_names = ds.class_names

    return ds


def get_dataset_from_types(model_type: ModelType, pretrain_type: PretrainType) -> tuple:
    train_dir = None

    if model_type == ModelType.BASE:
        train_dir = image_dirs[model_type]['train']
    elif model_type == ModelType.USER:
        train_dir = image_dirs[model_type][pretrain_type]

    train_ds = get_dataset_from_dir(train_dir)
    test_ds = get_dataset_from_dir(image_dirs[ModelType.BASE]['test'])

    return train_ds, test_ds


def make_pretrainable_model(pretrain_type: PretrainType) -> keras.Model:
    """
    Generates a transfer learning model from a pretrained model

    Args:
        pretrain_type: base model to use for transfer learning

    Returns:
        model: A tf.keras.Model object
    """

    pretrained_models = {
        PretrainType.INCEPTION_RESNET_V2: keras.applications.inception_resnet_v2.InceptionResNetV2,
        PretrainType.XCEPTION: keras.applications.xception.Xception
    }

    pretrained_model = pretrained_models[pretrain_type](input_shape=(img_height, img_width, 3), include_top=False)
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
        layers.Dense(num_classes),
    ])

    model.compile(**compile_options)
    return model


def save_model(model: keras.Model, directory: path) -> None:
    model_json = model.to_json()
    with open(path.join(directory, "model.json"), "w") as json_file:
        json_file.write(model_json)

    model.save_weights(path.join(directory, "weights.h5"))


def load_model(directory: path) -> keras.Model:
    if not path.exists(path.join(directory, "model.json")) or not path.exists(path.join(directory, "weights.h5")):
        print(f"Model not found in {directory}")
        return None
    else:
        with open(path.join(directory, "model.json"), "r") as json_file:
            model = keras.models.model_from_json(json_file.read())
            model.load_weights(path.join(directory, "weights.h5"))
            model.compile(**compile_options)

            return model


def get_base_model(pretrain_type: PretrainType) -> keras.Model:
    model = load_model(model_dirs[ModelType.BASE][pretrain_type])

    if model is not None:
        print("Using cached base model")

        return model
    else:
        print("Training new base model")

        model = make_pretrainable_model(pretrain_type)
        train_ds, test_ds = get_dataset_from_types(ModelType.BASE, pretrain_type)

        model.fit(train_ds, validation_data=test_ds, epochs=10)

        print("Saving new base model")
        save_model(model, model_dirs[ModelType.BASE][pretrain_type])

        return model


def get_user_model(pretrain_type: PretrainType):
    model = load_model(model_dirs[ModelType.USER][pretrain_type])

    if model is not None:
        print("Using cached user model")

        return model
    else:
        print("Using new base model")
        model = get_base_model(pretrain_type)

        print("Saving new user model")
        save_model(model, model_dirs[ModelType.USER][pretrain_type])

        return model


def get_model(model_type: ModelType, pretrain_type: PretrainType) -> keras.Model:
    if model_type == ModelType.BASE:
        return get_base_model(pretrain_type)
    elif model_type == ModelType.USER:
        return get_user_model(pretrain_type)
    else:
        raise ValueError("Invalid model type")


def train_user_model(model: keras.Model, pretrain_type: PretrainType, images: path, epochs=5) -> tuple:
    train_ds = get_dataset_from_dir(images)
    test_ds = get_dataset_from_dir(image_dirs[ModelType.BASE]['test'])

    history = model.fit(train_ds, validation_data=test_ds, epochs=epochs)

    print("Saving updated user model")
    save_model(model, model_dirs[ModelType.USER][pretrain_type])

    return model, history


def get_prediction(model: keras.Model, image_path: path) -> float:
    img = keras.utils.load_img(image_path, target_size=(img_height, img_width))
    img_array = keras.utils.img_to_array(img)
    img_array = tf.expand_dims(img_array, 0)

    predictions = model.predict(img_array)
    score = tf.nn.softmax(predictions[0])
    return class_names[np.argmax(score)]


def __main__():
    model = get_model(ModelType.USER, PretrainType.INCEPTION_RESNET_V2)
    # train_model(model, image_dirs[ModelType.USER]['train'])

    print(get_prediction(model, path.join(image_dirs[ModelType.BASE]['train'], 'hot_dog', '2417.jpg')))


if __name__ == '__main__':
    __main__()
