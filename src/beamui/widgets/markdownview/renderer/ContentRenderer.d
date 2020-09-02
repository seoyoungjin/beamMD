module beamui.widgets.markdownview.renderer.ContentRenderer;

import std.stdio;

import hunt.markdown.Extension;
import hunt.markdown.internal.renderer.NodeRendererMap;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.Renderer;

import beamui.core.geometry : Size;
import beamui.graphics.painter : Painter;

import beamui.widgets.markdownview.renderer.ContentWriter;
import beamui.widgets.markdownview.renderer.ContentNodeRendererFactory;
import beamui.widgets.markdownview.renderer.ContentNodeRendererContext;
import beamui.widgets.markdownview.renderer.CoreContentNodeRenderer;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.util.Common;

class ContentRenderer {

    private List!(ContentNodeRendererFactory) nodeRendererFactories;

    private this(Builder builder) {
        this.nodeRendererFactories = new ArrayList!ContentNodeRendererFactory(builder.nodeRendererFactories.size() + 1);
        this.nodeRendererFactories.addAll(builder.nodeRendererFactories);
        // Add as last. This means clients can override the rendering of core nodes if they want.
        this.nodeRendererFactories.add(new class ContentNodeRendererFactory {
            override public NodeRenderer create(ContentNodeRendererContext context) {
                return new CoreContentNodeRenderer(context);
            }
        });
    }

    /**
     * Create a new builder for configuring an {@link ContentRenderer}.
     *
     * @return a builder
     */
    public static Builder builder() {
        return new Builder();
    }

    public void render(Node node, Painter pr, Size sz) {
        RendererContext context = new RendererContext(new ContentWriter(pr, sz), pr, sz);
        context.render(node);
    }

    /**
     * Builder for configuring an {@link ContentRenderer}. See methods for default configuration.
     */
    public static class Builder {

        private List!(ContentNodeRendererFactory) nodeRendererFactories;

        this()
        {
            nodeRendererFactories = new ArrayList!ContentNodeRendererFactory();
        }
        
        /**
         * @return the configured {@link ContentRenderer}
         */
        public ContentRenderer build() {
            return new ContentRenderer(this);
        }

        /**
         * Add a factory for instantiating a node renderer (done when rendering). This allows to override the rendering
         * of node types or define rendering for custom node types.
         * <p>
         * If multiple node renderers for the same node type are created, the one from the factory that was added first
         * "wins". (This is how the rendering for core node types can be overridden; the default rendering comes last.)
         *
         * @param nodeRendererFactory the factory for creating a node renderer
         * @return {@code this}
         */
        public Builder nodeRendererFactory(ContentNodeRendererFactory nodeRendererFactory) {
            this.nodeRendererFactories.add(nodeRendererFactory);
            return this;
        }

        /**
         * @param extensions extensions to use on this text content renderer
         * @return {@code this}
         */
        public Builder extensions(Iterable!Extension extensions) {
            foreach (Extension extension ; extensions) {
                if (cast(ContentRenderer.ContentRendererExtension)extension !is null) {
                    ContentRenderer.ContentRendererExtension htmlRendererExtension =
                            cast(ContentRenderer.ContentRendererExtension) extension;
                    htmlRendererExtension.extend(this);
                }
            }
            return this;
        }
    }

    /**
     * Extension for {@link ContentRenderer}.
     */
    public interface ContentRendererExtension : Extension {
        void extend(ContentRenderer.Builder rendererBuilder);
    }

    private class RendererContext : ContentNodeRendererContext {
        private NodeRendererMap nodeRendererMap;
        private ContentWriter textContentWriter;
        private Painter _painter;
        private Size _size;

        private this(ContentWriter textContentWriter, Painter pr, Size sz) {
            nodeRendererMap = new NodeRendererMap();
            this.textContentWriter = textContentWriter;
            this._painter = pr;
            this._size = sz;

            // The first node renderer for a node type "wins".
            for (int i = nodeRendererFactories.size() - 1; i >= 0; i--) {
                ContentNodeRendererFactory nodeRendererFactory = nodeRendererFactories.get(i);
                NodeRenderer nodeRenderer = nodeRendererFactory.create(this);
                nodeRendererMap.add(nodeRenderer);
            }
        }

        override public bool stripNewlines() {
            // return _stripNewlines;
            return true;
        }

        override public Painter painter() {
            return _painter;
        }

        override public Size viewport() {
            return _size;
        }

        override public ContentWriter getWriter() {
            return textContentWriter;
        }

        public void render(Node node) {
            nodeRendererMap.render(node);
        }
    }
}