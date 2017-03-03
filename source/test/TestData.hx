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
}

typedef TestConfiguration = {
    verifyAtTheEnd : Bool
}
