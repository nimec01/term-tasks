module Main (main) where

import Test.QuickCheck
import DataType (Error(..),Type(..),Symbol(..),Signature(..),transTerm,toType)
import AllTerm (allTerms)
import InvalidTerm (differentTerms)
import System.IO
import Data.List (intercalate)

main ::IO ()
main = do
    hSetBuffering stdout NoBuffering
    putStrLn "Whenever you just press Enter, the default value will be taken"
    let ls_ex = ["a","b","c"]
    putStrLn ("Please input the symbols you want to use (default is " ++ show ls_ex ++ "):\nExample: if you want f(x,y), you need to input [\"f\",\"x\",\"y\"]")
    ls_inp <- getLine
    let ls = (if ls_inp == "" then ls_ex else read ls_inp :: [String])
        types_ex = ["A","B","C"]
    putStrLn ("Please input the type names of types you want to use (default is " ++ show types_ex ++ "):\nExample: the type name of Type \"A\" is \"A\"")
    types_inp <- getLine
    let types = (if types_inp == "" then types_ex else read types_inp :: [String])
        a_ex = 1
        b_ex = 10
    putStr "Please input the size range [a,b] of terms (default is [1,10] ):\na="
    a_inp <- getLine
    let a = (if a_inp == "" then a_ex else read a_inp :: Int)
    putStr "b="
    b_inp <- getLine
    let b = (if b_inp == "" then b_ex else read b_inp :: Int)
        l_ex = 5
    putStr "Please input the maximum number of parameters of a function symbol in this signature (default is 5):\nl="
    l_inp <- getLine
    let l = (if l_inp == "" then l_ex else read l_inp :: Int)
        e_ex = [(5,SWAP)]
    putStrLn ("Please input the error type and number of incorrect terms in this type (default is " ++ show e_ex ++"):\nError types are: " ++ intercalate ", " (map show [minBound .. maxBound :: Error]) ++ ".")
    e_inp <- getLine
    let e = (if e_inp == "" then e_ex else read e_inp :: [(Int,Error)])
        number_ex = 5
    putStr "Please input the number of correct terms you need (default is 5):\nnumber="
    number_inp <- getLine
    let number = (if number_inp == "" then number_ex else read number_inp :: Int)
    (sig,(correctTerms,incorrectTerms)) <- generate(allTerms ls (toType types) e l a b number)
    correctTerms' <- generate (differentTerms correctTerms number)
    let correctTerms'' = map transTerm correctTerms'
        incorrectTerms' = map (map transTerm) incorrectTerms
    putStrLn ("Here are function symbols and constants in this signature:\n" ++ show (transSignature sig))
    putStrLn ("Here are correct terms given to students:\n" ++ show correctTerms'')
    putStrLn ("Here are incorrect terms given to students:\n" ++ show incorrectTerms')

transSignature :: Signature -> [String]
transSignature (Signature fs) = map (\(Symbol s ts (Type t))-> s ++ ":" ++ toArguments ts ++ t) fs

toArguments :: [Type] -> String
toArguments ts = concatMap (\(Type s)->s ++ "->") ts
