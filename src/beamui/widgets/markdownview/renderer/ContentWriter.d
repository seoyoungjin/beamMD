module beamui.widgets.markdownview.renderer.ContentWriter;

import std.stdio;
import std.regex;
import std.conv;
import beamui;
import beamui.text.simple : drawSimpleText;

import hunt.Exceptions;
import hunt.util.Appendable;
import hunt.util.Common;
import hunt.text.Common;

class ContentWriter {

    private Painter painter;
    private Size size;

    private Point current;
    private TextStyle style;

    public this(Painter pr, Size sz) {
        painter = pr;
        size = sz;
        current.x = current.y = 0;

        style.font = FontManager.instance.getFont(FontSelector(FontFamily.serif, 10));
        style.color = NamedColor.black;
        style.decoration = TextDecor(TextDecorLine.none, style.color);
        style.alignment = TextAlign.start;
        style.wrap = true;
    }

    public void setHeadingStyle(int h) {
        writeln(__FUNCTION__, " ", h);
        int[] sizes = [24, 24, 18, 16, 13, 11];
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.sans_serif, sizes[h]));
    }

    public void line() {
        writeln(__FUNCTION__);
        painter.drawLine(0, current.y + 2, size.w, current.y + 2, NamedColor.black);
        current.y += 5;
    }

    public void writeStripped(string s) {
        writeln(__FUNCTION__);
        s = s.replaceAll(regex("[\\r\\n\\s]+"), " ");
        int sz = style.font.size();
        drawSimpleText(painter, to!dstring(s), current.x, current.y + sz, size.w, style);
        current.y += sz;
    }

    public void write(string s) {
        writeln(__LINE__, " ", __FUNCTION__, " ", s);
        int sz = style.font.size();
        drawSimpleText(painter, to!dstring(s), current.x, current.y + sz, size.w, style);
        current.y += sz;
    }
}
