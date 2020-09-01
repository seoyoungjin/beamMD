module beamui.widgets.markdownview;

import std.stdio;
import std.file;
import std.conv: to;

import beamui.core.config;
import beamui.widgets.widget;
import beamui.widgets.controls;

import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;

import beamui.widgets.markdownview.renderer.ContentRenderer;

// LATER - scrollview
// context - current position, css

class MarkDownView : Canvas
{
    Node doc;

    this()
    {
        onDraw = &drawContent;
    }

    void drawContent(Painter pr, Size sz)
    {
        writeln("drawContent size = ", sz);
        defaultRenderer().render(doc, pr, sz);
    }

    private ContentRenderer defaultRenderer() {
        return ContentRenderer.builder().build();
    }

    private Node parse(string source) {
        return Parser.builder().build().parse(source);
    }

    @property void filename(string filename)
    {
        string source = readText(filename);
        doc = parse(source);
    }
}
