# Configuration Manager - System Optimization
# ∞ En Eeke Mai Ea ∞ - Argead Kingdom Manifested
# 66 Code Supreme - Eternal Flame Burns

"""
Configuration Manager

Centralized configuration management:
- Validation and optimization
- Dynamic parameter adjustment
- Performance monitoring
- System health assessment

∞ En Eeke Mai Ea ∞ - Argead Kingdom Manifested
"""

import json
import os
import time
from typing import Dict, List, Any, Optional
import numpy as np

class ConfigurationManager:
    """
    Centralized configuration management system

    Handles all system parameters, validation, and optimization
    """

    def __init__(self, config_file: str = None):
        """
        Initialize the configuration manager

        Args:
            config_file: Path to configuration file (optional)
        """
        self.config_file = config_file or self._get_default_config_path()
        self.config = self._load_config()
        self.performance_metrics = self._initialize_metrics()
        self.optimization_history = []
        self.kingdom_seal = "CONFIGURATION_MANAGER_ACTIVATED"

    def _get_default_config_path(self) -> str:
        """Get default configuration file path"""
        return os.path.join(os.path.dirname(__file__), 'config.json')

    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from file or use defaults"""
        default_config = self._get_default_config()

        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r') as f:
                    loaded_config = json.load(f)
                # Merge loaded config with defaults
                default_config.update(loaded_config)
            except (json.JSONDecodeError, IOError) as e:
                print(f"Warning: Could not load config file {self.config_file}: {e}")
                print("Using default configuration")

        return default_config

    def _get_default_config(self) -> Dict[str, Any]:
        """Get default configuration parameters"""
        return {
            # Quantum Intelligence Engine
            'quantum_field_size': 369,
            'temporal_resonance_alpha': 0.369,
            'temporal_resonance_beta': 0.666,
            'temporal_resonance_gamma': 0.999,
            'insight_strength_max': 10.0,

            # Reality Manifestor
            'probability_field_size': 369,
            'temporal_anchors_count': 369,
            'collective_amplification_max': 3.0,
            'energy_conversion_base': 0.369,

            # Validation System
            'probability_shift_threshold': 0.05,
            'coherence_threshold': 0.369,
            'temporal_persistence_threshold': 0.666,
            'reality_alteration_threshold': 0.7,
            'p_value_threshold': 0.05,
            'validation_history_max': 1000,

            # Performance Settings
            'performance_monitoring_enabled': True,
            'optimization_interval': 100,  # Optimize every N operations
            'health_check_interval': 50,

            # System Limits
            'max_manifestation_intensity': 'absolute',
            'min_validation_score': 0.5,
            'max_processing_time': 30.0,  # seconds

            # Kingdom Parameters
            'kingdom_resonance_v369': 369,
            'eternal_flame_code': 66,
            'argead_dynasty_seal': "∞ En Eeke Mai Ea ∞"
        }

    def _initialize_metrics(self) -> Dict[str, Any]:
        """Initialize performance metrics tracking"""
        return {
            'total_operations': 0,
            'successful_operations': 0,
            'failed_operations': 0,
            'average_processing_time': 0.0,
            'peak_memory_usage': 0.0,
            'system_health_score': 1.0,
            'last_health_check': time.time(),
            'optimization_count': 0
        }

    def get(self, key: str, default: Any = None) -> Any:
        """
        Get configuration parameter

        Args:
            key: Configuration parameter key
            default: Default value if key not found

        Returns:
            Configuration value
        """
        return self.config.get(key, default)

    def set(self, key: str, value: Any, validate: bool = True) -> bool:
        """
        Set configuration parameter

        Args:
            key: Configuration parameter key
            value: New value
            validate: Whether to validate the change

        Returns:
            bool: Success status
        """
        if validate and not self._validate_parameter(key, value):
            return False

        old_value = self.config.get(key)
        self.config[key] = value

        # Log optimization change
        self.optimization_history.append({
            'timestamp': time.time(),
            'parameter': key,
            'old_value': old_value,
            'new_value': value,
            'kingdom_seal': self.kingdom_seal
        })

        # Save to file if auto-save enabled
        if self.get('auto_save_config', True):
            self.save_config()

        return True

    def _validate_parameter(self, key: str, value: Any) -> bool:
        """Validate configuration parameter"""
        validation_rules = {
            'quantum_field_size': lambda x: isinstance(x, int) and 100 <= x <= 1000,
            'temporal_resonance_alpha': lambda x: isinstance(x, (int, float)) and 0 <= x <= 1,
            'temporal_resonance_beta': lambda x: isinstance(x, (int, float)) and 0 <= x <= 1,
            'temporal_resonance_gamma': lambda x: isinstance(x, (int, float)) and 0 <= x <= 1,
            'probability_shift_threshold': lambda x: isinstance(x, (int, float)) and 0 <= x <= 1,
            'coherence_threshold': lambda x: isinstance(x, (int, float)) and 0 <= x <= 1,
            'performance_monitoring_enabled': lambda x: isinstance(x, bool),
            'max_processing_time': lambda x: isinstance(x, (int, float)) and x > 0
        }

        validator = validation_rules.get(key)
        if validator:
            return validator(value)

        # Default validation - accept any value
        return True

    def save_config(self, file_path: str = None) -> bool:
        """
        Save configuration to file

        Args:
            file_path: Path to save config (optional)

        Returns:
            bool: Success status
        """
        save_path = file_path or self.config_file

        try:
            # Create directory if it doesn't exist
            os.makedirs(os.path.dirname(save_path), exist_ok=True)

            with open(save_path, 'w') as f:
                json.dump(self.config, f, indent=2)

            return True
        except IOError as e:
            print(f"Error saving config to {save_path}: {e}")
            return False

    def optimize_system(self) -> Dict[str, Any]:
        """
        Perform system optimization

        Returns:
            dict: Optimization results
        """
        start_time = time.time()

        # Analyze performance metrics
        performance_analysis = self._analyze_performance()

        # Generate optimization recommendations
        recommendations = self._generate_optimization_recommendations(performance_analysis)

        # Apply safe optimizations
        applied_changes = self._apply_safe_optimizations(recommendations)

        # Update metrics
        self.performance_metrics['optimization_count'] += 1
        self.performance_metrics['last_optimization'] = time.time()

        optimization_time = time.time() - start_time

        result = {
            'optimization_success': True,
            'applied_changes': applied_changes,
            'performance_analysis': performance_analysis,
            'recommendations': recommendations,
            'optimization_time': optimization_time,
            'kingdom_seal': self.kingdom_seal
        }

        return result

    def _analyze_performance(self) -> Dict[str, Any]:
        """Analyze system performance metrics"""
        metrics = self.performance_metrics

        success_rate = metrics['successful_operations'] / max(metrics['total_operations'], 1)
        avg_processing_time = metrics['average_processing_time']

        health_indicators = {
            'success_rate': success_rate,
            'processing_efficiency': 1.0 / (avg_processing_time + 0.1),  # Inverse time
            'system_stability': metrics['system_health_score'],
            'optimization_frequency': metrics['optimization_count']
        }

        # Calculate overall health score
        health_score = np.mean(list(health_indicators.values()))

        return {
            'success_rate': success_rate,
            'avg_processing_time': avg_processing_time,
            'health_indicators': health_indicators,
            'overall_health_score': float(health_score)
        }

    def _generate_optimization_recommendations(self, analysis: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Generate optimization recommendations"""
        recommendations = []

        # Success rate optimization
        if analysis['success_rate'] < 0.8:
            recommendations.append({
                'type': 'threshold_adjustment',
                'parameter': 'probability_shift_threshold',
                'action': 'decrease',
                'reason': 'Low success rate indicates thresholds too strict',
                'expected_impact': 'medium'
            })

        # Processing time optimization
        if analysis['avg_processing_time'] > 5.0:
            recommendations.append({
                'type': 'performance_tuning',
                'parameter': 'quantum_field_size',
                'action': 'decrease',
                'reason': 'High processing time suggests field size too large',
                'expected_impact': 'high'
            })

        # Health score optimization
        if analysis['overall_health_score'] < 0.7:
            recommendations.append({
                'type': 'system_tuning',
                'parameter': 'validation_history_max',
                'action': 'decrease',
                'reason': 'Low health score indicates memory pressure',
                'expected_impact': 'medium'
            })

        return recommendations

    def _apply_safe_optimizations(self, recommendations: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Apply safe optimization changes"""
        applied_changes = []

        for rec in recommendations:
            if rec['expected_impact'] == 'low':
                # Apply low-impact changes
                if rec['action'] == 'decrease':
                    current_value = self.get(rec['parameter'], 0)
                    if isinstance(current_value, (int, float)) and current_value > 0:
                        new_value = current_value * 0.9  # 10% decrease
                        if self.set(rec['parameter'], new_value):
                            applied_changes.append({
                                'parameter': rec['parameter'],
                                'old_value': current_value,
                                'new_value': new_value,
                                'reason': rec['reason']
                            })

        return applied_changes

    def update_performance_metrics(self, operation_success: bool, processing_time: float):
        """
        Update performance metrics after operation

        Args:
            operation_success: Whether operation was successful
            processing_time: Time taken for operation
        """
        self.performance_metrics['total_operations'] += 1

        if operation_success:
            self.performance_metrics['successful_operations'] += 1
        else:
            self.performance_metrics['failed_operations'] += 1

        # Update rolling average processing time
        current_avg = self.performance_metrics['average_processing_time']
        total_ops = self.performance_metrics['total_operations']
        self.performance_metrics['average_processing_time'] = (
            (current_avg * (total_ops - 1)) + processing_time
        ) / total_ops

        # Health check
        if total_ops % self.get('health_check_interval', 50) == 0:
            self._perform_health_check()

        # Optimization check
        if total_ops % self.get('optimization_interval', 100) == 0:
            self.optimize_system()

    def _perform_health_check(self):
        """Perform system health check"""
        metrics = self.performance_metrics

        # Calculate health score based on multiple factors
        success_rate = metrics['successful_operations'] / max(metrics['total_operations'], 1)
        processing_efficiency = 1.0 / (metrics['average_processing_time'] + 0.1)

        health_score = (success_rate * 0.6) + (processing_efficiency * 0.4)
        health_score = min(health_score, 1.0)

        self.performance_metrics['system_health_score'] = health_score
        self.performance_metrics['last_health_check'] = time.time()

    def get_system_health(self) -> Dict[str, Any]:
        """Get comprehensive system health report"""
        self._perform_health_check()  # Ensure fresh data

        return {
            'overall_health': self.performance_metrics['system_health_score'],
            'performance_metrics': self.performance_metrics.copy(),
            'config_status': 'loaded' if os.path.exists(self.config_file) else 'default',
            'optimization_history_count': len(self.optimization_history),
            'kingdom_seal': self.kingdom_seal,
            'system_signature': '∞ En Eeke Mai Ea ∞'
        }

    def reset_metrics(self):
        """Reset performance metrics"""
        self.performance_metrics = self._initialize_metrics()
        self.optimization_history = []

    def get_config_summary(self) -> Dict[str, Any]:
        """Get configuration summary"""
        return {
            'total_parameters': len(self.config),
            'categories': {
                'quantum': len([k for k in self.config.keys() if 'quantum' in k]),
                'validation': len([k for k in self.config.keys() if 'validation' in k or 'threshold' in k]),
                'performance': len([k for k in self.config.keys() if 'performance' in k or 'processing' in k]),
                'kingdom': len([k for k in self.config.keys() if 'kingdom' in k or 'eternal' in k])
            },
            'last_modified': os.path.getmtime(self.config_file) if os.path.exists(self.config_file) else None,
            'kingdom_seal': self.kingdom_seal
        }
