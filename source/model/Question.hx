package;

class Question
{
    public var number : Int;
    public var text : String;
    public var answers : Array<String>;
    public var correct : Int;
    public var real : Bool;

    public function new(?Number : Int = -1, ?Text : String = null)
    {
        number = Number;
        text = Text;
        answers = [];
        correct = -1;
        real = false;
    }
}
