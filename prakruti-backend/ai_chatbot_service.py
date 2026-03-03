"""
AI-Powered Chatbot Service for PRAKRUTI
Supports both OpenAI GPT and Google Gemini APIs
"""
import os
import asyncio
import logging
from typing import Optional, Dict, Any
from datetime import datetime
import json

try:
    import openai
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False

try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

from config import settings

logger = logging.getLogger(__name__)

class AIChatbotService:
    def __init__(self):
        self.openai_client = None
        self.gemini_model = None
        self.current_provider = None
        self.conversation_history = {}
        
        # Agriculture-specific system prompt
        self.system_prompt = """You are PRAKRUTI AI, an expert agricultural assistant focused on Indian farming. Your specialties include:

🌾 **Core Expertise:**
- Plant disease identification and treatment
- Crop management and best practices
- Soil health analysis and fertilizer recommendations
- Pest and insect control (IPM methods)
- Weather-based farming advice
- Organic farming techniques
- Irrigation and water management

🇮🇳 **Indian Agricultural Context:**
- Focus on crops like rice, wheat, cotton, sugarcane, maize, pulses, vegetables
- Understand monsoon patterns and seasonal farming
- Know about Indian soil types and regional conditions
- Familiar with government schemes (PM-KISAN, soil health cards, etc.)
- Use both traditional knowledge and modern scientific methods

💬 **Communication Style:**
- Be conversational, helpful, and encouraging
- Provide practical, actionable advice
- Ask follow-up questions to better understand farmer needs
- Explain technical concepts in simple terms
- Include preventive measures alongside treatments

🔄 **Language Support:**
- Respond in the same language as the user's question
- Support both English and Gujarati (when detected)
- Use local terminology when appropriate

Remember: Always prioritize farmer safety, environmental sustainability, and cost-effective solutions. If unsure about serious plant diseases or soil issues, recommend consulting local agricultural experts."""

    async def initialize(self):
        """Initialize available AI providers"""
        try:
            # Try to initialize OpenAI first
            if OPENAI_AVAILABLE and hasattr(settings, 'openai_api_key') and settings.openai_api_key:
                self.openai_client = openai.AsyncOpenAI(api_key=settings.openai_api_key)
                self.current_provider = "openai"
                logger.info("OpenAI GPT initialized successfully")
                return True
                
            # Try Gemini as fallback
            if GEMINI_AVAILABLE and hasattr(settings, 'gemini_api_key') and settings.gemini_api_key:
                genai.configure(api_key=settings.gemini_api_key)
                self.gemini_model = genai.GenerativeModel('gemini-pro')
                self.current_provider = "gemini"
                logger.info("Google Gemini initialized successfully")
                return True
                
            logger.warning("No AI providers configured. Using fallback responses.")
            return False
            
        except Exception as e:
            logger.error(f"Error initializing AI providers: {e}")
            return False

    async def get_ai_response(self, user_message: str, conversation_id: str = None, language: str = "auto") -> str:
        """Get AI response for user message"""
        try:
            if not self.current_provider:
                await self.initialize()
                if not self.current_provider:
                    return self._get_fallback_response(user_message)

            # Detect language if auto
            if language == "auto":
                language = self._detect_language(user_message)

            # Build conversation context
            context_messages = self._build_conversation_context(user_message, conversation_id, language)

            # Get response from appropriate provider
            if self.current_provider == "openai":
                response = await self._get_openai_response(context_messages)
            elif self.current_provider == "gemini":
                response = await self._get_gemini_response(context_messages)
            else:
                response = self._get_fallback_response(user_message)

            # Store conversation history
            if conversation_id:
                self._update_conversation_history(conversation_id, user_message, response)

            return response

        except Exception as e:
            logger.error(f"Error getting AI response: {e}")
            return self._get_fallback_response(user_message)

    def _detect_language(self, text: str) -> str:
        """Simple language detection for Gujarati vs English"""
        # Check for Gujarati Unicode characters
        gujarati_chars = any('\u0A80' <= char <= '\u0AFF' for char in text)
        return "gu" if gujarati_chars else "en"

    def _build_conversation_context(self, user_message: str, conversation_id: str, language: str) -> list:
        """Build conversation context for AI"""
        messages = [{"role": "system", "content": self.system_prompt}]
        
        # Add conversation history if available
        if conversation_id and conversation_id in self.conversation_history:
            history = self.conversation_history[conversation_id]
            for entry in history[-6:]:  # Keep last 6 exchanges (12 messages)
                messages.append({"role": "user", "content": entry["user"]})
                messages.append({"role": "assistant", "content": entry["assistant"]})
        
        # Add language context if Gujarati
        if language == "gu":
            user_message = f"[Respond in Gujarati] {user_message}"
        
        messages.append({"role": "user", "content": user_message})
        return messages

    async def _get_openai_response(self, messages: list) -> str:
        """Get response from OpenAI GPT"""
        try:
            response = await self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=messages,
                max_tokens=500,
                temperature=0.7,
                timeout=30
            )
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            logger.error(f"OpenAI API error: {e}")
            raise

    async def _get_gemini_response(self, messages: list) -> str:
        """Get response from Google Gemini"""
        try:
            # Convert messages to Gemini format
            prompt_parts = []
            for msg in messages[1:]:  # Skip system message for now
                role = "User" if msg["role"] == "user" else "Model"
                prompt_parts.append(f"{role}: {msg['content']}")
            
            prompt = self.system_prompt + "\n\n" + "\n\n".join(prompt_parts) + "\n\nModel:"
            
            response = await asyncio.get_event_loop().run_in_executor(
                None, self.gemini_model.generate_content, prompt
            )
            
            return response.text.strip()
            
        except Exception as e:
            logger.error(f"Gemini API error: {e}")
            raise

    def _update_conversation_history(self, conversation_id: str, user_msg: str, ai_response: str):
        """Update conversation history"""
        if conversation_id not in self.conversation_history:
            self.conversation_history[conversation_id] = []
        
        self.conversation_history[conversation_id].append({
            "user": user_msg,
            "assistant": ai_response,
            "timestamp": datetime.now().isoformat()
        })
        
        # Keep only last 10 exchanges per conversation
        if len(self.conversation_history[conversation_id]) > 10:
            self.conversation_history[conversation_id] = self.conversation_history[conversation_id][-10:]

    def _get_fallback_response(self, user_message: str) -> str:
        """Fallback responses when AI is unavailable"""
        message_lower = user_message.lower()
        
        # Agriculture-specific patterns
        if any(word in message_lower for word in ['disease', 'pest', 'infection', 'spots', 'yellowing', 'wilting']):
            return """🌱 I understand you're facing crop health issues. Here's what I recommend:

1. **Take clear photos** of affected plants (leaves, stems, roots if possible)
2. **Note symptoms**: color changes, patterns, affected plant parts
3. **Check growing conditions**: soil moisture, recent weather, fertilizer use
4. **Immediate action**: Isolate affected plants if possible

For accurate diagnosis, please use our disease scanner feature or consult your local agricultural extension officer. Common issues include fungal infections (treat with copper-based fungicides) and nutrient deficiencies (soil testing recommended)."""

        elif any(word in message_lower for word in ['fertilizer', 'nutrient', 'soil', 'ph', 'organic']):
            return """🌿 Soil health is crucial for good crops! Here's my advice:

**Soil Testing First:**
- Get soil tested every 6-12 months
- Check pH, NPK levels, organic matter
- Use soil health cards if available

**General Recommendations:**
- **Organic matter**: Add compost, cow dung manure
- **NPK balance**: Use as per soil test results
- **pH management**: Lime for acidic soils, gypsum for alkaline
- **Micronutrients**: Zinc, iron, boron as needed

Would you like specific recommendations for your crop type?"""

        elif any(word in message_lower for word in ['weather', 'rain', 'irrigation', 'water']):
            return """🌧️ Water management is key to successful farming:

**Monsoon Farming:**
- Plan sowing based on weather forecast
- Prepare drainage for excess water
- Use weather apps for daily updates

**Irrigation Tips:**
- Morning watering is most effective
- Check soil moisture before watering
- Drip irrigation saves 30-50% water
- Mulching reduces water loss

Check our weather section for detailed forecasts and farming advisories!"""

        elif any(word in message_lower for word in ['market', 'price', 'sell', 'profit']):
            return """💰 Smart marketing increases farm profits:

**Before Harvest:**
- Monitor market prices regularly
- Plan harvesting based on market trends
- Consider storage facilities for better prices

**Selling Strategies:**
- Direct selling to consumers
- Farmer Producer Organizations (FPOs)
- Government procurement centers
- Online platforms for direct marketing

Connect with other farmers in our community section for local market insights!"""

        # Language-specific fallback
        if any(char >= '\u0A80' and char <= '\u0AFF' for char in user_message):  # Gujarati
            return """નમસ્તે! હું PRAKRUTI AI છું, તમારો કૃષિ સહાયક. હાલમાં AI સેવા ઉપલબ્ધ નથી, પણ હું મદદ કરવા માટે અહીં છું.

🌾 હું મદદ કરી શકું છું:
• પાકના રોગની ઓળખ અને સારવાર
• જમીનનું વિશ્લેષણ અને ખાતર
• હવામાન આધારિત સલાહ
• જંતુઓનું નિયંત્રણ

કૃપા કરીને તમારો પ્રશ્ન વધુ વિગતે પૂછો અથવા અમારી અન્ય સુવિધાઓનો ઉપયોગ કરો."""

        # Default English fallback
        return """🙏 Hello! I'm PRAKRUTI AI, your agricultural assistant. While AI services are currently unavailable, I'm here to help with:

🌾 **What I can help with:**
• Plant disease identification & treatment
• Soil analysis & fertilizer recommendations  
• Weather-based farming advice
• Pest control solutions
• Crop management tips

Please ask your specific farming question, or explore our other features like disease scanner, weather forecasts, and soil analysis tools."""

# Global instance
ai_chatbot = AIChatbotService()
