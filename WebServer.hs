{-# LANGUAGE OverloadedStrings #-}


module Thrift.WebServer where

import Data.Maybe
import Data.IORef
import qualified Data.ByteString as B
import Data.ByteString.Char8
import Data.ByteString.Lazy.Builder
import qualified Data.ByteString.Lazy as L

import Network.URI
import Network.HTTP hiding (port, host)
import Network.HTTP.Types

import qualified Network.Wai as W
import Network.Wai.Internal
import qualified Network.WebSockets as WC
import qualified Network.WebSockets.Connection as WC

import Thrift
import Thrift.Protocol.JSON
import Thrift.Transport
import Thrift.Transport.IOBuffer
import Thrift.Transport.Handle()

type DoResponse = (W.Response -> IO W.ResponseReceived)

data HttpTrans =
    HttpTrans {
         conn :: Maybe WC.Connection    
        ,reqBuffer :: ReadBuffer 
        ,resBuffer :: WriteBuffer 
        ,respond :: DoResponse 
    }

newHttpTrans :: Maybe WC.Connection -> W.Request -> DoResponse -> IO HttpTrans
newHttpTrans mc request doresp = do
    rbuf <- newReadBuffer
    rbody <- W.strictRequestBody request
    fillBuf rbuf rbody
    wbuf <- newWriteBuffer
    return $ HttpTrans mc rbuf wbuf doresp

instance Transport HttpTrans where
    tIsOpen t = case (conn t) of
                 Just c  -> readIORef $ WC.connectionSentClose c 
                 Nothing -> return True 
    tClose t = case (conn t) of
                 Just c  -> WC.sendClose c (pack "All done")
                 Nothing -> return ()
    tPeek  = peekBuf . reqBuffer
    tRead  = readBuf . reqBuffer
    tWrite = writeBuf . resBuffer
    tFlush t = do
        body <- flushBuf $ resBuffer t
        respond t $ W.responseLBS
            status200
            [("Content-Type","application/x-thrift"), 
             ("Content-Length", pack $ show $ L.length body) ]
            body
        return ()

-- | Run with Network.Wai.Handler.Warp -> run 8080 app
basicWebServerApp :: h 
    -> (h -> (JSONProtocol HttpTrans, JSONProtocol HttpTrans) -> IO Bool) 
    -> W.Application
basicWebServerApp handler processor = \req respond ->
    case W.requestMethod req of
        -- methodGet  -> undefined
        methodPost -> do 
            htrans <- newHttpTrans Nothing req respond
            let proto = JSONProtocol htrans
                inout = (proto,proto)
            proc_ inout
            return ResponseReceived
        methodOptions -> respond $ W.responseLBS status204 [("Content-Length", pack "0")] "No Content"
        _ -> respond $ W.responseLBS status403 [] "Not sure what's going on here"
    where 
        proc_ = processor handler

