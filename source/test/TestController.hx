package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.containers.Container;

class TestController extends XMLController
{
    var data : TestData;

    var currentQuestionIndex : Int;
    var currentQuestion : TestQuestion;

    var navButtons : Array<Button>;

    public function new(TestData : TestData)
    {
        super("assets/layouts/test.xml");

        data = TestData;

        var header : Text = getComponentAs("txtLessonHeader", Text);
        header.text = data.title;
        header.style.fontBold = true;

        // Prepare the exit button
        setupExitButton();

        if (data.questions != null && data.questions.length > 0)
        {
            // Prepare the prev/next buttons
            setupNavigationButtons();

            // Prepare the answer buttons
            setupAnswerButtons();

            // Build navigation buttons
            buildNavigationButtons();

            // Prepare the finish button
            setupFinishButton();

            if (!data.config.verifyAtTheEnd)
            {
                generateResultText();
            }

            // Start
            fetchQuestion();

            // Setup debug routines
            setupDebugRoutines();

            trace("Test with the following questions:");
            for (question in data.questions)
            {
                trace(" - " + question.question.id);
            }
        }
        else
        {
            getComponentAs("btnPrevQuestion", Button).visible = false;
            getComponentAs("btnNextQuestion", Button).visible = false;

            getComponentAs("txtQuestion", Text).text = "No hay preguntas";
            for (id in 1...5)
            {
                var btnId = "btnA" + id;
                getComponentAs("btnA" + id, Button).visible = false;
                getComponentAs("txtA" + id, Text).visible = false;
            }
        }
    }

    function setupExitButton()
    {
        getComponentAs("btnExit", Button).onClick = function(e : Dynamic) {
            // Save data before exiting
            Storage.store();
            root.removeAllChildren();


            if (data.failedQuestionsTest)
            {
                // Failure tests return to menu and won't save build options?
                root.addChild(new MainController().view);
            }
            else
            {
                // Normal tests return to lesson selection
                root.addChild(new LessonSelectionController().view);
            }
        };
    }

    function setupNavigationButtons()
    {
        getComponentAs("btnPrevQuestion", Button).onClick = navPrevQuestion;
        getComponentAs("btnNextQuestion", Button).onClick = navNextQuestion;
    }

    function setupAnswerButtons()
    {
        for (id in 1...5)
        {
            var btnId = "btnA" + id;
            getComponentAs(btnId, Button).onClick = handleQuestionAnswer;
        }
    }

    function buildNavigationButtons()
    {
        navButtons = [];

        var navPanel : Container = getComponentAs("directNavPanel", Container);
        for (i in 0...data.questions.length)
        {
            var btn : Button = new Button();
            btn.id = "nav" + (i);
            btn.text = "" + (i+1);
            btn.onClick = handleGoToQuestion;

            navPanel.addChild(btn);
            navButtons.push(btn);
        }
    }

    function setupFinishButton()
    {
        var finish : Button = getComponentAs("btnFinish", Button);
        finish.onClick = handleFinishButton;
    }

