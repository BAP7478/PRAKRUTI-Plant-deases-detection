# Understanding the Confusion Matrix for Disease Classification

This document explains what a confusion matrix is, how to interpret it in the context of the PRAKRUTI project, and provides the Python code to generate one once a model is trained.

---

### 1. What is a Confusion Matrix?

A confusion matrix is a table used to evaluate the performance of a classification model. It shows you where the model is getting things right and where it's getting them wrong (i.e., where it's "confused").

The matrix compares the **Actual (True) Labels** of your test data against the **Predicted Labels** made by the model.

#### Key Terms:
*   **True Positive (TP):** The model correctly predicted a positive class.
    *   *Example:* The plant actually has 'Rust', and the model correctly predicts 'Rust'.
*   **True Negative (TN):** The model correctly predicted a negative class.
    *   *Example:* The plant is 'Healthy', and the model correctly predicts 'Healthy'.
*   **False Positive (FP) - Type I Error:** The model incorrectly predicted a positive class.
    *   *Example:* The plant is 'Healthy', but the model incorrectly predicts 'Rust'. (This could cause a farmer to apply unnecessary pesticides).
*   **False Negative (FN) - Type II Error:** The model incorrectly predicted a negative class.
    *   *Example:* The plant actually has 'Rust', but the model incorrectly predicts 'Healthy'. (This is very dangerous as the disease could spread untreated).

---

### 2. Sample Confusion Matrix

Let's imagine we have a model that classifies three conditions: **Healthy**, **Rust**, and **Blight**. We test it on 100 images.

Here is a sample confusion matrix:

|                    | **Predicted: Healthy** | **Predicted: Rust** | **Predicted: Blight** |
| ------------------ | :--------------------: | :-----------------: | :-------------------: |
| **Actual: Healthy**|           30 (TP)          |        2 (FP)       |        1 (FP)         |
| **Actual: Rust**   |        3 (FN)          |       25 (TP)       |        2 (FN)         |
| **Actual: Blight** |        1 (FN)          |        1 (FN)       |       35 (TP)         |

#### How to Interpret This Sample Matrix:

*   **Healthy Plants:**
    *   **30** were correctly identified as Healthy.
    *   **3** were misclassified (2 as Rust, 1 as Blight).
*   **Rust Diseased Plants:**
    *   **25** were correctly identified as Rust.
    *   **5** were misclassified (3 as Healthy, 2 as Blight). This is a high number of False Negatives, which is a concern.
*   **Blight Diseased Plants:**
    *   **35** were correctly identified as Blight.
    *   **2** were misclassified (1 as Healthy, 1 as Rust).

**Overall Accuracy:** The number of correct predictions (diagonal) divided by the total number of predictions.
*   Accuracy = (30 + 25 + 35) / 100 = 90 / 100 = **90%**

---

### 3. How to Generate a Confusion Matrix in Python

Once you have a trained model and a test dataset, you can use libraries like `scikit-learn` and `seaborn` to generate and visualize a confusion matrix.

First, you'll need to install the necessary libraries:
```bash
pip install scikit-learn seaborn matplotlib pandas
```

Here is the Python code you would use:

```python
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# --- 1. Load your trained model and test data ---

# Load the model you saved after training
# model = load_model('path/to/your/trained_model.h5')

# Define your class labels in the correct order
class_labels = ['Healthy', 'Rust', 'Blight'] # Example labels

# Use ImageDataGenerator to load your test images
# Make sure the path points to your test dataset directory
test_datagen = ImageDataGenerator(rescale=1./255)
test_generator = test_datagen.flow_from_directory(
    'path/to/your/test_data_folder',
    target_size=(224, 224), # Must match your model's input size
    batch_size=32,
    class_mode='categorical',
    shuffle=False  # IMPORTANT: Do not shuffle to keep labels in order
)

# --- 2. Make Predictions on the Test Data ---

# Get the true labels from the generator
y_true = test_generator.classes

# Get the predicted probabilities for each class
# y_pred_probs = model.predict(test_generator)

# Convert probabilities to class indices
# y_pred = np.argmax(y_pred_probs, axis=1)

# NOTE: Since we don't have a real model, we will generate FAKE data for demonstration
# In your real code, you will use the commented-out lines above.
print("NOTE: Generating a FAKE confusion matrix for demonstration purposes.")
np.random.seed(42)
y_true = np.random.randint(0, 3, size=100)
y_pred = y_true.copy()
# Introduce some errors
for i in range(15):
    y_pred[np.random.randint(0, 100)] = np.random.randint(0, 3)


# --- 3. Generate and Plot the Confusion Matrix ---

# Create the confusion matrix
cm = confusion_matrix(y_true, y_pred)

# Plot the confusion matrix using Seaborn
plt.figure(figsize=(10, 8))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=class_labels,
            yticklabels=class_labels)

plt.title('Confusion Matrix')
plt.ylabel('Actual Label')
plt.xlabel('Predicted Label')
plt.show()

# You can also print a classification report for more metrics
from sklearn.metrics import classification_report
print("\nClassification Report:\n")
print(classification_report(y_true, y_pred, target_names=class_labels))

```

This script provides a complete template. When you have your trained model, you just need to update the file paths and uncomment the `model.predict` line to get a real evaluation of your model's performance.
