require "open-uri"
require "json"

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ("A".."Z").to_a.sample }
  end

  def score
    @word    = params[:word].to_s.strip
    @letters = params[:letters].to_s.split # => ["A","T","K",...]

    in_grid = in_grid?(@word, @letters)

    url = "https://dictionary.lewagon.com/#{@word}"
    json = URI.open(url).read
    api_result = JSON.parse(json) # {"found"=>true/false, "length"=>..., ...} :contentReference[oaicite:1]{index=1}

    if !in_grid
      @message = "Désolé mais #{@word.upcase} ne peut pas être construit avec #{@letters.join(', ')}."
      @score = 0
    elsif !api_result["found"]
      @message = "Désolé mais #{@word.upcase} n’est pas un mot anglais valide."
      @score = 0
    else
      @message = "Bravo ! #{@word.upcase} est valide 🎉"
      @score = api_result["length"] # ou @word.length
    end
  end

  private

  # vérifie les fréquences : ex. "FOO" nécessite 2 "O"
  def in_grid?(word, letters)
    attempt = word.upcase.chars
    attempt.all? { |char| attempt.count(char) <= letters.count(char) }
  end
end
