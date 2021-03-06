{-# LANGUAGE OverloadedStrings #-}

module Macbeth.Fics.Parsers.SeekMsgParsers (
  clearSeek,
  newSeek,
  removeSeeks,
  seekNotAvailable,
  seekInfoBlock
) where

import Macbeth.Fics.Api.Api
import Macbeth.Fics.FicsMessage
import Macbeth.Fics.Api.Game
import Macbeth.Fics.Api.Rating
import Macbeth.Fics.Api.Seek
import Macbeth.Fics.Parsers.Api
import Macbeth.Fics.Utils.Bitmask

import Control.Applicative
import Data.Attoparsec.ByteString.Char8
import Numeric

clearSeek :: Parser FicsMessage
clearSeek = "<sc>" *> pure ClearSeek

newSeek :: Parser FicsMessage
newSeek = NewSeek <$> seek'

removeSeeks :: Parser FicsMessage
removeSeeks = RemoveSeeks <$> ("<sr>" *> many1 (space *> decimal))

seekNotAvailable :: Parser FicsMessage
seekNotAvailable = commandHead 158 *> "That seek is not available." *> pure SeekNotAvailable

seekInfoBlock :: Parser FicsMessage
seekInfoBlock = Boxed
  <$> (commandHead 56 *> "seekinfo set.\n" *> sepBy (choice [ clearSeek, newSeek <* takeTill (== '\n')]) "\n")

seek' :: Parser Seek
seek' = Seek
  <$> ("<s>" *> space *> decimal)
  <*> (space *> "w=" *> manyTill anyChar space)
  <*> ("ti=" *> titles')
  <*> ("rt=" *> rating')
  <*> (space *> "t=" *> decimal)
  <*> (space *> "i=" *> decimal)
  <*> (space *> "r=" *> ("r" *> pure True <|> "u" *> pure False))
  <*> (space *> "tp=" *> gameType')
  <*> (space *> "c=" *> ("W" *> pure (Just White) <|>
                         "B" *> pure (Just Black) <|>
                         "?" *> pure Nothing))
  <*> (space *> "rr=" *> ((,) <$> decimal <*> ("-" *> decimal)))

gameType' :: Parser GameType
gameType' =
  "blitz" *> pure Blitz <|>
  "lightning" *> pure Lightning <|>
  "untimed" *> pure Untimed <|>
  "examined" *> pure ExaminedGame <|>
  "standard" *> pure Standard <|>
  "wild/" *> decimal *> pure Wild <|>
  "atomic" *> pure Atomic <|>
  "crazyhouse" *> pure Crazyhouse <|>
  "bughouse" *> pure Bughouse <|>
  "losers" *> pure Losers <|>
  "suicide" *> pure Suicide <|>
  takeTill (== ' ') *> pure NonStandardGame


rating' :: Parser Rating
rating' = Rating <$> decimal <*> provShow'


provShow' :: Parser ProvShow
provShow' = " " *> pure None <|>
            "E" *> pure Estimated <|>
            "P" *> pure Provisional


titles' :: Parser [Title]
titles' = manyTill anyChar space >>= pure . fromBitMask . fst . head . readHex
