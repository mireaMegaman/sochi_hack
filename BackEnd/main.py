from typing import List
import io
from time import sleep
from uuid import uuid4
import os
import base64
from zipfile import ZipFile, ZIP_DEFLATED
from shutil import rmtree
import json
from pydantic import BaseModel
from fastapi import BackgroundTasks, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from ml.sochi_ml.main import generate_proba
from ultralytics import YOLO
from PIL import Image
import torch
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
    yolo = YOLO(os.path.join('ml', 'best.pt'))
    processor = TrOCRProcessor.from_pretrained('microsoft/trocr-base-printed')
    ocr_model = VisionEncoderDecoderModel.from_pretrained('microsoft/trocr-base-stage1')


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
    rmtree(path)


def predict(base_path: str):
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
    session_id = uuid4()
    path_crops = os.path.join('sign', str(session_id))
    images = file.files
    json_ans = {"data": []}
    for i, file in enumerate(images):
        image_as_bytes = str.encode(file)  # convert string to bytes
        img_recovered = base64.b64decode(image_as_bytes)  # decode base64string
        image = Image.open(io.BytesIO(img_recovered))
        crops = yolo.predict(image)
        for el in crops:
            el.save_crop(path_crops)
        text, probabilities = predict(os.path.join(path_crops, 'sign', 'im.jpg'))
        json_ans['data'].append({'text': text, 'probabilities': probabilities})
    with open(os.path.join(path_crops, 'data.txt'), 'w') as outfile:
        json.dump(json_ans, outfile)
    background.add_task(remove_file, path_crops)
    return to_zip(path_crops)