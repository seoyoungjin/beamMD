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

    private Appendable buffer;
    private Painter painter;

    private char lastChar;
    int yyy; // XXX

    public this(Appendable o) {
        buffer = o;
    }

    public this(Painter pr) {
        writeln(__FUNCTION__);

        import hunt.util.StringBuilder;
        buffer = new StringBuilder();

        yyy = 20;
        painter = pr;
    }

    public void whitespace() {
        writeln(__FUNCTION__);
        if (lastChar != 0 && lastChar != ' ') {
            append(' ');
        }
    }

    public void colon() {
        writeln(__FUNCTION__);
        if (lastChar != 0 && lastChar != ':') {
            append(':');
        }
    }

    public void line() {
        writeln(__FUNCTION__);
        if (lastChar != 0 && lastChar != '\n') {
            append('\n');
        }
    }

    public void writeStripped(string s) {
        writeln(__FUNCTION__);
        append(s.replaceAll(regex("[\\r\\n\\s]+"), " "));
    }

    public void write(string s) {
        writeln(__LINE__, " ", __FUNCTION__, " ", s);

        auto font0 = FontManager.instance.getFont(FontSelector(FontFamily.sans_serif, 20));

        TextStyle st;
        st.font = font0;
        st.color = NamedColor.purple;
        st.decoration = TextDecor(TextDecorLine.under, st.color);
        st.alignment = TextAlign.start;
        st.wrap = true;

        // drawSimpleText(painter, s, 0, 80, sz.w, st);
        drawSimpleText(painter, to!dstring(s), 0, yyy, 1000.0, st);
        yyy += 20;
    }

    public void write(char c) {
        writeln(__LINE__, __FUNCTION__, c);
        append(c);
    }

    private void append(string s) {
        writeln(__FUNCTION__);
        try {
            buffer.append(s);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        int length = cast(int)(s.length);
        if (length != 0) {
            lastChar = s.charAt(length - 1);
        }
    }

    private void append(char c) {
        writeln(__FUNCTION__);
        try {
            buffer.append(c);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        lastChar = c;
    }
}
