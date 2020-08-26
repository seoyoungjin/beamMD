module app;

import beamui;
import beamui.widgets.markdownview;

mixin RegisterPlatforms;


int main()
{
    // initialize library
    GuiApp app;
    if (!app.initialize())
        return -1;

	// view the hardcoded CSS string as an embedded resource
    resourceList.embedFromMemory("_styles_.css", css);
	// setup a better theme and our stylesheet
    platform.stylesheets = [StyleResource("light"), StyleResource("_styles_")];

    // create a window with 1x1 size and expand it to the size of content
    Window window = platform.createWindow("MarkDownDemo", null, WindowOptions.expanded, 1, 1);

	// MarkDownView mdv = new MarkDownView();

    // show it with the temperature converter as its main widget
    window.show(() => render!MarkDownDemo);
    // run application event loop
    return platform.runEventLoop();
}

const css = `
MarkDownDemo {
    display: grid;
    grid-template-columns: 80px 80px;
    grid-template-rows: auto auto;
    padding: 12px;
}
.error { border-color: red }
`;

class MarkDownDemo : Panel
{
    override void build()
    {
        MarkDownView md = render!MarkDownView;
        wrap(
            md
        );
    }
}
