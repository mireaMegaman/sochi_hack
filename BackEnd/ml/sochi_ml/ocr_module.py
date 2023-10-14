import torch
import torch.nn.functional as F

from transformers import (
    TrOCRProcessor,
    VisionEncoderDecoderModel
)

from ultralytics import YOLO
from pathlib import Path
from PIL import Image

import warnings

warnings.filterwarnings('ignore')


def generate_proba(scores, tokens, processor):
    tok2prob = {}
    for token, proba in zip(tokens[0][1:-1], scores[:-1]):
        tok2prob[processor.tokenizer.decode([token])] = round(torch.max(F.softmax(proba[0])).item(), 3)

    return tok2prob


def is_proper(number: str) -> bool:
    """
    Checker for train's numbers
    :param number: recognized numver
    :return: bool, is number correct
    """
    transformation = lambda x: x // 10 + x % 10
    number, last_number = number[:-1], int(number[-1])
    odds = number[::2]
    evens = number[1::2]

    odds = [transformation(int(odd) * 2) for odd in odds]
    evens = [int(even) for even in evens]

    return (sum(odds) + sum(evens) + last_number) % 10 == 0


def recognize(path: str):
    base_path = Path(path)

    processor = TrOCRProcessor.from_pretrained('./processor')
    ocr_model = VisionEncoderDecoderModel.from_pretrained('./tr_ocr_m')

    image = Image.open(base_path).convert("RGB")
    pixel_values = processor(images=image, return_tensors="pt").pixel_values
    generated_ids = ocr_model.generate(
        pixel_values,
        output_scores=True,
        return_dict_in_generate=True
    )
    ids, scores = generated_ids['sequences'], generated_ids['scores']
    generated_text = processor.batch_decode(ids, skip_special_tokens=True)[0]  # лейбл
    probabilities = generate_proba(scores, ids, processor)  # вероятности

    is_correct = is_proper(generated_text)
    return probabilities, generated_text, is_correct
