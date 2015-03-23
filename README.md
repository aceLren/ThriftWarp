# ThriftWarp

This is adds to the Haskell Thrift library - works with xhr posts, I haven't finished websockets and some other stuff yet so it's still separate (I branched from 0.9.2).

# Use

Clone Thrift's repo, put WebServer.hs next to Server.hs, replace their Thrift.cabal with this one (or just add websockets, warp, and wai as dependencies and expose WebServer), and cabal install it and you're set.

Use warp's run like so:

    import Thrift.WebServer
    import Network.Wai.Handler.Warp
    import Network.Wai.Middleware.Cors
    import YourService
      
    main = do
      let app = basicWebServerApp YourHandler YourService.process
      run 9090 $ simpleCors app

And a JS client:

    var transport = new Thrift.Transport("http://localhost:9090/",{useCORS:true}),
        protocol = new Thrift.TJSONProtocol(transport);
    
    var client = new YourServiceClient(protocol);
    client.yourFunction();
