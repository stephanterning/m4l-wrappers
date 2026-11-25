// Only send normalized values to the VST3. Formatting is for display.
autowatch = 0;
inlets = 1;
outlets = 1;
mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

const width = 506;
const height = 169;
const centerX = width / 2;
const startAngle = Math.PI * 0.75;
const sweep = Math.PI * 1.5;
const palette = {
    panel: [0.12, 0.125, 0.125], recessed: [0.035, 0.04, 0.04],
    surface: [0.25, 0.28, 0.29], track: [0.32, 0.34, 0.34],
    border: [0.38, 0.40, 0.39], label: [0.73, 0.73, 0.70],
    text: [0.94, 0.94, 0.89], accent: [1, 0.48, 0.27], warm: [1, 0.35, 0.18],
};
const defaults = [0, 0, 0, 0, 0.5, 1, 1, 1, 0, 0, 1];
const positions = defaults.slice();
const dials = [
    {slot: 1, x: centerX - 187, y: 84, r: 34, label: "D R I V E", display: n => (10 * n).toFixed(1)},
    {slot: 3, x: centerX - 59, y: 94, r: 17, label: "LOW CUT", display: n => frequency(20 * Math.pow(50, n))},
    {slot: 4, x: centerX, y: 94, r: 17, label: "TONE", display: n => signedDb(24 * n - 12), center: 0.5},
    {slot: 5, x: centerX + 59, y: 94, r: 17, label: "HIGH CUT", display: n => frequency(1000 * Math.pow(20, n))},
    {slot: 6, x: centerX + 204, y: 99, r: 17, label: "MIX", display: n => (100 * n).toFixed(1) + "%"},
    {slot: 10, x: centerX + 140, y: 48, r: 16, label: "OUTPUT", display: n => signedDb(24 * n - 24)},
];
const styles = ["A", "E", "N", "T", "P"].map((label, i) => ({
    label, slot: 0, value: i / 4, x: centerX - 15 + (i - 2) * 43, y: 131, width: 30, height: 30,
}));
const switches = [
    {label: "ON", caption: "PUNISH", slot: 2, x: centerX - 137, y: 27, width: 28, height: 28},
    {label: "THUMP", slot: 8, x: centerX - 126, y: 93, width: 30, toggle: true},
    {label: "STEEP", slot: 9, x: centerX + 96, y: 93, width: 30, toggle: true},
    {label: "AUTO", slot: 7, x: centerX + 165, y: 42, width: 30, toggle: true},
];
const openButton = {x: centerX - 99, y: 12, width: 198, height: 24};
const driveEditorButton = {x: dials[0].x - 32, y: 9, width: 64, height: 15};
const buttonHeight = 19;
let phase = "loading";
let trimMode = 0;
let drag = null;

function status(value) {
    const next = String(value);
    if (next === phase) return;
    phase = next;
    drag = null;
    mgraphics.redraw();
}
function values() {
    if (arguments.length !== positions.length) return;
    let changed = false;
    for (let i = 0; i < positions.length; i++) {
        const next = Number(arguments[i]);
        if (!Number.isFinite(next)) continue;
        const value = Math.max(0, Math.min(1, next));
        if (positions[i] === value) continue;
        positions[i] = value;
        changed = true;
    }
    if (changed) mgraphics.redraw();
}
function autoTrim(enabled) {
    const next = Number(enabled);
    if (next === trimMode || ![0, 1, 2].includes(next)) return;
    trimMode = next;
    mgraphics.redraw();
}
function edit(slot, normalized) {
    const value = Math.max(0, Math.min(1, normalized));
    if (positions[slot] === value && (slot !== 10 || trimMode === 0)) return false;
    positions[slot] = value;
    outlet(0, "param", slot, value);
    mgraphics.redraw();
    return true;
}

