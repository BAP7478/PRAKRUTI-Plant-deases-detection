import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, classification_report
# We are not using a real model, so these are commented out
# from tensorflow.keras.models import load_model
# from tensorflow.keras.preprocessing.image import ImageDataGenerator

# --- 1. Define Labels and Generate FAKE Data ---

# Define your class labels in the correct order
class_labels = ['Healthy', 'Rust', 'Blight'] # Example labels

# NOTE: Since we don't have a real model, we will generate FAKE data for demonstration.
# In your real code, you would load a model and a test dataset.
print("NOTE: Generating a FAKE confusion matrix for demonstration purposes.")
np.random.seed(42)
# Imagine we have 100 test images
y_true = np.random.randint(0, 3, size=100) # The actual, true labels
y_pred = y_true.copy() # The model's predicted labels

# Let's introduce some random errors to make the matrix interesting
# This simulates a model that is not 100% accurate
for i in range(15): # Let's say the model makes 15 mistakes
    index_to_change = np.random.randint(0, 100)
    new_prediction = np.random.randint(0, 3)
    # Ensure the new prediction is actually different from the true label
    while new_prediction == y_true[index_to_change]:
        new_prediction = np.random.randint(0, 3)
    y_pred[index_to_change] = new_prediction


# --- 2. Generate and Plot the Confusion Matrix ---

print("\nGenerating Confusion Matrix plot...")
# Create the confusion matrix
cm = confusion_matrix(y_true, y_pred)

# Plot the confusion matrix using Seaborn
plt.figure(figsize=(10, 8))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=class_labels,
            yticklabels=class_labels)

plt.title('Sample Confusion Matrix')
plt.ylabel('Actual Label')
plt.xlabel('Predicted Label')

# Save the plot to a file instead of showing it
output_filename = 'confusion_matrix_sample.png'
plt.savefig(output_filename)
print(f"✅ Confusion Matrix plot saved to: {output_filename}")


# --- 3. Print the Classification Report ---

print("\nClassification Report:\n")
# This report gives you precision, recall, f1-score, and support
print(classification_report(y_true, y_pred, target_names=class_labels))
