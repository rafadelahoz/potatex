package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;

class SecondController extends XMLController
{
    public function new()
    {
        super("layouts/layout0.xml");

        attachEvent("buttonB", MouseEvent.CLICK, function(e:UIEvent) {
            var button : Button = getComponentAs("buttonB", Button);
            button.text = "Hahaha";

            root.removeAllChildren();
            root.addChild(new MainController().view);
        });
    }
}
