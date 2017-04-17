package;

import haxe.Serializer;
import haxe.Unserializer;

class Storage
{
    public static function store()
    {
        trace("Start saving...");

        var save : Save = new Save();
        save.bind("data");

        save.data.lastTestBuildOptions = serializeBuildOptions(Session.lastTestBuildOptions);
        save.data.statsData = serializeStatistics();
        save.data.id = "Hello potatex";

        save.close();

        trace("Saved successfully");
    }

    public static function restore()
    {
        trace("Restoring...");

        var save : Save = new Save();
        save.bind("data");

        trace("Found data with id: " + save.data.id);
        trace("TestBuildOptions " + (save.data.lastTestBuildOptions == null ? " not found" : " found"));
        trace("StatsData " + (save.data.statsData == null ? " not found" : " found"));

        Session.lastTestBuildOptions = unserializeBuildOptions(save.data.lastTestBuildOptions);
        unserializeStatistics(save.data.statsData);

        save.close();

        trace("Restored successfully");
    }

    static function serializeBuildOptions(opt : TestBuilder.TestBuildOptions) : Dynamic
    {
        var result : Dynamic;

        result = {};
        result.numberOfQuestions = opt.numberOfQuestions;
        result.onlyReal = opt.onlyReal;
        result.onlyAnswered = opt.onlyAnswered;
        result.config = opt.config;
        result.sourceLessons = [];
        for (lesson in opt.sourceLessons)
        {
            result.sourceLessons.push(lesson.title);
        }

        return result;
    }

    static function unserializeBuildOptions(input : Dynamic) : TestBuilder.TestBuildOptions
    {
        var sourceLessons : Array<Lesson> = [];

        if (input == null)
            return null;

        if (input.sourceLessons != null)
        {
            for (lessonTitle in cast(input.sourceLessons, Array<Dynamic>))
            {
                sourceLessons.push(DB.getLessonByTitle(lessonTitle));
            }
        }

        var result : TestBuilder.TestBuildOptions = {
            numberOfQuestions: input.numberOfQuestions,
            onlyReal: input.onlyReal,
            onlyAnswered: input.onlyAnswered,
            config: input.config,
            sourceLessons: sourceLessons
        }

        return result;
    }

    static function serializeStatistics() : String
    {
        var s : Serializer = new Serializer();
        s.serialize(Statistics.statsMap);
        s.serialize(Statistics.failedList);

        trace(s.toString());

        return s.toString();
    }

    static function unserializeStatistics(input : String)
    {
        trace(input);
        if (input == null)
        {
            Statistics.statsMap = new Map<String, StatsData>();
            Statistics.failedList = [];
        }
        else
        {
            var u : Unserializer = new Unserializer(input);

            try
            {
                Statistics.statsMap = u.unserialize();
            }
            catch (exception : Dynamic)
            {
                trace("Could not parse Statistics Map:\n" + exception);
                Statistics.statsMap = new Map<String, StatsData>();
            }

            try
            {
                Statistics.failedList = u.unserialize();
            }
            catch (exception : Dynamic)
            {
                trace("Could not parse Failed Questions list:\n" + exception);
                Statistics.failedList = [];
            }
        }
    }
}
