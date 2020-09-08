module beamui.widgets.markdownview;

import std.stdio;
import std.file;
import std.conv: to;

import beamui.core.config;
import beamui.core.geometry : Size;
import beamui.graphics.painter : Painter;
import beamui.widgets.controls;

import hunt.collection.Collections;
import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.ext.table;
import hunt.markdown.ext.matter.YamlFrontMatterExtension;

import beamui.widgets.markdownview.renderer.ContentRenderer;
import beamui.widgets.markdownview.renderer.FrontMatterExtension;;

// LATER - scrollview

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
        auto frontmatter = Collections.singleton(FrontMatterExtension.create());
        auto renderer = ContentRenderer.builder()
                .extensions(frontmatter)
                .build();
        return renderer;
    }

    private Node parse(string source) {
        auto fm_parser = Collections.singleton(YamlFrontMatterExtension.create());
        auto table_parser = Collections.singleton(TableExtension.create());
        Parser parser = Parser.builder()
                .extensions(fm_parser)
                .extensions(table_parser)
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