function frequency(hz) {
    return hz >= 1000 ? (hz / 1000).toFixed(2) + " kHz" : hz.toFixed(1) + " Hz";
}
function signedDb(value) {
    const rounded = Math.round(value * 10) / 10;
    return (rounded > 0 ? "+" : "") + rounded.toFixed(1) + " dB";
}
function color(rgb) {
    mgraphics.set_source_rgba(rgb[0], rgb[1], rgb[2], 1);
}
function rect(x, y, w, h, rgb) {
    color(rgb);
    mgraphics.rectangle(x, y, w, h);
    mgraphics.fill();
}
function rounded(x, y, w, h, radius, rgb) {
    color(rgb);
    mgraphics.rectangle_rounded(x, y, w, h, radius, radius);
    mgraphics.fill();
}
function text(value, x, baseline, size, rgb, centered, bold) {
    const g = mgraphics;
    g.select_font_face("Arial", "normal", bold ? "bold" : "normal");
    g.set_font_size(size);
    color(rgb);
    g.move_to(centered ? x - g.text_measure(value)[0] * 0.5 : x, baseline);
    g.show_text(value);
}
function ring(x, y, radius, first, last, rgb) {
    if (last <= first) return;
    color(rgb);
    mgraphics.set_line_width(2.6);
    mgraphics.arc(x, y, radius, startAngle + first * sweep, startAngle + last * sweep);
    mgraphics.stroke();
}
function line(x1,y1,x2,y2,rgb,weight) {
    color(rgb); mgraphics.set_line_width(weight || 1);
    mgraphics.move_to(x1,y1); mgraphics.line_to(x2,y2); mgraphics.stroke();
}
function disk(x,y,r,rgb) {
    color(rgb); mgraphics.ellipse(x-r,y-r,r*2,r*2); mgraphics.fill();
}
function button(control, selected) {
    const {x,y,width:w,label} = control;
    const h = control.height || buttonHeight;
    if (control.toggle) {
        const cx=x+w/2, cy=y+8;
        text(label,cx,y-3,7.5,palette.label,true,true);
        disk(cx,cy,6,palette.border); disk(cx,cy,4.5,palette.recessed);
        line(cx,cy+2,cx,cy+(selected?-6:5),selected?palette.text:palette.label,2.5);
        if (selected) disk(cx+9,cy,1.8,palette.accent);
        return;
    }
    if (control.caption) text(control.caption,x+w/2,y-5,8,palette.label,true,true);
    rounded(x,y,w,h,2,palette.recessed);
    rect(x+1,y+1,w-2,h-2,palette.border);
    rect(x+3,y+3,w-6,h-6,selected?palette.accent:palette.surface);
    line(x+3,y+3,x+w-3,y+3,selected?[1,0.70,0.49]:[0.48,0.51,0.51]);
    text(label,x+w/2,y+h/2+3.5,control.slot===2?9:11,palette.text,true,true);
}
function drawDial(dial) {
    const {x,y,r,label,slot} = dial;
    const value=positions[slot], mode=slot===10?trimMode:0;
    text(label,x,y-r-10,slot===1?10:8.5,palette.label,true,true);
    for (let i=0;i<=10;i++) {
        const a=startAngle+i*sweep/10;
        const rr=r+5;
        disk(x+Math.cos(a)*rr,y+Math.sin(a)*rr,0.95,palette.label);
    }
    disk(x+1,y+2,r+2,[0.025,0.027,0.027]);
    disk(x,y,r,[0.32,0.34,0.33]);
    disk(x,y,r-1,[0.12,0.14,0.14]);
    for(let i=0;i<28;i++) {
        const a=i*Math.PI/14;
        line(x+Math.cos(a)*(r-3),y+Math.sin(a)*(r-3),x+Math.cos(a)*(r-0.5),y+Math.sin(a)*(r-0.5),i<14?[0.23,0.25,0.25]:[0.07,0.08,0.08],1.1);
    }
    disk(x,y,r-5,[0.055,0.063,0.063]);
    disk(x-0.5,y-0.5,r-7,[0.10,0.115,0.115]);
    if(mode===0) {
        const a=startAngle+value*sweep;
        line(x+Math.cos(a)*(r-10),y+Math.sin(a)*(r-10),x+Math.cos(a)*(r-2),y+Math.sin(a)*(r-2),palette.text,2);
    } else if(mode===1) text("A",x,y+3,10,palette.accent,true,true);
    if (slot === 10) text(mode===1?"Auto":mode===2?"—":dial.display(value),x,y+r+12,8.5,mode===1?palette.accent:palette.text,true,false);
}
function paint() {
    const g=mgraphics;
    g.save(); g.scale(g.size[0]/width,g.size[1]/height);
    rect(0,0,width,height,[0.24,0.12,0.06]);
    for(let x=0;x<width;x+=2) {
        const shade=0.19+0.035*Math.sin(x*2.4);
        rect(x,0,1,height,[shade+0.12,shade*0.67,shade*0.32]);
    }
    rounded(9,3,width-18,height-6,4,palette.recessed);
    for(let y=6;y<height-6;y++) {
        const shade=0.10+0.055*Math.sin(Math.PI*y/height)+0.004*Math.sin(y*1.9);
        rect(12,y,width-24,1,[shade,shade+0.006,shade+0.006]);
    }
    rect(12,129,width-24,34,[0.07,0.075,0.075]);
    for(let y=131;y<163;y+=3) for(let x=14;x<width-14;x+=4) disk(x+(y%2),y,0.6,[0.015,0.019,0.019]);
    line(12,128,width-12,128,palette.border);
    text("D E C A P I T A T O R",centerX,28,13,palette.text,true,true);
    rounded(driveEditorButton.x, driveEditorButton.y, driveEditorButton.width, driveEditorButton.height, 2, palette.surface);
    text("Open plug-in", dials[0].x, driveEditorButton.y + 10.5, 8.5, palette.text, true, true);
    text("v1.0",37,153,8,[0.38,0.38,0.37],false,false);
    dials.forEach(drawDial);
    const style=Math.round(positions[0]*4);
    styles.forEach((choice,i)=>button(choice,i===style));
    switches.forEach(control=>button(control,positions[control.slot]>=0.5));
    for(const x of [19,width-19]) for(const y of [11,158]) {
        disk(x,y,3,[0.28,0.29,0.28]); line(x-1.5,y+1.5,x+1.5,y-1.5,palette.recessed,1.2);
    }
    g.restore();
}

