package;

class TestBuilder
{
    public static function build(buildOptions : TestBuildOptions) : TestData
    {
        var lessons : Array<Lesson> = buildOptions.sourceLessons;
        // Fetch all questions together
        var allQuestions = mergeAllQuestions(lessons);

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

        var data : TestData = new TestData("Dummy Test!", questions, buildOptions.config);
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
    config : TestData.TestConfiguration
}
