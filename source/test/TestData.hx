package;

class TestData
{
    public var title : String;
    public var config : TestConfiguration;
    public var questions : Array<TestQuestion>;

    public function new(Title : String, ?Questions : Array<TestQuestion> = null, Config : TestConfiguration)
    {
        title = Title;
        if (Questions == null)
            Questions = [];
        questions = Questions;
        config = Config;
    }

    public function getCorrectlyAswered() : Int
    {
        var correct : Int = 0;
        for (question in questions)
        {
            if (question.question.correct > -1 && question.answer == question.question.correct)
                correct += 1;
        }

        return correct;
    }

    public function getAnswerableQuestions() : Int
    {
        var answerable : Int = 0;
        for (question in questions)
        {
            if (question.question.correct > -1)
                answerable += 1;
        }

        return answerable;
    }
}

typedef TestConfiguration = {
    verifyAtTheEnd : Bool
}
