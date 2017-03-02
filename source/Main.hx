package;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.themes.GradientTheme;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.events.MenuEvent;

class Main {
    public static function main() {
        Toolkit.theme = new GradientTheme();
        Toolkit.init();
        Toolkit.openFullscreen(function(root:Root) {
            root.addChild(new MainController().view);
       });
    }
}
