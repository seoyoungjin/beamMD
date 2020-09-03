module beamui.widgets.markdownview.renderer.CoreContentNodeRenderer;

import hunt.markdown.node;
import hunt.markdown.node.AbstractVisitor;
import hunt.markdown.node.Heading;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.internal.renderer.text.BulletListHolder;
import hunt.markdown.internal.renderer.text.ListHolder;
import hunt.markdown.internal.renderer.text.OrderedListHolder;

import hunt.collection.HashSet;
import hunt.collection.Set;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.collection.Collections;
import hunt.text;

import std.stdio;
import std.regex;
import std.conv;

import beamui.core.geometry : Point, Size;
import beamui.graphics.colors;
import beamui.graphics.painter : Painter;
import beamui.text.fonts;
import beamui.text.line;
import beamui.text.simple;
import beamui.text.style;

import beamui.widgets.markdownview.renderer.ContentNodeRendererContext;

const int DEFAULT_FONT_SIZE = 16;
const float[] HEADING_FONT_SIZES = [32, 24, 18.72, 16, 13.28, 10.72];
const int HEADING_UPPPER_SPACE = 3;
const int HEADING_UNDER_SPACE = 5;

/**
 * The node renderer that renders all the core nodes (comes last in the order of node renderers).
 */
class CoreContentNodeRenderer : AbstractVisitor, NodeRenderer {

    protected ContentNodeRendererContext context;
    private ListHolder listHolder;

    private Painter painter;
    private Size viewport;
    private Point current;
    private TextStyle style;

