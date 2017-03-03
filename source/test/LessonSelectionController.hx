package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.containers.Container;
import haxe.ui.toolkit.controls.Text;

class LessonSelectionController extends XMLController
{
    public function new()
    {
        super("layouts/lessonSelection.xml");

        var panel : Container = getComponentAs("lessonList", Container);
        if (panel == null)
            throw "Container \"lessonList\" not found!";

        for (lesson in DB.lessons)
        {
            var button : Button = new Button();
            button.text = lesson.title;
            button.userData = lesson;
            button.onClick = handleLessonButtonClick;
            button.horizontalAlign = "center";
            button.percentWidth = 80;

            panel.addChild(button);
        }
    }

    function handleLessonButtonClick(e : UIEvent)
    {
        var button = cast(e.component, Button);

        var lesson : Lesson = DB.getLessonByTitle(button.text);

        var options : TestBuilder.TestBuildOptions = {
            numberOfQuestions: 45,
            sourceLessons: [lesson],
            config: {
                verifyAtTheEnd: true
            }
        };

        var testData : TestData = TestBuilder.build(options);

        root.removeAllChildren();
        root.addChild(new TestController(testData).view);
    }
}
