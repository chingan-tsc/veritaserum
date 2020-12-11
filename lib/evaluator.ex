defmodule Veritaserum.Evaluator do
  @moduledoc """
  Evaluates words, boosters, negators and emoticons.
  """

  @words %{
    "en" => Veritaserum.Builder.get("en", "word"),
    "es" => Veritaserum.Builder.get("es", "word"),
    "pt" => Veritaserum.Builder.get("pt", "word")
  }

  @negators %{
    "en" => Veritaserum.Builder.get("en", "negator"),
    "es" => Veritaserum.Builder.get("es", "negator"),
    "pt" => Veritaserum.Builder.get("pt", "negator")
  }

  @boosters %{
    "en" => Veritaserum.Builder.get("en", "booster"),
    "es" => Veritaserum.Builder.get("es", "booster"),
    "pt" => Veritaserum.Builder.get("pt", "booster")
  }

  @emoticons "#{__DIR__}/../config/facets/emoticon.json"
             |> File.read!()
             |> Jason.decode!()

  Veritaserum.supported_languages()
  |> Enum.each(fn lang ->
    @doc """
    Lists all the words in the specified language

        iex> Veritaserum.Evaluator.word_list("en")
        ["hi", ...]
    """
    def word_list(unquote(lang)) do
      Map.get(@words, unquote(lang), %{})
      |> Map.keys()
    end

    def evaluate_word(word, unquote(lang)) do
      Map.get(@words, unquote(lang), %{})
      |> Map.get(word, nil)
    end

    def evaluate_negator(word, unquote(lang)) do
      Map.get(@negators, unquote(lang), %{})
      |> Map.get(word, nil)
    end

    def evaluate_booster(word, unquote(lang)) do
      Map.get(@boosters, unquote(lang), %{})
      |> Map.get(word, nil)
    end
  end)

  def word_list(_), do: []
  def evaluate_word(_, _), do: nil

  @doc """
  Lists all the supported emojis.

      iex> Veritaserum.Evaluator.emoticon_list()
      ["😍", ...]
  """
  def unquote(:emoticon_list)(),
    do: unquote(Map.keys(@emoticons))

  def evaluate_emoticon(word) do
    Map.get(@emoticons, word, nil)
  end
end
