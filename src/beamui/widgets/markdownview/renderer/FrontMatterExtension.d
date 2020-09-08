module beamui.widgets.markdownview.renderer.FrontMatterExtension;

import hunt.collection.HashSet;
import hunt.collection.Set;

import hunt.markdown.Extension;
import hunt.markdown.node.Node;
import hunt.markdown.ext.matter.YamlFrontMatterBlock;
import hunt.markdown.ext.matter.YamlFrontMatterNode;
import hunt.markdown.ext.matter.YamlFrontMatterVisitor;

import hunt.markdown.renderer.NodeRenderer;
import beamui.widgets.markdownview.renderer.ContentRenderer;
import beamui.widgets.markdownview.renderer.ContentNodeRendererFactory;
import beamui.widgets.markdownview.renderer.ContentNodeRendererContext;

import std.stdio;

class FrontMatterNodeRenderer : YamlFrontMatterVisitor, NodeRenderer {

    private ContentNodeRendererContext context;

    // TypeInfo for D
    override public Set!TypeInfo_Class getNodeTypes() {
        return new HashSet!TypeInfo_Class([
                typeid(YamlFrontMatterBlock),
                typeid(YamlFrontMatterNode)
        ]);
    }

    public this(ContentNodeRendererContext context) {
        this.context = context;
    }


    public void render(Node front) {
        writeln(front);
        front.accept(this);

        writeln(getData);
    }
}

class FrontMatterExtension : ContentRenderer.ContentRendererExtension {

    private this() { }

    public static Extension create() {
        return new FrontMatterExtension();
    }

    override public void extend(ContentRenderer.Builder rendererBuilder) {
        rendererBuilder.nodeRendererFactory(new class ContentNodeRendererFactory {
            override public NodeRenderer create(ContentNodeRendererContext context) {
                return new FrontMatterNodeRenderer(context);
            }
        });
    }
}
