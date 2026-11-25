"""Compare a stereo impulse export with direct VST3 on the left and wrapper on the right."""
import argparse
import json
from pathlib import Path
import wave


def impulse_peaks(samples, sample_rate, threshold):
    # The test source emits one isolated pulse per 32768 frames. Treat nearby
    # samples above the threshold as one transient, including filter ringing.
    gap = round(sample_rate * .005)
    peaks = []
    last = -gap
    for index, value in enumerate(samples):
        amplitude = abs(value)
        if amplitude < threshold:
            continue
        if not peaks or index - last > gap:
            peaks.append((index, amplitude))
        elif amplitude > peaks[-1][1]:
            peaks[-1] = (index, amplitude)
        last = index
    return [index for index, _ in peaks]


def compare(path, threshold):
    with wave.open(str(path), "rb") as audio:
        width, rate = audio.getsampwidth(), audio.getframerate()
        if audio.getnchannels() != 2 or width not in (2, 3, 4):
            raise ValueError("Export a stereo PCM WAV at 16, 24 or 32 bits.")
        data = audio.readframes(audio.getnframes())
    channels = []
    for channel in range(2):
        values = (int.from_bytes(data[i:i+width], "little", signed=True)
                  for i in range(channel*width, len(data), 2*width))
        channels.append(impulse_peaks(values, rate, threshold * (1 << (8*width-1))))
    native, wrapper = channels
    if len(native) < 2 or len(native) != len(wrapper):
        raise ValueError(f"Expected matching impulse trains, found {len(native)} and {len(wrapper)} pulses")
    offsets = [w-n for n,w in zip(native, wrapper)]
    return {"rate": rate, "pairs": len(offsets), "first_direct": native[0],
            "first_wrapper": wrapper[0], "offsets_in_samples": sorted(set(offsets))}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("export", type=Path)
    parser.add_argument("--threshold", type=float, default=.05, help="Minimum pulse amplitude relative to full scale")
    args = parser.parse_args()
    if not 0 < args.threshold < 1:
        parser.error("threshold must be between zero and one")
    result = compare(args.export, args.threshold)
    print(json.dumps(result))
    raise SystemExit(result["offsets_in_samples"] != [0])
