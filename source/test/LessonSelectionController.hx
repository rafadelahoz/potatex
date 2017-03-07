package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.containers.Container;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;

class LessonSelectionController extends XMLController
{
    var lessonCheckboxes : Array<CheckBox>;

    public function new()
    {
        super("layouts/lessonSelection.xml");

        var panel : Container = getComponentAs("lessonList", Container);
        if (panel == null)
            throw "Container \"lessonList\" not found!";

        lessonCheckboxes = [];

        for (lesson in DB.lessons)
        {
            var box : CheckBox = new CheckBox();
            box.text = lesson.title;
            panel.addChild(box);
            lessonCheckboxes.push(box);
        }

        var startButton : Button = getComponentAs("btnStart", Button);
        startButton.onClick = handleStartButtonClick;
    }

    function handleStartButtonClick(e : UIEvent)
    {
        var lessons : Array<Lesson> = [];
        for (box in lessonCheckboxes)
        {
            if (box.selected)
                lessons.push(DB.getLessonByTitle(box.text));
        }

        if (lessons.length == 0)
        {
            showPopup("Si no eliges algún tema, no puedo preparar el test :(");
            return;
        }

        var nQuestionsTextBox : TextInput = getComponentAs("txtNumberOfQuestions", TextInput);
        var txtNumQuestions : String = nQuestionsTextBox.text;
        var numQuestions : Null<Int> = Std.parseInt(txtNumQuestions);
        if (numQuestions == null)
        {
            showPopup("¿Podrías indicar cuántas preguntas tiene que tener el test?");
            return;
        }

        var options : TestBuilder.TestBuildOptions = {
            numberOfQuestions:  numQuestions,
            sourceLessons:      lessons,
            onlyReal:           getSafeCheckboxValue("checkOnlyReal"),
            onlyAnswered:       getSafeCheckboxValue("checkOnlyAnswered"),
            config: {
                verifyAtTheEnd: !getSafeCheckboxValue("checkAutomaticCorrection")
            }
        };

        var testData : TestData = TestBuilder.build(options);

        root.removeAllChildren();
        root.addChild(new TestController(testData).view);
    }

    function getSafeCheckboxValue(checkboxId : String) : Bool
    {
        var value : Bool = false;
        var checkbox : CheckBox = getComponentAs(checkboxId, CheckBox);
        if (checkbox != null)
            value = checkbox.selected;
        else
            trace("Checkbox not found: " + checkboxId);

        return value;
    }
}
