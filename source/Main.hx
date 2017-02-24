package;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.themes.GradientTheme;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;
import haxe.ui.toolkit.core.PopupManager;

class Main {
    public static function main() {
        Toolkit.theme = new GradientTheme();
        Toolkit.init();
        Toolkit.openFullscreen(function(root:Root) {

            var view : IDisplayObject = Toolkit.processXmlResource("layouts/layout.xml");
            root.addChild(view);

            PopupManager.instance.showBusy("Please wait", 1000, "Busy popup");

            var button:Button = new Button();
            button.text = "Click Me!";
            button.x = 100;
            button.y = 100;
            button.onClick = function(e:UIEvent) {
                e.component.text = "You clicked me!";
            };
            root.addChild(button);
       });
    }
}
