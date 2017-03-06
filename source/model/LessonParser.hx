package;

import openfl.Assets;

class LessonParser
{
    var lessonPath : String = "assets/lessons";

    public function new()
    {

    }

    public function loadLessons()
    {
        var lessonNames : Array<String> = sys.FileSystem.readDirectory(lessonPath);
        var lessonObject : Lesson = null;
        for (lessonName in lessonNames)
        {
            var lessonString : String = Assets.getText(lessonPath + "/" + lessonName);
            if (lessonString != null)
            {
                lessonObject = parseLesson(lessonName, lessonString);
                DB.lessons.push(lessonObject);

                if (debugOutput)
                    break;
            }
        }

        DB.lessons.sort(function(a : Lesson, b : Lesson) : Int {
            if (a.title > b.title)
                return 1;
            else if (a.title < b.title)
                return -1;
            else
                return 0;
        });
    }

    function parseLesson(filename : String, contents : String) : Lesson
    {
        var lesson : Lesson = new Lesson();

        var lines : Array<String> = contents.split("\n");

        var token : Token = Title;
        var currentText : String = "";
        var question : Question = null;

        for (line in lines)
        {
            if (StringTools.trim(line).length > 0)
            {
                dtrace("## line: " + line);

                var markerPos = line.indexOf("-");
                if (markerPos > 0)
                {
                    var originalLine : String = line;

                    var mark : String = line.substring(0, markerPos);
                    line = line.substring(markerPos+1);
                    mark = StringTools.trim(mark);
                    dtrace("### Marker: " + mark);

                    var prevToken : Token = token;
                    var foundNewToken : Bool = false;
                    // Analize the token
                    {
                        var realQuestion : Bool = false;
                        // If an R is found, we have found a real question
                        if (mark.charAt(mark.length-1) == "R")
                        {
                            realQuestion = true;
                            // Make sure to remove the R from the mark
                            mark = mark.substring(0, mark.length-1);
                            dtrace("#### The question is real, marker:" + mark);
                        }

                        // Check if this is a question
                        var number : Null<Int> = Std.parseInt(mark);
                        if (number != null)
                        {
                            dtrace("Located question, #" + number);
                            question = new Question(lesson.title, number);
                            question.real = realQuestion;
                            token = Question;

                            foundNewToken = true;
                        }
                        // Or maybe it is an answer
                        else if (mark == "A" || mark == "B" || mark == "C" || mark=="D")
                        {
                            dtrace("Located answer");
                            token = Answer;

                            foundNewToken = true;
                        }
                        else
                        {
                            dtrace("#### This is no marker: " + mark);
                            // The token was no token, restore the line
                            line = originalLine;
                        }
                    }

                    if (foundNewToken)
                    {
                        // Close the previous token
                        switch (prevToken)
                        {
                            case Title:
                                dtrace("#### Finish title: set lesson title: " + currentText);
                                lesson.title = currentText;
                                if (lesson.title == null || lesson.title == "")
                                    lesson.title = filename.substring(0, filename.indexOf(".txt"));
                                currentText = "";
                            case Question:
                                dtrace("Finish question: set question text: " + currentText);
                                question.text = currentText;
                                lesson.questions.push(question);
                                currentText = "";
                            case Answer:
                                dtrace("Finish answer: add answer: " + currentText);
                                question.answers.push(currentText);
                                currentText = "";
                            default:
                                dtrace("Finished what?");
                                currentText = "";
                        }
                    }
                }
                else
                {
                    // Check if it's the answers line
                    if (~/([1-9]+[a-d].?,?)+\.?/i.match(line))
                    {
                        dtrace("Found answers line");
                        var correctAnswers : Array<String> = line.split(",");
                        for (correctAnswer in correctAnswers)
                        {
                            correctAnswer = StringTools.trim(correctAnswer);
                            var letter : String = correctAnswer.charAt(correctAnswer.length-1).toLowerCase();
                            var number : Int = Std.parseInt(correctAnswer.substring(0, correctAnswer.length-1));
                            var q : Question = lesson.getQuestion(number);
                            if (q != null)
                            {
                                q.correct = ["a", "b", "c", "d"].indexOf(letter);
                                if (q.correct > -1)
                                    q.correct += 1;
                                dtrace("Question " + number + ": " + q.correct + "(" + letter + ")");
                            }
                            else
                            {
                                dtrace("Question " + number + " not found!");
                            }
                        }

                        continue;
                    }
                }

                // Append the text of the current line to the line
                currentText += " " + line;
                dtrace("#### CurrentText: " + currentText);
            }
        }

        return lesson;
    }

    static var debugOutput : Bool = false;
    static function dtrace(what : Dynamic)
    {
        if (debugOutput)
            trace(what);
    }
}

enum Token
{
    Title; Question; Answer; Answers;
}
