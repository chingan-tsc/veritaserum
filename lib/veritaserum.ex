defmodule Veritaserum do
  @moduledoc """
  Sentiment analysis based on AFINN-165, emojis and some enhancements.

  Also supports:
  - emojis (❤️, 😱...)
  - boosters (*very*, *really*...)
  - negators (*don't*, *not*...).
  """

  alias Veritaserum.Evaluator

  @doc """
  Returns a sentiment value for the given text

      iex> Veritaserum.analyze(["I ❤️ Veritaserum", "Veritaserum is really awesome"])
      [3, 5]

      iex> Veritaserum.analyze("I love Veritaserum")
      3
  """
  @spec analyze(list(String.t()) | String.t()) :: list(integer) | integer
  def analyze(input) when is_list(input) do
    input
    |> Stream.map(&analyze/1)
    |> Enum.to_list()
  end

  def analyze(input) do
    {score, _} = analyze(input, return: :score_and_marks)

    score
  end

  @doc """
  Returns a tuple of the sentiment value and the metadata for the given text

      iex> Veritaserum.analyze("I love Veritaserum", return: :score_and_marks)
      {3, [{:neutral, 0, "i"}, {:word, 3, "love"}, {:neutral, 0, "veritaserum"}]}
      
  """
  @spec analyze(String.t(), return: :score_and_marks) :: {number(), [{atom, number, String.t()}]}
  def analyze(input, return: :score_and_marks) do
    list_with_marks =
      input
      |> clean
      |> String.split()
      |> Enum.map(&mark_word/1)

    score = get_score(list_with_marks)

    {score, list_with_marks}
  end

  # Mark every word in the input with type and score
  defp mark_word(word) do
    with {_, nil, _} <- {:negator, Evaluator.evaluate_negator(word), word},
         {_, nil, _} <- {:booster, Evaluator.evaluate_booster(word), word},
         {_, nil, _} <- {:emoticon, Evaluator.evaluate_emoticon(word), word},
         {_, nil, _} <- {:word, Evaluator.evaluate_word(word), word},
         do: {:neutral, 0, word}
  end

  # Compute the score from a list of marked words
  defp get_score(words) do
    words
    |> Stream.chunk_every(2, 1)
    |> Stream.map(fn pair ->
      case pair do
        [{:negator, _, _}, {:word, score, _}] ->
          -score

        [{:booster, booster_score, _}, {:word, word_score, _}] ->
          if word_score > 0, do: word_score + booster_score, else: word_score - booster_score

        [_, {type, score, _}] when type in [:word, :emoticon] ->
          score

        _ ->
          0
      end
    end)
    |> Enum.sum()
  end

  # Clean and sanitize the input text
  defp clean(text) do
    text
    |> String.replace(~r/\n/, " ")
    |> String.downcase()
    |> String.replace(~r/[.,\/#!$%\^&\*;:{}=_`\"~()]/, " ")
    |> String.replace(Evaluator.emoticon_list(), "  ", insert_replaced: 1)
    |> String.replace(~r/ {2,}/, " ")
  end
end
