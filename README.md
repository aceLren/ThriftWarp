# ThriftWarp

This is adds to the Haskell Thrift library - works with xhr posts, websockets and can also serve static files (I branched from 0.9.2).  Since creating this I decided to just fork the repo and put it all in the right place, so if you clone my fork and build it this should all work as well.  The fork is [here](https://github.com/aceLren/thrift).

# Use

Clone Thrift's repo, put WebServer.hs and WSServer.hs next to Server.hs, the new Transport files (HttpTrans and WSTrans) in the Transport folder, replace their Thrift.cabal with this one (or just add websockets, warp, and wai as dependencies and expose these files), and cabal install it and you're set.

Example warp server:

    import Thrift.WebServer
    import Thrift.WSServer
    import Network.Wai.Handler.Warp
    import Network.Wai.Middleware.Cors
    import Network.Wai.Middleware.Static

    import qualified Network.WebSockets as WS
    import qualified Network.WebSockets.Connection as WS
    import qualified Network.Wai.Handler.WebSockets as WS

    import YourService

    main = do
      let app = basicWebServerApp yourHandler YourService.process
          wsMiddle = WS.websocketsOr WS.defaultConnectionOptions (wsHandler yourHandler YourService.process)
          staticMiddle = staticPolicy $ addBase "your/web/dir"
      run 8080 $ (wsMiddle . staticMiddle . simpleCors) app

JS XHR client:

    var transport = new Thrift.Transport("http://localhost:8080/",{useCORS:true}),
        protocol = new Thrift.Protocol(transport);

    var client = new YourServiceClient(protocol);
    client.yourFunction();

JS WS client:

    var transport = new Thrift.TWebSocketTransport("ws://localhost:8080"),
        protocol = new Thrift.Protocol(transport);

    var client = new YourServiceClient(protocol);
    transport.open();
