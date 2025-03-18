-- Copyright Till Straumann, 2023. Licensed under the EUPL-1.2 or later.
-- You may obtain a copy of the license at
--   https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
-- This notice must not be removed.

-- THIS FILE WAS AUTOMATICALLY GENERATED; DO NOT EDIT!

-- Generated from: 'tic_nic.yaml':
--
-- deviceDesc:
--   configurationDesc:
--     functionNCM:
--       enabled: true
--       iFunction: Tic-Nic PTP Ethernet Adapter
--       iMACAddress: 02deadbeef31
--       numMulticastFilters: 32800
--     functionUAC2Input:
--       enabled: true
--       iFunction: Mecatica Microphone Test
--       iInputTerminal:
--       - Sin-Test
--       - CIC-1stg
--       - CIC-2stg
--       - CIC-3stg
--       - CIC-4stg
--       iSelector: Mecatica Mic Capture
--       numBits: 16
--       numChannels: 1
--   iProduct: Till's Mecatica USB Example Device
--   idProduct: 34897
-- 

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

use     work.Usb2Pkg.all;

package body Usb2AppCfgPkg is
   function usb2AppGetDescriptors return Usb2ByteArray is
      constant c : Usb2ByteArray := (
      -- Usb2DeviceDesc
        0 => x"12",  -- bLength
        1 => x"01",  -- bDescriptorType
        2 => x"00",  -- bcdUSB
        3 => x"02",
        4 => x"ef",  -- bDeviceClass
        5 => x"02",  -- bDeviceSubClass
        6 => x"01",  -- bDeviceProtocol
        7 => x"40",  -- bMaxPacketSize0
        8 => x"09",  -- idVendor
        9 => x"12",
       10 => x"51",  -- idProduct
       11 => x"88",
       12 => x"00",  -- bcdDevice
       13 => x"01",
       14 => x"00",  -- iManufacturer
       15 => x"01",  -- iProduct
       16 => x"00",  -- iSerialNumber
       17 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
       18 => x"0a",  -- bLength
       19 => x"06",  -- bDescriptorType
       20 => x"00",  -- bcdUSB
       21 => x"02",
       22 => x"ef",  -- bDeviceClass
       23 => x"02",  -- bDeviceSubClass
       24 => x"01",  -- bDeviceProtocol
       25 => x"40",  -- bMaxPacketSize0
       26 => x"01",  -- bNumConfigurations
       27 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
       28 => x"09",  -- bLength
       29 => x"02",  -- bDescriptorType
       30 => x"70",  -- wTotalLength
       31 => x"01",
       32 => x"06",  -- bNumInterfaces
       33 => x"01",  -- bConfigurationValue
       34 => x"00",  -- iConfiguration
       35 => x"a0",  -- bmAttributes
       36 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
       37 => x"08",  -- bLength
       38 => x"0b",  -- bDescriptorType
       39 => x"00",  -- bFirstInterface
       40 => x"02",  -- bInterfaceCount
       41 => x"02",  -- bFunctionClass
       42 => x"02",  -- bFunctionSubClass
       43 => x"00",  -- bFunctionProtocol
       44 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
       45 => x"09",  -- bLength
       46 => x"04",  -- bDescriptorType
       47 => x"00",  -- bInterfaceNumber
       48 => x"00",  -- bAlternateSetting
       49 => x"01",  -- bNumEndpoints
       50 => x"02",  -- bInterfaceClass
       51 => x"02",  -- bInterfaceSubClass
       52 => x"00",  -- bInterfaceProtocol
       53 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
       54 => x"05",  -- bLength
       55 => x"24",  -- bDescriptorType
       56 => x"00",  -- bDescriptorSubtype
       57 => x"20",  -- bcdCDC
       58 => x"01",
      -- Usb2CDCFuncCallManagementDesc
       59 => x"05",  -- bLength
       60 => x"24",  -- bDescriptorType
       61 => x"01",  -- bDescriptorSubtype
       62 => x"00",  -- bmCapabilities
       63 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
       64 => x"04",  -- bLength
       65 => x"24",  -- bDescriptorType
       66 => x"02",  -- bDescriptorSubtype
       67 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
       68 => x"05",  -- bLength
       69 => x"24",  -- bDescriptorType
       70 => x"06",  -- bDescriptorSubtype
       71 => x"00",  -- bControlInterface
       72 => x"01",
      -- Usb2EndpointDesc
       73 => x"07",  -- bLength
       74 => x"05",  -- bDescriptorType
       75 => x"82",  -- bEndpointAddress
       76 => x"03",  -- bmAttributes
       77 => x"08",  -- wMaxPacketSize
       78 => x"00",
       79 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
       80 => x"09",  -- bLength
       81 => x"04",  -- bDescriptorType
       82 => x"01",  -- bInterfaceNumber
       83 => x"00",  -- bAlternateSetting
       84 => x"02",  -- bNumEndpoints
       85 => x"0a",  -- bInterfaceClass
       86 => x"00",  -- bInterfaceSubClass
       87 => x"00",  -- bInterfaceProtocol
       88 => x"00",  -- iInterface
      -- Usb2EndpointDesc
       89 => x"07",  -- bLength
       90 => x"05",  -- bDescriptorType
       91 => x"81",  -- bEndpointAddress
       92 => x"02",  -- bmAttributes
       93 => x"40",  -- wMaxPacketSize
       94 => x"00",
       95 => x"00",  -- bInterval
      -- Usb2EndpointDesc
       96 => x"07",  -- bLength
       97 => x"05",  -- bDescriptorType
       98 => x"01",  -- bEndpointAddress
       99 => x"02",  -- bmAttributes
      100 => x"40",  -- wMaxPacketSize
      101 => x"00",
      102 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      103 => x"08",  -- bLength
      104 => x"0b",  -- bDescriptorType
      105 => x"02",  -- bFirstInterface
      106 => x"02",  -- bInterfaceCount
      107 => x"01",  -- bFunctionClass
      108 => x"00",  -- bFunctionSubClass
      109 => x"20",  -- bFunctionProtocol
      110 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      111 => x"09",  -- bLength
      112 => x"04",  -- bDescriptorType
      113 => x"02",  -- bInterfaceNumber
      114 => x"00",  -- bAlternateSetting
      115 => x"00",  -- bNumEndpoints
      116 => x"01",  -- bInterfaceClass
      117 => x"01",  -- bInterfaceSubClass
      118 => x"20",  -- bInterfaceProtocol
      119 => x"00",  -- iInterface
      -- Usb2UAC2FuncHeaderDesc
      120 => x"09",  -- bLength
      121 => x"24",  -- bDescriptorType
      122 => x"01",  -- bDescriptorSubtype
      123 => x"00",  -- bcdADC
      124 => x"02",
      125 => x"03",  -- bCategory
      126 => x"88",  -- wTotalLength
      127 => x"00",
      128 => x"00",  -- bmControls
      -- Usb2UAC2ClockSourceDesc
      129 => x"08",  -- bLength
      130 => x"24",  -- bDescriptorType
      131 => x"0a",  -- bDescriptorSubtype
      132 => x"09",  -- bClockID
      133 => x"00",  -- bmAttributes
      134 => x"01",  -- bmControls
      135 => x"00",  -- bAssocTerminal
      136 => x"00",  -- iClockSource
      -- Usb2UAC2InputTerminalDesc
      137 => x"11",  -- bLength
      138 => x"24",  -- bDescriptorType
      139 => x"02",  -- bDescriptorSubtype
      140 => x"01",  -- bTerminalID
      141 => x"01",  -- wTerminalType
      142 => x"02",
      143 => x"00",  -- bAssocTerminal
      144 => x"09",  -- bCSourceID
      145 => x"01",  -- bNrChannels
      146 => x"04",  -- bmChannelConfig
      147 => x"00",
      148 => x"00",
      149 => x"00",
      150 => x"00",  -- iChannelNames
      151 => x"00",  -- bmControls
      152 => x"00",
      153 => x"04",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      154 => x"11",  -- bLength
      155 => x"24",  -- bDescriptorType
      156 => x"02",  -- bDescriptorSubtype
      157 => x"10",  -- bTerminalID
      158 => x"01",  -- wTerminalType
      159 => x"02",
      160 => x"00",  -- bAssocTerminal
      161 => x"09",  -- bCSourceID
      162 => x"01",  -- bNrChannels
      163 => x"04",  -- bmChannelConfig
      164 => x"00",
      165 => x"00",
      166 => x"00",
      167 => x"00",  -- iChannelNames
      168 => x"00",  -- bmControls
      169 => x"00",
      170 => x"05",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      171 => x"11",  -- bLength
      172 => x"24",  -- bDescriptorType
      173 => x"02",  -- bDescriptorSubtype
      174 => x"11",  -- bTerminalID
      175 => x"01",  -- wTerminalType
      176 => x"02",
      177 => x"00",  -- bAssocTerminal
      178 => x"09",  -- bCSourceID
      179 => x"01",  -- bNrChannels
      180 => x"04",  -- bmChannelConfig
      181 => x"00",
      182 => x"00",
      183 => x"00",
      184 => x"00",  -- iChannelNames
      185 => x"00",  -- bmControls
      186 => x"00",
      187 => x"06",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      188 => x"11",  -- bLength
      189 => x"24",  -- bDescriptorType
      190 => x"02",  -- bDescriptorSubtype
      191 => x"12",  -- bTerminalID
      192 => x"01",  -- wTerminalType
      193 => x"02",
      194 => x"00",  -- bAssocTerminal
      195 => x"09",  -- bCSourceID
      196 => x"01",  -- bNrChannels
      197 => x"04",  -- bmChannelConfig
      198 => x"00",
      199 => x"00",
      200 => x"00",
      201 => x"00",  -- iChannelNames
      202 => x"00",  -- bmControls
      203 => x"00",
      204 => x"07",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      205 => x"11",  -- bLength
      206 => x"24",  -- bDescriptorType
      207 => x"02",  -- bDescriptorSubtype
      208 => x"13",  -- bTerminalID
      209 => x"01",  -- wTerminalType
      210 => x"02",
      211 => x"00",  -- bAssocTerminal
      212 => x"09",  -- bCSourceID
      213 => x"01",  -- bNrChannels
      214 => x"04",  -- bmChannelConfig
      215 => x"00",
      216 => x"00",
      217 => x"00",
      218 => x"00",  -- iChannelNames
      219 => x"00",  -- bmControls
      220 => x"00",
      221 => x"08",  -- iTerminal
      -- Usb2UAC2SelectorUnitDesc
      222 => x"0c",  -- bLength
      223 => x"24",  -- bDescriptorType
      224 => x"05",  -- bDescriptorSubtype
      225 => x"0f",  -- bUnitID
      226 => x"05",  -- bNrInPins
      227 => x"01",  -- baSourceID
      228 => x"10",
      229 => x"11",
      230 => x"12",
      231 => x"13",
      232 => x"03",  -- bmControls
      233 => x"09",  -- iSelector
      -- Usb2UAC2MonoFeatureUnitDesc
      234 => x"0a",  -- bLength
      235 => x"24",  -- bDescriptorType
      236 => x"06",  -- bDescriptorSubtype
      237 => x"02",  -- bUnitID
      238 => x"0f",  -- bSourceID
      239 => x"0f",  -- bmaControls0
      240 => x"00",
      241 => x"00",
      242 => x"00",
      243 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      244 => x"0c",  -- bLength
      245 => x"24",  -- bDescriptorType
      246 => x"03",  -- bDescriptorSubtype
      247 => x"03",  -- bTerminalID
      248 => x"01",  -- wTerminalType
      249 => x"01",
      250 => x"00",  -- bAssocTerminal
      251 => x"02",  -- bSourceID
      252 => x"09",  -- bCSourceID
      253 => x"00",  -- bmControls
      254 => x"00",
      255 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      256 => x"09",  -- bLength
      257 => x"04",  -- bDescriptorType
      258 => x"03",  -- bInterfaceNumber
      259 => x"00",  -- bAlternateSetting
      260 => x"00",  -- bNumEndpoints
      261 => x"01",  -- bInterfaceClass
      262 => x"02",  -- bInterfaceSubClass
      263 => x"20",  -- bInterfaceProtocol
      264 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      265 => x"09",  -- bLength
      266 => x"04",  -- bDescriptorType
      267 => x"03",  -- bInterfaceNumber
      268 => x"01",  -- bAlternateSetting
      269 => x"01",  -- bNumEndpoints
      270 => x"01",  -- bInterfaceClass
      271 => x"02",  -- bInterfaceSubClass
      272 => x"20",  -- bInterfaceProtocol
      273 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      274 => x"10",  -- bLength
      275 => x"24",  -- bDescriptorType
      276 => x"01",  -- bDescriptorSubtype
      277 => x"03",  -- bTerminalLink
      278 => x"00",  -- bmControls
      279 => x"01",  -- bFormatType
      280 => x"01",  -- bmFormats
      281 => x"00",
      282 => x"00",
      283 => x"00",
      284 => x"01",  -- bNrChannels
      285 => x"04",  -- bmChannelConfig
      286 => x"00",
      287 => x"00",
      288 => x"00",
      289 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      290 => x"06",  -- bLength
      291 => x"24",  -- bDescriptorType
      292 => x"02",  -- bDescriptorSubtype
      293 => x"01",  -- bFormatType
      294 => x"02",  -- bSubslotSize
      295 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      296 => x"07",  -- bLength
      297 => x"05",  -- bDescriptorType
      298 => x"83",  -- bEndpointAddress
      299 => x"05",  -- bmAttributes
      300 => x"62",  -- wMaxPacketSize
      301 => x"00",
      302 => x"01",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      303 => x"08",  -- bLength
      304 => x"25",  -- bDescriptorType
      305 => x"01",  -- bDescriptorSubtype
      306 => x"00",  -- bmAttributes
      307 => x"00",  -- bmControls
      308 => x"00",  -- bLockDelayUnits
      309 => x"00",  -- wLockDelay
      310 => x"00",
      -- Usb2InterfaceAssociationDesc
      311 => x"08",  -- bLength
      312 => x"0b",  -- bDescriptorType
      313 => x"04",  -- bFirstInterface
      314 => x"02",  -- bInterfaceCount
      315 => x"02",  -- bFunctionClass
      316 => x"0d",  -- bFunctionSubClass
      317 => x"00",  -- bFunctionProtocol
      318 => x"0a",  -- iFunction
      -- Usb2InterfaceDesc
      319 => x"09",  -- bLength
      320 => x"04",  -- bDescriptorType
      321 => x"04",  -- bInterfaceNumber
      322 => x"00",  -- bAlternateSetting
      323 => x"01",  -- bNumEndpoints
      324 => x"02",  -- bInterfaceClass
      325 => x"0d",  -- bInterfaceSubClass
      326 => x"00",  -- bInterfaceProtocol
      327 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      328 => x"05",  -- bLength
      329 => x"24",  -- bDescriptorType
      330 => x"00",  -- bDescriptorSubtype
      331 => x"20",  -- bcdCDC
      332 => x"01",
      -- Usb2CDCFuncUnionDesc
      333 => x"05",  -- bLength
      334 => x"24",  -- bDescriptorType
      335 => x"06",  -- bDescriptorSubtype
      336 => x"04",  -- bControlInterface
      337 => x"05",
      -- Usb2CDCFuncEthernetDesc
      338 => x"0d",  -- bLength
      339 => x"24",  -- bDescriptorType
      340 => x"0f",  -- bDescriptorSubtype
      341 => x"0b",  -- iMACAddress
      342 => x"00",  -- bmEthernetStatistics
      343 => x"00",
      344 => x"00",
      345 => x"00",
      346 => x"ea",  -- wMaxSegmentSize
      347 => x"05",
      348 => x"20",  -- wNumberMCFilters
      349 => x"80",
      350 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      351 => x"06",  -- bLength
      352 => x"24",  -- bDescriptorType
      353 => x"1a",  -- bDescriptorSubtype
      354 => x"00",  -- bcdNcmVersion
      355 => x"01",
      356 => x"01",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      357 => x"07",  -- bLength
      358 => x"05",  -- bDescriptorType
      359 => x"85",  -- bEndpointAddress
      360 => x"03",  -- bmAttributes
      361 => x"10",  -- wMaxPacketSize
      362 => x"00",
      363 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
      364 => x"09",  -- bLength
      365 => x"04",  -- bDescriptorType
      366 => x"05",  -- bInterfaceNumber
      367 => x"00",  -- bAlternateSetting
      368 => x"00",  -- bNumEndpoints
      369 => x"0a",  -- bInterfaceClass
      370 => x"00",  -- bInterfaceSubClass
      371 => x"01",  -- bInterfaceProtocol
      372 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      373 => x"09",  -- bLength
      374 => x"04",  -- bDescriptorType
      375 => x"05",  -- bInterfaceNumber
      376 => x"01",  -- bAlternateSetting
      377 => x"02",  -- bNumEndpoints
      378 => x"0a",  -- bInterfaceClass
      379 => x"00",  -- bInterfaceSubClass
      380 => x"01",  -- bInterfaceProtocol
      381 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      382 => x"07",  -- bLength
      383 => x"05",  -- bDescriptorType
      384 => x"84",  -- bEndpointAddress
      385 => x"02",  -- bmAttributes
      386 => x"40",  -- wMaxPacketSize
      387 => x"00",
      388 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      389 => x"07",  -- bLength
      390 => x"05",  -- bDescriptorType
      391 => x"04",  -- bEndpointAddress
      392 => x"02",  -- bmAttributes
      393 => x"40",  -- wMaxPacketSize
      394 => x"00",
      395 => x"00",  -- bInterval
      -- Usb2SentinelDesc
      396 => x"02",  -- bLength
      397 => x"ff",  -- bDescriptorType
      -- Usb2DeviceDesc
      398 => x"12",  -- bLength
      399 => x"01",  -- bDescriptorType
      400 => x"00",  -- bcdUSB
      401 => x"02",
      402 => x"ef",  -- bDeviceClass
      403 => x"02",  -- bDeviceSubClass
      404 => x"01",  -- bDeviceProtocol
      405 => x"40",  -- bMaxPacketSize0
      406 => x"09",  -- idVendor
      407 => x"12",
      408 => x"51",  -- idProduct
      409 => x"88",
      410 => x"00",  -- bcdDevice
      411 => x"01",
      412 => x"00",  -- iManufacturer
      413 => x"01",  -- iProduct
      414 => x"00",  -- iSerialNumber
      415 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
      416 => x"0a",  -- bLength
      417 => x"06",  -- bDescriptorType
      418 => x"00",  -- bcdUSB
      419 => x"02",
      420 => x"ef",  -- bDeviceClass
      421 => x"02",  -- bDeviceSubClass
      422 => x"01",  -- bDeviceProtocol
      423 => x"40",  -- bMaxPacketSize0
      424 => x"01",  -- bNumConfigurations
      425 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
      426 => x"09",  -- bLength
      427 => x"02",  -- bDescriptorType
      428 => x"70",  -- wTotalLength
      429 => x"01",
      430 => x"06",  -- bNumInterfaces
      431 => x"01",  -- bConfigurationValue
      432 => x"00",  -- iConfiguration
      433 => x"a0",  -- bmAttributes
      434 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
      435 => x"08",  -- bLength
      436 => x"0b",  -- bDescriptorType
      437 => x"00",  -- bFirstInterface
      438 => x"02",  -- bInterfaceCount
      439 => x"02",  -- bFunctionClass
      440 => x"02",  -- bFunctionSubClass
      441 => x"00",  -- bFunctionProtocol
      442 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
      443 => x"09",  -- bLength
      444 => x"04",  -- bDescriptorType
      445 => x"00",  -- bInterfaceNumber
      446 => x"00",  -- bAlternateSetting
      447 => x"01",  -- bNumEndpoints
      448 => x"02",  -- bInterfaceClass
      449 => x"02",  -- bInterfaceSubClass
      450 => x"00",  -- bInterfaceProtocol
      451 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      452 => x"05",  -- bLength
      453 => x"24",  -- bDescriptorType
      454 => x"00",  -- bDescriptorSubtype
      455 => x"20",  -- bcdCDC
      456 => x"01",
      -- Usb2CDCFuncCallManagementDesc
      457 => x"05",  -- bLength
      458 => x"24",  -- bDescriptorType
      459 => x"01",  -- bDescriptorSubtype
      460 => x"00",  -- bmCapabilities
      461 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
      462 => x"04",  -- bLength
      463 => x"24",  -- bDescriptorType
      464 => x"02",  -- bDescriptorSubtype
      465 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
      466 => x"05",  -- bLength
      467 => x"24",  -- bDescriptorType
      468 => x"06",  -- bDescriptorSubtype
      469 => x"00",  -- bControlInterface
      470 => x"01",
      -- Usb2EndpointDesc
      471 => x"07",  -- bLength
      472 => x"05",  -- bDescriptorType
      473 => x"82",  -- bEndpointAddress
      474 => x"03",  -- bmAttributes
      475 => x"08",  -- wMaxPacketSize
      476 => x"00",
      477 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      478 => x"09",  -- bLength
      479 => x"04",  -- bDescriptorType
      480 => x"01",  -- bInterfaceNumber
      481 => x"00",  -- bAlternateSetting
      482 => x"02",  -- bNumEndpoints
      483 => x"0a",  -- bInterfaceClass
      484 => x"00",  -- bInterfaceSubClass
      485 => x"00",  -- bInterfaceProtocol
      486 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      487 => x"07",  -- bLength
      488 => x"05",  -- bDescriptorType
      489 => x"81",  -- bEndpointAddress
      490 => x"02",  -- bmAttributes
      491 => x"00",  -- wMaxPacketSize
      492 => x"02",
      493 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      494 => x"07",  -- bLength
      495 => x"05",  -- bDescriptorType
      496 => x"01",  -- bEndpointAddress
      497 => x"02",  -- bmAttributes
      498 => x"00",  -- wMaxPacketSize
      499 => x"02",
      500 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      501 => x"08",  -- bLength
      502 => x"0b",  -- bDescriptorType
      503 => x"02",  -- bFirstInterface
      504 => x"02",  -- bInterfaceCount
      505 => x"01",  -- bFunctionClass
      506 => x"00",  -- bFunctionSubClass
      507 => x"20",  -- bFunctionProtocol
      508 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      509 => x"09",  -- bLength
      510 => x"04",  -- bDescriptorType
      511 => x"02",  -- bInterfaceNumber
      512 => x"00",  -- bAlternateSetting
      513 => x"00",  -- bNumEndpoints
      514 => x"01",  -- bInterfaceClass
      515 => x"01",  -- bInterfaceSubClass
      516 => x"20",  -- bInterfaceProtocol
      517 => x"00",  -- iInterface
      -- Usb2UAC2FuncHeaderDesc
      518 => x"09",  -- bLength
      519 => x"24",  -- bDescriptorType
      520 => x"01",  -- bDescriptorSubtype
      521 => x"00",  -- bcdADC
      522 => x"02",
      523 => x"03",  -- bCategory
      524 => x"88",  -- wTotalLength
      525 => x"00",
      526 => x"00",  -- bmControls
      -- Usb2UAC2ClockSourceDesc
      527 => x"08",  -- bLength
      528 => x"24",  -- bDescriptorType
      529 => x"0a",  -- bDescriptorSubtype
      530 => x"09",  -- bClockID
      531 => x"00",  -- bmAttributes
      532 => x"01",  -- bmControls
      533 => x"00",  -- bAssocTerminal
      534 => x"00",  -- iClockSource
      -- Usb2UAC2InputTerminalDesc
      535 => x"11",  -- bLength
      536 => x"24",  -- bDescriptorType
      537 => x"02",  -- bDescriptorSubtype
      538 => x"01",  -- bTerminalID
      539 => x"01",  -- wTerminalType
      540 => x"02",
      541 => x"00",  -- bAssocTerminal
      542 => x"09",  -- bCSourceID
      543 => x"01",  -- bNrChannels
      544 => x"04",  -- bmChannelConfig
      545 => x"00",
      546 => x"00",
      547 => x"00",
      548 => x"00",  -- iChannelNames
      549 => x"00",  -- bmControls
      550 => x"00",
      551 => x"04",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      552 => x"11",  -- bLength
      553 => x"24",  -- bDescriptorType
      554 => x"02",  -- bDescriptorSubtype
      555 => x"10",  -- bTerminalID
      556 => x"01",  -- wTerminalType
      557 => x"02",
      558 => x"00",  -- bAssocTerminal
      559 => x"09",  -- bCSourceID
      560 => x"01",  -- bNrChannels
      561 => x"04",  -- bmChannelConfig
      562 => x"00",
      563 => x"00",
      564 => x"00",
      565 => x"00",  -- iChannelNames
      566 => x"00",  -- bmControls
      567 => x"00",
      568 => x"05",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      569 => x"11",  -- bLength
      570 => x"24",  -- bDescriptorType
      571 => x"02",  -- bDescriptorSubtype
      572 => x"11",  -- bTerminalID
      573 => x"01",  -- wTerminalType
      574 => x"02",
      575 => x"00",  -- bAssocTerminal
      576 => x"09",  -- bCSourceID
      577 => x"01",  -- bNrChannels
      578 => x"04",  -- bmChannelConfig
      579 => x"00",
      580 => x"00",
      581 => x"00",
      582 => x"00",  -- iChannelNames
      583 => x"00",  -- bmControls
      584 => x"00",
      585 => x"06",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      586 => x"11",  -- bLength
      587 => x"24",  -- bDescriptorType
      588 => x"02",  -- bDescriptorSubtype
      589 => x"12",  -- bTerminalID
      590 => x"01",  -- wTerminalType
      591 => x"02",
      592 => x"00",  -- bAssocTerminal
      593 => x"09",  -- bCSourceID
      594 => x"01",  -- bNrChannels
      595 => x"04",  -- bmChannelConfig
      596 => x"00",
      597 => x"00",
      598 => x"00",
      599 => x"00",  -- iChannelNames
      600 => x"00",  -- bmControls
      601 => x"00",
      602 => x"07",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      603 => x"11",  -- bLength
      604 => x"24",  -- bDescriptorType
      605 => x"02",  -- bDescriptorSubtype
      606 => x"13",  -- bTerminalID
      607 => x"01",  -- wTerminalType
      608 => x"02",
      609 => x"00",  -- bAssocTerminal
      610 => x"09",  -- bCSourceID
      611 => x"01",  -- bNrChannels
      612 => x"04",  -- bmChannelConfig
      613 => x"00",
      614 => x"00",
      615 => x"00",
      616 => x"00",  -- iChannelNames
      617 => x"00",  -- bmControls
      618 => x"00",
      619 => x"08",  -- iTerminal
      -- Usb2UAC2SelectorUnitDesc
      620 => x"0c",  -- bLength
      621 => x"24",  -- bDescriptorType
      622 => x"05",  -- bDescriptorSubtype
      623 => x"0f",  -- bUnitID
      624 => x"05",  -- bNrInPins
      625 => x"01",  -- baSourceID
      626 => x"10",
      627 => x"11",
      628 => x"12",
      629 => x"13",
      630 => x"03",  -- bmControls
      631 => x"09",  -- iSelector
      -- Usb2UAC2MonoFeatureUnitDesc
      632 => x"0a",  -- bLength
      633 => x"24",  -- bDescriptorType
      634 => x"06",  -- bDescriptorSubtype
      635 => x"02",  -- bUnitID
      636 => x"0f",  -- bSourceID
      637 => x"0f",  -- bmaControls0
      638 => x"00",
      639 => x"00",
      640 => x"00",
      641 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      642 => x"0c",  -- bLength
      643 => x"24",  -- bDescriptorType
      644 => x"03",  -- bDescriptorSubtype
      645 => x"03",  -- bTerminalID
      646 => x"01",  -- wTerminalType
      647 => x"01",
      648 => x"00",  -- bAssocTerminal
      649 => x"02",  -- bSourceID
      650 => x"09",  -- bCSourceID
      651 => x"00",  -- bmControls
      652 => x"00",
      653 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      654 => x"09",  -- bLength
      655 => x"04",  -- bDescriptorType
      656 => x"03",  -- bInterfaceNumber
      657 => x"00",  -- bAlternateSetting
      658 => x"00",  -- bNumEndpoints
      659 => x"01",  -- bInterfaceClass
      660 => x"02",  -- bInterfaceSubClass
      661 => x"20",  -- bInterfaceProtocol
      662 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      663 => x"09",  -- bLength
      664 => x"04",  -- bDescriptorType
      665 => x"03",  -- bInterfaceNumber
      666 => x"01",  -- bAlternateSetting
      667 => x"01",  -- bNumEndpoints
      668 => x"01",  -- bInterfaceClass
      669 => x"02",  -- bInterfaceSubClass
      670 => x"20",  -- bInterfaceProtocol
      671 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      672 => x"10",  -- bLength
      673 => x"24",  -- bDescriptorType
      674 => x"01",  -- bDescriptorSubtype
      675 => x"03",  -- bTerminalLink
      676 => x"00",  -- bmControls
      677 => x"01",  -- bFormatType
      678 => x"01",  -- bmFormats
      679 => x"00",
      680 => x"00",
      681 => x"00",
      682 => x"01",  -- bNrChannels
      683 => x"04",  -- bmChannelConfig
      684 => x"00",
      685 => x"00",
      686 => x"00",
      687 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      688 => x"06",  -- bLength
      689 => x"24",  -- bDescriptorType
      690 => x"02",  -- bDescriptorSubtype
      691 => x"01",  -- bFormatType
      692 => x"02",  -- bSubslotSize
      693 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      694 => x"07",  -- bLength
      695 => x"05",  -- bDescriptorType
      696 => x"83",  -- bEndpointAddress
      697 => x"05",  -- bmAttributes
      698 => x"62",  -- wMaxPacketSize
      699 => x"00",
      700 => x"04",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      701 => x"08",  -- bLength
      702 => x"25",  -- bDescriptorType
      703 => x"01",  -- bDescriptorSubtype
      704 => x"00",  -- bmAttributes
      705 => x"00",  -- bmControls
      706 => x"00",  -- bLockDelayUnits
      707 => x"00",  -- wLockDelay
      708 => x"00",
      -- Usb2InterfaceAssociationDesc
      709 => x"08",  -- bLength
      710 => x"0b",  -- bDescriptorType
      711 => x"04",  -- bFirstInterface
      712 => x"02",  -- bInterfaceCount
      713 => x"02",  -- bFunctionClass
      714 => x"0d",  -- bFunctionSubClass
      715 => x"00",  -- bFunctionProtocol
      716 => x"0a",  -- iFunction
      -- Usb2InterfaceDesc
      717 => x"09",  -- bLength
      718 => x"04",  -- bDescriptorType
      719 => x"04",  -- bInterfaceNumber
      720 => x"00",  -- bAlternateSetting
      721 => x"01",  -- bNumEndpoints
      722 => x"02",  -- bInterfaceClass
      723 => x"0d",  -- bInterfaceSubClass
      724 => x"00",  -- bInterfaceProtocol
      725 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      726 => x"05",  -- bLength
      727 => x"24",  -- bDescriptorType
      728 => x"00",  -- bDescriptorSubtype
      729 => x"20",  -- bcdCDC
      730 => x"01",
      -- Usb2CDCFuncUnionDesc
      731 => x"05",  -- bLength
      732 => x"24",  -- bDescriptorType
      733 => x"06",  -- bDescriptorSubtype
      734 => x"04",  -- bControlInterface
      735 => x"05",
      -- Usb2CDCFuncEthernetDesc
      736 => x"0d",  -- bLength
      737 => x"24",  -- bDescriptorType
      738 => x"0f",  -- bDescriptorSubtype
      739 => x"0b",  -- iMACAddress
      740 => x"00",  -- bmEthernetStatistics
      741 => x"00",
      742 => x"00",
      743 => x"00",
      744 => x"ea",  -- wMaxSegmentSize
      745 => x"05",
      746 => x"20",  -- wNumberMCFilters
      747 => x"80",
      748 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      749 => x"06",  -- bLength
      750 => x"24",  -- bDescriptorType
      751 => x"1a",  -- bDescriptorSubtype
      752 => x"00",  -- bcdNcmVersion
      753 => x"01",
      754 => x"01",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      755 => x"07",  -- bLength
      756 => x"05",  -- bDescriptorType
      757 => x"85",  -- bEndpointAddress
      758 => x"03",  -- bmAttributes
      759 => x"10",  -- wMaxPacketSize
      760 => x"00",
      761 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      762 => x"09",  -- bLength
      763 => x"04",  -- bDescriptorType
      764 => x"05",  -- bInterfaceNumber
      765 => x"00",  -- bAlternateSetting
      766 => x"00",  -- bNumEndpoints
      767 => x"0a",  -- bInterfaceClass
      768 => x"00",  -- bInterfaceSubClass
      769 => x"01",  -- bInterfaceProtocol
      770 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      771 => x"09",  -- bLength
      772 => x"04",  -- bDescriptorType
      773 => x"05",  -- bInterfaceNumber
      774 => x"01",  -- bAlternateSetting
      775 => x"02",  -- bNumEndpoints
      776 => x"0a",  -- bInterfaceClass
      777 => x"00",  -- bInterfaceSubClass
      778 => x"01",  -- bInterfaceProtocol
      779 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      780 => x"07",  -- bLength
      781 => x"05",  -- bDescriptorType
      782 => x"84",  -- bEndpointAddress
      783 => x"02",  -- bmAttributes
      784 => x"00",  -- wMaxPacketSize
      785 => x"02",
      786 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      787 => x"07",  -- bLength
      788 => x"05",  -- bDescriptorType
      789 => x"04",  -- bEndpointAddress
      790 => x"02",  -- bmAttributes
      791 => x"00",  -- wMaxPacketSize
      792 => x"02",
      793 => x"00",  -- bInterval
      -- Usb2StringDesc
      794 => x"04",  -- bLength
      795 => x"03",  -- bDescriptorType
      796 => x"09",  -- langID 0x0409
      797 => x"04",
      -- Usb2StringDesc
      798 => x"46",  -- bLength
      799 => x"03",  -- bDescriptorType
      800 => x"54",  -- T
      801 => x"00",
      802 => x"69",  -- i
      803 => x"00",
      804 => x"6c",  -- l
      805 => x"00",
      806 => x"6c",  -- l
      807 => x"00",
      808 => x"27",  -- '
      809 => x"00",
      810 => x"73",  -- s
      811 => x"00",
      812 => x"20",  --  
      813 => x"00",
      814 => x"4d",  -- M
      815 => x"00",
      816 => x"65",  -- e
      817 => x"00",
      818 => x"63",  -- c
      819 => x"00",
      820 => x"61",  -- a
      821 => x"00",
      822 => x"74",  -- t
      823 => x"00",
      824 => x"69",  -- i
      825 => x"00",
      826 => x"63",  -- c
      827 => x"00",
      828 => x"61",  -- a
      829 => x"00",
      830 => x"20",  --  
      831 => x"00",
      832 => x"55",  -- U
      833 => x"00",
      834 => x"53",  -- S
      835 => x"00",
      836 => x"42",  -- B
      837 => x"00",
      838 => x"20",  --  
      839 => x"00",
      840 => x"45",  -- E
      841 => x"00",
      842 => x"78",  -- x
      843 => x"00",
      844 => x"61",  -- a
      845 => x"00",
      846 => x"6d",  -- m
      847 => x"00",
      848 => x"70",  -- p
      849 => x"00",
      850 => x"6c",  -- l
      851 => x"00",
      852 => x"65",  -- e
      853 => x"00",
      854 => x"20",  --  
      855 => x"00",
      856 => x"44",  -- D
      857 => x"00",
      858 => x"65",  -- e
      859 => x"00",
      860 => x"76",  -- v
      861 => x"00",
      862 => x"69",  -- i
      863 => x"00",
      864 => x"63",  -- c
      865 => x"00",
      866 => x"65",  -- e
      867 => x"00",
      -- Usb2StringDesc
      868 => x"1a",  -- bLength
      869 => x"03",  -- bDescriptorType
      870 => x"4d",  -- M
      871 => x"00",
      872 => x"65",  -- e
      873 => x"00",
      874 => x"63",  -- c
      875 => x"00",
      876 => x"61",  -- a
      877 => x"00",
      878 => x"74",  -- t
      879 => x"00",
      880 => x"69",  -- i
      881 => x"00",
      882 => x"63",  -- c
      883 => x"00",
      884 => x"61",  -- a
      885 => x"00",
      886 => x"20",  --  
      887 => x"00",
      888 => x"41",  -- A
      889 => x"00",
      890 => x"43",  -- C
      891 => x"00",
      892 => x"4d",  -- M
      893 => x"00",
      -- Usb2StringDesc
      894 => x"32",  -- bLength
      895 => x"03",  -- bDescriptorType
      896 => x"4d",  -- M
      897 => x"00",
      898 => x"65",  -- e
      899 => x"00",
      900 => x"63",  -- c
      901 => x"00",
      902 => x"61",  -- a
      903 => x"00",
      904 => x"74",  -- t
      905 => x"00",
      906 => x"69",  -- i
      907 => x"00",
      908 => x"63",  -- c
      909 => x"00",
      910 => x"61",  -- a
      911 => x"00",
      912 => x"20",  --  
      913 => x"00",
      914 => x"4d",  -- M
      915 => x"00",
      916 => x"69",  -- i
      917 => x"00",
      918 => x"63",  -- c
      919 => x"00",
      920 => x"72",  -- r
      921 => x"00",
      922 => x"6f",  -- o
      923 => x"00",
      924 => x"70",  -- p
      925 => x"00",
      926 => x"68",  -- h
      927 => x"00",
      928 => x"6f",  -- o
      929 => x"00",
      930 => x"6e",  -- n
      931 => x"00",
      932 => x"65",  -- e
      933 => x"00",
      934 => x"20",  --  
      935 => x"00",
      936 => x"54",  -- T
      937 => x"00",
      938 => x"65",  -- e
      939 => x"00",
      940 => x"73",  -- s
      941 => x"00",
      942 => x"74",  -- t
      943 => x"00",
      -- Usb2StringDesc
      944 => x"12",  -- bLength
      945 => x"03",  -- bDescriptorType
      946 => x"53",  -- S
      947 => x"00",
      948 => x"69",  -- i
      949 => x"00",
      950 => x"6e",  -- n
      951 => x"00",
      952 => x"2d",  -- -
      953 => x"00",
      954 => x"54",  -- T
      955 => x"00",
      956 => x"65",  -- e
      957 => x"00",
      958 => x"73",  -- s
      959 => x"00",
      960 => x"74",  -- t
      961 => x"00",
      -- Usb2StringDesc
      962 => x"12",  -- bLength
      963 => x"03",  -- bDescriptorType
      964 => x"43",  -- C
      965 => x"00",
      966 => x"49",  -- I
      967 => x"00",
      968 => x"43",  -- C
      969 => x"00",
      970 => x"2d",  -- -
      971 => x"00",
      972 => x"31",  -- 1
      973 => x"00",
      974 => x"73",  -- s
      975 => x"00",
      976 => x"74",  -- t
      977 => x"00",
      978 => x"67",  -- g
      979 => x"00",
      -- Usb2StringDesc
      980 => x"12",  -- bLength
      981 => x"03",  -- bDescriptorType
      982 => x"43",  -- C
      983 => x"00",
      984 => x"49",  -- I
      985 => x"00",
      986 => x"43",  -- C
      987 => x"00",
      988 => x"2d",  -- -
      989 => x"00",
      990 => x"32",  -- 2
      991 => x"00",
      992 => x"73",  -- s
      993 => x"00",
      994 => x"74",  -- t
      995 => x"00",
      996 => x"67",  -- g
      997 => x"00",
      -- Usb2StringDesc
      998 => x"12",  -- bLength
      999 => x"03",  -- bDescriptorType
      1000 => x"43",  -- C
      1001 => x"00",
      1002 => x"49",  -- I
      1003 => x"00",
      1004 => x"43",  -- C
      1005 => x"00",
      1006 => x"2d",  -- -
      1007 => x"00",
      1008 => x"33",  -- 3
      1009 => x"00",
      1010 => x"73",  -- s
      1011 => x"00",
      1012 => x"74",  -- t
      1013 => x"00",
      1014 => x"67",  -- g
      1015 => x"00",
      -- Usb2StringDesc
      1016 => x"12",  -- bLength
      1017 => x"03",  -- bDescriptorType
      1018 => x"43",  -- C
      1019 => x"00",
      1020 => x"49",  -- I
      1021 => x"00",
      1022 => x"43",  -- C
      1023 => x"00",
      1024 => x"2d",  -- -
      1025 => x"00",
      1026 => x"34",  -- 4
      1027 => x"00",
      1028 => x"73",  -- s
      1029 => x"00",
      1030 => x"74",  -- t
      1031 => x"00",
      1032 => x"67",  -- g
      1033 => x"00",
      -- Usb2StringDesc
      1034 => x"2a",  -- bLength
      1035 => x"03",  -- bDescriptorType
      1036 => x"4d",  -- M
      1037 => x"00",
      1038 => x"65",  -- e
      1039 => x"00",
      1040 => x"63",  -- c
      1041 => x"00",
      1042 => x"61",  -- a
      1043 => x"00",
      1044 => x"74",  -- t
      1045 => x"00",
      1046 => x"69",  -- i
      1047 => x"00",
      1048 => x"63",  -- c
      1049 => x"00",
      1050 => x"61",  -- a
      1051 => x"00",
      1052 => x"20",  --  
      1053 => x"00",
      1054 => x"4d",  -- M
      1055 => x"00",
      1056 => x"69",  -- i
      1057 => x"00",
      1058 => x"63",  -- c
      1059 => x"00",
      1060 => x"20",  --  
      1061 => x"00",
      1062 => x"43",  -- C
      1063 => x"00",
      1064 => x"61",  -- a
      1065 => x"00",
      1066 => x"70",  -- p
      1067 => x"00",
      1068 => x"74",  -- t
      1069 => x"00",
      1070 => x"75",  -- u
      1071 => x"00",
      1072 => x"72",  -- r
      1073 => x"00",
      1074 => x"65",  -- e
      1075 => x"00",
      -- Usb2StringDesc
      1076 => x"3a",  -- bLength
      1077 => x"03",  -- bDescriptorType
      1078 => x"54",  -- T
      1079 => x"00",
      1080 => x"69",  -- i
      1081 => x"00",
      1082 => x"63",  -- c
      1083 => x"00",
      1084 => x"2d",  -- -
      1085 => x"00",
      1086 => x"4e",  -- N
      1087 => x"00",
      1088 => x"69",  -- i
      1089 => x"00",
      1090 => x"63",  -- c
      1091 => x"00",
      1092 => x"20",  --  
      1093 => x"00",
      1094 => x"50",  -- P
      1095 => x"00",
      1096 => x"54",  -- T
      1097 => x"00",
      1098 => x"50",  -- P
      1099 => x"00",
      1100 => x"20",  --  
      1101 => x"00",
      1102 => x"45",  -- E
      1103 => x"00",
      1104 => x"74",  -- t
      1105 => x"00",
      1106 => x"68",  -- h
      1107 => x"00",
      1108 => x"65",  -- e
      1109 => x"00",
      1110 => x"72",  -- r
      1111 => x"00",
      1112 => x"6e",  -- n
      1113 => x"00",
      1114 => x"65",  -- e
      1115 => x"00",
      1116 => x"74",  -- t
      1117 => x"00",
      1118 => x"20",  --  
      1119 => x"00",
      1120 => x"41",  -- A
      1121 => x"00",
      1122 => x"64",  -- d
      1123 => x"00",
      1124 => x"61",  -- a
      1125 => x"00",
      1126 => x"70",  -- p
      1127 => x"00",
      1128 => x"74",  -- t
      1129 => x"00",
      1130 => x"65",  -- e
      1131 => x"00",
      1132 => x"72",  -- r
      1133 => x"00",
      -- Usb2StringDesc
      1134 => x"1a",  -- bLength
      1135 => x"03",  -- bDescriptorType
      1136 => x"30",  -- 0
      1137 => x"00",
      1138 => x"32",  -- 2
      1139 => x"00",
      1140 => x"64",  -- d
      1141 => x"00",
      1142 => x"65",  -- e
      1143 => x"00",
      1144 => x"61",  -- a
      1145 => x"00",
      1146 => x"64",  -- d
      1147 => x"00",
      1148 => x"62",  -- b
      1149 => x"00",
      1150 => x"65",  -- e
      1151 => x"00",
      1152 => x"65",  -- e
      1153 => x"00",
      1154 => x"66",  -- f
      1155 => x"00",
      1156 => x"33",  -- 3
      1157 => x"00",
      1158 => x"31",  -- 1
      1159 => x"00",
      -- Usb2SentinelDesc
      1160 => x"02",  -- bLength
      1161 => x"ff"   -- bDescriptorType
      );
   begin
      return c;
   end function usb2AppGetDescriptors;

   constant USB2_APP_DESCRIPTORS_C : Usb2ByteArray := usb2AppGetDescriptors;

end package body Usb2AppCfgPkg;
