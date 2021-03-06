{-# OPTIONS_GHC -fno-warn-unused-imports #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TemplateHaskell   #-}

-- |
-- Module:      SwiftNav.SBP.Settings
-- Copyright:   Copyright (C) 2015-2018 Swift Navigation, Inc.
-- License:     LGPL-3
-- Maintainer:  Swift Navigation <dev@swiftnav.com>
-- Stability:   experimental
-- Portability: portable
--
-- Messages for reading and writing the device's device settings.  Note that
-- some of these messages share the same message type ID for both the host
-- request and the device response. See the accompanying document for
-- descriptions of settings configurations and examples:  https://github.com
-- /swift-nav/piksi\_firmware/blob/master/docs/settings.pdf

module SwiftNav.SBP.Settings
  ( module SwiftNav.SBP.Settings
  ) where

import BasicPrelude
import Control.Lens
import Control.Monad.Loops
import Data.Binary
import Data.Binary.Get
import Data.Binary.IEEE754
import Data.Binary.Put
import Data.ByteString.Lazy hiding (ByteString)
import Data.Int
import Data.Word
import SwiftNav.SBP.TH
import SwiftNav.SBP.Types

{-# ANN module ("HLint: ignore Use camelCase"::String) #-}
{-# ANN module ("HLint: ignore Redundant do"::String) #-}
{-# ANN module ("HLint: ignore Use newtype instead of data"::String) #-}


msgSettingsSave :: Word16
msgSettingsSave = 0x00A1

-- | SBP class for message MSG_SETTINGS_SAVE (0x00A1).
--
-- The save settings message persists the device's current settings
-- configuration to its onboard flash memory file system.
data MsgSettingsSave = MsgSettingsSave
  deriving ( Show, Read, Eq )

instance Binary MsgSettingsSave where
  get =
    pure MsgSettingsSave

  put MsgSettingsSave =
    pure ()
$(makeSBP 'msgSettingsSave ''MsgSettingsSave)
$(makeJSON "_msgSettingsSave_" ''MsgSettingsSave)
$(makeLenses ''MsgSettingsSave)

msgSettingsWrite :: Word16
msgSettingsWrite = 0x00A0

-- | SBP class for message MSG_SETTINGS_WRITE (0x00A0).
--
-- The setting message writes the device configuration.
data MsgSettingsWrite = MsgSettingsWrite
  { _msgSettingsWrite_setting :: !Text
    -- ^ A NULL-terminated and delimited string with contents [SECTION_SETTING,
    -- SETTING, VALUE]. A device will only process to this message when it is
    -- received from sender ID 0x42.
  } deriving ( Show, Read, Eq )

instance Binary MsgSettingsWrite where
  get = do
    _msgSettingsWrite_setting <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    pure MsgSettingsWrite {..}

  put MsgSettingsWrite {..} = do
    putByteString $ encodeUtf8 _msgSettingsWrite_setting

$(makeSBP 'msgSettingsWrite ''MsgSettingsWrite)
$(makeJSON "_msgSettingsWrite_" ''MsgSettingsWrite)
$(makeLenses ''MsgSettingsWrite)

msgSettingsWriteResp :: Word16
msgSettingsWriteResp = 0x00AF

-- | SBP class for message MSG_SETTINGS_WRITE_RESP (0x00AF).
--
-- Return the status of a write request with the new value of the setting.  If
-- the requested value is rejected, the current value will be returned.
data MsgSettingsWriteResp = MsgSettingsWriteResp
  { _msgSettingsWriteResp_status :: !Word8
    -- ^ Write status
  , _msgSettingsWriteResp_setting :: !Text
    -- ^ A NULL-terminated and delimited string with contents [SECTION_SETTING,
    -- SETTING, VALUE].
  } deriving ( Show, Read, Eq )

instance Binary MsgSettingsWriteResp where
  get = do
    _msgSettingsWriteResp_status <- getWord8
    _msgSettingsWriteResp_setting <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    pure MsgSettingsWriteResp {..}

  put MsgSettingsWriteResp {..} = do
    putWord8 _msgSettingsWriteResp_status
    putByteString $ encodeUtf8 _msgSettingsWriteResp_setting

$(makeSBP 'msgSettingsWriteResp ''MsgSettingsWriteResp)
$(makeJSON "_msgSettingsWriteResp_" ''MsgSettingsWriteResp)
$(makeLenses ''MsgSettingsWriteResp)

msgSettingsReadReq :: Word16
msgSettingsReadReq = 0x00A4

-- | SBP class for message MSG_SETTINGS_READ_REQ (0x00A4).
--
-- The setting message reads the device configuration.
data MsgSettingsReadReq = MsgSettingsReadReq
  { _msgSettingsReadReq_setting :: !Text
    -- ^ A NULL-terminated and delimited string with contents [SECTION_SETTING,
    -- SETTING]. A device will only respond to this message when it is received
    -- from sender ID 0x42.
  } deriving ( Show, Read, Eq )

instance Binary MsgSettingsReadReq where
  get = do
    _msgSettingsReadReq_setting <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    pure MsgSettingsReadReq {..}

  put MsgSettingsReadReq {..} = do
    putByteString $ encodeUtf8 _msgSettingsReadReq_setting

$(makeSBP 'msgSettingsReadReq ''MsgSettingsReadReq)
$(makeJSON "_msgSettingsReadReq_" ''MsgSettingsReadReq)
$(makeLenses ''MsgSettingsReadReq)

msgSettingsReadResp :: Word16
msgSettingsReadResp = 0x00A5

-- | SBP class for message MSG_SETTINGS_READ_RESP (0x00A5).
--
-- The setting message reads the device configuration.
data MsgSettingsReadResp = MsgSettingsReadResp
  { _msgSettingsReadResp_setting :: !Text
    -- ^ A NULL-terminated and delimited string with contents [SECTION_SETTING,
    -- SETTING, VALUE].
  } deriving ( Show, Read, Eq )

instance Binary MsgSettingsReadResp where
  get = do
    _msgSettingsReadResp_setting <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    pure MsgSettingsReadResp {..}

  put MsgSettingsReadResp {..} = do
    putByteString $ encodeUtf8 _msgSettingsReadResp_setting

$(makeSBP 'msgSettingsReadResp ''MsgSettingsReadResp)
$(makeJSON "_msgSettingsReadResp_" ''MsgSettingsReadResp)
$(makeLenses ''MsgSettingsReadResp)

msgSettingsReadByIndexReq :: Word16
msgSettingsReadByIndexReq = 0x00A2

-- | SBP class for message MSG_SETTINGS_READ_BY_INDEX_REQ (0x00A2).
--
-- The settings message for iterating through the settings values. It will read
-- the setting at an index, returning a NULL-terminated and delimited string
-- with contents [SECTION_SETTING, SETTING, VALUE]. A device will only respond
-- to this message when it is received from sender ID 0x42.
data MsgSettingsReadByIndexReq = MsgSettingsReadByIndexReq
  { _msgSettingsReadByIndexReq_index :: !Word16
    -- ^ An index into the device settings, with values ranging from 0 to
    -- length(settings)
  } deriving ( Show, Read, Eq )

instance Binary MsgSettingsReadByIndexReq where
  get = do
    _msgSettingsReadByIndexReq_index <- getWord16le
    pure MsgSettingsReadByIndexReq {..}

  put MsgSettingsReadByIndexReq {..} = do
    putWord16le _msgSettingsReadByIndexReq_index

$(makeSBP 'msgSettingsReadByIndexReq ''MsgSettingsReadByIndexReq)
$(makeJSON "_msgSettingsReadByIndexReq_" ''MsgSettingsReadByIndexReq)
$(makeLenses ''MsgSettingsReadByIndexReq)

msgSettingsReadByIndexResp :: Word16
msgSettingsReadByIndexResp = 0x00A7

-- | SBP class for message MSG_SETTINGS_READ_BY_INDEX_RESP (0x00A7).
--
-- The settings message for iterating through the settings values. It will read
-- the setting at an index, returning a NULL-terminated and delimited string
-- with contents [SECTION_SETTING, SETTING, VALUE].
data MsgSettingsReadByIndexResp = MsgSettingsReadByIndexResp
  { _msgSettingsReadByIndexResp_index :: !Word16
    -- ^ An index into the device settings, with values ranging from 0 to
    -- length(settings)
  , _msgSettingsReadByIndexResp_setting :: !Text
    -- ^ A NULL-terminated and delimited string with contents [SECTION_SETTING,
    -- SETTING, VALUE].
  } deriving ( Show, Read, Eq )

instance Binary MsgSettingsReadByIndexResp where
  get = do
    _msgSettingsReadByIndexResp_index <- getWord16le
    _msgSettingsReadByIndexResp_setting <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    pure MsgSettingsReadByIndexResp {..}

  put MsgSettingsReadByIndexResp {..} = do
    putWord16le _msgSettingsReadByIndexResp_index
    putByteString $ encodeUtf8 _msgSettingsReadByIndexResp_setting

$(makeSBP 'msgSettingsReadByIndexResp ''MsgSettingsReadByIndexResp)
$(makeJSON "_msgSettingsReadByIndexResp_" ''MsgSettingsReadByIndexResp)
$(makeLenses ''MsgSettingsReadByIndexResp)

msgSettingsReadByIndexDone :: Word16
msgSettingsReadByIndexDone = 0x00A6

-- | SBP class for message MSG_SETTINGS_READ_BY_INDEX_DONE (0x00A6).
--
-- The settings message for indicating end of the settings values.
data MsgSettingsReadByIndexDone = MsgSettingsReadByIndexDone
  deriving ( Show, Read, Eq )

instance Binary MsgSettingsReadByIndexDone where
  get =
    pure MsgSettingsReadByIndexDone

  put MsgSettingsReadByIndexDone =
    pure ()
$(makeSBP 'msgSettingsReadByIndexDone ''MsgSettingsReadByIndexDone)
$(makeJSON "_msgSettingsReadByIndexDone_" ''MsgSettingsReadByIndexDone)
$(makeLenses ''MsgSettingsReadByIndexDone)

msgSettingsRegister :: Word16
msgSettingsRegister = 0x00AE

-- | SBP class for message MSG_SETTINGS_REGISTER (0x00AE).
--
-- This message registers the presence and default value of a setting with a
-- settings daemon.  The host should reply with MSG_SETTINGS_WRITE for this
-- setting to set the initial value.
data MsgSettingsRegister = MsgSettingsRegister
  { _msgSettingsRegister_setting :: !Text
    -- ^ A NULL-terminated and delimited string with contents [SECTION_SETTING,
    -- SETTING, VALUE].
  } deriving ( Show, Read, Eq )

instance Binary MsgSettingsRegister where
  get = do
    _msgSettingsRegister_setting <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    pure MsgSettingsRegister {..}

  put MsgSettingsRegister {..} = do
    putByteString $ encodeUtf8 _msgSettingsRegister_setting

$(makeSBP 'msgSettingsRegister ''MsgSettingsRegister)
$(makeJSON "_msgSettingsRegister_" ''MsgSettingsRegister)
$(makeLenses ''MsgSettingsRegister)
