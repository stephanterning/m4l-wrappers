// The VST host reports samples. Publish a change in the same Max message turn.
function latency(samples) {
    const value = Number(samples);
    if (!Number.isInteger(value) || value < 0) return;
    if (Number(patch.getattr("latency")) !== value) patch.setattr("latency", value);
}
