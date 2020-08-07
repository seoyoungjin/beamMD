module app;

import beamui;
import beamui.widgets.markdownview;
import hunt.markdown.parser.Parser;

mixin RegisterPlatforms;


int main()
{
    Parser p = Parser.builder().build();

    // initialize library
    GuiApp app;
    if (!app.initialize())
        return -1;
    // load a better theme
    platform.stylesheets = [StyleResource("light")];

    // set some global styles before we start
    setStyleSheet(currentTheme, css);

    // create a window with 1x1 size and expand it to the size of content
    Window window = platform.createWindow("MarkDownView", null, WindowOptions.expanded, 1, 1);

	// MarkDownView mdv = new MarkDownView();

    // show it with the temperature converter as its main widget
    window.show(() => render!MarkDownView);
    // run application event loop
    return platform.runEventLoop();
}

const css = `
TemperatureConverter {
    display: grid;
    grid-template-columns: 80px 80px;
    grid-template-rows: auto auto;
    padding: 12px;
}
.error { border-color: red }
`;

