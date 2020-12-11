defmodule Veritaserum.Builder do
  @moduledoc """
  Build a lookup Map from JSON file
  """

  def get(lang, facet) do
    original_wordlist =
      "#{__DIR__}/../config/facets/#{lang}/#{facet}.json"
      |> File.read!()
      |> Jason.decode!()

    wordlist =
      with loc when is_bitstring(loc) <-
             Application.get_env(:veritaserum, :"custom_#{lang}_#{facet}") do
        loc
        |> File.read!()
        |> Jason.decode!()
        |> Map.merge(original_wordlist)
      else
        _ -> original_wordlist
      end
  end
end
