from os import makedirs, path

# dataset directories
for directory in ['truth', 'user']:
    for dataset in ['train', 'test']:
        for label in ['hot_dog', 'not_hot_dog']:
            makedirs(path.join('..', directory, dataset, label), exist_ok=True)

# model directory
makedirs(path.join('..', 'models'), exist_ok=True)
