import           Data.Text as T
import           LibFtdi   (DeviceHandle, ftdiDeInit, ftdiInit, ftdiUSBClose,
                            ftdiUSBOpen, ftdiUSBReset, withFtdi)
import           Protolude

doStuff :: DeviceHandle -> IO ()
doStuff d = do
  ftdiUSBOpen d (0x09fb, 0x6001)
  ftdiUSBReset d
  putStrLn ("Init OK" :: Text)
  ftdiUSBClose d
  ftdiDeInit d

main :: IO ()
main = do
    dh <- ftdiInit
    case dh of
      Left err -> putStrLn $ T.pack $ "Error:" ++ show err
      Right _ -> withFtdi doStuff
