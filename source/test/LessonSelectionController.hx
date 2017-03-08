package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.containers.Container;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.containers.HBox;

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

            // Restore last selected lessons
            if (Session.lastTestBuildOptions != null)
            {
                if (Session.lastTestBuildOptions.sourceLessons.indexOf(lesson) > -1)
                    box.selected = true;
            }
        }

        if (Session.lastTestBuildOptions != null)
        {
            getComponentAs("txtNumberOfQuestions", TextInput).text = "" + Session.lastTestBuildOptions.numberOfQuestions;
            getComponentAs("checkOnlyReal", CheckBox).selected = Session.lastTestBuildOptions.onlyReal;
            getComponentAs("checkOnlyAnswered", CheckBox).selected = Session.lastTestBuildOptions.onlyAnswered;
            getComponentAs("checkAutomaticCorrection", CheckBox).selected = !Session.lastTestBuildOptions.config.verifyAtTheEnd;
        }

        var startButton : Button = getComponentAs("btnStart", Button);
        startButton.onClick = handleStartButtonClick;

        var backButton : Button = getComponentAs("btnExit", Button);
        backButton.onClick = handleExitButtonClick;

        setupLessonListButtons();

        /*var accordion : Accordion = getComponentAs("accordion", Accordion);
        accordion.getButton(0).dispatchEvent(new UIEvent(UIEvent.CLICK));
        accordion.showPage(0);*/
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

        // Store the current test build options
        Session.lastTestBuildOptions = options;
        Storage.store();

        if (testData.questions == null || testData.questions.length == 0)
        {
            showPopup("No hay ninguna pregunta dentro de los temas elegidos " +
                    "con la configuración seleccionada.\n" +
                    "Relaja la configuración y vuelve a probar",
                    "Demasiado específico");
            return;
        }
        else if (testData.questions.length < options.numberOfQuestions)
        {
            showConfirmationPopup("No hay suficientes preguntas",
                                    "Con esa configuración puedo preparar un test con " +
                                    testData.questions.length + " preguntas, pero tú querías " +
                                    options.numberOfQuestions + ".\n" +
                                    "¿Quires hacer un test con " + testData.questions.length + " preguntas?",
                                    "Sí, adelante", "No, revisaré la configuración",
                                    function(e:Dynamic) {
                                        root.removeAllChildren();
                                        root.addChild(new TestController(testData).view);
                                    });

            return;
        }

        root.removeAllChildren();
        root.addChild(new TestController(testData).view);
    }

    function handleExitButtonClick(ev : Dynamic)
    {
        root.removeAllChildren();
        root.addChild(new MainController().view);
    }

    function setupLessonListButtons()
    {
        var allButton : Button = getComponentAs("btnSelectAll", Button);
        allButton.onClick = function(evt : Dynamic) {
            for (checkbox in lessonCheckboxes)
            {
                checkbox.selected = true;
            }
        };

        var noneButton : Button = getComponentAs("btnSelectNone", Button);
        noneButton.onClick = function(evt : Dynamic) {
            for (checkbox in lessonCheckboxes)
            {
                checkbox.selected = false;
            }
        };

        var randomButton = getComponentAs("btnSelectRandom", Button);
        randomButton.onClick = function(evt : Dynamic) {
            for (checkbox in lessonCheckboxes)
            {
                checkbox.selected = Random.float() < 0.5;
            }
        };
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

    function showConfirmationPopup(title : String, message : String, okLabel : String, cancelLabel : String, okCallback : Dynamic -> Void)
    {
        var popup : Popup = PopupManager.instance.showSimple(message, title, {});

        var hbox : HBox = new HBox();
        hbox.percentWidth = 100;
        popup.addChild(hbox);

        var okBtn = new Button();
        okBtn.text = okLabel;
        okBtn.horizontalAlign = "center";
        okBtn.onClick = okCallback;
        hbox.addChild(okBtn);

        var cancelBtn = new Button();
        cancelBtn.text = cancelLabel;
        cancelBtn.horizontalAlign = "center";
        cancelBtn.onClick = function(e:Dynamic) {
            PopupManager.instance.hidePopup(popup);
        };
        hbox.addChild(cancelBtn);
    }
}
