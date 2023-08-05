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

import Common
import LoadFile
import Eval

import ErrM
import Data.Either (Either(Left, Right))

type ParseFun a = [Token] -> Err a

myLLexer = myLexer

type Verbosity = Int

putStrV :: Verbosity -> String -> IO ()
putStrV v s = when (v > 1) $ putStrLn s

runFile :: Verbosity -> ([Token] -> Err Program) -> FilePath -> IO ()
-- runFile :: (Print a, Show a) => Verbosity -> ParseFun a -> FilePath -> IO ()
runFile v p f = putStrLn f >> readFile f >>= run v p

run :: Verbosity -> ([Token] -> Err Program) -> String -> IO ()
-- run :: (Print a, Show a) => Verbosity -> ParseFun a -> String -> IO ()
run v p s = let ts = myLLexer s in case p ts of
           Bad s    -> do putStrLn "\nParse              Failed...\n"
                          putStrV v "Tokens:"
                          putStrV v $ show ts
                          putStrLn s
                          exitFailure
           Ok  tree -> do putStrLn "\nParse Successful!"
                          showTree v tree


                          exitSuccess

showTree' :: Either Common.State String -> String
showTree' (Left s) = show (eval s)
showTree' (Right e) = show e

showTree ::   Int -> Program -> IO ()
showTree v tree
 = do
      putStrV v $ "\n[Abstract Syntax]\n\n" ++ showTree' (loadFile tree)
      putStrV v $ "\n[Linearized tree]\n\n" ++ printTree tree

usage :: IO ()
usage = do
  putStrLn $ unlines
    [ "usage: Call with one of the following argument combinations:"
    , "  --help          Display this help message."
    , "  (no arguments)  Parse stdin verbosely."
    , "  (files)         Parse content of files verbosely."
    , "  -s (files)      Silent mode. Parse content of files silently."
    ]
  exitFailure

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["--help"] -> usage
    [] -> getContents >>= run 2 pProgram
    "-s":fs -> mapM_ (runFile 0 pProgram) fs
    fs -> mapM_ (runFile 2 pProgram) fs

-- main :: IO ()
-- main = do {
--    putStrLn "Hello, World!" ;
--    return ()
--    }
