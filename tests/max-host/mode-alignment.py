"""Measure the six interleaved parallel-chain impulse tests in a stereo Live export.

The left channel is the reference. The six tracks emit isolated impulses at
4500-frame intervals, then leave a longer gap before the 32768-frame cycle
restarts. The gap identifies each track even when a render starts mid-cycle.
"""
import argparse
import json
from pathlib import Path
import wave

import numpy as np

MODES = ("Decapitator Mix 0", "Oxford split off", "Oxford split on",
         "Spectre Normal", "Spectre Good", "Spectre Best")


def peaks(samples):
    indices = np.flatnonzero(np.abs(samples) > 22)
    if indices.size == 0:
        raise ValueError("No impulses above the 16-bit dither floor")
    groups = np.split(indices, np.flatnonzero(np.diff(indices) > 250) + 1)
    return np.array([group[np.abs(samples[group]).argmax()] for group in groups])


def measure(path):
    with wave.open(str(path)) as wav:
        if wav.getnchannels() != 2 or wav.getsampwidth() != 2:
            raise ValueError("Expected a stereo 16-bit PCM export")
        rate = wav.getframerate()
        data = np.frombuffer(wav.readframes(wav.getnframes()), "<i2").astype(np.int32).reshape(-1, 2)
    left, right = data.T
    reference, test = peaks(left), peaks(right)
    if reference.size < 18 or reference.size != test.size:
        raise ValueError(f"Missing or extra pulses: {len(reference)} reference, {len(test)} test")
    gaps = np.diff(reference)
    long_gaps = np.flatnonzero(gaps > 1.6*np.median(gaps))
    if not long_gaps.size or not np.all(np.diff(long_gaps) == len(MODES)):
        raise ValueError("Reference does not contain the six-track impulse pattern")
    first_track = (-int(long_gaps[0])-1) % len(MODES)
    results = []
    for index, mode in enumerate(MODES):
        start = (index-first_track) % len(MODES)
        lags, error = [], 0
        for pos, hit in zip(reference[start::6], test[start::6]):
            # Truncate both windows equally at file boundaries.
            before = min(200, pos, hit)
            after = min(200, len(left)-pos-1, len(right)-hit-1)
            a = left[pos-before:pos+after+1].astype(float)
            b = right[hit-before:hit+after+1].astype(float)
            lag = int(hit-pos + np.correlate(b, a, "full").argmax() - (len(a)-1))
            lags.append(lag)
            lo, hi = max(0, pos-180, -lag), min(len(left), pos+181, len(right)-lag)
            error = max(error, int(np.abs(left[lo:hi]-right[lo+lag:hi+lag]).max()))
        results.append(dict(mode=mode, impulses=len(lags), offsets=sorted(set(lags)),
                            max_difference_lsb_after_alignment=error))
    return dict(rate=rate, frames=len(data), modes=results)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("exports", nargs="+", type=Path)
    measurements = [measure(path) for path in parser.parse_args().exports]
    print(json.dumps(measurements, indent=2))
    raise SystemExit(any(m["offsets"] != [0] for row in measurements for m in row["modes"]))
