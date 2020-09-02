module beamui.widgets.markdownview.renderer.ContentNodeRendererContext;

import hunt.markdown.node.Node;
import beamui.core.geometry : Size;
import beamui.graphics.painter : Painter;
import beamui.widgets.markdownview.renderer.ContentWriter;

public interface ContentNodeRendererContext {

    /**
     * @return true for stripping new lines and render text as "single line",
     * false for keeping all line breaks.
     */
    bool stripNewlines();

    /**
     * @return painter
     */
    Painter painter();

    /**
     * @return viewport size
     */
    Size viewport();

    /**
     * @return the writer to use
     */
    ContentWriter getWriter();

    /**
     * Render the specified node and its children using the configured renderers. This should be used to render child
     * nodes; be careful not to pass the node that is being rendered, that would result in an endless loop.
     *
     * @param node the node to render
     */
    void render(Node node);
}