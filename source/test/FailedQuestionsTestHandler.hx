package;

class FailedQuestionsTestHandler
{
    public function new()
    {

    }

    public function prepareTest() : TestController
    {
        // Prepares a test with the failed questions
        var testData : TestData = TestBuilder.buildFailedQuestionsTest();
        trace(testData);
        return new TestController(testData);
    }
}
