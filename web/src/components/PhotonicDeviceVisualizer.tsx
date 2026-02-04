import React from 'react';
import './PhotonicDeviceVisualizer.css'; // Assuming we create a CSS file for component-specific styles

interface PhotonicDeviceVisualizerProps {
  resonanceScore?: number | null;
}

const PhotonicDeviceVisualizer: React.FC<PhotonicDeviceVisualizerProps> = ({ resonanceScore = 0 }) => {
  const resonanceValue = resonanceScore ?? 0;
  const isActivated = resonanceValue > 66;

  return (
    <div className="photonic-device-visualizer">
      <h3>Light Photonic Grid Device</h3>
      <div className={`device-container ${isActivated ? 'activated' : ''}`}>
        <img
          src="/assets/photonic-device/full_device.svg"
          alt="Light Photonic Grid Device"
          className={`device-svg ${isActivated ? 'pulse-golden glow-blue heart-beat' : ''}`}
        />
      </div>
      <p>Resonance Score: {resonanceScore}</p>
      {isActivated && <p className="activation-message">Device Activated! 66+ Resonance Achieved.</p>}
    </div>
  );
};

export default PhotonicDeviceVisualizer;
