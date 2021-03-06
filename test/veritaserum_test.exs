defmodule VeritaserumTest do
  use ExUnit.Case

  doctest Veritaserum

  import Veritaserum

  describe "when given a list" do
    @list ["I love Veritaserum", "I hate nothing"]

    test "calculates sentimental value for each" do
      assert analyze(@list) == [3, -3]
    end
  end

  describe "when text has relevant word" do
    test "calculates sentimental value" do
      en_text = "I love Veritaserum"

      assert analyze(en_text) == 3
    end

    test "calculates sentimental value for the specified language" do
      pt_text = "eu favores veritaserum"

      assert analyze(pt_text, "pt") == 2
    end
  end

  describe "when text has no relevant word" do
    @text "I build Veritaserum"

    test "sentimental value is 0" do
      assert analyze(@text) == 0
    end
  end

  describe "when language is not supported" do
    @text "amo il veritaserum"

    test "sentiment value is nil" do
      assert analyze(@text, "it") == nil
    end
  end

  describe "when using analyze_with_metadata" do
    @text "You really love Veritaserum. Don't you?"

    test "returns score with marks" do
      result =
        {4,
         [
           {:neutral, 0, "you"},
           {:booster, 1, "really"},
           {:word, 3, "love"},
           {:neutral, 0, "veritaserum"},
           {:negator, 1, "don't"},
           {:neutral, 0, "you?"}
         ]}

      assert ^result = analyze_with_metadata(@text)
    end
  end

  describe "when text has relevant emoji" do
    @text "I ❤️ Veritaserum"

    test "calculates sentimental value" do
      assert analyze(@text) == 3
    end

    @text "I❤️Veritaserum"

    test "calculates sentimental value of emoji without spaces" do
      assert analyze(@text) == 3
    end
  end

  describe "when text has irrelevant characters" do
    @text "I love! Veritaserum"

    test "removes irrelevant characters" do
      assert analyze(@text) == 3
    end
  end

  describe "when text has negator" do
    @text "I don't hate Veritaserum"

    test "the negator flips the value of the next word" do
      assert analyze(@text) == 3
    end
  end

  describe "when positive word has booster" do
    @text "I really love Veritaserum"

    test "the booster increases the value of the next word" do
      assert analyze(@text) == 4
    end
  end

  describe "when negative word has booster" do
    @text "I really hate Veritaserum"

    test "the booster decreases the value of the next word" do
      assert analyze(@text) == -4
    end
  end

  describe "when irrelevant word has booster" do
    @text "I really buy Veritaserum"

    test "the booster does not affect the value of the next word" do
      assert analyze(@text) == 0
    end
  end
end
