package;

class TestBuilder
{
    public static function build(buildOptions : TestBuildOptions) : TestData
    {
        var lessons : Array<Lesson> = buildOptions.sourceLessons;
        // Fetch all questions together
        var allQuestions = mergeAllQuestions(lessons);

        // Filter out unwanted questions
        // 1. Real questions only
        if (buildOptions.onlyReal)
        {
            allQuestions = allQuestions.filter(function (question : Question) : Bool {
                return question.real;
            });
        }

        // 2. Answerable questions only
        if (buildOptions.onlyAnswered)
        {
            allQuestions = allQuestions.filter(function (question : Question) : Bool {
                return question.correct > -1;
            });
        }

        // Check if there are enough questions to fill the expected qtty.
        var availableQuestions = allQuestions.length;
        // If there's not enough, use all of them?
        var targetQuestions : Int = Std.int(Math.min(availableQuestions, buildOptions.numberOfQuestions));

        // Select questions
        var questions : Array<TestQuestion> = [];
        for (number in 0...targetQuestions)
        {
            var question : Question = Random.getObject(allQuestions);
            allQuestions.remove(question);

            var tquestion : TestQuestion = new TestQuestion(question);
            questions.push(tquestion);
        }

        var data : TestData = new TestData("Test a medida", questions, buildOptions.config);
        return data;
    }

    public static function buildFailedQuestionsTest() : TestData
    {
        var questions : Array<TestQuestion> = [];
        trace(Statistics.failedList);
        for (questionId in Statistics.failedList)
        {
            var question : Question = DB.findQuestionById(questionId);
            if (question != null)
                questions.push(new TestQuestion(question));
        }

        Random.shuffle(questions);

        var config : TestData.TestConfiguration = {
            verifyAtTheEnd: false
        };

        var data : TestData = new TestData("Test de Repaso", questions, config);
        data.failedQuestionsTest = true;
        return data;
    }

    static function mergeAllQuestions(lessons : Array<Lesson>) : Array<Question>
    {
        var questions : Array<Question> = [];

        for (lesson in lessons)
            for (question in lesson.questions)
                questions.push(question);

        return questions;
    }
}

typedef TestBuildOptions = {
    numberOfQuestions : Int,
    sourceLessons : Array<Lesson>,
    onlyReal : Bool,
    onlyAnswered : Bool,
    config : TestData.TestConfiguration
}
