import re
from typing import Dict, List, Tuple

class ChatHandler:
    def __init__(self, remedies: Dict):
        self.remedies = remedies
        self.disease_patterns = {
            r'disease|infection|spot|blight|mildew|rust': self._handle_disease,
            r'weather|rain|temperature|humidity': self._handle_weather,
            r'soil|fertilizer|nutrient|ph': self._handle_soil,
            r'pest|insect|bug|worm': self._handle_pest,
            r'market|price|sell|buy': self._handle_market,
            r'help|support|guide': self._handle_help,
        }
        
    def get_response(self, message: str) -> str:
        # Convert message to lowercase for pattern matching
        message = message.lower()
        
        # Check each pattern
        for pattern, handler in self.disease_patterns.items():
            if re.search(pattern, message):
                return handler(message)
        
        # Default response if no pattern matches
        return self._handle_default(message)
    
    def _handle_disease(self, message: str) -> str:
        # Extract specific disease mentions
        diseases = [d for d in self.remedies.keys() if d.lower() in message]
        
        if diseases:
            disease = diseases[0]
            remedies = self.remedies.get(disease, ["No specific remedies available."])
            return f"I see you're asking about {disease}. Here's what I know:\n\n" + "\n".join([f"• {r}" for r in remedies])
        
        return ("I notice you're asking about plant diseases. To get accurate identification and treatment advice, "
                "I recommend:\n\n"
                "1. Using our disease scanner feature to analyze your plant\n"
                "2. Taking clear photos of affected areas\n"
                "3. Sharing images in our community section for expert opinions\n\n"
                "Would you like me to guide you through using the disease scanner?")

    def _handle_weather(self, message: str) -> str:
        return ("For weather-related queries, I recommend:\n\n"
                "1. Checking our weather section for current conditions\n"
                "2. Setting up weather alerts for your location\n"
                "3. Planning farming activities based on the forecast\n\n"
                "Would you like to see the detailed weather forecast?")

    def _handle_soil(self, message: str) -> str:
        return ("Regarding soil health:\n\n"
                "1. Our soil analysis feature can help identify nutrient levels\n"
                "2. Regular testing is recommended every 6-12 months\n"
                "3. We can provide specific fertilizer recommendations\n\n"
                "Would you like to learn more about our soil analysis tools?")

    def _handle_pest(self, message: str) -> str:
        return ("For pest control guidance:\n\n"
                "1. Can you describe the pests you're seeing?\n"
                "2. Share photos for accurate identification\n"
                "3. We'll recommend eco-friendly control measures\n\n"
                "What kind of pests are you dealing with?")

    def _handle_market(self, message: str) -> str:
        return ("For market information:\n\n"
                "1. Check our community section for price updates\n"
                "2. Connect with local farmers\n"
                "3. Access historical price trends\n\n"
                "Would you like to see current market prices?")

    def _handle_help(self, message: str) -> str:
        return ("I can help you with:\n\n"
                "• Plant disease identification\n"
                "• Weather monitoring and alerts\n"
                "• Soil health analysis\n"
                "• Pest control guidance\n"
                "• Market prices and trends\n"
                "• Farming best practices\n\n"
                "What specific area would you like to know more about?")

    def _handle_default(self, message: str) -> str:
        return (f"I understand you're asking about \"{message}\". To help you better:\n\n"
                "1. Could you provide more specific details?\n"
                "2. Are you facing any particular farming challenges?\n"
                "3. Would you like to explore our features for farm management?")
