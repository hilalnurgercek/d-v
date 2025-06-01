import torch
import pickle
from PIL import Image
from torchvision import models, transforms as T
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'models', 'train_cable.pkl')

with open(MODEL_PATH, 'rb') as f:
    train_outputs = pickle.load(f)

# --- Load Model and Preprocessing ---
# Load pretrained ResNet18
base_model = models.resnet18(pretrained=True)

# Extract features after layer1 (output size 56x56, 64 channels)
feature_extractor = torch.nn.Sequential(
    base_model.conv1,
    base_model.bn1,
    base_model.relu,
    base_model.maxpool,
    base_model.layer1  # <- this gives [64, 56, 56]
)

# Add 1x1 conv to reduce channels to 100
reduction_layer = torch.nn.Conv2d(64, 100, kernel_size=1)

# Combine
model = torch.nn.Sequential(
    feature_extractor,
    reduction_layer
)

model.eval()

# Define preprocessing transforms
transform = T.Compose([
    T.Resize((256, 256)),
    T.CenterCrop(224),
    T.ToTensor(),
    T.Normalize(mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225])
])

# Load precomputed mean and covariance for "bottle"
with open(MODEL_PATH, 'rb') as f:
    train_outputs = pickle.load(f)

mean = torch.tensor(train_outputs[0])
cov = torch.tensor(train_outputs[1])

# Fix shapes
mean = mean.view(100, 56, 56)
cov = cov.view(100, 100, 56, 56)

# Precompute inverse covariance matrix
inv_cov = []
for h in range(mean.shape[1]):
    for w in range(mean.shape[2]):
        cov_matrix = cov[:, :, h, w]
        inv_cov.append(torch.linalg.pinv(cov_matrix))  # Pseudo-inverse
inv_cov = torch.stack(inv_cov).reshape(mean.shape[1], mean.shape[2], mean.shape[0], mean.shape[0])

# --- Predict Function ---
def predict_image(image_path: str) -> str:
    img = Image.open(image_path).convert('RGB')
    x = transform(img).unsqueeze(0)  # Add batch dimension

    with torch.no_grad():
        features = model(x).squeeze(0)  # [C, H, W]

    # Reshape
    features = features.permute(1, 2, 0)  # [H, W, C]
    mean_perm = mean.permute(1, 2, 0)     # [H, W, C]

    delta = features - mean_perm  # [H, W, C]
    dist_list = []

    for h in range(delta.shape[0]):
        for w in range(delta.shape[1]):
            diff = delta[h, w]
            inv = inv_cov[h, w]
            dist = torch.sqrt(torch.matmul(torch.matmul(diff, inv), diff))
            dist_list.append(dist)

    dist_list = torch.stack(dist_list).reshape(56, 56)

    anomaly_score = dist_list.max().item()


    # --- Simple Threshold ---
    threshold = 60.0  # <-- Adjust based on your dataset
    print("Anomaly Score:", anomaly_score)
    if anomaly_score > threshold:
        return "Defect detected ❌"
    else:
        return "No defects detected ✅"
