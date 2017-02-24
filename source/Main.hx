package;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.events.UIEvent;

class Main {
    public static function main() {
        // Macros.addStyleSheet("styles/gradient/gradient.css");
        Toolkit.init();
        Toolkit.openFullscreen(function(root:Root) {
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
