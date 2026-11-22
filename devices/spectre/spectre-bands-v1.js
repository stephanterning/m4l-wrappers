// Spectre band editor. VST3 parameters travel as zero-based indices and normalized values.
autowatch = 0;
inlets = 1;
outlets = 1;
mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

var W = 610, H = 169, SIDE = 427;
var plot = {left:29, right:414, top:39, bottom:143};
function rgb(hex) {
    return [((hex >> 16)&255)/255, ((hex >> 8)&255)/255, (hex&255)/255];
}
var P = {
    graph:rgb(0x101638), graphBottom:rgb(0x161947), panel:rgb(0x171c44),
    well:rgb(0x111737), field:rgb(0x242b56), border:rgb(0x292f59),
    grid:rgb(0x252d53), major:rgb(0x30375d),
    edge:rgb(0x5b689b), soft:rgb(0xb4bbdf),
    text:rgb(0xedf0ff), glow:rgb(0x9eafff),
    black:rgb(0x131638), warn:rgb(0xfcb082)
};
var colors = [0xec58f3,0xb875ff,0xa18aff,0x7399ff,0x42c8f4].map(rgb);
var spectrumStops = [0,.23,.48,.73,1];
var titleColors = [0xeda2f8,0xe1a6fb,0xd3a9fc,0xc4adfd,0xb4b1fe,0xa1b5ff,0x8eb8ff].map(rgb);
var types = ["Low shelf","Bell","Bell","Bell","High shelf"];
var colorNames = ["Solid","Warm","Tube","Tape","Class B","Diode","Digital","Bit","Rectify","Half Rectify","Clean"];
var channels = ["Stereo","Left","Right","Mid","Side"];
var qualityNames = ["Normal","Good","Best"];
var modeNames = ["Subtle","Medium","Aggressive"];
var logSpan = Math.log(1000);
var state = "loading", selected = 2, globalPage = false;
var values = [], targets = [], drag = null, menu = null;
var frequencyDefaults = [.10768191516399384,.3046046197414398,.5000101923942566,.6966350078582764,.893747091293335];
for (var b = 0; b < 5; b++) {
    values.push(frequencyDefaults[b], 0, .06131313368678093, 1, 0, 0);
}
values = values.concat([0.5,0.5,0.5,0,0.5,1,0,0,0]);

var factoryDefaults = values.slice();

function clamp(v, lo, hi) { return Math.min(hi,Math.max(lo,v)); }
function validIndex(i) { return i === (i|0) && i >= 0 && i < 39; }
function receive(i, v) {
    if (!validIndex(i) || !isFinite(v)) return false;
    v = clamp(v,0,1);
    if (values[i] === v) return false;
    values[i] = v;
    return true;
}
function param(i, v) {
    if (receive(+i,+v)) mgraphics.redraw();
}
function params() {
    if (arguments.length !== 39) return;
    var changed = false;
    for (var i = 0; i < 39; i++) {
        if (receive(i,Number(arguments[i]))) changed = true;
    }
    if (changed) mgraphics.redraw();
}
function status(s) {
    s = String(s);
    if (state !== s) {
        state = s;
        mgraphics.redraw();
    }
}
function edit(i, v) {
    if (receive(i,v)) {
        outlet(0,"param",i,values[i]);
        mgraphics.redraw();
    }
}
function choices(i) {
    if (i >= 0 && i < 30 && i%6 === 4) return colorNames;
    if ((i >= 0 && i < 30 && i%6 === 5) || i === 37) return channels;
    if (i === 34) return qualityNames;
    if (i === 36) return modeNames;
    return null;
}
function setView(isGlobal, band) {
    if (globalPage === isGlobal && selected === band) return;
    globalPage = isGlobal;
    selected = band;
    mgraphics.redraw();
}
function pick(i) { setView(false,i); }

