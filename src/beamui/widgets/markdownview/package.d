module beamui.widgets.markdownview;

import std.stdio;
import std.file;
import std.conv: to;

import beamui.core.config;
import beamui.widgets.editors;

import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;

import beamui.widgets.markdownview.renderer.ContentRenderer;

class MarkDownView : TextArea
{
    this()
    {
        string source = readText("resources/spec.md");
        string rendered = defaultRenderer().render(parse(source));

        content = new EditableContent;
        content.text = to!dstring(rendered);
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
