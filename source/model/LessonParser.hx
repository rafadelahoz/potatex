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
                break;
            }
        }
    }

    function parseLesson(filename : String, contents : String) : Lesson
    {
        var lesson : Lesson = new Lesson();

        var lines : Array<String> = contents.split("\n");

        var token : Token = Title;
        var currentText : String = "";
        var question = new Question();

        for (line in lines)
        {
            if (StringTools.trim(line).length > 0)
            {
                trace("## line: " + line);

                var markerPos = line.indexOf("-");
                if (markerPos > 0)
                {
                    var mark : String = line.substring(0, markerPos);
                    line = line.substring(markerPos+1);
                    mark = StringTools.trim(mark);
                    trace("### Marker: " + mark);

                    // Close the previous token
                    switch (token)
                    {
                        case Title:
                            trace("#### Finish title: set lesson title: " + currentText);
                            lesson.title = currentText;
                            currentText = "";
                        case Question:
                            trace("Finish question: set question text: " + currentText);
                            question.text = currentText;
                            lesson.questions.push(question);
                            currentText = "";
                        case Answer:
                            trace("Finish answer: add answer: " + currentText);
                            question.answers.push(currentText);
                            currentText = "";
                        default:
                            trace("Finished what?");
                            currentText = "";
                    }

                    var realQuestion : Bool = false;
                    // If an R is found, we have found a real question
                    if (mark.charAt(mark.length-1) == "R")
                    {
                        realQuestion = true;
                        // Make sure to remove the R from the mark
                        mark = mark.substring(0, mark.length-1);
                        trace("#### The question is real, marker:" + mark);
                    }

                    // Check if this is a question
                    var number : Null<Int> = Std.parseInt(mark);
                    if (number != null)
                    {
                        trace("Located question, #" + number);
                        question = new Question(number);
                        question.real = realQuestion;
                        token = Question;
                    }
                    // Or maybe it is an answer
                    else if (~/[A-D]/i.match(mark))
                    {
                        trace("Located answer");
                        token = Answer;
                    }
                }
                else
                {
                    // Check if it's the answers line
                    if (~/([1-9]+[a-d].?,?)+\.?/i.match(line))
                    {
                        trace("Found answers line");
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
                                trace("Question " + number + ": " + q.correct + "(" + letter + ")");
                            }
                            else
                            {
                                trace("Question " + number + " not found!");
                            }
                        }
                    }

                    continue;
                }

                trace("Storing line");
                // Append the text of the current line to the line
                currentText += " " + line;
                trace("#### CurrentText: " + currentText);
            }
        }

        return lesson;
    }
}

enum Token
{
    Title; Question; Answer; Answers;
}
