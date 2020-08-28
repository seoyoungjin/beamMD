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
    string source;
    Node doc;

    this()
    {
        source = readText("resources/spec.md");
        doc = parse(source);
        onDraw = &drawContent;
    }

    void drawContent(Painter pr, Size sz)
    {
        writeln("drawContent size = ", sz);
        // content = new EditableContent;
        // content.text = to!dstring(rendered);
        // string rendered = defaultRenderer().render(parse(source));
        defaultRenderer().render(doc, pr);
    }

    private ContentRenderer defaultRenderer() {
        return ContentRenderer.builder().build();
    }


    private Node parse(string source) {
        return Parser.builder().build().parse(source);
    }
}
