{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}

module Server.Handler
  ( health
  , itemUrl
  , allItems
  , feedback
  , keywords
  , search
  , root
  , subscribe
  )
  where

import           Control.Monad.Error.Class        (MonadError, throwError)
import           Control.Monad.IO.Class           (MonadIO, liftIO)
import           Control.Monad.Reader             (asks)
import           Control.Monad.Reader.Class       (MonadReader)
import qualified Data.ByteString.Lazy             as BS
import           Data.Semigroup                   ((<>))
import qualified Data.Text                        as T
import qualified Data.Text.Encoding               as T
import           Data.UUID                        (UUID)
import           Network.Socket                   (SockAddr)

import           Servant.API.ContentTypesExtended (RawHtml (..))
import           Servant.Server                   (ServantErr, err301, err404,
                                                   errHeaders)


import qualified Database
import qualified Logger
import qualified Mailchimp
import           Server.API.Types
import qualified Server.Config

health :: Monad m => m T.Text
health = pure "OK!"

feedback
  :: ( MonadReader Server.Config.Handle m
     , MonadIO m
     )
  => PublicFeedback
  -> m T.Text
feedback fdbck@(PublicFeedback msg) = do
  loggerHandle   <- asks Server.Config.hLogger
  databaseHandle <- asks Server.Config.hDB

  liftIO
    $ Logger.info loggerHandle
    $ "Feedback Received:  " <> show msg

  -- Persisting to Database
  liftIO $ Database.runDatabase databaseHandle
         $ Database.feedback fdbck

  pure "OK"

itemUrl
  :: ( MonadReader Server.Config.Handle m
     , MonadError ServantErr m
     , MonadIO m
     )
  => SockAddr
  -> UUID
  -> m T.Text
itemUrl sockAddr uuid = do
  databaseHandle <- asks Server.Config.hDB
  loggerHandle   <- asks Server.Config.hLogger

  mIdAndUrl <- liftIO
    $ Database.runDatabase databaseHandle
    $ Database.itemUrlByUUID uuid

  liftIO
    $ Logger.info loggerHandle
    $ "url returned " <> show mIdAndUrl

  case mIdAndUrl of
    Nothing  ->
      throwError err404

    Just (itemId, url) -> do
      liftIO
        $ Logger.info loggerHandle
        $ "Tracking Click " <> show mIdAndUrl

      liftIO
        $ Database.runDatabase databaseHandle
        $ Database.itemClick sockAddr itemId

      throwError $ err301 {
        errHeaders = [("Location", T.encodeUtf8 url)] }

allItems
  :: ( MonadReader Server.Config.Handle m
     , MonadIO m
     )
  => m [PublicItem]
allItems = do
  loggerHandle   <- asks Server.Config.hLogger
  databaseHandle <- asks Server.Config.hDB

  liftIO $ Logger.info loggerHandle ("Getting all the items in the Database" :: T.Text)
  items <- liftIO $ Database.runDatabase databaseHandle Database.allItems
  pure items

search
  :: ( MonadReader Server.Config.Handle m
     , MonadIO m
     )
  => Maybe T.Text  -- ^ Optional Search query
  -> m [PublicItem]
search mQuery = do
  loggerHandle   <- asks Server.Config.hLogger
  databaseHandle <- asks Server.Config.hDB

  case mQuery of
    Nothing    -> do
      liftIO $ Logger.info loggerHandle ("No search query provided" :: T.Text)
      pure []

    Just query -> do
      liftIO $ Logger.info loggerHandle $ "Search query provided " <> query
      itemsByTags <- liftIO $ Database.runDatabase databaseHandle (Database.searchByTagName query)
      itemsByAuthors <- liftIO $ Database.runDatabase databaseHandle (Database.searchByAuthor query)
      pure $ itemsByTags <> itemsByAuthors

root :: MonadIO m => m RawHtml
root = do
  content <- liftIO $ BS.readFile "static/index.html"
  return $ RawHtml content

keywords
  :: ( MonadReader Server.Config.Handle m
     , MonadIO m
     )
  => m [PublicKeyword]
keywords = do
  databaseHandle <- asks Server.Config.hDB
  liftIO $ Database.runDatabase databaseHandle Database.keywords

subscribe
  :: ( MonadReader Server.Config.Handle m
     , MonadIO m
     )
  => EmailAddress
  -> m ()
subscribe (EmailAddress email) = do
  mailchimpHandle <- asks Server.Config.hMailchimp
  loggerHandle    <- asks Server.Config.hLogger

  r <- liftIO $ Mailchimp.subscribe mailchimpHandle email

  liftIO
    $ Logger.info loggerHandle
    $ "Mailchimp Subscribing Result " <> show r

  return ()
