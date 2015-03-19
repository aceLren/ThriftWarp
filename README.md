# ThriftWarp

This is adds to the Haskell Thrift library - works with xhr posts, I haven't finished websockets and some other stuff yet so it's still separate.

# Use

Clone Thrift's repo, put WebServer.hs next to Server.hs, replace their Thrift.cabal with this one (or just add websockets, warp, and wai as dependencies and expose WebServer), and cabal install it and you're set.

Use warp's run like so:

    import Thrift.WebServer
    import Network.Wai.Handler.Warp
    import Network.Wai.Middleware.Cors
    import YourHandler
      
    main = do
      let app = basicWebServerApp YourHandler YourHandler.process
      run 9090 $ simpleCors app
