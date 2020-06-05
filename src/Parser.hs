module Parser
        ( parseString
        , parseFile
        , parseExpression
        ) where

{-
It always makes me so happy,
when you find someone alive.
    - Alaska State Troopers S4 E16
-}

---- Format Import
import Data.Char
import Main.Utf8 (withUtf8)

---- Parsec Import
import Text.ParserCombinators.Parsec

---- Language Import
import Encoding
import Lexer
import AST

---- Statement Parser
whileParser :: Parser Sequence
whileParser = manyTill sequentStatement eof

sequentStatement :: Parser Stmt
sequentStatement = do
        whiteSpace
        s <- statement
        whiteSpace
        return s

statement :: Parser Stmt
statement = importStmt <|> expressStmt <|> assignStmt

expressStmt :: Parser Stmt
expressStmt = reservedOp "!!" *> (Express <$> expression)

assignStmt :: Parser Stmt
assignStmt = do
        var <- identifier
        reservedOp ":="
        expr <- expression
        spaces
        arity <- getArity expr <|> countArity expr
        return $ Assign var expr arity

countArity :: Bλ -> Parser Integer
countArity = return . countLambda

getArity :: Bλ -> Parser Integer
getArity expr = do
    fullArity <- countArity expr
    reservedOp "::"
    arity <- natural

    if arity > fullArity then
        error "Parse Error\narity cannot be higher than the number of binders"
    else
        return arity

importStmt :: Parser Stmt
importStmt = do
    string "#import"
    spaces
    file <- angles (many1 alphaNum)
    return $ Import file

---- Compiler Specific Expression Parser (CSEP)
forCompiler :: Parser Bλ
forCompiler =  funcExpression
           <|> skidExpression

funcExpression :: Parser Bλ
funcExpression = do
        name <- many1 alphaNum
        args <- braces (sepBy expression comma) <|> return []
        return $ Fun name args

skidExpression :: Parser Bλ
skidExpression = do
        reservedOp "%"
        index <- toInteg <$> many1 digit
        return $ Prc index


---- Expression Parser
expression :: Parser Bλ
expression =  idxExpression
          <|> absExpression
          <|> appExpression
          <|> synSugar
          <|> forCompiler

idxExpression :: Parser Bλ
idxExpression = Idx <$> natural

absExpression :: Parser Bλ
absExpression = reservedOp "λ" *> (Abs <$> expression)

appExpression :: Parser Bλ
appExpression = do
        l <- idxExpression <|> parens expression
        spaces
        r <- idxExpression <|> parens expression
        return $ App l r

synSugar :: Parser Bλ
synSugar =  unlP <|> prtP <|> intP <|> chrP

unlP, intP, chrP :: Parser Bλ
unlP = try $ string "UNL" *> (Unl <$> braces (many1 (noneOf "}")))
prtP = try $ string "PRT" *> (toPrint <$> braces (many1 (noneOf "}")))
intP = try $ string "INT" *> (encode EncZ toInt <$> braces (many1 digit))
chrP = try $ string "CHR" *> (encode EncX ord <$> braces anyChar)


---- User Input, Debug
parseString :: String -> Sequence
parseString str = case parse whileParser "String Parser" str of
                    Left  e -> error $ show e
                    Right r -> r

parseFile :: String -> IO Sequence
parseFile file = withUtf8 $ do
        program <- readFile file
        case parse whileParser file program of
          Left  e -> print e >> fail "Parse Error"
          Right r -> return r

-- This is really only for debugging and testing purposes
parseExpression :: String -> Bλ
parseExpression str = case parse expression "Expression Parser" str of
                    Left  e -> error $ show e
                    Right r -> r