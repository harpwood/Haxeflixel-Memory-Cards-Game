package;

import Card;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	static inline final READY = "Ready to play";

	private var NUMBER_OF_CARDS:Int = 24;
	private var CARDS_PER_ROW:Int = 8;
	private var cards:Array<Int> = new Array();
	private var card:Card;
	private var pickedCards:Array<Card> = new Array();
	private var canPick:Bool = true;
	private var matchesFound = 0;
	private var canResetGame = false;
	private var statusText:FlxText;

	override public function create()
	{
		super.create();

		// cards creation loop
		for (i in 0...NUMBER_OF_CARDS)
		{
			cards.push(Math.floor(i / 2) + 1);
		}
		trace("My cards: " + cards);
		// end of cards creation loop

		// Fisher-Yates shuffle algorithm
		// shuffling loop
		var i:Int = NUMBER_OF_CARDS;
		var swap:Int, tmp:Int;
		while (i-- > 0)
		{
			swap = Math.floor(Math.random() * i);
			tmp = cards[i];
			cards[i] = cards[swap];
			cards[swap] = tmp;
		}
		trace("My shuffled cards: " + cards);
		// end of shuffling loop

		FlxG.plugins.add(new FlxMouseEventManager());

		// card placing loop
		for (i in 0...NUMBER_OF_CARDS)
		{
			card = new Card(cards[i]);
			add(card);
			var hm:Float = (FlxG.width - card.width * CARDS_PER_ROW - 10 * (CARDS_PER_ROW - 1)) / 2;
			var vm:Float = (FlxG.height - card.height * (NUMBER_OF_CARDS / CARDS_PER_ROW) - 10 * (NUMBER_OF_CARDS / CARDS_PER_ROW)) / 2;
			card.x = hm + (card.width + 10) * (i % CARDS_PER_ROW);
			card.y = vm + (card.height + 10) * (Math.floor(i / CARDS_PER_ROW));

			FlxMouseEventManager.add(card, onMouseDown);
		}
		// end of card placing loop
		statusText = new FlxText(0, FlxG.height - 50, FlxG.width, READY, 30);
		statusText.alignment = FlxTextAlign.CENTER;
		add(statusText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (((FlxG.mouse.justPressed) && (canResetGame)) || (FlxG.keys.justPressed.R))
		{
			FlxG.resetGame();
		}
	}

	private function onMouseDown(picked:Card)
	{
		statusText.text = "You picked a " + C.color[picked.index] + " card";

		if (canPick)
		{
			if (pickedCards.indexOf(picked) == -1)
			{
				pickedCards.push(picked);
				picked.flip();
			}

			if (pickedCards.length == 2)
			{
				canPick = false;
				if (pickedCards[0].index == pickedCards[1].index)
				{
					// cards match!!
					statusText.text = "Cards match!!!!";
					FlxMouseEventManager.remove(pickedCards[0]);
					FlxMouseEventManager.remove(pickedCards[1]);
					canPick = true;
					matchesFound++;
					pickedCards = new Array();
					if (matchesFound == NUMBER_OF_CARDS / 2)
					{
						statusText.text = "You won! Click anywhere to play again!";
						haxe.Timer.delay(function()
						{
							canResetGame = true;
						}, 1000);
					}
				}
				else
				{
					// cards do not match
					statusText.text = "Cards do not match";

					haxe.Timer.delay(function()
					{
						pickedCards[0].flipBack();
						pickedCards[1].flipBack();
						pickedCards = new Array();
						canPick = true;
						statusText.text = READY;
					}, 1000);
				}
			} // end checking if we picked 2 cards
		}
	}
}
