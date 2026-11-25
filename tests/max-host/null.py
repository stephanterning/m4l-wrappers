"""Compare the two channels of an unnormalized, undithered stereo PCM WAV."""
import argparse
import json
import math
from pathlib import Path
import wave


def compare(path, start_seconds=0):
    with wave.open(str(path), "rb") as audio:
        width = audio.getsampwidth()
        if audio.getnchannels() != 2 or width not in (2, 3, 4) or audio.getcomptype() != "NONE":
            raise ValueError("Expected an uncompressed stereo integer PCM WAV")
        rate = audio.getframerate()
        if not math.isfinite(start_seconds) or start_seconds < 0:
            raise ValueError("Start time must be finite and nonnegative")
        start = round(start_seconds * rate)
        if start >= audio.getnframes():
            raise ValueError("Comparison window starts after the last sample")
        audio.setpos(start)
        peak = [0, 0]
        peak_delta = differing = frames = 0
        first_difference = peak_position = None
        energy = difference_energy = 0
        while chunk := audio.readframes(32768):
            for offset in range(0, len(chunk), 2*width):
                left = int.from_bytes(chunk[offset:offset+width], "little", signed=True)
                right = int.from_bytes(chunk[offset+width:offset+2*width], "little", signed=True)
                delta = left-right
                peak[0] = max(peak[0], abs(left))
                peak[1] = max(peak[1], abs(right))
                if abs(delta) > peak_delta:
                    peak_delta = abs(delta)
                    peak_position = start + frames
                    if first_difference is None:
                        first_difference = peak_position
                difference_energy += delta*delta
                energy += left*left
                differing += delta != 0
                frames += 1
    if min(peak) == 0 or not frames:
        raise ValueError("Cannot compare silent or empty reference channels")
    full_scale = 1 << (width*8-1)
    return {"sample_rate": rate, "bits": width*8, "start_frame": start, "frames": frames,
            "channel_peaks": peak, "different_frames": differing, "maximum_difference_lsb": peak_delta,
            "first_difference_frame": first_difference, "peak_difference_frame": peak_position,
            "peak_difference_dbfs": 20*math.log10(peak_delta/full_scale) if peak_delta else None,
            "rms_difference_dbfs": 10*math.log10(difference_energy/frames/full_scale**2) if difference_energy else None,
            "relative_rms_difference_db": 10*math.log10(difference_energy/energy) if difference_energy else None}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=Path)
    parser.add_argument("--from-seconds", type=float, default=0, help="Skip the leading part of the file")
    args = parser.parse_args()
    print(json.dumps(compare(args.file, args.from_seconds)))