    public this(ContentNodeRendererContext context) {
        this.context = context;

        this.painter = context.painter();
        this.viewport = context.viewport();
        this.current.x = this.current.y = 0;

        // LATER
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.serif, DEFAULT_FONT_SIZE));
        style.color = NamedColor.black;
        style.decoration = TextDecor(TextDecorLine.none, style.color);
        style.alignment = TextAlign.start;
        style.wrap = true;
    }

    override public Set!TypeInfo_Class getNodeTypes() {
        return new HashSet!TypeInfo_Class([
                typeid(Document),
                typeid(Heading),
                typeid(Paragraph),
                typeid(BlockQuote),
                typeid(BulletList),
                typeid(FencedCodeBlock),
                typeid(HtmlBlock),
                typeid(ThematicBreak),
                typeid(IndentedCodeBlock),
                typeid(Link),
                typeid(ListItem),
                typeid(OrderedList),
                typeid(Image),
                typeid(Emphasis),
                typeid(StrongEmphasis),
                typeid(Text),
                typeid(Code),
                typeid(HtmlInline),
                typeid(SoftLineBreak),
                typeid(HardLineBreak)
        ]);
    }

    public void render(Node node) {
        writeln("render(node) ", node);
        node.accept(this);
    }

    override public void visit(Document document) {
        painter.drawLine(0, current.y, viewport.w, current.y, NamedColor.red); // DEBUG
        visitChildren(document);
    }

    override public void visit(Heading heading) {
        writeln("visit(heading) ", heading.getLevel());
        auto h = heading.getLevel();
        int size = cast(int)(DEFAULT_FONT_SIZE * HEADING_FONT_SIZES[h] / 10 + 0.5);

        current.x = 0;
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.sans_serif, size));
        Node node = heading.getFirstChild();
        assert(typeid(node) is typeid(Text) && node.getNext() is null);
        context.render(node);
        current.y += HEADING_UNDER_SPACE;
        painter.drawLine(0, current.y, viewport.w, current.y, NamedColor.red); // DEBUG
    }

    override public void visit(Paragraph paragraph) {
        writeln(">>> Paragraph");
        current.x = 0;
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.sans_serif, DEFAULT_FONT_SIZE));
        visitChildren(paragraph);
        writeln("<<< Paragraph");
    }

    override public void visit(BlockQuote blockQuote) {
        writeln("visit(blockQoute)", blockQuote);
        // html.line();
        // html.tag("blockquote", getAttrs(blockQuote, "blockquote"));
        // html.line();
        visitChildren(blockQuote);
        // html.line();
        // html.tag("/blockquote");
        // html.line();
    }

    override public void visit(BulletList bulletList) {
        // listHolder = new BulletListHolder(listHolder, bulletList);
        visitChildren(bulletList);
        // writeEndOfLineIfNeeded(bulletList, null);
        // if (listHolder.getParent() !is null) {
        //    listHolder = listHolder.getParent();
        // } else {
        //    listHolder = null;
        //}
    }

    override public void visit(Code code) {
        writeln("visit(code) ", code);
        // textContent.write('\"');
        // textContent.write(code.getLiteral());
        // textContent.write('\"');
    }

    override public void visit(FencedCodeBlock fencedCodeBlock) {
        writeln("visit(FencedCodeBlock) ", fencedCodeBlock);
        /*
        if (context.stripNewlines()) {
            textContent.writeStripped(fencedCodeBlock.getLiteral());
            writeEndOfLineIfNeeded(fencedCodeBlock, null);
        } else {
            textContent.write(fencedCodeBlock.getLiteral());
        }
        */
    }

    override public void visit(HardLineBreak hardLineBreak) {
        writeln("visit(HardLineBreak) ", hardLineBreak);
/*
        writeEndOfLineIfNeeded(hardLineBreak, null);
*/
    }

    override public void visit(ThematicBreak thematicBreak) {
        writeln("visit(ThematicBreak) ", thematicBreak);
        painter.drawLine(0, current.y + 2, viewport.w, current.y + 2, NamedColor.black);
        current.y += 5;
    }

    override public void visit(HtmlInline htmlInline) {
        drawText(htmlInline.getLiteral());
    }

    override public void visit(HtmlBlock htmlBlock) {
        drawText(htmlBlock.getLiteral());
    }

    override public void visit(Image image) {
        writeLink(image, image.getTitle(), image.getDestination());
    }

    override public void visit(IndentedCodeBlock indentedCodeBlock) {
        writeln("visit(IndentedCodeBlock) ", indentedCodeBlock);
/*
        if (context.stripNewlines()) {
            textContent.writeStripped(indentedCodeBlock.getLiteral());
            writeEndOfLineIfNeeded(indentedCodeBlock, null);
        } else {
            textContent.write(indentedCodeBlock.getLiteral());
        }
*/
    }

    override public void visit(Link link) {
        writeln("visit(Link) ", link);
        writeLink(link, link.getTitle(), link.getDestination());
    }

    override public void visit(ListItem listItem) {
        writeln("visit(ListItem) ", listItem);
/*
        if (listHolder !is null && cast(OrderedListHolder)listHolder !is null) {
            OrderedListHolder orderedListHolder = cast(OrderedListHolder) listHolder;
            string indent = context.stripNewlines() ? "" : orderedListHolder.getIndent();
            textContent.write(indent ~ orderedListHolder.getCounter().to!string ~ orderedListHolder.getDelimiter() ~ " ");
            visitChildren(listItem);
            writeEndOfLineIfNeeded(listItem, null);
            orderedListHolder.increaseCounter();
        } else if (listHolder !is null && cast(BulletListHolder)listHolder !is null) {
            BulletListHolder bulletListHolder = cast(BulletListHolder) listHolder;
            if (!context.stripNewlines()) {
                textContent.write(bulletListHolder.getIndent() ~ bulletListHolder.getMarker() ~ " ");
            }
            visitChildren(listItem);
            writeEndOfLineIfNeeded(listItem, null);
        }
*/
    }

    override public void visit(OrderedList orderedList) {
/*
        if (listHolder !is null) {
            writeEndOfLine();
        }
        listHolder = new OrderedListHolder(listHolder, orderedList);
        visitChildren(orderedList);
        writeEndOfLineIfNeeded(orderedList, null);
        if (listHolder.getParent() !is null) {
            listHolder = listHolder.getParent();
        } else {
            listHolder = null;
        }
*/
    }

    override public void visit(SoftLineBreak softLineBreak) {
        const spaceWidth = style.font.spaceWidth;
        // DEBUG
        painter.fillRect(current.x, current.y, spaceWidth, style.font.height, NamedColor.yellow);
        current.x += spaceWidth;
    }

    override public void visit(Text text) {
        drawText(text.getLiteral());
    }

    override protected void visitChildren(Node parent) {
        Node node = parent.getFirstChild();
        while (node !is null) {
            Node next = node.getNext();
            context.render(node);
            node = next;
        }
    }

    private void drawText(string text) {
        writeln(__FUNCTION__);
        dstring str = to!dstring(text);

        if (str.length == 0)
            return;

        TextLine txt = TextLine(str);
        auto layoutStyle = TextLayoutStyle(style);
        txt.measure(layoutStyle);
        if (style.wrap)
            txt.wrap(viewport.w);
        txt.draw(painter, current.x, current.y, viewport.w, style);

        if (txt.wrapped is true)
            current.x += txt.wrapSpans[txt.wrapSpans.length - 1].width;
        else
            current.x += txt.size.w;
        current.y +=  txt.height;
    }

    private void writeLink(Node node, string title, string destination) {
        bool hasChild = node.getFirstChild() !is null;
        bool hasTitle = title !is null && !(title == destination);
        bool hasDestination = destination !is null && !(destination == (""));

/*
        if (hasChild) {
            textContent.write('"');
            visitChildren(node);
            textContent.write('"');
            if (hasTitle || hasDestination) {
                textContent.whitespace();
                textContent.write('(');
            }
        }

        if (hasTitle) {
            textContent.write(title);
            if (hasDestination) {
                textContent.colon();
                textContent.whitespace();
            }
        }

        if (hasDestination) {
            textContent.write(destination);
        }

        if (hasChild && (hasTitle || hasDestination)) {
            textContent.write(')');
        }
*/
    }


    private void writeEndOfLine() {
/*
        if (context.stripNewlines()) {
            textContent.whitespace();
        } else {
            textContent.line();
        }
*/
    }
}
