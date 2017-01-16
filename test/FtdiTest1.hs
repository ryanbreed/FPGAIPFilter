import Protolude
import LibFtdi (ftdiInit, ftdiDeInit)
import Data.Text as T

main :: IO ()
main = do
  dh <- ftdiInit
  case dh of
    Left err -> putStrLn $ T.pack $ "Error:" ++ show err
    Right d -> do
      putStrLn ("Init OK" :: Text)
      ftdiDeInit d
