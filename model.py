from keras._tf_keras.keras.models import Sequential
from keras._tf_keras.keras.layers import Input, Conv2D, MaxPooling2D, Flatten, Dense, Dropout

def TslNET(input_shape=(512,512,1), output_classes=29):

    model = Sequential()

    model.add(Input(shape=input_shape))

    # First Convolutional Layer
    model.add(Conv2D(32, (3, 3), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))

    # Second Convolutional Layer
    model.add(Conv2D(64, (3, 3), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))

    # Third Convolutional Layer
    model.add(Conv2D(128, (3, 3), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))

    # Flattening Layer
    model.add(Flatten())

    # Fully Connected Layers
    model.add(Dense(128, activation='relu'))
    model.add(Dropout(0.5))  # Dropout to reduce overfitting
    model.add(Dense(output_classes, activation='softmax'))  # Output layer (number of classes)

    return model
