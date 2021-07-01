module DealWithTerm (
   getTermSymbol,
   transTerm
   ) where

import DataType
import Data.List (intercalate)

getTermSymbol :: Term -> [String]
getTermSymbol (Term x xs) = x : getTermSymbol' xs

getTermSymbol' :: [Term] -> [String]
getTermSymbol' [] = []
getTermSymbol' (Term x xs:ys) = [x] ++ getTermSymbol' xs ++ getTermSymbol' ys

transTerm :: Term -> String
transTerm (Term x []) = x
transTerm (Term s xs) = s ++ "(" ++ intercalate "," (map transTerm xs) ++ ")"
