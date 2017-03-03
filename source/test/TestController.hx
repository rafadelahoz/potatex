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
        if (Next <= 0)
            Next = 1;

        if (Next > 0 && data.questions.length > Next)
        {
            currentQuestionIndex = Next;

            // Don't fail on next for now
            currentQuestion = data.questions[Next];

            trace("Q"+Next+": " + currentQuestion);

            var text : Text = getComponentAs("txtQuestion", Text);
            text.text = currentQuestion.question.text;
            text.multiline = true;
            text.wrapLines = true;

            var index : Int = 1;
            for (answer in currentQuestion.question.answers)
            {
                text = getComponentAs("txtA" + index, Text);
                text.text = answer;
                text.wrapLines = true;
                text.multiline = true;

                // Check correctness
                // if (index == currentQuestion.question.correct)

                index += 1;
            }
        }
        else
        {
            throw "Question not found " + Next;
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
