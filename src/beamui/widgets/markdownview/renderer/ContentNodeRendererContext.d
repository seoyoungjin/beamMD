module beamui.widgets.markdownview.renderer.ContentNodeRendererContext;

import hunt.markdown.node.Node;
import beamui.core.geometry : Size;
import beamui.graphics.painter : Painter;

public interface ContentNodeRendererContext {

    /**
     * @return painter
     */
    Painter painter();

    /**
     * @return viewport size
     */
    Size viewport();

    /**
     * Render the specified node and its children using the configured renderers. This should be used to render child
     * nodes; be careful not to pass the node that is being rendered, that would result in an endless loop.
     *
     * @param node the node to render
     */
    void render(Node node);
}
