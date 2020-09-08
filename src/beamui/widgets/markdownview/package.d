module beamui.widgets.markdownview;

import std.stdio;
import std.file;
import std.conv: to;

import beamui.core.config;
import beamui.widgets.widget;
import beamui.widgets.controls;

import hunt.collection.Collections;
import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.ext.table;
import hunt.markdown.ext.matter.YamlFrontMatterExtension;

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
        // writeln("drawContent size = ", sz);
        defaultRenderer().render(doc, pr, sz);
    }

    private ContentRenderer defaultRenderer() {
        auto frontmatter_ext = Collections.singleton(YamlFrontMatterExtension.create());
        auto table_ext = Collections.singleton(TableExtension.create());
        // LATER make extention
        // auto renderer = ContentRenderer.builder().build();
        auto renderer = ContentRenderer.builder()
                .extensions(frontmatter_ext)
                .extensions(table_ext)
                .build();
        return renderer;
    }

    private Node parse(string source) {
        auto frontmatter_ext = Collections.singleton(YamlFrontMatterExtension.create());
        auto table_ext = Collections.singleton(TableExtension.create());
        Parser parser = Parser.builder()
                .extensions(frontmatter_ext)
                .extensions(table_ext)
                .build();
        Node document = parser.parse(source);
        return document;
    }

    @property void filename(string filename)
    {
        string source = readText(filename);
        doc = parse(source);
    }
}
