import cv2
import numpy as np

def convert_one_channel(img):
    if len(img.shape) > 2:
        img = img[:, :, 0]
        return img
    else:
        return img


def pre_images(resize_shape, path):
    img = cv2.imread(path)
    resize_img = cv2.resize(img, resize_shape, interpolation=cv2.INTER_LANCZOS4)
    resize_img = np.expand_dims(resize_img, axis=-1)
    converted_img = convert_one_channel(resize_img)
    image = np.float32(converted_img / 255)
    return image