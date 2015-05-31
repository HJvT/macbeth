{-# LANGUAGE OverloadedStrings #-}

module WxGameResult (
  wxGameResult
) where

import Game

import Graphics.UI.WX
import Graphics.UI.WXCore
import System.IO

main :: IO ()
main = do
  start $ wxGameResult "Foobar checkmated" WhiteWins undefined stdout

wxGameResult :: String -> GameResult -> Frame () -> Handle -> IO ()
wxGameResult reason gameResult f_board h = do
  f <- frame [ text := "Game finished" ]
  p <- panel f []

  b_rematch  <- button p [text := "Rematch", on command := hPutStrLn h "5 rematch" >> close f ]
  b_closeBoard <- button p [text := "Close board", on command := close f_board >> close f]
  b_ok <- button p [text := "OK", on command := close f]

  st_result <- staticText p [ text := (reason ++ "\n" ++ show gameResult)
                            , fontFace := "Avenir Next Medium"]

  set f [ layout := container p $ margin 10 $
            column 20 [ widget st_result
                     , floatBottomRight $ row 5 [widget b_rematch, widget b_closeBoard, widget b_ok]]]

  windowShow f
  return ()