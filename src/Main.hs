{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           Data.Aeson
import           Text.Pandoc

import qualified Codec.Binary.UTF8.String as W8
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C8

main :: IO ()
main = quickHttpServe site

data SMResult = SMResult {
    msg :: String
} deriving Show

instance ToJSON SMResult where
     toJSON (SMResult msg) = object ["msg" .= msg]

instance FromJSON SMResult where
    parseJSON (Object v) = SMResult <$>
                            v .: "msg"
     -- A non-Object value is of the wrong type, so fail.

writerOption :: WriterOptions
writerOption = def { writerHtml5  = True,
                     writerSlideVariant=RevealJsSlides }

myPandoc :: String -> Pandoc
myPandoc mkd = readMarkdown def mkd

mkd2html :: C8.ByteString -> String
mkd2html mkd = writeHtmlString writerOption (myPandoc mkd')
    where mkd' = W8.decode $ BS.unpack mkd

site :: Snap ()
site =
    ifTop (writeBS "/slideme") <|>
    route [ ("help", writeBS "me")
          , ("slideme/", method POST slideMe)
          , ("slideme/:mkd", slideMe)
          ] <|>
    dir "static" (serveDirectory ".")

slideMe :: Snap ()
slideMe = do
    param <- getParam "mkd"
    case param of
        Just p -> writeBS $ BS.concat $ BL.toChunks $ Data.Aeson.encode $ SMResult (mkd2html p)
        Nothing -> writeBS "{'msg':'error'}"
