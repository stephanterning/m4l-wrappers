mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

inlets = 1;
outlets = 0;

var label = String(jsarguments[1]);

function set(value) {
    label = String(value);
    mgraphics.redraw();
}

function paint() {
    var g = mgraphics;
    var size = g.size;
    g.select_font_face("Arial", "normal", "normal");
    g.set_font_size(9);
    g.set_source_rgba(0.82, 0.82, 0.82, 1);
    g.move_to((size[0] - g.text_measure(label)[0]) / 2, size[1] / 2 + 3);
    g.show_text(label);
}
