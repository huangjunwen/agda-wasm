module Agda.VersionCommit where

import Development.GitRev

import Agda.Version

versionWithCommitInfo :: String
versionWithCommitInfo = version ++ maybe "" ("-" ++) commitInfo

-- | Information about current git commit, generated at compile time
commitInfo :: Maybe String
commitInfo
  | hash == "UNKNOWN" = Nothing
  | otherwise         = Just $ abbrev hash ++ dirty
  where

    -- (agda-wasm) WASM backend does not support TemplateHaskell yet 
    -- so harcode the git hash here
    -- https://www.reddit.com/r/haskell/comments/1355jm7/help_compiling_to_wasm/
    hash = "b499d12412bac32ab1af9f470463ed9dc54f8907"

    dirty = ""

    -- Abbreviate a commit hash while keeping it unambiguous
    abbrev = take 7
