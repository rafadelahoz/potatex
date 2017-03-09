package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;

class MainController extends XMLController
{
    public function new()
    {
        super("assets/layouts/menu.xml");

        if (DB.lessons == null || DB.lessons.length <= 0)
        {
            var parser : LessonParser = new LessonParser();
            parser.loadLessons();

            Storage.restore();
        }

        attachEvent("btnQuickTest", MouseEvent.CLICK, function(e:UIEvent) {
            var button : Button = getComponentAs("btnQuickTest", Button);
            button.text = "Hahaha";

            root.removeAllChildren();
            root.addChild(new InfiniteTestController().view);
        });

        attachEvent("btnCustomTest", MouseEvent.CLICK, function(e:UIEvent) {
            root.removeAllChildren();
            root.addChild(new LessonSelectionController().view);
        });
    }
}
