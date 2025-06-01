from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import pandas as pd
import shutil
import os
from datetime import datetime
from backend.padim_inference import predict_image



# --- Setup ---
app = FastAPI()

# Allow frontend to communicate with backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development (you can restrict later)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Path for log file
log_file = "inspection_log.csv"

# Ensure the log file has headers
if not os.path.exists(log_file):
    df = pd.DataFrame(columns=["timestamp", "filename", "prediction"])
    df.to_csv(log_file, index=False)


def predict_defect(image_path: str) -> str:
    return predict_image(image_path)

# --- Prediction Endpoint ---
@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    try:
        temp_file_path = f"temp_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        prediction = predict_defect(temp_file_path)

        new_log = pd.DataFrame([{
            "timestamp": datetime.now().isoformat(),
            "filename": file.filename,
            "prediction": prediction
        }])
        new_log.to_csv(log_file, mode='a', header=False, index=False)

        os.remove(temp_file_path)

        return {"prediction": prediction}

    except Exception as e:
        print(f"❌ Error during prediction: {str(e)}")
        return {"error": str(e)}  # <-- Return the error as JSON



@app.get("/logs/")
async def get_logs():
    df = pd.read_csv(log_file)
    return df.to_dict(orient="records")

´
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
