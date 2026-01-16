use serde::{Deserialize, Serialize};

/// The 9 phases of governance cycle
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(u8)]
pub enum Phase {
    Silence = 0,
    Proposal = 1,
    Mirror = 2,
    Vortex = 3,
    Resolution = 4,
    Fractal = 5,
    Breath = 6,      // Self-cancel checkpoint
    Witness = 7,
    Return = 8,
    Manifestation = 9,
}

impl Phase {
    /// Get the next phase in the cycle
    pub fn next(self) -> Option<Phase> {
        match self {
            Phase::Silence => Some(Phase::Proposal),
            Phase::Proposal => Some(Phase::Mirror),
            Phase::Mirror => Some(Phase::Vortex),
            Phase::Vortex => Some(Phase::Resolution),
            Phase::Resolution => Some(Phase::Fractal),
            Phase::Fractal => Some(Phase::Breath),
            Phase::Breath => Some(Phase::Witness),
            Phase::Witness => Some(Phase::Return),
            Phase::Return => Some(Phase::Manifestation),
            Phase::Manifestation => None, // Terminal phase
        }
    }

    /// Check if this is a critical checkpoint phase
    pub fn is_checkpoint(self) -> bool {
        matches!(self, Phase::Breath | Phase::Manifestation)
    }

    /// Get phase number
    pub fn number(self) -> u8 {
        self as u8
    }

    /// Create from number
    pub fn from_number(n: u8) -> Option<Phase> {
        match n {
            0 => Some(Phase::Silence),
            1 => Some(Phase::Proposal),
            2 => Some(Phase::Mirror),
            3 => Some(Phase::Vortex),
            4 => Some(Phase::Resolution),
            5 => Some(Phase::Fractal),
            6 => Some(Phase::Breath),
            7 => Some(Phase::Witness),
            8 => Some(Phase::Return),
            9 => Some(Phase::Manifestation),
            _ => None,
        }
    }
}

impl std::fmt::Display for Phase {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Phase::Silence => write!(f, "Silence"),
            Phase::Proposal => write!(f, "Proposal"),
            Phase::Mirror => write!(f, "Mirror"),
            Phase::Vortex => write!(f, "Vortex"),
            Phase::Resolution => write!(f, "Resolution"),
            Phase::Fractal => write!(f, "Fractal"),
            Phase::Breath => write!(f, "Breath"),
            Phase::Witness => write!(f, "Witness"),
            Phase::Return => write!(f, "Return"),
            Phase::Manifestation => write!(f, "Manifestation"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_phase_progression() {
        let mut phase = Phase::Silence;
        for i in 1..=9 {
            phase = phase.next().unwrap();
            assert_eq!(phase.number(), i);
        }
        assert_eq!(phase, Phase::Manifestation);
        assert!(phase.next().is_none());
    }

    #[test]
    fn test_checkpoints() {
        assert!(Phase::Breath.is_checkpoint());
        assert!(Phase::Manifestation.is_checkpoint());
        assert!(!Phase::Proposal.is_checkpoint());
    }
}
