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
from ml.classiffier import Classifier
from ultralytics import YOLO
from PIL import Image


yolo = None
classifier = None

app = FastAPI(title="Recognition of railway car numbers")

class CheckText(BaseModel):
    text: str

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
    global yolo, classifier
    yolo = YOLO(os.path.join('ml', 'yolo8nano_best_model.pt'))
    # yolo.export(format='onnx') 'engine'
    classifier = Classifier()
    classifier.get_model_from_file(os.path.join('ml', 'classifier_efficient_net_95-8acc.pt'))


@app.post('/text')
def send_text(value: CheckText):
    return {'data': value}

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


@app.post('/get_result_64')
def main_64(file: Image64, background: BackgroundTasks):
    session_id = uuid4()
    path_crops = os.path.join('swans')
    images = file.files
    json_ans = {"data": []}
    for i, file in enumerate(images):
        image_as_bytes = str.encode(file)  # convert string to bytes
        img_recovered = base64.b64decode(image_as_bytes)  # decode base64string
        image = Image.open(io.BytesIO(img_recovered))
        results = yolo.predict(image)
        for el in results:
            el.save_crop(path_crops)
        predict = 'something'
        json_ans['data'].append({"file_name" : f"file_{i+1}", "pred_class" : predict})
    with open(os.path.join(path_crops, 'data.txt'), 'w') as outfile:
        json.dump(json_ans, outfile)
    background.add_task(remove_file, path_crops)
    return to_zip(path_crops)