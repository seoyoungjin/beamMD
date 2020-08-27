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

    Window window = platform.createWindow("MarkDownDemo");

	// MarkDownView mdv = new MarkDownView();

    // show it with the temperature converter as its main widget
    window.show(() => render!MarkDownDemo);
    // run application event loop
    return platform.runEventLoop();
}

const css = `
MarkDownDemo {
    display: flex;
    flex-direction: column;
    padding: 12px;
}
MarkDownView {
    width: 500px;
    height: 400px;
}
.error { border-color: red }
`;

class MarkDownDemo : Panel
{
    override void build()
    {
        MarkDownView md = render!MarkDownView;
        wrap(
            render((Label lb) { lb.text = "Top"; }),
            md,
            render((Label lb) { lb.text = "Bottom"; }),
        );
    }
}
