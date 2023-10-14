from typing import List
import io
from time import sleep
import os
import sys
sys.path.append('BackEnd\\ml')

sys.path.append('BackEnd\\ml\\sochi_ml')
from main import generate_proba
from cv2_converter import crop, draw_boxes
# from ml.sochi_ml.cv2_converter import crop, draw_boxes
# from ml.sochi_ml.main import generate_proba
from cv2 import imwrite
import base64
from zipfile import ZipFile, ZIP_DEFLATED
import json
from pydantic import BaseModel
from fastapi import BackgroundTasks, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse

from ultralytics import YOLO
from PIL import Image
import torch.nn.functional as F

from transformers import (
    TrOCRProcessor,
    VisionEncoderDecoderModel
)


yolo = None
ocr = None

app = FastAPI(title="Recognition of railway car numbers")

class Image64(BaseModel):
    files: List[str]
    files_names: List[str]

origins = [
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    # allow_methods=["GET", "POST", "OPTIONS", "DELETE", "PATCH", "PUT"],
    # allow_headers=["Content-Type", "Set-Cookie", "Access-Control-Allow-Headers", "Access-Control-Allow-Origin",
    #                "Authorization"],
    allow_methods=["*",],
    allow_headers=["*",],
)


@app.on_event("startup")
def startup_event():
    global yolo, processor, ocr_model
    yolo = YOLO(os.path.join('BackEnd', 'ml', 'best.pt'))
    # processor = TrOCRProcessor.from_pretrained('microsoft/trocr-base-printed')
    # ocr_model = VisionEncoderDecoderModel.from_pretrained('microsoft/trocr-base-stage1')
    processor = TrOCRProcessor.from_pretrained('BackEnd\\ml\\processor')
    ocr_model = VisionEncoderDecoderModel.from_pretrained('BackEnd\\ml\\tr_ocr_m')


def to_zip(path: str):
    zip_io = io.BytesIO()
    with ZipFile(zip_io, mode='w', compression=ZIP_DEFLATED) as temp_zip:
        for root, _, files in os.walk(path):
            for fileName in files:
                temp_zip.write(os.path.join(root, fileName), fileName) # первый параметр отвечает за то, какой файл выбрать, а второй, как он будет называться
                # temp_zip.write(os.path.join(root, fileName), os.path.join('response', fileName))
    return StreamingResponse(
        iter([zip_io.getvalue()]), 
        media_type="application/x-zip-compressed", 
        headers = { "Content-Disposition": f"attachment; filename=images.zip"}
    )


def remove_file(path: str) -> None:
    sleep(10)
    for f in os.listdir(path):
        os.remove(os.path.join(path, f))


def recognize(base_path: str):
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
    return generated_text, probabilities


@app.post('/get_result_64')
def main_64(file: Image64, background: BackgroundTasks):
    path_files = os.path.join('photos')
    images = file.files
    names = file.files_names
    json_ans = {"data": []}
    for i, file in enumerate(images):
        image_as_bytes = str.encode(file)  # convert string to bytes
        img_recovered = base64.b64decode(image_as_bytes)  # decode base64string
        image = Image.open(io.BytesIO(img_recovered))
        base_file_path = os.path.join(path_files, f'file-{i+1}.jpg')
        _ = image.save(base_file_path)
        results = yolo.predict(image)
        cropped_image = crop(base_file_path, results)
        imwrite(os.path.join('photos', f"cropped_image-{i+1}.jpg"), cropped_image)
        bbox_image = draw_boxes(base_file_path, results)
        imwrite(os.path.join('photos', f"boxed_image-{i+1}.jpg"), bbox_image)
        text, probabilities = recognize(os.path.join('photos', f"cropped_image-{i+1}.jpg"))
        json_ans['data'].append({'name' : names[i], 'text': text, 'probabilities': probabilities})
    with open(os.path.join(path_files, 'data.txt'), 'w') as outfile:
        json.dump(json_ans, outfile)
    background.add_task(remove_file, path_files)
    return to_zip(path_files)