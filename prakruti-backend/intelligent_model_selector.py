#!/usr/bin/env python3
"""
Intelligent Model Selector for PRAKRUTI
Automatically selects the best model based on device capabilities and requirements
"""

import platform
import psutil
import time
import logging
from typing import Dict, Optional
from model_selector import AVAILABLE_MODELS

logger = logging.getLogger(__name__)

class IntelligentModelSelector:
    """Automatically selects the best model based on system capabilities"""
    
    def __init__(self):
        self.system_info = self._analyze_system()
        self.performance_cache = {}
        
    def _analyze_system(self) -> Dict:
        """Analyze current system capabilities"""
        try:
            # Get system information
            cpu_count = psutil.cpu_count()
            memory_gb = psutil.virtual_memory().total / (1024**3)
            cpu_freq = psutil.cpu_freq()
            max_freq = cpu_freq.max if cpu_freq else 2000  # Default 2GHz
            
            # Detect platform type
            system = platform.system().lower()
            machine = platform.machine().lower()
            
            # Classify device type
            if memory_gb < 4:
                device_type = "mobile"
            elif memory_gb < 8:
                device_type = "tablet"  
            else:
                device_type = "desktop"
                
            # Performance score (0-100)
            performance_score = min(100, (
                (cpu_count * 10) +           # CPU cores weight
                (memory_gb * 5) +            # RAM weight  
                (max_freq / 100)             # CPU frequency weight
            ))
            
            return {
                "device_type": device_type,
                "cpu_count": cpu_count,
                "memory_gb": memory_gb,
                "max_freq_mhz": max_freq,
                "performance_score": performance_score,
                "system": system,
                "machine": machine
            }
            
        except Exception as e:
            logger.warning(f"Error analyzing system: {e}")
            # Default fallback
            return {
                "device_type": "desktop",
                "cpu_count": 4,
                "memory_gb": 8,
                "max_freq_mhz": 2000,
                "performance_score": 60,
                "system": "unknown",
                "machine": "unknown"
            }
    
    def select_model_by_priority(self, priority: str = "balanced") -> str:
        """Select model based on priority: speed, accuracy, or balanced"""
        
        device_type = self.system_info["device_type"]
        performance_score = self.system_info["performance_score"]
        
        logger.info(f"Selecting model for {device_type} with performance score {performance_score}")
        
        if priority == "speed":
            # Always prioritize speed
            return "mobilenet_tflite"
            
        elif priority == "accuracy":
            # Prioritize accuracy based on device capability
            if device_type == "mobile" or performance_score < 40:
                return "efficientnetb0"  # Best we can do on mobile
            elif device_type == "tablet" or performance_score < 70:
                return "efficientnetb0"  # Good balance for tablets
            else:
                return "resnet50"        # Best accuracy for powerful devices
                
        else:  # balanced (default)
            # Intelligent selection based on device capabilities
            if device_type == "mobile":
                if performance_score > 50:
                    return "mobilenet_h5"    # Slightly better than TFLite
                else:
                    return "mobilenet_tflite"  # Fastest for weak mobile
                    
            elif device_type == "tablet":
                if performance_score > 60:
                    return "efficientnetb0"   # Good balance
                else:
                    return "mobilenet_h5"     # Safer choice
                    
            else:  # desktop
                if performance_score > 80:
                    return "resnet50"         # Best accuracy
                elif performance_score > 60:
                    return "efficientnetb0"   # Good balance
                else:
                    return "mobilenet_h5"     # Conservative choice
    
    def benchmark_model(self, model_name: str, test_iterations: int = 3) -> Dict:
        """Benchmark a specific model performance"""
        try:
            import numpy as np
            import tensorflow as tf
            from app_enhanced import _run_inference, preprocess_image
            
            # Create test image
            test_image_bytes = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8).tobytes()
            processed_image = preprocess_image(test_image_bytes)
            
            # Run benchmark
            times = []
            for _ in range(test_iterations):
                start_time = time.time()
                result = _run_inference(processed_image)
                end_time = time.time()
                times.append((end_time - start_time) * 1000)  # Convert to ms
            
            avg_time = sum(times) / len(times)
            min_time = min(times)
            max_time = max(times)
            
            benchmark_result = {
                "model": model_name,
                "avg_time_ms": avg_time,
                "min_time_ms": min_time,
                "max_time_ms": max_time,
                "iterations": test_iterations,
                "timestamp": time.time()
            }
            
            # Cache result
            self.performance_cache[model_name] = benchmark_result
            return benchmark_result
            
        except Exception as e:
            logger.error(f"Benchmark failed for {model_name}: {e}")
            return {
                "model": model_name,
                "avg_time_ms": 9999,
                "error": str(e)
            }
    
    def adaptive_model_selection(self, target_response_time_ms: int = 500) -> str:
        """Adaptively select model based on target response time"""
        
        # Try models in order of preference
        model_order = ["mobilenet_tflite", "mobilenet_h5", "efficientnetb0", "resnet50"]
        
        for model_name in model_order:
            # Check if we have cached performance
            if model_name in self.performance_cache:
                cached_result = self.performance_cache[model_name]
                if cached_result["avg_time_ms"] <= target_response_time_ms:
                    logger.info(f"Selected {model_name} (cached: {cached_result['avg_time_ms']:.0f}ms)")
                    return model_name
            else:
                # Estimate based on system performance
                model_info = AVAILABLE_MODELS[model_name]
                estimated_time = self._estimate_model_time(model_name)
                
                if estimated_time <= target_response_time_ms:
                    logger.info(f"Selected {model_name} (estimated: {estimated_time:.0f}ms)")
                    return model_name
        
        # Fallback to fastest model
        logger.warning(f"No model meets {target_response_time_ms}ms target, using fastest")
        return "mobilenet_tflite"
    
    def _estimate_model_time(self, model_name: str) -> float:
        """Estimate model inference time based on system performance"""
        
        # Base times for reference system (performance_score = 60)
        base_times = {
            "mobilenet_tflite": 25,
            "mobilenet_h5": 30,
            "efficientnetb0": 100,
            "resnet50": 400
        }
        
        # Adjust based on system performance
        performance_factor = 60 / max(self.system_info["performance_score"], 20)
        estimated_time = base_times.get(model_name, 100) * performance_factor
        
        return estimated_time
    
    def get_recommendation_report(self) -> str:
        """Generate a detailed recommendation report"""
        
        report = []
        report.append("🤖 INTELLIGENT MODEL SELECTION REPORT")
        report.append("=" * 50)
        report.append(f"💻 Device Type: {self.system_info['device_type'].title()}")
        report.append(f"⚡ Performance Score: {self.system_info['performance_score']:.0f}/100")
        report.append(f"🧠 CPU Cores: {self.system_info['cpu_count']}")
        report.append(f"💾 RAM: {self.system_info['memory_gb']:.1f} GB")
        report.append("")
        
        # Recommendations for different priorities
        speed_model = self.select_model_by_priority("speed")
        balanced_model = self.select_model_by_priority("balanced")
        accuracy_model = self.select_model_by_priority("accuracy")
        
        report.append("🎯 RECOMMENDATIONS:")
        report.append(f"🏃 Speed Priority: {speed_model}")
        report.append(f"⚖️  Balanced: {balanced_model} (RECOMMENDED)")
        report.append(f"🎯 Accuracy Priority: {accuracy_model}")
        report.append("")
        
        # Adaptive recommendations
        fast_model = self.adaptive_model_selection(100)  # 100ms target
        medium_model = self.adaptive_model_selection(500)  # 500ms target
        
        report.append("🚀 ADAPTIVE SELECTION:")
        report.append(f"⚡ Ultra Fast (<100ms): {fast_model}")
        report.append(f"⏱️  Standard (<500ms): {medium_model}")
        
        return "\n".join(report)

# Global intelligent selector instance
intelligent_selector = None

def get_intelligent_selector() -> IntelligentModelSelector:
    """Get or create the intelligent model selector"""
    global intelligent_selector
    if intelligent_selector is None:
        intelligent_selector = IntelligentModelSelector()
    return intelligent_selector

def auto_select_model(priority: str = "balanced") -> str:
    """Convenience function for automatic model selection"""
    selector = get_intelligent_selector()
    return selector.select_model_by_priority(priority)

if __name__ == "__main__":
    # Demo the intelligent selector
    selector = IntelligentModelSelector()
    print(selector.get_recommendation_report())
