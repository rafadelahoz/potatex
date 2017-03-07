package;

class Lesson
{
    public var number : Int;
    public var filename : String;
    public var title : String;
    public var questions : Array<Question>;

    public function new()
    {
        number = -1;
        filename = "filename";
        title = "Dummy lesson";
        questions = [];
    }

    public function getQuestion(num : Int) : Question
    {
        for (q in questions)
        {
            if (q.number == num)
                return q;
        }

        return null;
    }
}
