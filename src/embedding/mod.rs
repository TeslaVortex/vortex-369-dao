// Vector embedding module (ONNX-based)
// TODO: Implement ONNX Runtime integration for local embeddings

pub mod embedder;
pub mod semantic;

pub use embedder::VectorEmbedder;
pub use semantic::SemanticAnalyzer;
