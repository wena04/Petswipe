import firebase_admin
from firebase_admin import credentials, firestore
import json

# init Firebase
cred = credentials.Certificate("cannot share.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# load JSON data
with open("example.json", "r") as f:
    pets = json.load(f)

# upload data to Firestore
for pet in pets:
    doc_id = pet["_id"]  # use _id as Firestore document ID
    db.collection("pets").document(doc_id).set({
        "petName": pet["petName"],
        "petAge": pet["petAge"],
        "petPicture": pet["petPicture"],
        "petLocation": pet["petLocation"],
        "petBreed": pet["petBreed"]
    })

print("Upload finished")