    function fetchQuestion(?Next : Int = -1)
    {
        if (Next < 0)
            Next = 0;

        // Cycle!
        if (Next >= data.questions.length)
            Next = 0;

        if (Next > -1 && Next < data.questions.length)
        {
            currentQuestionIndex = Next;

            currentQuestion = data.questions[Next];

            var text : Text = getComponentAs("txtQuestion", Text);
            text.text = (Next+1) + "-" + currentQuestion.question.text;
            text.multiline = true;
            text.wrapLines = true;

            var btn : Button = null;

            var index : Int = 1;
            for (answer in currentQuestion.question.answers)
            {
                btn = getComponentAs("btnA" + index, Button);
                btn.visible = true;

                text = getComponentAs("txtA" + index, Text);

                if (text == null)
                {
                    trace("Answer not found for updating: " + currentQuestion.question.lessonId + "-" + currentQuestion.question.number + ": txtA" + index);
                    var btn : Button = getComponentAs("btnA" + index, Button);
                    btn.disabled = true;
                }
                else
                {
                    btn.disabled = false;
                    text.text = answer;
                    text.wrapLines = true;
                    text.multiline = true;
                    resetAnswerStyle(text);

                    // Check correctness
                    // if (index == currentQuestion.question.correct)
                    switch (currentQuestion.state)
                    {
                        case Pending:
                            styleAnswerPending(text);
                        case Answered:
                            styleAnswerAnswered(index, text);
                        case Aftermath:
                            styleAnswerAftermath(index, text);
                    }
                }

                index += 1;
            }

            // There may be less than 4 answers
            if (index <= 4)
            {
                for (i in index...5)
                {
                    btn = getComponentAs("btnA" + index, Button);
                    text = getComponentAs("txtA" + index, Text);

                    btn.visible = false;
                    text.text = "";
                }
            }

            // Handle question state
            switch (currentQuestion.state)
            {
                case Pending:
                    setAnswerButtonsElabled(true);
                case Answered:
                    setAnswerButtonsElabled(true);
                case Aftermath:
                    setAnswerButtonsElabled(false);
            }

            highlightCurrentNavButton();
        }
        else
        {
            throw "Question not found " + Next;
        }
    }

    function styleAnswerPending(text : Text)
    {
        // NoP!
    }

    function styleAnswerAnswered(index : Int, text : Text)
    {
        if (currentQuestion.answer == index)
        {
            text.style.fontBold = true;
        }
    }

    function styleAnswerAftermath(index : Int, text : Text)
    {
        if (currentQuestion.question.correct < 0)
            return;
        if (index == currentQuestion.question.correct)
        {
            // If the user has not answered use a different color
            if (currentQuestion.answer < 0)
                text.style.color = 0x011671;
            else
                text.style.color = 0x117c00;
            text.style.fontBold = true;
        }
        else if (currentQuestion.answer == index)
        {
            text.style.color = 0xFF000a;
            text.style.fontBold = true;
        }
    }

    function resetAnswerStyle(text : Text)
    {
        text.style.color = 0x000000;
        text.style.fontBold = false;
    }

    function highlightCurrentNavButton()
    {
        // Update nav button
        for (button in navButtons)
        {
            var number : Int = Std.parseInt(button.id.substring(3));
            if (number == currentQuestionIndex)
            {
                button.style.borderSize = 3;
                button.style.borderColor = 0xFFFFFF;
            }
            else
            {
                button.style.borderSize = 1;
                button.style.borderColor = 0x495267;
            }
        }
    }

    function setAnswerButtonsElabled(enabled : Bool)
    {
        for (id in 1...5)
        {
            var btnId = "btnA" + id;
            getComponentAs(btnId, Button).disabled = !enabled;
        }
    }

    function handleQuestionAnswer(e : UIEvent) : Void
    {
        var button : Button = e.getComponentAs(Button);
        var answer = button.id.substr(button.id.length-1);

        var wasAnswered : Bool = (currentQuestion.state == Answered);
        var oldAnswer : Int = currentQuestion.answer;

        currentQuestion.state = Answered;
        currentQuestion.answer = Std.parseInt(answer);

        // Check if questions have to be verified as they are answered
        if (!data.config.verifyAtTheEnd)
        {
            currentQuestion.state = Aftermath;
            recordQuestionAnswer(currentQuestion);
            styleQuestionAftermath(currentQuestionIndex);
            updateResultText();
        }
        else
        {
            // Update nav button
            var navPanel : Container = getComponentAs("directNavPanel", Container);
            var navBtn : Button = navPanel.findChild("nav" + currentQuestionIndex, Button, true);
            if (navBtn != null)
            {
                if (currentQuestion.state == Answered)
                    navBtn.styleName = "answered";
                else
                    navBtn.styleName = null;
            }
        }

        // if (!navigateOnAnswer)
        // Double click same answer to navigate to next question
        if (wasAnswered && Std.parseInt(answer) == oldAnswer)
        {
            navNextQuestion(null);
        }
        else
        {
            // if (navigateOnAnswer)
                // Go to next
                // navNextQuestion(null);
            // else
                // Refresh current
                navToQuestion(currentQuestionIndex);
        }
    }

