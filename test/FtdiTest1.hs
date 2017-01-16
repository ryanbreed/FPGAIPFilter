import Protolude
import LibFtdi (ftdiInit)

main :: IO ()
main = do
  dh <- ftdiInit
  putStrLn ("Test suite not yet implemented" :: Text)