function source(c, alpha) {
    mgraphics.set_source_rgba(c[0],c[1],c[2],alpha === undefined ? 1 : alpha);
}
function addStop(pattern, position, c, alpha) {
    pattern.add_color_stop_rgba(position,c[0],c[1],c[2],alpha);
}
function spectrum(alpha) {
    var pattern=mgraphics.pattern_create_linear(plot.left,0,plot.right,0);
    for (var i=0;i<colors.length;i++) addStop(pattern,spectrumStops[i],colors[i],alpha);
    return pattern;
}
function rect(x,y,w,h,c) {
    source(c); mgraphics.rectangle(x,y,w,h); mgraphics.fill();
}
function roundRect(x,y,w,h,r,c,alpha) {
    source(c,alpha); mgraphics.rectangle_rounded(x,y,w,h,r,r); mgraphics.fill();
}
function disk(x,y,r,c) {
    source(c); mgraphics.ellipse(x-r,y-r,2*r,2*r); mgraphics.fill();
}
function line(x1,y1,x2,y2,c,w,alpha) {
    source(c,alpha); mgraphics.set_line_width(w);
    mgraphics.move_to(x1,y1); mgraphics.line_to(x2,y2); mgraphics.stroke();
}
function label(s,x,y,size,c,align,bold) {
    s = String(s);
    var g = mgraphics;
    g.select_font_face("Arial","normal",bold ? "bold" : "normal");
    g.set_font_size(size);
    var width = align ? g.text_measure(s)[0] : 0;
    source(c);
    g.move_to(x - width*(align === 1 ? 0.5 : 1),y); g.show_text(s);
}
function target(type,x,y,w,h,index) {
    targets.push({type:type,x:x,y:y,w:w,h:h,index:index});
}
function xHz(f) { return plot.left + Math.log(f/20)/logSpan*(plot.right-plot.left); }
function yDb(db) { return plot.bottom - (plot.bottom-plot.top)*db/12; }
function xBand(i) {return plot.left + values[i*6]*(plot.right-plot.left);}
function yBand(i) {return yDb(values[i*6+1]*12);}

function header() {
    var name="SPECTRE", left=10;
    for (var letter=0;letter<name.length;letter++) {
        var ch=name.charAt(letter);
        label(ch,left,16.5,12,titleColors[letter],0,true);
        left+=mgraphics.text_measure(ch)[0]+1.15;
    }
    label("v1.0",left+5,16,8.5,P.soft);
    var x, i;
    // Direct band selection keeps coincident handles independently reachable.
    for (i=0;i<5;i++) {
        x=147+i*24;
        roundRect(x,4,21,17,3,P.well);
        if (i===selected) {
            roundRect(x,4,21,17,3,colors[i],.52);
            roundRect(x+1,5,19,15,2,P.field);
        }
        label(i+1,x+10.5,16,9.5,colors[i],1,true);
        target("band",x-1,2,23,21,i);
    }
    var title = state === "missing" ? "VST3 missing · Retry" : state === "ready" ? "Open plug-in" : "Loading…";
    var width = state === "missing" ? 103 : 73;
    x = SIDE-width-6;
    roundRect(x,4,width,17,3,P.field);
    label(title,x+width/2,16,9.4,state === "missing" ? P.warn : P.text,1,true);
    if (state === "missing" || state === "ready") target("action",x,2,width,21,0);
    line(0,25,SIDE,25,P.grid,1);
}
function grid(spectralLine) {
    var f, x, mult, decade, y, db, i;
    for (decade=10;decade<=10000;decade*=10) {
        for (mult=1;mult<=9;mult++) {
            f=mult*decade;
            if (f<20 || f>20000) continue;
            x=xHz(f);
            line(x,plot.top,x,plot.bottom,mult===1?P.major:P.grid,mult===1?1:0.72);
        }
    }
    var ticks=[20,50,100,200,500,1000,2000,5000,10000,20000];
    for (i=0;i<ticks.length;i++) {
        f=ticks[i]; x=xHz(f);
        label(f>=1000 ? String(f/1000)+"k" : f,x,161,8.4,P.soft,f===20?0:f===20000?2:1);
    }
    for (db=3;db<=12;db+=3) {
        y=yDb(db);
        line(plot.left,y,plot.right,y,P.grid,0.9);
        if (db%6===0) label("+"+db,plot.left-5,y+3,8.3,P.soft,2);
    }
    var g=mgraphics;
    g.set_source(spectralLine);g.set_line_width(1.2);
    g.move_to(plot.left,plot.bottom);g.line_to(plot.right,plot.bottom);g.stroke();
}

