package;

class Question
{
    public var lessonId : String;

    public var number : Int;
    public var text : String;

    public var answers : Array<String>;

    public var correct : Int;
    public var real : Bool;

    public function new(?LessonId : String = null, ?Number : Int = -1, ?Text : String = null)
    {
        lessonId = LessonId;
        number = Number;
        text = Text;
        answers = [];
        correct = -1;
        real = false;
    }

    public function toString() : String
    {
        var string : String = "";

        string += lessonId + ": " + "Q" + number + ": " + text + (real ? " (Real) " : " ") + (correct < 0 ? "X" : [" ", "A", "B", "C", "D"][correct]) + "\n";
        for (answer in answers)
        {
            string += "  - " + answer + "\n";
        }

        return string;
    }

    public function getDetailLine() : String
    {
        return lessonId + ": " + "Q" + number + ": " + text + (real ? " (Real) " : " ") + (correct < 0 ? "X" : [" ", "A", "B", "C", "D"][correct]);
    }
}
