package;

class DB
{
    public static var lessons : Array<Lesson> = [];

    public static function getLessonByTitle(title : String) : Lesson
    {
        for (lesson in lessons)
        {
            if (lesson.title == title)
                return lesson;
        }

        return null;
    }

    public static function getLessonByFilename(filename : String) : Lesson
    {
        for (lesson in lessons)
        {
            if (lesson.filename == filename)
                return lesson;
        }

        return null;
    }

    public static function getIdsOfQuestionsOfLesson(title : String) : Array<String>
    {
        var list : Array<String> =  [];

        for (question in DB.getLessonByTitle(title).questions) {
            list.push(question.id);
        }

        return list;
    }

    public static function findQuestionById(questionId : String) : Question
    {
        var question : Question = null;

        trace("QuestionId: " + questionId);

        if (questionId != null)
        {
            var lessonId : String = Question.lessonFromId(questionId);
            trace("LessonId: " + lessonId);
            if (lessonId != null)
            {
                var lesson : Lesson = getLessonByTitle(lessonId);
                if (lesson != null)
                {
                    trace("Found lesson");
                    question = lesson.getQuestionById(questionId);
                    trace("Question: " + question);
                }
            }
        }

        return question;
    }
}
