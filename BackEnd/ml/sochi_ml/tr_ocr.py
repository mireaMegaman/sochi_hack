from transformers import (
    TrOCRProcessor,
    VisionEncoderDecoderModel
)

from PIL import Image


def is_proper(number):
    transformation = lambda x: x // 10 + x % 10
    number, last_number = number[:-1], int(number[-1])
    odds = number[::2]
    evens = number[1::2]

    odds = [transformation(int(odd) * 2) for odd in odds]
    evens = [int(even) for even in evens]

    return (sum(odds) + sum(evens) + last_number) % 10 == 0

def generate_probs():
    """image = Image.open('/content/crops/sign/im11.jpg').convert("RGB")
    pixel_values = processor(images=image, return_tensors="pt").pixel_values
    generated_ids = model.generate(pixel_values.to('cuda'), output_scores=True, return_dict_in_generate=True)
    ids, scores = generated_ids['sequences'], generated_ids['scores']
    torch.max(torch.nn.functional.softmax(scores[0][0])) # вероятность
    token = processor.tokenizer.decode([4027])"""


def recognize(
        model: VisionEncoderDecoderModel,
        processor: TrOCRProcessor,
        device: str,
        image_path: str,
        generation_type: str,
        return_dict: bool,
        output_scores: bool
):
    update_model = get_config(model, processor, generation_type).to(device)
    image = Image.open(image_path).convert("RGB")
    pixel_values = processor(images=image, return_tensors="pt").pixel_values
    return_dict = update_model.generate(
        pixel_values.to(device),
        output_scores=output_scores,
        return_dict_in_generate=return_dict
    )

    if return_dict:
        ids, scores = return_dict['sequences'], return_dict['sequences_scores']
        generated_text = processor.batch_decode(ids, skip_special_tokens=True)[0]
    else:
        generated_text = processor.batch_decode(return_dict, skip_special_tokens=True)[0]

    return generated_text
