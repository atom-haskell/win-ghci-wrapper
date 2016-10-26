module Main where

import System.Process
import System.Environment
import System.IO
import System.Exit
import Control.Concurrent

proc' :: FilePath -> [String] -> CreateProcess
proc' cmd args = CreateProcess {  cmdspec = RawCommand cmd args,
                                  cwd = Nothing,
                                  env = Nothing,
                                  std_in = CreatePipe,
                                  std_out = Inherit,
                                  std_err = Inherit,
                                  close_fds = False,
                                  create_group = True,
                                  delegate_ctlc = True,
                                  detach_console = False,
                                  create_new_console = False,
                                  new_session = False,
                                  child_group = Nothing,
                                  child_user = Nothing }

main :: IO ()
main = do
  (cmd:args) <- getArgs
  (Just pin, _, _, pHandle) <- createProcess $ proc' cmd args
  hSetBuffering pin NoBuffering
  hSetBuffering stdin NoBuffering
  forkIO $ getContents >>= mapM_ (f pHandle pin)
  waitForProcess pHandle >>= exitWith
  where
    f h i '\x03' = interruptProcessGroupOf h
    f _ i c = hPutChar i c
