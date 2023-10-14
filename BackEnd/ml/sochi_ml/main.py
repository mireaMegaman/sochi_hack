import torch
import torch.nn.functional as F

from transformers import (
    TrOCRProcessor,
    VisionEncoderDecoderModel
)

from pathlib import Path
from PIL import Image


def generate_proba(scores, tokens, processor):
    tok2prob = {}
    for token, proba in zip(tokens[0][1:-1], scores[:-1]):
        tok2prob[processor.tokenizer.decode([token])] = round(torch.max(F.softmax(proba[0])).item(), 3)

    return tok2prob


if __name__ == '__main__':
    base_path = Path("./image")  # вот тут меняй как хочешь

    processor = TrOCRProcessor.from_pretrained('./tr_ocr_m')
    ocr_model = VisionEncoderDecoderModel.from_pretrained('./processor')

    image = Image.open(base_path).convert("RGB")
    pixel_values = processor(images=image, return_tensors="pt").pixel_values
    generated_ids = ocr_model.generate(
        pixel_values,
        output_scores=True,
        return_dict_in_generate=True
    )
    ids, scores = generated_ids['sequences'], generated_ids['scores']
    generated_text = processor.batch_decode(ids, skip_special_tokens=True)[0] # лейбл
    probabilities = generate_proba(scores, ids, processor) # вероятности
