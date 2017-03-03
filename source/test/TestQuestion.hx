package;

class TestQuestion
{
    public var question : Question;
    public var state : QuestionState;
    public var answer : Int;

    public function new(Question : Question)
    {
        question = Question;
        state = Pending;
        answer = -1;
    }

    public function doAnswer(selected : Int)
    {
        state = Answered;
        answer = selected;
    }
}

enum QuestionState {Pending; Answered; Aftermath;}