// Analogue bell/shelf magnitudes describe the band controls; no audio-rate analyzer.
function bandGain(i,r,q,a) {
    var r2=r*r, d=1-r2, k=r/q, n, den;
    if (i===0 || i===4) {
        if (i===4) {r=1/r;r2=r*r;k=r/q;}
        n = (a-r2)*(a-r2)+a*k*k;
        den = (1-a*r2)*(1-a*r2)+a*k*k;
        return 10*Math.log(a*a*n/den)/Math.LN10;
    }
    return 10*Math.log((d*d+a*a*k*k)/(d*d+k*k/(a*a)))/Math.LN10;
}
var curveSteps=142, curveFreq=[];
for (var k=0;k<=curveSteps;k++) curveFreq.push(20*Math.exp(logSpan*k/curveSteps));
function curve(i, spectralLine, spectralFill) {
    var base=i*6, db=12*values[base+1];
    if (values[base+3]<0.5 || db<0.001) return;
    var g=mgraphics, q=0.1+9.9*values[base+2], a=Math.pow(10,db/40);
    var freq=20*Math.exp(logSpan*values[base]), j, x, y;
    // Bound paths to the displayed range at high shelf resonances.
    for (j=0;j<=curveSteps;j++) {
        x=plot.left+(plot.right-plot.left)*j/curveSteps;
        y=yDb(clamp(bandGain(i,curveFreq[j]/freq,q,a),0,12));
        if (!j) g.move_to(x,y); else g.line_to(x,y);
    }
    g.set_source(spectralLine); g.set_line_width(i===selected?1.7:1.15);
    g.stroke_preserve();
    g.line_to(plot.right,plot.bottom); g.line_to(plot.left,plot.bottom); g.close_path();
    g.set_source(spectralFill); g.fill();
    if (i===0 || i===4) line(xBand(i),yDb(db/2),xBand(i),yBand(i),colors[i],0.9,0.66);
}
function handle(i) {
    var x=xBand(i),y=yBand(i),c=colors[i],on=values[i*6+3]>=0.5;
    if (i===selected) {
        disk(x,y,10,c);
        disk(x,y,9,P.graph);
    }
    disk(x,y,7,c);
    if (!on) disk(x,y,5.9,P.panel);
    label(i+1,x,y+3.1,9.5,on?P.black:c,1,true);
}
function tabs() {
    var x=SIDE+6,w=(W-x-8)/2,i;
    for (i=0;i<2;i++) {
        var active = Boolean(i) === globalPage;
        roundRect(x+i*(w+2),4,w,18,3,active?P.field:P.well);
        if (active) rect(x+i*(w+2)+3,20,w-6,1.4,i===0?colors[selected]:P.glow);
        label(i===0?"Band":"Global",x+i*(w+2)+w/2,16.5,10,active?P.text:P.soft,1,true);
        target("page",x+i*(w+2),3,w,20,i);
    }
}
function freqText(n) {
    var f=20*Math.exp(logSpan*n);
    if (f<1000) return Math.round(f)+" Hz";
    return (f/1000).toFixed(f>=10000?1:2)+" kHz";
}
function dBText(d) {
    return (d>=0.05?"+":"")+(Math.abs(d)<0.05?"0.0":d.toFixed(1))+" dB";
}
function dial(i,name,read,x,y,r,c) {
    var g=mgraphics,from=Math.PI*0.75,to=from+Math.PI*1.5,ang=from+(to-from)*values[i];
    label(name,x,y-r-6,9.6,P.text,1,true);
    g.set_line_width(3);source(P.well);g.arc(x,y,r,from,to);g.stroke();
    if (values[i]>0.00001) {source(c);g.arc(x,y,r,from,ang);g.stroke();}
    source(P.field);g.ellipse(x-r+1.9,y-r+1.9,2*r-3.8,2*r-3.8);g.fill();
    line(x+Math.cos(ang)*r*0.35,y+Math.sin(ang)*r*0.35,
         x+Math.cos(ang)*(r-3.2),y+Math.sin(ang)*(r-3.2),P.text,1.6);
    label(read,x,y+r+13,9.2,globalPage?P.soft:c,1);
    target("dial",x-23,y-r-14,46,r*2+31,i);
}
function chooser(i,title,x,y,w) {
    var items=choices(i),row=Math.round(values[i]*(items.length-1));
    label(title,x+1,y-3,9,P.soft);
    roundRect(x,y,w,19,3,P.field);
    label(items[row],x+5,y+13,9.2,P.text);
    line(x+w-11,y+8,x+w-8,y+11,P.soft,1);
    line(x+w-8,y+11,x+w-5,y+8,P.soft,1);
    target("menu",x,y,w,19,i);
}
// Paint the popup inside the graph, leaving its originating control and label visible.
function openMenu(t) {
    var items=choices(t.index),cols=items.length>6?2:1;
    var rows=Math.ceil(items.length/cols),width=cols===1?105:178,height=26+16*rows;
    menu={index:t.index,items:items,rows:rows,cols:cols,w:width,h:height,
          x:SIDE-8-width,y:clamp(Math.round(t.y+t.h/2-height/2),28,152-height)};
    mgraphics.redraw();
}
function menuBox(i) {
    var width=(menu.w-6)/menu.cols,col=Math.floor(i/menu.rows),row=i%menu.rows;
    return {x:menu.x+3+col*width,y:menu.y+23+row*16,w:width,h:16};
}
function menuAt(x,y) {
    for (var i=0;i<menu.items.length;i++) {
        var r=menuBox(i);
        if (x>=r.x && x<r.x+r.w && y>=r.y && y<r.y+r.h) return i;
    }
    return -1;
}
function drawMenu() {
    var i=menu.index,names=menu.items,current=Math.round(values[i]*(names.length-1));
    var title=i===34?"Quality":i===36?"Mode":i<30 && i%6===4?"Saturation":"Channel";
    var c=globalPage?P.glow:colors[selected];
    roundRect(menu.x+1,menu.y+2,menu.w,menu.h,4,P.black);
    roundRect(menu.x,menu.y,menu.w,menu.h,4,P.edge);
    roundRect(menu.x+1,menu.y+1,menu.w-2,menu.h-2,3,P.panel);
    label(title,menu.x+9,menu.y+15,10,P.text,0,true);
    line(menu.x+4,menu.y+20,menu.x+menu.w-4,menu.y+20,P.major,1);
    for (i=0;i<names.length;i++) {
        var r=menuBox(i);
        if (i===current) {
            roundRect(r.x+1,r.y+0.6,r.w-2,r.h-1.2,2,P.field);
            line(r.x+4,r.y+8,r.x+6.5,r.y+10.5,c,1.3);
            line(r.x+6.5,r.y+10.5,r.x+10.5,r.y+5,c,1.3);
        }
        label(names[i],r.x+14,r.y+11.7,9.7,i===current?c:P.text,0,i===current);
    }
}
function toggle(i,title,x,y,w) {
    var on=values[i]>=0.5, c=globalPage?P.glow:colors[selected];
    roundRect(x,y+2,11,11,2,on?c:P.edge);
    if (on) {
        line(x+2,y+7,x+4.5,y+9.5,P.black,1.4);
        line(x+4.5,y+9.5,x+9.2,y+4.2,P.black,1.4);
    } else roundRect(x+1,y+3,9,9,1.3,P.well);
    label(title,x+15,y+11.4,9.5,P.text);
    target("toggle",x,y-1,w,18,i);
}
function inputLink(x,y) {
    var on=values[33]>=0.5, ink=on?P.black:P.soft, g=mgraphics;
    if (on) roundRect(x-9,y-7,18,14,4,P.glow);
    source(ink,on?1:.68);g.set_line_width(1.5);
    for (var side=-1;side<=1;side+=2) {
        var cx=x+side*(on?2.75:3.45);
        g.rectangle_rounded(cx-2.65,y-1.65,5.3,3.3,1.65,1.65);g.stroke();
    }
    if (on) line(x-1.5,y,x+1.5,y,ink,1.5);
    target("toggle",x-9,y-8,18,16,33);
}
function inspector() {
    var x=SIDE+7,w=W-x-7;
    tabs();
    if (globalPage) {
        dial(30,"Input",dBText(24*values[30]-12),x+w/6,81,14,P.glow);
        dial(31,"Output",dBText(24*values[31]-12),x+w/2,81,14,P.glow);
        dial(32,"Mix",Math.round(100*values[32])+" %",x+5*w/6,81,14,P.glow);
        chooser(34,"Quality",x,137,95);
        chooser(36,"Mode",x+99,137,w-99);
        toggle(35,"De-emphasis",x+w-72,30,72);
        inputLink(x+w/3,81);
    } else {
        var base=selected*6,c=colors[selected];
        roundRect(x,30,15,15,3,c); label(selected+1,x+7.5,41,9.5,P.black,1,true);
        label(types[selected],x+20,41.5,10.8,P.text,0,true);
        toggle(base+3,"On",x+w-31,30,32);
        dial(base,"Freq",freqText(values[base]),x+w/6,81,14,c);
        dial(base+1,"Gain",dBText(12*values[base+1]),x+w/2,81,14,c);
        dial(base+2,"Q",(0.1+9.9*values[base+2]).toFixed(2),x+5*w/6,81,14,c);
        chooser(base+4,"Saturation",x,137,95);
        chooser(base+5,"Channel",x+99,137,w-99);
    }
}
function paint() {
    var g=mgraphics,size=g.size,i;
    targets=[];
    g.save();g.scale(size[0]/W,size[1]/H);
    var background=g.pattern_create_linear(0,0,0,H);
    addStop(background,0,P.graph,1);addStop(background,1,P.graphBottom,1);
    g.set_source(background);g.rectangle(0,0,SIDE,H);g.fill();
    rect(SIDE,0,W-SIDE,H,P.panel);
    var spectralLine=spectrum(1);
    header();grid(spectralLine);
    var otherLine=spectrum(.73), otherFill=spectrum(.30);
    for (i=0;i<5;i++) if (i!==selected) curve(i,otherLine,otherFill);
    curve(selected,spectralLine,spectrum(.53));
    for (i=0;i<5;i++) if (i!==selected) handle(i);
    handle(selected);
    line(SIDE,0,SIDE,H,P.border,1);
    inspector();
    if (menu) drawMenu();
    g.restore();
}

