# PRAKRUTI: Project Viva Voce Questions

This document provides a comprehensive list of potential viva voce (oral examination) questions for the PRAKRUTI project. The questions are categorized to cover all aspects of the project, from high-level concepts to technical details.

---

### 1. High-Level & Conceptual Questions

1.  **Project Overview:** Can you briefly explain the PRAKRUTI project in your own words? What is its primary goal?
2.  **Problem Statement:** What specific problem does PRAKRUTI aim to solve for farmers? Why is this problem significant?
3.  **Target Audience:** Who is the primary user of your application? How have you designed the app to meet their specific needs?
4.  **Innovation:** What makes PRAKRUTI unique compared to other existing solutions in the market?
5.  **Project Name:** Why did you choose the name "PRAKRUTI"? What is its significance?
6.  **Social Impact:** How do you see this project making a positive impact on the agricultural community?

---

### 2. Technical Architecture & Design

7.  **System Architecture:** Describe the overall architecture of your application. What are the main components and how do they interact? (e.g., Frontend, Backend, Database, ML Model).
8.  **Technology Stack:** Which technologies did you choose for the frontend and backend? Justify your choices (e.g., Why Flutter for the mobile app? Why Python/FastAPI for the backend?).
9.  **Client-Server Communication:** How does the Flutter app communicate with the Python backend? What data format do you use (e.g., JSON)? Can you explain the request-response cycle for a key feature like disease detection?
10. **API Design:** Can you give an example of an API endpoint in your backend? What does it do, what parameters does it take, and what does it return?
11. **Scalability:** How would you scale this application if it were to be used by millions of farmers? What challenges would you anticipate?
12. **Database:** What kind of data are you storing? Did you use a database? If not, how is data being managed?

---

### 3. Machine Learning & Disease Detection

13. **Model's Role:** What is the role of the Machine Learning model in your project?
14. **Model Choice:** Which ML model architecture did you use (e.g., ResNet, MobileNet, EfficientNet)? Why did you choose that specific model?
15. **Training Data:** What dataset did you use to train your model? How did you ensure the data was of good quality?
16. **Prediction Process:** Explain the step-by-step process from when a user uploads an image to when they receive a prediction.
17. **Confidence Score:** What does the "confidence score" signify? Why is it important for the user?
18. **Model Accuracy:** How accurate is your model? How would you go about improving its accuracy in the future?
19. **Challenges:** What were the biggest challenges you faced while integrating the ML model with the backend? (e.g., performance, dependency issues, model size).
20. **Fake Confidence:** You implemented a "fake" confidence score. Can you explain why this was done and how it works? What are the implications of this for a real-world application?

---

### 4. Flutter Frontend (Mobile App)

21. **Why Flutter?:** What are the advantages of using Flutter for this project?
22. **State Management:** What state management solution did you use in the Flutter app (e.g., Provider, BLoC, Riverpod)? Why did you choose it?
23. **Key Features:** Walk me through the code for one of the key features in your app (e.g., image capture, displaying results, weather forecast).
24. **Localization:** You've integrated Gujarati language support. How did you implement localization in Flutter? What challenges did you face?
25. **User Interface (UI):** What principles did you follow while designing the user interface? How did you ensure it was user-friendly for farmers?
26. **Dependencies:** What are some of the key packages (`pubspec.yaml`) you used in your Flutter app and what do they do?

---

### 5. Python Backend

27. **Why FastAPI?:** What are the benefits of using FastAPI for your backend server?
28. **Asynchronous Processing:** FastAPI is an asynchronous framework. Did you leverage `async/await`? Why is this important for an API server?
29. **Backend Scripts:** You have several server startup scripts (`start_prakruti.sh`, `start_backend_simple.sh`). Can you explain their purpose and why a simplified script was necessary?
30. **Error Handling:** How do you handle potential errors in your backend, such as a failed prediction or a bad request?
31. **Environment Management:** Why is it important to use a virtual environment (like `venv`) for a Python project?

---

### 6. Future Scope & Improvements

32. **Next Steps:** If you had more time, what would be the next feature you would add to PRAKRUTI?
33. **Monetization:** How could this project be monetized or sustained financially?
34. **Model Improvement:** What are the concrete steps you would take to train a new, more accurate model?
35. **Security:** What security vulnerabilities might your application have, and how would you address them?
36. **Offline Functionality:** How could you make parts of your app work without an internet connection? Is it feasible?

---
