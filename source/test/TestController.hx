package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
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
        super("layouts/test.xml");

        data = TestData;

        var header : Text = getComponentAs("txtLessonHeader", Text);
        header.text = data.title;
        header.style.fontBold = true;

        // Prepare the prev/next buttons
        setupNavigationButtons();

        // Prepare the answer buttons
        setupAnswerButtons();

        // Build navigation buttons
        buildNavigationButtons();

        // Prepare the finish button
        setupFinishButton();

        // Start
        fetchQuestion();

        /*view.addEventListener(UIEvent.RESIZE, function(what : Dynamic) {
            var navPanel : Container = getComponentAs("directNavPanel", Container);
            if (navPanel != null)
                navPanel.onRefresh()
            else
                trace("what");
        });*/
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

            var index : Int = 1;
            for (answer in currentQuestion.question.answers)
            {
                text = getComponentAs("txtA" + index, Text);
                if (text == null)
                {
                    trace("Answer not found for updating: " + "txtA" + index);
                    continue;
                }

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

                index += 1;
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
        if (index == currentQuestion.question.correct)
        {
            text.style.backgroundColor = 0x00FF0a;
            text.style.backgroundAlpha = 1;
        }
        else if (currentQuestion.answer == index)
        {
            text.style.backgroundColor = 0xFF000a;
            text.style.backgroundAlpha = 1;
        }
    }

    function resetAnswerStyle(text : Text)
    {
        text.style.backgroundColor = 0xFFFFFF;
        text.style.backgroundAlpha = 0;
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
        for (question in data.questions)
        {
            question.state = Aftermath;
        }

        styleNavButtonsAftermath();

        var panel : Container = cast(e.component.parent, Container);
        panel.removeChild(e.component, true);

        var text : Text = new Text();
        text.text = "Correctas: " + data.getCorrectlyAswered() + "/" + data.getAnswerableQuestions();
        text.style.fontBold = true;
        text.horizontalAlign = "center";
        panel.addChild(text);
    }

    function styleNavButtonsAftermath()
    {
        // Update nav button
        for (button in navButtons)
        {
            var index : Int = Std.parseInt(button.id.substring(3));
            var question : TestQuestion = data.questions[index];

            if (question.question.correct < 0)
                button.styleName = "unknown";
            else if (question.answer == question.question.correct)
                button.styleName = "correct";
            else
                button.styleName = "wrong";
        }
    }
}
