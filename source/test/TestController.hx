package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;

class TestController extends XMLController
{
    var data : TestData;

    var currentQuestionIndex : Int;
    var currentQuestion : TestQuestion;

    public function new(TestData : TestData)
    {
        super("layouts/test.xml");

        data = TestData;

        var header : Text = getComponentAs("txtLessonHeader", Text);
        header.text = data.title;
        header.style.fontBold = true;

        fetchQuestion();

        for (id in 1...5)
        {
            var btnId = "btnA" + id;
            attachEvent(btnId, MouseEvent.CLICK, dispatchAnswer(btnId));
        }
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

    function setAnswerButtonsElabled(enabled : Bool)
    {
        for (id in 1...5)
        {
            var btnId = "btnA" + id;
            getComponentAs(btnId, Button).disabled = !enabled;
        }
    }

    function dispatchAnswer(compId : String) : UIEvent -> Void
    {
        return function(e : UIEvent) : Void
        {
            var answer = compId.substr(compId.length-1);
            trace("Answer: " + answer);

            currentQuestion.state = Answered;
            currentQuestion.answer = Std.parseInt(answer);

            if (Std.parseInt(answer) == currentQuestion.question.correct)
                trace("Hurray!");

            fetchQuestion(currentQuestionIndex+1);
        };
    }
}
