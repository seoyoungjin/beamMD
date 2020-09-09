module beamui.widgets.markdownview.renderer.ListHolder;

import hunt.markdown.node.BulletList;
import hunt.markdown.node.OrderedList;

abstract class ListHolder {
    private __gshared string  INDENT_DEFAULT = "   ";
    private __gshared string  INDENT_EMPTY = "";

    private ListHolder parent;
    private string indent;

    this(ListHolder parent) {
        this.parent = parent;

        if (parent !is null) {
            indent = parent.indent ~ INDENT_DEFAULT;
        } else {
            indent = INDENT_EMPTY;
        }
    }

    public ListHolder getParent() {
        return parent;
    }

    public string getIndent() {
        return indent;
    }
}


class BulletListHolder : ListHolder {
    private __gshared dstring[] BULLET_MARKER = [ "\u2022", "\u25e6", "\u25a0", "\u25a1"];
    private char marker;

    public this(ListHolder parent, BulletList list) {
        super(parent);
        marker = list.getBulletMarker();
    }

    // LATER
    public dstring getMarker(int list_level) {
        int level = list_level;
        if (level < 1)
            level = 1;
        else if (level > 4)
            level = 4;
        return BULLET_MARKER[level - 1];
    }
}

class OrderedListHolder : ListHolder {
    private char delimiter;
    private int counter;

    public this(ListHolder parent, OrderedList list) {
        super(parent);
        delimiter = list.getDelimiter();
        counter = list.getStartNumber();
    }

    public char getDelimiter() {
        return delimiter;
    }

    public int getCounter() {
        return counter;
    }

    public void increaseCounter() {
        counter++;
    }
}
