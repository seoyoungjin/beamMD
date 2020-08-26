module beamui.widgets.markdownview;

import std.stdio;

import beamui.core.config;
import beamui.widgets.widget;

import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;

import beamui.widgets.markdownview.renderer.ContentRenderer;

class MarkDownView : Widget
{
    this()
    {
        string source = "foo foo\n\nbar\nbar";
        string rendered = defaultRenderer().render(parse(source));
        writeln(rendered);
    }

    // override void drawContent(Painter pr)
    // {
    // }

    private ContentRenderer defaultRenderer() {
        return ContentRenderer.builder().build();
    }


    private Node parse(string source) {
        return Parser.builder().build().parse(source);
    }
}
