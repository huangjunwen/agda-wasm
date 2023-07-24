// (agda-wasm) tzset not found when linking with libHStime-1.12.2, maybe fixed in
// https://github.com/haskell/time/commit/2b3026fff50417bb57d909b2fa87d298c091cc1c
int tzset() { return 0; }
