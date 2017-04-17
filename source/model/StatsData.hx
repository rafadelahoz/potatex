package;

import haxe.Serializer;
import haxe.Unserializer;

class StatsData
{
    public var questionId : String;

    public var timesAnswered : Int;
    public var timesFailed : Int;

    public var answerLog : Array<TimedAnswer>;

    public function new(qid : String, ?timesAnswered : Int = 0, ?timesFailed : Int = 0)
    {
        this.questionId = qid;
        this.timesAnswered = timesAnswered;
        this.timesFailed = timesFailed;
        this.answerLog = [];
    }

    @:keep
    function hxSerialize(s : Serializer)
    {
        s.serialize(questionId);
        s.serialize(timesAnswered);
        s.serialize(timesFailed);
    }

    @:keep
    function hxUnserialize(u : Unserializer)
    {
        questionId = u.unserialize();
        timesAnswered = u.unserialize();
        timesFailed = u.unserialize();
        answerLog = [];
    }
}

class TimedAnswer
{
    public var time : Date;
    public var ok : Bool;

    public function new(time : Date, ok : Bool)
    {
        this.time = time;
        this.ok = ok;
    }
}
