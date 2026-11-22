autowatch=0;
inlets=1;
outlets=1;
mgraphics.init();
mgraphics.relative_coords=0;
mgraphics.autofill=0;
var outputSide=Number(jsarguments[1])===1;
var readings=null;
var ready=[false,false,false];
var names=["LUFS","RMS","Peak"];

function color(name,fallback){
    try{
        var found=max.getcolor(name);
        if(found && found.length>=3 && found[3]!==0)return found;
    }catch(e){}
    return fallback;
}
function fill(c){
    mgraphics.set_source_rgba(c[0],c[1],c[2],c[3]===undefined?1:c[3]);
}
function card(x,y,w,h,r,c){
    fill(c);mgraphics.rectangle_rounded(x,y,w,h,r,r);mgraphics.fill();
}
function label(value,x,y,size,c,bold){
    fill(c);mgraphics.select_font_face("Arial","normal",bold?"bold":"normal");
    mgraphics.set_font_size(size);mgraphics.move_to(x,y);mgraphics.show_text(value);
}
function brightness(c){return .2126*c[0]+.7152*c[1]+.0722*c[2];}
function shade(a,b,mix){return [a[0]*(1-mix)+b[0]*mix,a[1]*(1-mix)+b[1]*mix,a[2]*(1-mix)+b[2]*mix,1];}
function width(value,size,bold){
    mgraphics.select_font_face("Arial","normal",bold?"bold":"normal");
    mgraphics.set_font_size(size);
    return mgraphics.text_measure(value)[0];
}
function centered(value,x,y,size,c,bold){
    label(value,x-width(value,size,bold)/2,y,size,c,bold);
}
function formatted(db){
    if(db<=-200)return "−∞";
    var rounded=db.toFixed(1);
    return rounded==="-0.0"?"0.0":rounded;
}
function paint(){
    var w=mgraphics.size[0];
    var buttonWidth=54;
    var buttonX=w-buttonWidth-5;
    var center=(outputSide?buttonX-3:w)/2;
    var lcd=color("live_lcd_bg",[.16,.16,.17,1]);
    var bg=shade(lcd,[.50,.50,.50,1],.34);
    var themeText=color("live_lcd_fg",[.80,.97,.98,1]);
    var contrast=brightness(bg)<.46?[.84,.94,.95,1]:[.13,.18,.20,1];
    var fg=Math.abs(brightness(bg)-brightness(themeText))>.42?themeText:contrast;
    var line=shade(bg,fg,.21);
    var labelColor=shade(fg,bg,.26);
    card(0,3,w,163,4,line);
    card(1,4,w-2,161,3,bg);
    centered(outputSide?"OUTPUT":"INPUT",center,19,10,labelColor,true);
    for(var i=0;i<3;i++){
        var y=43+i*42;
        centered(names[i],center,y,9,labelColor,false);
        var value=readings===null?"—":formatted(readings[i]);
        var numberSize=i===0?17:15;
        centered(value,center,y+19,numberSize,fg,true);
        if(outputSide){
            card(buttonX,y,buttonWidth,20,3,shade(bg,fg,ready[i]?.39:.18));
            card(buttonX+1,y+1,buttonWidth-2,18,3,shade(bg,fg,ready[i]?.24:.105));
            centered("Gain match",buttonX+buttonWidth/2,y+13,9,ready[i]?fg:shade(fg,bg,.33),true);
        }
    }
}
function available(a,b,c){
    var next=[!!a,!!b,!!c];
    if(next.every(function(v,i){return v===ready[i];}))return;
    ready=next;mgraphics.redraw();
}
function levels(a,b,c){
    var next=[Number(a),Number(b),Number(c)];
    if(readings&&next.every(function(v,i){return formatted(v)===formatted(readings[i]);}))return;
    readings=next;mgraphics.redraw();
}
function clear(){readings=null;mgraphics.redraw();}
function theme(){mgraphics.redraw();}
function onclick(){outlet(0,"meter_reset");}
