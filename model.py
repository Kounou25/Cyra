import os
import urllib.request
import cv2

# Dossier pour stocker les modèles
model_dir = "models"
os.makedirs(model_dir, exist_ok=True)

# URLs des fichiers
prototxt_url = "https://raw.githubusercontent.com/opencv/opencv/master/samples/dnn/face_detector/deploy.prototxt"
caffemodel_url = "https://raw.githubusercontent.com/opencv/opencv_3rdparty/dnn_samples_face_detector_20170830/res10_300x300_ssd_iter_140000.caffemodel"

# Chemins locaux
prototxt_path = os.path.join(model_dir, "deploy.prototxt")
caffemodel_path = os.path.join(model_dir, "res10_300x300_ssd_iter_140000.caffemodel")

# Télécharger si nécessaire
if not os.path.exists(prototxt_path):
    print("Téléchargement de deploy.prototxt ...")
    urllib.request.urlretrieve(prototxt_url, prototxt_path)

if not os.path.exists(caffemodel_path):
    print("Téléchargement de res10_300x300_ssd_iter_140000.caffemodel ...")
    urllib.request.urlretrieve(caffemodel_url, caffemodel_path)

# Charger le modèle DNN
net = cv2.dnn.readNetFromCaffe(prototxt_path, caffemodel_path)
print("Modèle chargé avec succès !")
