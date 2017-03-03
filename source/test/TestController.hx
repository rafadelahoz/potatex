package;

import haxe.ui.toolkit.core.XMLController;
import openfl.events.MouseEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;

class TestController extends XMLController
{
    var lesson : Lesson;
    var currentQuestionIndex : Int;
    var currentQuestion : Question;

    public function new()
    {
        super("layouts/test.xml");

        lesson = DB.lessons[0];

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

        if (Next > 0 && lesson.questions.length > Next)
        {
            var prevQuestion : Question = currentQuestion;
            currentQuestionIndex = Next;

            // Don't fail on next for now
            currentQuestion = lesson.getQuestion(Next);
            if (currentQuestion == null)
            {
                currentQuestion = lesson.questions[lesson.questions.indexOf(prevQuestion)+1];
            }

            trace("Q"+Next+": " + currentQuestion);

            var text : Text = getComponentAs("txtQuestion", Text);
            text.text = currentQuestion.text;
            text.style.autoSize = true;

            var index : Int = 1;
            for (answer in currentQuestion.answers)
            {
                text = getComponentAs("txtA" + index, Text);
                text.text = answer;
                if (index == currentQuestion.correct)
                    text.style.color=0xFF00FF0a;
                else
                    text.style.color=0xFF000000;

                text.style.autoSize = true;

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

            if (Std.parseInt(answer) == currentQuestion.correct)
                trace("Hurray!");

            fetchQuestion(currentQuestionIndex+1);

            /*
            var button : Button = getComponentAs(compId, Button);
            root.removeAllChildren();
            root.addChild(new MainController().view);*/
        };
    }
}
