autowatch=0;inlets=1;outlets=0;
mgraphics.init();mgraphics.relative_coords=0;mgraphics.autofill=0;
var skin=null; // The builder can embed a locally supplied Oxford skin.
var vals=[0,0,0,0,1,0,1,0], state="cold";
var W=318,H=169;
function value(i,v){if(vals[i]!==v){vals[i]=v;mgraphics.redraw();}}
function status(s){if(state!==s){state=s;mgraphics.redraw();}}
function col(g,c){g.set_source_rgba(c[0],c[1],c[2],c.length===4?c[3]:1);}
function rect(g,x,y,w,h,c){col(g,c);g.rectangle(x,y,w,h);g.fill();}
function rr(g,x,y,w,h,r,c){col(g,c);g.rectangle_rounded(x,y,w,h,r,r);g.fill();}
function txt(g,t,x,y,size,c,align,bold){
    g.select_font_face("Arial","normal",bold?"bold":"normal");g.set_font_size(size);
    var tw=g.text_measure(t)[0];col(g,c);g.move_to(x-(align===1?tw*.5:align===2?tw:0),y);g.show_text(t);
}
function art(g,x,y,w,h,X,Y,ww,hh){g.image_surface_draw(skin,x,y,w,h,X,Y,ww,hh);}
var dark=[.075,.095,.14],ink=[.045,.055,.075],pale=[.94,.96,1],yellow=[.92,.88,.41];
function readout(g,s,cx){
    rr(g,cx-23,45,46,15,2,[.10,.11,.16]);rr(g,cx-22,46,44,12,1,[.155,.18,.25]);
    txt(g,s,cx,56.4,11,yellow,1,false);
}
function fader(g,i,cx){
    var min=[-6,0,-50,-12][i],max=[12,100,50,0][i];
    var norm=Math.max(0,Math.min(1,(vals[i]-min)/(max-min)));
    var y=146-69*norm;
    rr(g,cx-12,64,24,97,2,[.21,.29,.44,.19]);
    rr(g,cx-2,74,4,76,2,[.19,.24,.34]);rr(g,cx-1,76,2,71,1,[.44,.51,.65]);
    if(skin) art(g,49,405,57,111,cx-12,y-14,24,29);
    else {
        rr(g,cx-11,y-10,22,20,3,[.76,.80,.88]);
        rect(g,cx-8,y-1,16,2,ink);
    }
}
function button(g,cx,y,label,v,oncolor){
    var c=v?oncolor:[.61,.66,.75];
    rr(g,cx-28,y+2,57,22,1,[.22,.24,.32]);rect(g,cx-28,y,56,22,[.25,.28,.35]);
    rect(g,cx-27,y+1,54,20,[.93,.95,.98]);rect(g,cx-25,y+3,50,16,c);
    rect(g,cx-24,y+4,48,2,[1,1,1,.20]);g.select_font_face("Arial","normal","bold");
    g.set_font_size(9);
    var labelWidth=g.text_measure(label)[0];
    var fontSize=Math.min(9,9*44/Math.max(1,labelWidth));
    txt(g,label,cx,y+14,fontSize,ink,1,true);
}
function paintFace(g){
    rect(g,0,0,W,H,dark);
    if(skin){
    art(g,5,6,875,47,2,2,314,23);
    art(g,8,58,11,619,2,27,60,140);art(g,279,58,10,619,64,27,189,140);
    art(g,864,58,12,619,255,27,61,140);
    }else{
        rect(g,2,2,314,23,[.23,.31,.46]);
        txt(g,"Oxford Inflator",159,18,14,pale,1,true);
        rect(g,2,27,60,140,[.28,.37,.52]);
        rect(g,64,27,189,140,[.68,.73,.82]);
        rect(g,255,27,61,140,[.28,.37,.52]);
    }
    var xs=[32,94,222,286],titles=["INPUT","EFFECT","CURVE","OUTPUT"];
    for(var i=0;i<4;i++){
        txt(g,titles[i],xs[i],41,11,i===0||i===3?pale:ink,1,true);
        var v=vals[i],display=i===0||i===3?v.toFixed(1)+" dB":i===1?Math.round(v)+" %":String(Math.round(v));
        readout(g,display,xs[i]);fader(g,i,xs[i]);
    }

    txt(g,"v1.0",158,41,9,[.28,.35,.48],1,false);
    button(g,158,68,"CLIP 0 dB",vals[6],[.96,.38,.43]);
    button(g,158,100,"BAND SPLIT",vals[5],[.98,.82,.27]);
    button(g,158,132,"EFFECT IN",vals[4],[.24,.92,.58]);
    if(state==="missing"||state==="loading"){
        rect(g,54,2,210,23,state==="missing"?[.30,.135,.09]:[.22,.32,.46]);
        txt(g,state==="missing"?"VST3 missing   ·   Retry":"Loading Oxford Inflator…",159,18,12,pale,1,true);
    }
}
function paint(){var g=mgraphics;g.save();var size=g.size;g.scale(size[0]/W,size[1]/H);paintFace(g);g.restore();}
