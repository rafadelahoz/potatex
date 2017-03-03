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
}
