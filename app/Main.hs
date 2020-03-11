module Main where

import System.Process
import System.Environment
import System.IO
import System.Exit
import Control.Concurrent

proc' :: FilePath -> [String] -> CreateProcess
proc' cmd args = (proc cmd args) { std_in = CreatePipe,
                                   create_group = True,
                                   delegate_ctlc = False
                                 }

main :: IO ()
main = do
  (cmd:args) <- getArgs
  (Just pin, _, _, pHandle) <- createProcess $ proc' cmd args
  hSetBuffering pin NoBuffering
  hSetBuffering stdin NoBuffering
  let f '\x03' = interruptProcessGroupOf pHandle
      f c = hPutChar pin c
  forkIO $ getContents >>= mapM_ f
  waitForProcess pHandle >>= exitWith
