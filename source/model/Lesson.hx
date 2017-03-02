package;

class Lesson
{
    public var title : String;
    public var questions : Array<Question>;

    public function new()
    {
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
