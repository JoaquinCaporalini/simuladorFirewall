module Main (main) where

import System.IO ( stdin, hGetContents )
import System.Environment ( getArgs, getProgName )
import System.Exit ( exitFailure, exitSuccess )
import Control.Monad (when)

import LexSimFirewall
import ParSimFirewall
import SkelSimFirewall
import PrintSimFirewall
import AbsSimFirewall

import Lib

main :: IO ()
main = do {
   putStrLn "Hello, World!" ;
   return ()
   }
