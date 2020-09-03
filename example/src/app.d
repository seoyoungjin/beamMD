module app;

import beamui;
import beamui.widgets.markdownview;

mixin RegisterPlatforms;


int main(string[] args)
{
    // initialize library
    GuiApp app;
    if (!app.initialize())
        return -1;

    if (args.length > 1)
        data.filename = args[1];
    else
        data.filename = "resources/spec.md";

    // view the hardcoded CSS string as an embedded resource
    resourceList.embedFromMemory("_styles_.css", css);
    // setup a better theme and our stylesheet
    platform.stylesheets = [StyleResource("light"), StyleResource("_styles_")];

    Window window = platform.createWindow("MarkDownDemo");

    // MarkDownView mdv = render!MarkDownView;
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
    min-width: 100;
    min-height: 400px;
}
.error { border-color: red }
`;

struct AppData {
    string filename;
}

AppData data;

class MarkDownDemo : Panel
{
    override void build()
    {
        MarkDownView md = render!MarkDownView;
        md.filename = data.filename;
        md.attributes["stretch"];

        wrap(
            render((Label lb) { lb.text = "Top"; }),
            md,
            render((Label lb) { lb.text = "Bottom"; }),
        );
    }
}
