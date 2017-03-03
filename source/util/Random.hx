package;

class Random
{
    /**
	 * Pseudorandomly select from an array of weighted options. For example, if you passed in an array of [50, 30, 20]
	 * there would be a 50% chance of returning a 0, a 30% chance of returning a 1, and a 20% chance of returning a 2.
	 * Note that the values in the array do not have to add to 100 or any other number.
	 * The percent chance will be equal to a given value in the array divided by the total of all values in the array.
	 *
	 * @param   WeightsArray   An array of weights.
	 * @return  A value between 0 and (SelectionArray.length - 1), with a probability equivalent to the values in SelectionArray.
	 */
	public static function weightedPick(WeightsArray:Array<Float>):Int
	{
		var totalWeight:Float = 0;
		var pick:Int = 0;

		for (i in WeightsArray)
		{
			totalWeight += i;
		}

		totalWeight = float(0, totalWeight);

		for (i in 0...WeightsArray.length)
		{
			if (totalWeight < WeightsArray[i])
			{
				pick = i;
				break;
			}

			totalWeight -= WeightsArray[i];
		}

		return pick;
	}

	/**
	 * Returns a random object from an array.
	 *
	 * @param   Objects        An array from which to return an object.
	 * @param   WeightsArray   Optional array of weights which will determine the likelihood of returning a given value from Objects.
	 * 						   If none is passed, all objects in the Objects array will have an equal likelihood of being returned.
	 *                         Values in WeightsArray will correspond to objects in Objects exactly.
	 * @param   StartIndex     Optional index from which to restrict selection. Default value is 0, or the beginning of the Objects array.
	 * @param   EndIndex       Optional index at which to restrict selection. Ignored if 0, which is the default value.
	 * @return  A pseudorandomly chosen object from Objects.
	 */
	@:generic
	public static function getObject<T>(Objects:Array<T>, ?WeightsArray:Array<Float>, StartIndex:Int = 0, ?EndIndex:Null<Int>):T
	{
		var selected:Null<T> = null;
        var _arrayFloatHelper:Array<Float> = null;

		if (Objects.length != 0)
		{
			if (WeightsArray == null)
			{
				WeightsArray = [for (i in 0...Objects.length) 1];
			}

			if (EndIndex == null)
			{
				EndIndex = Objects.length - 1;
			}

			StartIndex = Std.int(bound(StartIndex, 0, Objects.length - 1));
			EndIndex = Std.int(bound(EndIndex, 0, Objects.length - 1));

			// Swap values if reversed
			if (EndIndex < StartIndex)
			{
				StartIndex = StartIndex + EndIndex;
				EndIndex = StartIndex - EndIndex;
				StartIndex = StartIndex - EndIndex;
			}

			if (EndIndex > WeightsArray.length - 1)
			{
				EndIndex = WeightsArray.length - 1;
			}

			_arrayFloatHelper = [for (i in StartIndex...EndIndex + 1) WeightsArray[i]];
			selected = Objects[weightedPick(_arrayFloatHelper)];
		}

		return selected;
	}

    /**
	 * Bound a number by a minimum and maximum. Ensures that this number is
	 * no smaller than the minimum, and no larger than the maximum.
	 * Leaving a bound `null` means that side is unbounded.
	 *
	 * @param	Value	Any number.
	 * @param	Min		Any number.
	 * @param	Max		Any number.
	 * @return	The bounded value of the number.
	 */
	public static inline function bound(Value:Float, ?Min:Float, ?Max:Float):Float
	{
		var lowerBound:Float = (Min != null && Value < Min) ? Min : Value;
		return (Max != null && lowerBound > Max) ? Max : lowerBound;
	}

    public static function float(Min:Float = 0, Max:Float = 1)
    {
        return Min+Math.random()*(Max-Min);
    }
}
