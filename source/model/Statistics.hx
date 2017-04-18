package;

class Statistics
{
    public static var statsMap : Map<String, StatsData>;
    public static var failedList : Array<String>;

    public static function recordAnswer(questionId : String, ok : Bool, ?clearFailure : Bool = false)
    {
        if (statsMap == null)
            statsMap = new Map<String, StatsData>();

        if (!statsMap.exists(questionId)) {
            statsMap.set(questionId, new StatsData(questionId));
        }

        statsMap.get(questionId).timesAnswered += 1;

        if (!ok)
        {
            statsMap.get(questionId).timesFailed += 1;
            if (failedList.indexOf(questionId) < 0)
                failedList.push(questionId);
        }
        else if (clearFailure)
        {
            if (failedList.indexOf(questionId) > -1)
            {
                failedList.remove(questionId);
                trace("Removed " + questionId + " from failures list");
            }
        }

        // trace(statsMap);
        // trace(failedList);
    }
}
