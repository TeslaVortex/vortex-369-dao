#[cfg(test)]
mod resonance_tests {
    use super::*;

    #[test]
    fn test_high_resonance_keywords() {
        let proposal = "Create abundance through 369 resonance and 432 Hz harmony with vortex energy";
        let score = calculate_resonance_score(proposal);
        assert!(score > 66, "Score was {}, expected > 66", score);
    }

    #[test]
    fn test_low_resonance() {
        let proposal = "Buy a car for the team";
        let score = calculate_resonance_score(proposal);
        assert!(score < 33, "Score was {}, expected < 33", score);
    }

    #[test]
    fn test_medium_resonance() {
        let proposal = "Improve our documentation and user experience";
        let score = calculate_resonance_score(proposal);
        assert!(score >= 33 && score <= 66, "Score was {}, expected 33-66", score);
    }
}
