{
module Main(main) where
import AlexScanner
import Evaluator
}

%name parse
%tokentype {Token}
%error {parseError}

%token
    NL      { NewLine }
    VAR     { Term $$ }
    '.'     { Dot }
    'λ'     { Lambda }
    '('     { OpenPar }
    ')'     { ClosedPar }

%left 'λ' '.' VAR

%%

start   : line          { [$1] }
        | start line    { $2 : $1 }

line    : NL            { Empty }
        | exp NL        { $1 }

exp     : VAR                       { Var $1 }
        | '(' exp ')'               { $2 }
        | 'λ' VAR '.' exp           { Abs $2 $4 }
        | exp exp                   { App $1 $2 }


{

parseError :: [Token] -> a
parseError e = error (show e ++ "Error while parsing")

main :: IO ()
main = do
    s <- readFile "../test.txt"
    let tokens = alexScanTokens s ++ [ NewLine ]
    let parsedTerms = filter (/= Empty) (reverse (parse tokens))
    let evaluatedTerms = map eval parsedTerms
    mapM_ (print) evaluatedTerms
}