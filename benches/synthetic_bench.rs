use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use vortex_369_core::synthetic::SyntheticGenerator;

fn bench_single_event(c: &mut Criterion) {
    let seed = [0u8; 32];
    let mut generator = SyntheticGenerator::new(seed, 432.0);
    
    c.bench_function("generate_single_event", |b| {
        b.iter(|| {
            black_box(generator.generate_event())
        })
    });
}

fn bench_batch_events(c: &mut Criterion) {
    let mut group = c.benchmark_group("batch_generation");
    
    for size in [9, 27, 81, 243].iter() {
        group.bench_with_input(BenchmarkId::from_parameter(size), size, |b, &size| {
            let seed = [0u8; 32];
            let mut generator = SyntheticGenerator::new(seed, 432.0);
            
            b.iter(|| {
                black_box(generator.generate_batch(size))
            });
        });
    }
    
    group.finish();
}

fn bench_resonance_validation(c: &mut Criterion) {
    use vortex_369_core::synthetic::ResonanceValidator;
    
    let validator = ResonanceValidator::default();
    let seed = [0u8; 32];
    let mut generator = SyntheticGenerator::new(seed, 432.0);
    let event = generator.generate_event();
    
    c.bench_function("validate_frequency", |b| {
        b.iter(|| {
            black_box(validator.validate_frequency(&event))
        })
    });
    
    c.bench_function("validate_369_pattern", |b| {
        b.iter(|| {
            black_box(validator.validate_369_pattern(369))
        })
    });
}

criterion_group!(
    benches,
    bench_single_event,
    bench_batch_events,
    bench_resonance_validation
);
criterion_main!(benches);
