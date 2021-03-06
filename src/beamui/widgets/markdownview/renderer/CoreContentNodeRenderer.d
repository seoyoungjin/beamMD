module beamui.widgets.markdownview.renderer.CoreContentNodeRenderer;

import hunt.markdown.node;
import hunt.markdown.node.AbstractVisitor;
import hunt.markdown.node.Heading;
import hunt.markdown.renderer.NodeRenderer;

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
import beamui.graphics.bitmap;
import beamui.graphics.colors;
import beamui.graphics.images;
import beamui.graphics.painter : Painter;
import beamui.text.fonts;
import beamui.text.line;
import beamui.text.simple;
import beamui.text.style;

import beamui.widgets.markdownview.renderer.ListHolder;
import beamui.widgets.markdownview.renderer.textline;
import beamui.widgets.markdownview.renderer.ContentNodeRendererContext;

const int DEFAULT_FONT_SIZE = 14;
const float[] HEADING_FONT_SIZES = [32, 24, 18.72, 16, 13.28, 10.72];
const int HEADING_UPPER_MARGIN = 3;
const int HEADING_UNDER_MARGIN = 5;
const int PARAGRAPH_UPPER_MARGIN = 3;
const int PARAGRAPH_UNDER_MARGIN = 3;
const int QUOTE_UPPER_MARGIN = 5;
const int QUOTE_UNDER_MARGIN = 5;
const int QUOTE_LEVEL_MARGIN = 20;
const int LIST_UPPER_MARGIN = 5;
const int LIST_UNDER_MARGIN = 5;
const int LISTITEM_UPPER_MARGIN = 3;
const int LISTITEM_UNDER_MARGIN = 3;
const int LISTITEM_MARGIN = 30;
const int CODE_BLOCK_UPPER_MARGIN = 5;
const int CODE_BLOCK_UNDER_MARGIN = 5;

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
    private int bq_level;
    private int list_level;

    public this(ContentNodeRendererContext context) {
        this.context = context;

        this.painter = context.painter();
        this.viewport = context.viewport();
        this.current.x = this.current.y = 0;
        this.current.x = this.current.y = 0;
        this.bq_level = 0;
        this.list_level = 0;

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
        // writeln("render(node) ", node);
        node.accept(this);
    }

    // LATER - blockquote level, list level
    public float leftMargin() {
        return bq_level * QUOTE_LEVEL_MARGIN + list_level * LISTITEM_MARGIN;
    }

    override public void visit(Document document) {
        debug debugLine(NamedColor.red);
        visitChildren(document);
    }

    override public void visit(Heading heading) {
        // writeln("visit(heading) ", heading.getLevel());
        auto h = heading.getLevel();
        int size = cast(int)(DEFAULT_FONT_SIZE * HEADING_FONT_SIZES[h] / 10 + 0.5);

        current.x = leftMargin();
        TextStyle oldStyle = style;
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.sans_serif, size));
        visitChildren(heading);
        newLine();

        style = oldStyle;
        debug debugLine(NamedColor.red);
        current.y += HEADING_UNDER_MARGIN;
    }

    override public void visit(Paragraph paragraph) {
        // writeln(">>> Paragraph");
        if (paragraph.getParent() is null || cast(ListItem)paragraph.getParent() is null) {
            current.y += PARAGRAPH_UPPER_MARGIN;
        }
        debug debugLine(NamedColor.red);
        current.x = leftMargin();

        TextStyle oldStyle = style;
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.sans_serif, DEFAULT_FONT_SIZE));
        visitChildren(paragraph);
        // Add "end of line" only if its "root paragraph.
        // if (paragraph.getParent() is null || cast(Document)paragraph.getParent() !is null) {
           newLine();
        // }
        style = oldStyle;

        debug debugLine(NamedColor.red);
        if (paragraph.getParent() is null || cast(ListItem)paragraph.getParent() is null) {
            current.y += PARAGRAPH_UNDER_MARGIN;
        }
        // writeln("<<< Paragraph");
    }

    override public void visit(BlockQuote blockQuote) {
        // writeln("visit(blockQoute)", blockQuote);
        current.y += QUOTE_UPPER_MARGIN;
        debug debugLine(NamedColor.yellow);
        Point org = current;

        bq_level++;
        TextStyle oldStyle = style;
        style.color = NamedColor.dark_gray;
        style.decoration = TextDecor(TextDecorLine.none, style.color);
        visitChildren(blockQuote);
        painter.fillRect(org.x, org.y, 5, current.y - org.y, NamedColor.dark_gray);
        newLine();
        style = oldStyle;
        bq_level--;
        current.x = leftMargin();

        debug debugLine(NamedColor.yellow);
        current.y += QUOTE_UNDER_MARGIN;
    }

    override public void visit(BulletList bulletList) {
        // writeln("visit(BulletList)");
        list_level++;
        listHolder = new BulletListHolder(listHolder, bulletList);
        visitChildren(bulletList);
        if (listHolder.getParent() !is null) {
           listHolder = listHolder.getParent();
        } else {
           listHolder = null;
        }
        list_level--;
    }

    override public void visit(OrderedList orderedList) {
        // writeln("visit(OrderedList) ", orderedList.getDelimiter());
        list_level++;
        // if (listHolder !is null) {
        //     newLine();
        // }
        listHolder = new OrderedListHolder(listHolder, orderedList);
        visitChildren(orderedList);
        newLine();
        if (listHolder.getParent() !is null) {
            listHolder = listHolder.getParent();
        } else {
            listHolder = null;
        }
        list_level--;
    }

    override public void visit(ListItem listItem) {
        // writeln("visit(ListItem) ", listItem);
        if (listHolder !is null && cast(OrderedListHolder)listHolder !is null) {
            OrderedListHolder olHolder = cast(OrderedListHolder) listHolder;
            dstring marker = olHolder.getCounter().to!dstring ~ olHolder.getDelimiter();
            drawMarker(leftMargin() - 15, marker);
            visitChildren(listItem);
            olHolder.increaseCounter();
        } else if (listHolder !is null && cast(BulletListHolder)listHolder !is null) {
            BulletListHolder bulletListHolder = cast(BulletListHolder) listHolder;
            dstring marker = bulletListHolder.getMarker(list_level);
            drawMarker(leftMargin() - 15, marker);
            visitChildren(listItem);
        }
        // newLine();
    }

    override public void visit(Code code) {
        // writeln("visit(code) ", code.getLiteral());
        TextStyle oldStyle = style;
        const Font f = style.font;
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.monospace, f.size));
        style.background = NamedColor.light_gray;

        drawText(code.getLiteral());

        style = oldStyle;
    }

    override public void visit(FencedCodeBlock fencedCodeBlock) {
        // writeln("visit(FencedCodeBlock) ", fencedCodeBlock);
        TextStyle oldStyle = style;
        const Font f = style.font;
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.monospace, f.size));
        style.color = NamedColor.gray;
        style.decoration = TextDecor(TextDecorLine.none, style.color);

        current.y += CODE_BLOCK_UPPER_MARGIN;
        debugLine(NamedColor.gray);
        // newLine();
        // drawText(fencedCodeBlock.getLiteral());
        SimpleText txt = SimpleText(to!dstring(fencedCodeBlock.getLiteral()));
        txt.style = style;
        txt.measure();
        txt.wrap(viewport.w - leftMargin());
        txt.draw(painter, leftMargin(), current.y, viewport.w - leftMargin());
        current.y += txt.sizeAfterWrap.h;
        debugLine(NamedColor.gray);
        current.y += CODE_BLOCK_UNDER_MARGIN;

        style = oldStyle;
    }

    override public void visit(IndentedCodeBlock indentedCodeBlock) {
        // writeln("visit(IndentedCodeBlock) ", indentedCodeBlock);
        TextStyle oldStyle = style;
        const Font f = style.font;
        style.font = FontManager.instance.getFont(FontSelector(FontFamily.monospace, f.size));
        style.color = NamedColor.gray;
        style.decoration = TextDecor(TextDecorLine.none, style.color);

        current.y += CODE_BLOCK_UPPER_MARGIN;
        debugLine(NamedColor.gray);
        // drawText(indentedCodeBlock.getLiteral());
        SimpleText txt = SimpleText(to!dstring(indentedCodeBlock.getLiteral()));
        txt.style = style;
        txt.measure();
        txt.wrap(viewport.w - leftMargin());
        txt.draw(painter, leftMargin(), current.y, viewport.w - leftMargin());
        current.y += txt.sizeAfterWrap.h;
        debugLine(NamedColor.gray);
        current.y += CODE_BLOCK_UNDER_MARGIN;

        style = oldStyle;
    }

    override public void visit(HardLineBreak hardLineBreak) {
        // writeln("visit(HardLineBreak) ", hardLineBreak);
        newLine();
    }

    override public void visit(ThematicBreak thematicBreak) {
        // writeln("visit(ThematicBreak) ", thematicBreak);
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
        // writeln("visit(Image) ", image);
        bool hasChild = image.getFirstChild() !is null;

        // LATER - merge with current file path
        Bitmap bitmap = loadImage(image.getDestination());
        if (bitmap) {
            painter.drawImage(bitmap, current.x, current.y, 1);
            current.y += bitmap.height();
        }
        else if (hasChild) {
            assert(cast(Text)image.getFirstChild() !is null);
            visitChildren(image);
        }
    }

    override public void visit(Link link) {
        // writeln("visit(Link) ", link);
        TextStyle oldStyle = style;
        style.color = NamedColor.blue;
        style.decoration = TextDecor(TextDecorLine.under, style.color);
        drawLink(link, link.getTitle(), link.getDestination());
        style = oldStyle;
    }

    override public void visit(SoftLineBreak softLineBreak) {
        const r = style.font.spaceWidth / 2;
        const h = style.font.height / 2;
        debug painter.fillCircle(current.x + r, current.y + h, r - 1, Color(0x00BFFF));
        current.x += style.font.spaceWidth;
    }

    override public void visit(Emphasis emphasis) {
        // writeln("visit(Emphasis) ", emphasis.getOpeningDelimiter());
        TextStyle oldStyle = style;
        const Font f = style.font;
        style.font = FontManager.instance.getFont(FontSelector(f.family, f.size, FontStyle.italic, f.weight));
        visitChildren(emphasis);
        style = oldStyle;
    }

    override public void visit(StrongEmphasis emphasis) {
        // writeln("visit(StrongEmphasis) ", emphasis.getOpeningDelimiter());
        TextStyle oldStyle = style;
        const Font f = style.font;
        style.font = FontManager.instance.getFont(FontSelector(f.family, f.size, f.italic, FontWeight.bold));
        visitChildren(emphasis);
        style = oldStyle;
    }

    override public void visit(Text text) {
        // writeln("visit(Text) ", text.getLiteral());
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

    private void drawMarker(float x, dstring marker) {
        dstring str = to!dstring(marker);
        if (str.length == 0)
            return;
        TextLine2 txt = TextLine2(str);
        auto layoutStyle = TextLayoutStyle(style);
        txt.measure(layoutStyle);
        txt.draw(painter, x, current.y, viewport.w, style);
    }

    private void drawText(string text) {
        dstring str = to!dstring(text);

        if (str.length == 0)
            return;

        float loffset = leftMargin();
        float vpw = viewport.w - loffset;

        TextLine2 txt = TextLine2(str);
        txt.setOffset(loffset);
        auto layoutStyle = TextLayoutStyle(style);
        txt.measure(layoutStyle);
        if (style.wrap)
            txt.wrap(current.x, vpw);
        txt.draw(painter, current.x, current.y, vpw, style);

        if (txt.wrapped is true)
            current.x = txt.wrapSpans[txt.wrapSpans.length - 1].width;
        else
            current.x += txt.size.w;
        // LATER - last line height
        current.y +=  txt.height - style.font.height;
    }

    private void drawLink(Node node, string title, string destination) {
        bool hasChild = node.getFirstChild() !is null;
        bool hasTitle = title !is null && !(title == destination);
        bool hasDestination = destination !is null && !(destination == (""));

        if (hasChild) {
            visitChildren(node);
        }

        // tooltip
        // if (hasTitle) {
        //     textContent.write(title);
        // }

        // if (hasDestination) {
        //     textContent.write(destination);
        // }
    }

    private void newLine() {
        // line break after paragraph
        // LATER - last line height
        float xorg = leftMargin();
        if (xorg != current.x) {
            current.y += style.font.height;
            current.x = xorg;
        }
    }

debug:
    void debugLine(Color color) {
        painter.drawLine(0, current.y, viewport.w, current.y, color);
    }
}