    function navPrevQuestion(e : UIEvent) : Void
    {
        navToQuestion(currentQuestionIndex-1);
    }

    function navNextQuestion(e : UIEvent) : Void
    {
        navToQuestion(currentQuestionIndex+1);
    }

    function handleGoToQuestion(e : UIEvent) : Void
    {
        var target : Int = Std.parseInt(e.getComponentAs(Button).text)-1;
        navToQuestion(target);
    }

    function navToQuestion(index : Int)
    {
        // Safeguard index
        if (index > data.questions.length-1)
            index = 0;
        else if (index < 0)
            index = data.questions.length-1;

        // Go
        fetchQuestion(index);
    }

    function handleFinishButton(e : UIEvent) : Void
    {
        // TODO: Popup with confirmation

        // Set the questions state to Aftermath
        for (question in data.questions)
        {
            question.state = Aftermath;
            recordQuestionAnswer(question);
        }

        // Update individual question style
        styleNavButtonsAftermath();

        // Replace the finish button by the result text
        generateResultText();

        // Update current question style
        fetchQuestion();
    }

    function generateResultText()
    {
        // Remove the finish button
        var btnFinish : Button = getComponentAs("btnFinish", Button);
        var panel : Container = getComponentAs("buttonHeader", Container);
        panel.removeChild(btnFinish, true);

        // Add the question result text instead of the button
        var text : Text = new Text();
        text.id = "resultText";
        text.style.fontBold = true;
        text.horizontalAlign = "center";
        panel.addChild(text);

        updateResultText(text);
    }

    function updateResultText(?label : Text = null)
    {
        if (label == null)
        {
            var panel : Container = getComponentAs("buttonHeader", Container);
            label = panel.findChild("resultText", Text);
        }

        if (label != null)
            label.text = "Correctas: " + data.getCorrectlyAswered() + "/" + data.getAnswerableQuestions();
    }

    function styleNavButtonsAftermath()
    {
        // Update nav button
        for (button in navButtons)
        {
            styleSingleButtonAftermath(button);
        }
    }

    function styleQuestionAftermath(questionIndex : Int)
    {
        if (questionIndex > -1 && questionIndex < data.questions.length)
        {
            var btn : Button = navButtons[questionIndex];
            styleSingleButtonAftermath(btn);
        }
    }

    function styleSingleButtonAftermath(button : Button)
    {
        var index : Int = Std.parseInt(button.id.substring(3));
        var question : TestQuestion = data.questions[index];

        if (question.question.correct < 0)
            button.styleName = "unknown";
        else if (question.answer < 0)
            button.styleName = "unanswered";
        else if (question.answer == question.question.correct)
            button.styleName = "correct";
        else
            button.styleName = "wrong";
    }

    function recordQuestionAnswer(question : TestQuestion)
    {
        var correct : Bool = false;

        if (question.question.correct < 0)
            correct = false;
        else if (question.answer < 0)
            correct = false;
        else if (question.answer == question.question.correct)
            correct = true;
        else
            correct = false;

        Statistics.recordAnswer(question.question.id, correct, data.failedQuestionsTest);
    }

    function setupDebugRoutines()
    {
        getComponent("btnDebug").onClick = handleDebugClick;
    }

    function handleDebugClick(thing : Dynamic) : Void
    {
        var txt : Text = getComponentAs("txtQuestion", Text);

        if (txt == null)
        {
            trace("#txtQuestion not found");
        }
        else
        {
            if (txt.userData == null || txt.userData == false)
                txt.userData = true;
            else
                txt.userData = false;

            if (txt.userData == true)
                txt.text = (currentQuestionIndex+1) + "-" + currentQuestion.question.getDetailLine();
            else
                txt.text = (currentQuestionIndex+1) + "-" + currentQuestion.question.text;
        }
    }
}
