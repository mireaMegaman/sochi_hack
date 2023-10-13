import torch
import torchvision
from torchvision.io import read_image
import torchvision.models as models
from typing import List
import numpy as np


class Classifier:
    """
    Класс классификации лебедя на основе ранее кропнутых фотографий
    """

    def __init__(self):
        self.model = None

    def get_model_from_file(
            self,
            path_to_model: str
    ) -> torchvision.models.efficientnet.EfficientNet:
        """
        Функция, которая загружает предобученую модель из файла формата .pt
        :param path_to_model: путь до модели
        :return: модель класса EfficientNet
        """
        model = torchvision.models.efficientnet_v2_s()
        model.classifier[1] = torch.nn.Linear(1280, 3)
        model.load_state_dict(torch.load(path_to_model, map_location=torch.device('cpu')))
        model.eval()
        self.model = model
        return self

    def predict(self, path_to_image: str) -> int:
        """
        Делает предсказание модели - конкретную метку класса
        :param path_to_image: полный путь до изображения (вместе с именем файла)
        :param model: модель для предсказания
        :return: метка класса изображения
        """
        img = read_image(path_to_image)
        weights = models.EfficientNet_V2_S_Weights.IMAGENET1K_V1
        preprocess = weights.transforms()
        batch = preprocess(img).unsqueeze(0)
        prediction = self.model(batch).squeeze(0).softmax(0)
        class_id = prediction.argmax().item()
        return class_id

    def solo_object_prediction(self, path_to_image: str) -> int:
        """
        Делаем предсказание, если на вход поступает не лист обьектов, а один конкретный
        :param path_to_image: путь к фотке
        :return: метка класса
        """
        return self.predict(path_to_image) + 1

    def VoitingEnsemble(
            self,
            path_to_images: List[str]
    ) -> int:
        """
        Метод, определяющий метку класса в случае, если парсинг фотографии дал много кропов
        (на фотографии стая лебедей, например)
        :param path_to_images: лист путей к фоткам
        :return: метка класса
        """
        votes = np.array([0, 0, 0])
        for path in path_to_images:
            votes[self.predict(path)] += 1

        return votes.argmax() + 1