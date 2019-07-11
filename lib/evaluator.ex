defmodule Veritaserum.Evaluator do
  @moduledoc """
  Evaluats words, boosters, negators and emoticons.
  """

  # Builds the evaluator for language-specific facets (words, boosters and negators)
  ["pt", "en"]
  |> Enum.each(fn lang ->
    ["word", "negator", "booster"]
    |> Enum.each(fn facet ->
      wordlist =
        "#{__DIR__}/../config/facets/#{lang}/#{facet}.json"
        |> File.read!()
        |> Jason.decode!()

      @doc """
      Lists all the words in the #{facet} facet for the specified language.

          iex> Veritaserum.Evaluator.#{facet}_list("#{lang}")
          ["#{facet}_word", ...]
      """
      def unquote(:"#{facet}_list")(unquote(lang)),
        do: unquote(Map.keys(wordlist))

      Enum.each(wordlist, fn {word, score} ->
        @doc """
        Evaluates if a word/emoji is a **#{facet}** and returns the associated score.

            iex> Veritaserum.Evaluator.evaluate_#{facet}("#{word}", "#{lang}")
            #{score}
        """
        def unquote(:"evaluate_#{facet}")(unquote(word), unquote(lang)), do: unquote(score)
      end)

      def unquote(:"evaluate_#{facet}")(_, unquote(lang)), do: nil
    end)
  end)

  # Builds the evaluator for language-agnostic facets (emoticon)
  emoticons =
    "#{__DIR__}/../config/facets/emoticon.json"
    |> File.read!()
    |> Jason.decode!()

  @doc """
  Lists all the supported emojis.

      iex> Veritaserum.Evaluator.emoticon_list()
      ["😍", ...]
  """
  def unquote(:emoticon_list)(),
    do: unquote(Map.keys(emoticons))

  Enum.each(emoticons, fn {emoji, score} ->
    @doc """
    Evaluates if a word/emoji is a **emoticon** and returns the associated score.

        iex> Veritaserum.Evaluator.evaluate_emoticon("#{emoji}")
        #{score}
    """
    def unquote(:evaluate_emoticon)(unquote(emoji)), do: unquote(score)
  end)

  def unquote(:evaluate_emoticon)(_), do: nil
end
