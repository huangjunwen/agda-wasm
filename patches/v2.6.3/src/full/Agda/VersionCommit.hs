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

    hash = "b499d12412bac32ab1af9f470463ed9dc54f8907"

    dirty = ""

    -- Abbreviate a commit hash while keeping it unambiguous
    abbrev = take 7
