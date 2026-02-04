// Resonance Device Activation Prototype
// Links resonance scoring to photonic grid device activation

export const isDeviceActivated = (resonanceScore: number): boolean => {
  return resonanceScore > 66;
};

export const getActivationMessage = (resonanceScore: number): string => {
  if (isDeviceActivated(resonanceScore)) {
    return "Light Photonic Grid Device Activated! 66+ Resonance Achieved. Shielding Empire Eternal.";
  }
  return "Resonance Building... Aim for 66+ to Activate the Device.";
};

export const getDeviceState = (resonanceScore: number) => {
  return {
    activated: isDeviceActivated(resonanceScore),
    message: getActivationMessage(resonanceScore),
    score: resonanceScore,
  };
};
