// Foreground panel shared by every wrapper.
inlets = 1;
outlets = 1;
mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

const panelStart = Number(jsarguments[1]);
const panelWidth = Number(jsarguments[2]);
let phase = "loading";
let detail = "";
let started = 0;
const pulse = new Task(function () { mgraphics.redraw(); }, this);
pulse.interval = 100;
const buttonY = 12, buttonWidth = 45, buttonHeight = 24;

function status(value, reason) {
    reason = String(reason || "");
    if (phase === value && detail === reason) return;
    pulse.cancel();
    phase = value;
    detail = reason;
    if (phase === "missing" || phase === "loaderror") {
        started = Date.now();
        pulse.repeat();
    }
    mgraphics.redraw();
}

function cardSize() { return phase === "loaderror" ? [280, 76] : [218, 48]; }

function drawReason(width) {
    const g = mgraphics;
    g.select_font_face("Arial", "normal", "normal");
    g.set_font_size(10);
    const words = detail.trim().split(/\s+/);
    for (let line = 0; line < 2 && words.length; line++) {
        let s = words.shift();
        while (words.length && g.text_measure(s + " " + words[0])[0] <= width) s += " " + words.shift();
        if (g.text_measure(s)[0] > width || (line === 1 && words.length)) {
            while (s && g.text_measure(s + "…")[0] > width) s = s.slice(0, -1);
            s += "…";
        }
        text(s, 12, 53 + line * 13, 10, false, false);
    }
}

function rounded(x, y, width, height, radius) {
    mgraphics.rectangle_rounded(x, y, width, height, radius, radius);
    mgraphics.fill();
}

function text(value, x, baseline, size, bold, centered) {
    mgraphics.select_font_face("Arial", "normal", bold ? "bold" : "normal");
    mgraphics.set_font_size(size);
    mgraphics.move_to(centered ? x - mgraphics.text_measure(value)[0] / 2 : x, baseline);
    mgraphics.show_text(value);
}

function paint() {
    if (phase === "editor") {
        const g = mgraphics, [w, h] = g.size;
        g.set_source_rgba(0.19, 0.20, 0.21, 0.77);
        g.rectangle(0, 0, w, h);
        g.fill();
        g.set_source_rgba(1, 1, 1, 1);
        text("Click to close plug-in window", w * (panelStart + panelWidth / 2), h / 2 + 4, 12, true, true);
        return;
    }
    if (phase !== "missing" && phase !== "loaderror" && phase !== "loading") return;
    const g = mgraphics, [w, h] = g.size;
    const [cardWidth, cardHeight] = cardSize(), buttonX = cardWidth - buttonWidth - 9;
    const loading = phase === "loading";
    g.set_source_rgba(0.07, 0.08, 0.11, 0.40);
    g.rectangle(w * panelStart, 0, w * panelWidth, h);
    g.fill();
    g.set_source_rgba(0.07, 0.08, 0.11, 0.20);
    g.rectangle(0, 0, w * panelStart, h);
    g.rectangle(w * (panelStart + panelWidth), 0, w * (1 - panelStart - panelWidth), h);
    g.fill();
    g.save();
    g.translate(w * (panelStart + panelWidth / 2) - cardWidth / 2, (h - cardHeight) / 2);
    if (loading) g.set_source_rgba(0.70, 0.70, 0.72, 1);
    else g.set_source_rgba(0.95, 0.61, 0.55, 1);
    rounded(0, 0, cardWidth, cardHeight, 5);
    const blend = (1 - Math.cos((Date.now() - started) * Math.PI / 1200)) / 2;
    if (loading) g.set_source_rgba(0.28, 0.27, 0.29, 1);
    else g.set_source_rgba(0.396 + 0.20 * blend, 0.153 + 0.09 * blend, 0.145 + 0.071 * blend, 1);
    rounded(1, 1, cardWidth - 2, cardHeight - 2, 4);
    g.set_source_rgba(1, 1, 1, 1);
    g.set_line_width(1.25);
    g.ellipse(12, 16, 16, 16);
    g.stroke();
    text(loading ? "…" : "!", 20, 29, 12, true, true);
    text(loading ? "Looking for VST3…" : phase === "loaderror" ? "VST3 load error" : "VST3 missing", 36, 21, 13, true, false);
    text("Audio passes through dry.", 36, 36, 10, false, false);
    if (phase === "loaderror") drawReason(cardWidth - 24);
    if (loading) g.set_source_rgba(0.59, 0.59, 0.60, 1);
    else g.set_source_rgba(1, 0.94, 0.91, 1);
    rounded(buttonX, buttonY, buttonWidth, buttonHeight, 4);
    g.set_source_rgba(0.23, 0.15, 0.14, 1);
    text("Retry", buttonX + buttonWidth / 2, 29, 11, true, true);
    g.restore();
}

function onclick(x, y, button, cmd, shift, caps, alt, ctrl, pointer) {
    if (phase === "editor" && !(pointer && pointer.contextModifier)) {
        outlet(0, "closeEditor");
        return;
    }
    if ((phase !== "missing" && phase !== "loaderror") || (pointer && pointer.contextModifier)) return;
    const [w, h] = mgraphics.size;
    const [cardWidth, cardHeight] = cardSize(), buttonX = cardWidth - buttonWidth - 9;
    const dx = x - (w * (panelStart + panelWidth / 2) - cardWidth / 2) - buttonX;
    const dy = y - (h - cardHeight) / 2 - buttonY;
    if (dx >= 0 && dx < buttonWidth && dy >= 0 && dy < buttonHeight) outlet(0, "retry");
}

function notifydeleted() { pulse.cancel(); }