function logical(x,y) {return [x*W/mgraphics.size[0],y*H/mgraphics.size[1]];}
function nodeAt(x,y) {
    if (x<plot.left-12 || x>plot.right+12 || y<plot.top-12 || y>plot.bottom+12) return -1;
    var nearest=-1,min=12*12,i,dx,dy,dist;
    for (i=0;i<5;i++) {
        dx=xBand(i)-x;dy=yBand(i)-y;dist=dx*dx+dy*dy;
        if (dist<min || (dist===min && i===selected)) {min=dist;nearest=i;}
    }
    return nearest;
}
function targetAt(x,y) {
    for (var i=targets.length-1;i>=0;i--) {
        var t=targets[i];
        if (x>=t.x && x<t.x+t.w && y>=t.y && y<t.y+t.h) return t;
    }
    return null;
}
// V8 normalizes Command on macOS and Ctrl on Windows in pointer.commandKey.
function commandHeld(pointer,cmd) {
    return pointer && pointer.commandKey !== undefined ? pointer.commandKey : cmd;
}
function modifier(cmd,alt) {return alt?"q":cmd?"freq":"free";}
function onidleout() {
    if (menu) {menu=null;mgraphics.redraw();}
}
function onclick(px,py,but,cmd,shift,caps,alt,ctrl,pointer) {
    var p=logical(px,py),x=p[0],y=p[1],idx=nodeAt(x,y),t;
    drag=null;
    if (pointer && ((pointer.buttons & 2) || pointer.contextModifier)) {
        if (menu || idx<0) return;
        pick(idx);
        var parameter=idx*6+4;
        var count=colorNames.length;
        var current=Math.round(values[parameter]*(count-1));
        var direction=commandHeld(pointer,cmd) ? -1 : 1;
        edit(parameter,((current+direction+count)%count)/(count-1));
        return;
    }
    if (menu) {
        var row=menuAt(x,y),which=menu.index,count=menu.items.length;
        menu=null;
        if (row>=0) edit(which,row/(count-1));
        mgraphics.redraw();
        return;
    }
    if (idx>=0) {
        pick(idx);
        drag={kind:"node",i:idx,x:x,y:y,mode:modifier(commandHeld(pointer,cmd),alt),axis:""};
        return;
    }
    t=targetAt(x,y);
    if (!t) return;
    if (t.type==="band") pick(t.index);
    else if (t.type==="page") setView(Boolean(t.index),selected);
    else if (t.type==="action") outlet(0,"action");
    else if (t.type==="toggle") edit(t.index,values[t.index]>=0.5?0:1);
    else if (t.type==="dial") drag={kind:"dial",i:t.index,x:x,y:y};
    else if (t.type==="menu") openMenu(t);
}
function ondrag(px,py,but,cmd,shift,caps,alt,ctrl,pointer) {
    if (!drag) return;
    if (!but) {drag=null;return;}
    var p=logical(px,py),x=p[0],y=p[1],dx=x-drag.x,dy=drag.y-y;
    if (drag.kind==="dial") {
        edit(drag.i,values[drag.i]+dy/(shift?720:135));
    } else {
        var mode=modifier(commandHeld(pointer,cmd),alt),base=drag.i*6;
        if (mode!==drag.mode) {
            drag.mode=mode;
            drag.axis="";
        } else if (mode==="q") {
            // Both vertical and horizontal Option drags work. Latch the first axis.
            if (!drag.axis) {
                if (Math.max(Math.abs(dx),Math.abs(dy))<1) return;
                drag.axis=Math.abs(dy)>=Math.abs(dx)?"y":"x";
            }
            var q=0.1+9.9*values[base+2];
            q*=Math.exp((drag.axis==="y"?dy:dx)*Math.log(100)/150);
            edit(base+2,(q-0.1)/9.9);
        } else {
            if (dx) edit(base,values[base]+dx/(plot.right-plot.left));
            if (mode==="free" && dy) edit(base+1,values[base+1]+dy/(plot.bottom-plot.top));
        }
    }
    drag.x=x;drag.y=y;
}
function ondblclick(px,py) {
    if (menu) return;
    var p=logical(px,py), t=targetAt(p[0],p[1]);
    if (t && t.type==="dial") {
        drag=null;
        edit(t.index,factoryDefaults[t.index]);
    }
}
ondblclick.local=1;
onclick.local=1;
ondrag.local=1;
onidleout.local=1;