function logical(x, y) {
    return [x * width / mgraphics.size[0], y * height / mgraphics.size[1]];
}
function insideButton(button, x, y) {
    return x >= button.x && x < button.x + button.width && y >= button.y && y < button.y + (button.height || buttonHeight);
}
function dialAt(x, y) {
    return dials.find(dial => Math.abs(x - dial.x) < dial.r + 8 && y >= dial.y - dial.r - 7 && y <= dial.y + dial.r + 14) || null;
}
function onclick(px, py, but, cmd, shift, caps, alt, ctrl, pointer) {
    if (phase !== "ready" || (pointer && pointer.contextModifier)) return;
    const [x, y] = logical(px, py);
    const dial = dialAt(x, y);
    if (dial) {
        drag = {slot: dial.slot, y};
        return;
    }
    const style = styles.find(button => insideButton(button, x, y));
    if (style) {
        edit(style.slot, style.value);
        return;
    }
    const toggle = switches.find(button => insideButton(button, x, y));
    if (toggle) {
        edit(toggle.slot, positions[toggle.slot] >= 0.5 ? 0 : 1);
        return;
    }
    if (insideButton(openButton, x, y) || insideButton(driveEditorButton, x, y)) outlet(0, "action");
}
function ondrag(px, py, but, cmd, shift) {
    if (phase !== "ready" || !drag) return;
    if (!but) {
        drag = null;
        return;
    }
    const [, y] = logical(px, py);
    const delta = (drag.y - y) / (shift ? 720 : 130);
    drag.y = y;
    if (delta) edit(drag.slot, positions[drag.slot] + delta);
}
function ondblclick(px, py) {
    if (phase !== "ready") return;
    const [x, y] = logical(px, py);
    const dial = dialAt(x, y);
    drag = null;
    if (dial) edit(dial.slot, defaults[dial.slot]);
}
onclick.local = 1;
ondrag.local = 1;
ondblclick.local = 1;
