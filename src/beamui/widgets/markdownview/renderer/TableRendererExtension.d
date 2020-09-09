module beamui.widgets.markdownview.renderer.TableRendererExtension;

import hunt.collection.HashSet;
import hunt.collection.Set;

import hunt.markdown.Extension;

import hunt.markdown.ext.table.TableBlock;
import hunt.markdown.ext.table.TableBody;
import hunt.markdown.ext.table.TableCell;
import hunt.markdown.ext.table.TableHead;
import hunt.markdown.ext.table.TableRow;

import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;
import beamui.widgets.markdownview.renderer.ContentRenderer;
import beamui.widgets.markdownview.renderer.ContentNodeRendererFactory;
import beamui.widgets.markdownview.renderer.ContentNodeRendererContext;

import std.stdio;

class TableNodeRenderer : NodeRenderer {

    private ContentNodeRendererContext context;

    // TypeInfo for D
    override public Set!TypeInfo_Class getNodeTypes() {
        return new HashSet!TypeInfo_Class([
                typeid(TableBlock),
                typeid(TableHead),
                typeid(TableBody),
                typeid(TableRow),
                typeid(TableCell)
        ]);
    }

    public this(ContentNodeRendererContext context) {
        this.context = context;
    }


    public void render(Node node) {
        if (cast(TableBlock)node !is null) {
            renderBlock(cast(TableBlock) node);
        } else if (cast(TableHead)node !is null ) {
            renderHead(cast(TableHead) node);
        } else if (cast(TableBody)node !is null) {
            renderBody(cast(TableBody) node);
        } else if (cast(TableRow)node !is null) {
            renderRow(cast(TableRow) node);
        } else if (cast(TableCell)node !is null) {
            renderCell(cast(TableCell) node);
        }
    }

    protected void renderBlock(TableBlock node)
    {
        writeln(node);
        renderChildren(node);
    }

    protected void renderHead(TableHead node)
    {
        writeln(node);
        renderChildren(node);
    }

    protected void renderBody(TableBody node)
    {
        writeln(node);
        renderChildren(node);
    }

    protected void renderRow(TableRow node)
    {
        writeln(node);
        renderChildren(node);
    }

    protected void renderCell(TableCell node)
    {
        writeln(node);
        renderChildren(node);
    }

    private void renderChildren(Node parent) {
        Node node = parent.getFirstChild();
        while (node !is null) {
            Node next = node.getNext();
            context.render(node);
            node = next;
        }
    }
}

class TableRendererExtension : ContentRenderer.ContentRendererExtension {

    private this() { }

    public static Extension create() {
        return new TableRendererExtension();
    }

    override public void extend(ContentRenderer.Builder rendererBuilder) {
        rendererBuilder.nodeRendererFactory(new class ContentNodeRendererFactory {
            override public NodeRenderer create(ContentNodeRendererContext context) {
                return new TableNodeRenderer(context);
            }
        });
    }
}
