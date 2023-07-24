#### Attemp to run agda.wasm

Add a fake project root to avoid 

> getDirectoryContents:openDirStream: permission denied\n(Operation not permitted)

```
$ touch /xyz.agda-lib
```

Example cmd:

```
wasmtime run --dir=/ --coredump-on-trap agda.core ./agda.wasm --  --interaction-json

IOTCM "/tmp/test.agda" NonInteractive Indirect (Cmd_load "/tmp/test.agda" [])
```


#### How to build static link native executable

By adding

> ld-options: -static in your executable section of the cabal file 

Use upx can reduce a lot of size

ref: 
- https://www.reddit.com/r/haskell/comments/6xuiy7/comment/dmjqode/
- https://www.reddit.com/r/haskell/comments/5lk33p/struggling_building_a_static_binary_for_aws/

1. add 'ld-options: -static' in cabal
2. cabal update && cabal install --enable-split-objs --ghc-options="-fPIC" -v3
