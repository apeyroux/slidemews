import Text.Pandoc

writerOption :: WriterOptions
writerOption = def { writerHtml5  = True,
                     writerSlideVariant=RevealJsSlides }

myPandoc :: Pandoc
myPandoc = readMarkdown def  "# slide 1\nJe suis un slide !"

main :: IO()
main = do
  putStrLn httpl
  where
    httpl = writeHtmlString writerOption myPandoc  
