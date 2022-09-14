module Magitty (app) where

import Brick (Widget, simpleMain, str)

ui :: Widget ()
ui = str "Hello, Magitty!"

app :: IO ()
app = simpleMain ui