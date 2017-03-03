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
}
