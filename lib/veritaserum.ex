defmodule Veritaserum do
  @moduledoc """
  Sentiment analysis based on AFINN-165, emojis and some enhancements.

  Also supports:
  - emojis (❤️, 😱...)
  - boosters (*very*, *really*...)
  - negators (*don't*, *not*...).
  """

  alias Veritaserum.Evaluator

  @supported_languages ["pt", "es", "en"]

  @doc """
  Returns the list of supported languages.

      iex> Veritaserum.supported_languages()
      ["pt", "es", "en"]
  """
  @spec supported_languages() :: list(String.t())
  def supported_languages(), do: @supported_languages

  @doc """
  Returns the sentiment value for the given text.

  `lang` can be used to specify the language of the text (currently only English is supported)

      iex> Veritaserum.analyze(["I ❤️ Veritaserum", "Veritaserum is really awesome"])
      [3, 5]

      iex> Veritaserum.analyze("I love Veritaserum")
      3
  """
  @spec analyze(String.t() | list(String.t()), String.t()) :: integer | list(integer)
  def analyze(input, lang \\ "en")

  def analyze(input, lang) when is_list(input) and lang in @supported_languages do
    Enum.map(input, &analyze(&1, lang))
  end

  def analyze(input, lang) when is_bitstring(input) and lang in @supported_languages do
    input
    |> clean
    |> String.split()
    |> Enum.map(&mark_word(&1, lang))
    |> get_score()
  end

  def analyze(_, _), do: nil

  @doc """
  Returns a tuple of the sentiment value and the metadata for the given text.

  `lang` can be used to specify the language of the text (currently only English is supported)

      iex> Veritaserum.analyze_with_metadata("I love Veritaserum")
      {3, [{:neutral, 0, "i"}, {:word, 3, "love"}, {:neutral, 0, "veritaserum"}]}
      
  """
  @spec analyze_with_metadata(String.t(), String.t()) :: {number(), [{atom, number, String.t()}]}
  def analyze_with_metadata(input, lang \\ "en")

  def analyze_with_metadata(input, lang)
      when is_bitstring(input) and lang in @supported_languages do
    list_with_marks =
      input
      |> clean
      |> String.split()
      |> Enum.map(&mark_word(&1, lang))

    score = get_score(list_with_marks)

    {score, list_with_marks}
  end

  def analyze_with_metadata(_, _), do: nil

  # Mark every word in the input with type and score
  defp mark_word(word, lang) do
    with {_, nil, _} <- {:negator, Evaluator.evaluate_negator(word, lang), word},
         {_, nil, _} <- {:booster, Evaluator.evaluate_booster(word, lang), word},
         {_, nil, _} <- {:emoticon, Evaluator.evaluate_emoticon(word), word},
         {_, nil, _} <- {:word, Evaluator.evaluate_word(word, lang), word},
         do: {:neutral, 0, word}
  end

  # Compute the score from a list of marked words
  defp get_score(words) do
    [List.first(words) | words]
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
